import 'dart:convert';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:path_provider/path_provider.dart';
import 'models.dart';

class SSHService {
  SSHClient? _client;
  SftpClient? _sftp;
  ServerConfig? _currentServer;
  String _currentPath = '/';
  
  bool get isConnected => _client != null;
  String get currentPath => _currentPath;
  ServerConfig? get currentServer => _currentServer;
  
  Future<void> connect(ServerConfig server) async {
    try {
      final socket = await SSHSocket.connect(
        server.host,
        server.port,
        timeout: const Duration(seconds: 10),
      );
      
      _client = SSHClient(
        socket,
        username: server.username,
        onPasswordRequest: () => server.password ?? '',
      );
      
      _sftp = await _client!.sftp();
      _currentServer = server;
      _currentPath = '/home/${server.username}';
    } catch (e) {
      throw Exception('Error conectando: $e');
    }
  }
  
  Future<void> disconnect() async {
    _sftp?.close();
    _client?.close();
    _sftp = null;
    _client = null;
    _currentServer = null;
  }
  
  Future<List<FileItem>> listDirectory([String? path]) async {
    if (_client == null) throw Exception('No conectado');
    
    final targetPath = path ?? _currentPath;
    final result = await runCommand('ls -la "$targetPath"');
    
    final lines = result.split('\n')
        .where((l) => l.isNotEmpty && !l.startsWith('total'))
        .where((l) => !l.endsWith('.') && !l.endsWith('..'))
        .toList();
    
    return lines.map((l) => FileItem.fromLsLine(l, targetPath)).toList();
  }
  
  Future<String> runCommand(String command) async {
    if (_client == null) throw Exception('No conectado');
    
    final session = await _client!.execute(command);
    final stdout = await session.stdout.transform(const Utf8Decoder()).join();
    await session.done;
    return stdout;
  }
  
  Future<void> changeDirectory(String path) async {
    if (path.startsWith('/')) {
      _currentPath = path;
    } else if (path == '..') {
      final parts = _currentPath.split('/');
      if (parts.length > 1) {
        parts.removeLast();
        _currentPath = parts.isEmpty ? '/' : parts.join('/');
      }
    } else {
      _currentPath = '$_currentPath/$path';
    }
    _currentPath = _currentPath.replaceAll('//', '/');
  }
  
  Future<void> createDirectory(String name) async {
    await runCommand('mkdir -p "$_currentPath/$name"');
  }
  
  Future<void> deleteFile(String name) async {
    await runCommand('rm -rf "$_currentPath/$name"');
  }
  
  Future<void> renameFile(String oldName, String newName) async {
    await runCommand('mv "$_currentPath/$oldName" "$_currentPath/$newName"');
  }
  
  Future<String> getFileInfo(String name) async {
    return await runCommand('stat "$_currentPath/$name"');
  }
  
  Future<void> downloadFile(String remoteName, String localPath) async {
    if (_sftp == null) throw Exception('SFTP no disponible');
    
    final remoteFile = await _sftp!.open('$_currentPath/$remoteName');
    final localFile = File(localPath);
    final sink = localFile.openWrite();
    
    await for (final chunk in remoteFile.read()) {
      sink.add(chunk);
    }
    
    await sink.close();
    await remoteFile.close();
  }
  
  Future<void> uploadFile(String localPath, String remoteName) async {
    if (_sftp == null) throw Exception('SFTP no disponible');
    
    final localFile = File(localPath);
    final remoteFile = await _sftp!.open(
      '$_currentPath/$remoteName',
      mode: SftpFileOpenMode.create | SftpFileOpenMode.write,
    );
    
    await remoteFile.write(localFile.openRead().cast());
    await remoteFile.close();
  }
  
  Future<void> extractZip(String zipName) async {
    await runCommand('cd "$_currentPath" && unzip -o "$zipName"');
  }
  
  Future<ServerStatus?> detectServer(String path) async {
    // Detectar package.json para Node.js
    final hasPackageJson = await runCommand('test -f "$path/package.json" && echo "yes"');
    if (hasPackageJson.trim() == 'yes') {
      final isRunning = await runCommand('pgrep -f "node.*$path" || true');
      return ServerStatus(
        isRunning: isRunning.trim().isNotEmpty,
        type: 'nodejs',
        name: path.split('/').last,
        port: 3000,
      );
    }
    
    // Detectar pom.xml o build.gradle para Java
    final hasJava = await runCommand('test -f "$path/pom.xml" -o -f "$path/build.gradle" && echo "yes"');
    if (hasJava.trim() == 'yes') {
      final isRunning = await runCommand('pgrep -f "java.*$path" || true');
      return ServerStatus(
        isRunning: isRunning.trim().isNotEmpty,
        type: 'java',
        name: path.split('/').last,
        port: 8080,
      );
    }
    
    return null;
  }
  
  Future<void> startNodeServer(String path) async {
    await runCommand('cd "$path" && nohup npm start > /dev/null 2>&1 &');
  }
  
  Future<void> stopNodeServer(String path) async {
    await runCommand('pkill -f "node.*$path" || true');
  }
  
  Future<void> restartNodeServer(String path) async {
    await stopNodeServer(path);
    await Future.delayed(const Duration(seconds: 1));
    await startNodeServer(path);
  }
  
  Future<void> setupPortRedirect(int fromPort, int toPort) async {
    await runCommand(
      'sudo iptables -t nat -A PREROUTING -p tcp --dport $fromPort -j REDIRECT --to-port $toPort'
    );
  }
  
  Future<void> removePortRedirect(int fromPort, int toPort) async {
    await runCommand(
      'sudo iptables -t nat -D PREROUTING -p tcp --dport $fromPort -j REDIRECT --to-port $toPort || true'
    );
  }
  
  Future<DiskUsageNode> getDiskUsage(String path, {int depth = 2}) async {
    final result = await runCommand('du -b --max-depth=$depth "$path" 2>/dev/null || du -sk "$path"');
    final lines = result.split('\n').where((l) => l.isNotEmpty).toList();
    
    final nodes = <String, DiskUsageNode>{};
    
    for (final line in lines) {
      final parts = line.split('\t');
      if (parts.length >= 2) {
        final size = int.tryParse(parts[0]) ?? 0;
        final nodePath = parts[1];
        final name = nodePath.split('/').last;
        
        nodes[nodePath] = DiskUsageNode(
          name: name.isEmpty ? nodePath : name,
          path: nodePath,
          size: size,
          isDirectory: true,
        );
      }
    }
    
    return nodes[path] ?? DiskUsageNode(
      name: path.split('/').last,
      path: path,
      size: 0,
      isDirectory: true,
    );
  }
}

class ConfigService {
  static const String _configFileName = 'servers.json';
  
  Future<String> get _configPath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$_configFileName';
  }
  
  Future<List<ServerConfig>> loadServers() async {
    try {
      final file = File(await _configPath);
      if (!await file.exists()) return [];
      
      final content = await file.readAsString();
      final List<dynamic> json = jsonDecode(content);
      return json.map((j) => ServerConfig.fromJson(j)).toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<void> saveServers(List<ServerConfig> servers) async {
    final file = File(await _configPath);
    final json = servers.map((s) => s.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
  }
  
  Future<void> addServer(ServerConfig server) async {
    final servers = await loadServers();
    servers.add(server);
    await saveServers(servers);
  }
  
  Future<void> removeServer(String name) async {
    final servers = await loadServers();
    servers.removeWhere((s) => s.name == name);
    await saveServers(servers);
  }
}
