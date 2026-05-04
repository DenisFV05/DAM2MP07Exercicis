import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'models.dart';
import 'services.dart';
import 'widgets.dart';
import 'ai_service.dart';

void main() {
  runApp(const GestorProxmoxAIApp());
}

class GestorProxmoxAIApp extends StatelessWidget {
  const GestorProxmoxAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor Proxmox IA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final SSHService _ssh = SSHService();
  final ConfigService _config = ConfigService();
  late AIService _aiService;
  
  List<ServerConfig> _servers = [];
  ServerConfig? _selectedServer;
  List<FileItem> _files = [];
  FileItem? _selectedFile;
  ServerStatus? _serverStatus;
  bool _isLoading = false;
  bool _portRedirectActive = false;
  String _statusMessage = '';
  
  // Chat state
  final List<Map<String, String>> _chatHistory = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScroll = ScrollController();
  bool _showChat = true;
  bool _isAiLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadServers();
    _aiService = AIService(
      ssh: _ssh, 
      config: _config,
      onConnect: _connectFromAI
    );
  }
  
  Future<void> _loadServers() async {
    final servers = await _config.loadServers();
    setState(() => _servers = servers);
  }
  
  void _setLoading(bool value, [String message = '']) {
    setState(() {
      _isLoading = value;
      _statusMessage = message;
    });
  }
  
  Future<void> _connectToServer(ServerConfig server) async {
    _setLoading(true, 'Connectant a ${server.name}...');
    try {
      await _ssh.connect(server);
      await _refreshFiles();
      setState(() => _selectedServer = server);
      _setLoading(false, 'Connectat a ${server.name}');
    } catch (e) {
      _setLoading(false, 'Error: $e');
    }
  }

  // Wrapper para llamar desde IA que ya gestiona el estado
  Future<void> _connectFromAI(ServerConfig server) async {
    // No usamos setLoading global para no bloquear chat, pero sí actualizamos estado
    try {
      if (_ssh.isConnected) await _ssh.disconnect();
      await _ssh.connect(server);
      await _refreshFiles();
      setState(() {
        _selectedServer = server;
        _statusMessage = 'Connectat a ${server.name} via IA';
      });
    } catch (e) {
      setState(() => _statusMessage = 'Error connectant via IA: $e');
      throw e; // Re-lanzar para que IA lo sepa
    }
  }
  
  Future<void> _disconnect() async {
    await _ssh.disconnect();
    setState(() {
      _selectedServer = null;
      _files = [];
      _selectedFile = null;
    });
    _setLoading(false, 'Desconnectat');
  }
  
  Future<void> _refreshFiles() async {
    try {
      final files = await _ssh.listDirectory();
      setState(() {
        _files = files;
        _selectedFile = null;
      });
      await _detectServer();
    } catch (e) {
      _setLoading(false, 'Error: $e');
    }
  }
  
  Future<void> _detectServer() async {
    final status = await _ssh.detectServer(_ssh.currentPath);
    setState(() => _serverStatus = status);
  }
  
  Future<void> _navigateToFolder(String path) async {
    _setLoading(true, 'Navegant...');
    try {
      await _ssh.changeDirectory(path);
      await _refreshFiles();
      _setLoading(false);
    } catch (e) {
      _setLoading(false, 'Error: $e');
    }
  }
  
  Future<void> _deleteSelected() async {
    if (_selectedFile == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminació'),
        content: Text('Vols eliminar "${_selectedFile!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel·lar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      _setLoading(true, 'Eliminant...');
      try {
        await _ssh.deleteFile(_selectedFile!.name);
        await _refreshFiles();
        _setLoading(false, 'Eliminat correctament');
      } catch (e) {
        _setLoading(false, 'Error: $e');
      }
    }
  }
  
  Future<void> _sendMessage() async {
    if (_chatController.text.trim().isEmpty) return;
    
    final msg = _chatController.text.trim();
    setState(() {
      _chatHistory.add({"role": "user", "content": msg});
      _chatController.clear();
      _isAiLoading = true;
    });
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScroll.hasClients) {
        _chatScroll.animateTo(
          _chatScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      final response = await _aiService.sendMessage(msg, _chatHistory);
      if (mounted) {
        setState(() {
          _chatHistory.add({"role": "assistant", "content": response});
          _isAiLoading = false;
        });
        
        // Refrescar archivos si la IA hizo algo que pudo cambiarlos
        if (_ssh.isConnected) {
          await _refreshFiles();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _chatHistory.add({"role": "assistant", "content": "Error: $e"});
          _isAiLoading = false;
        });
      }
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScroll.hasClients) {
        _chatScroll.animateTo(
          _chatScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showConfigDialog() {
    final urlCtrl = TextEditingController(text: _aiService.baseUrl);
    final modelCtrl = TextEditingController(text: _aiService.model);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Configuració IA'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LabeledTextField(label: 'URL Ollama', controller: urlCtrl, hintText: 'http://localhost:11414/api/chat'),
            const SizedBox(height: 12),
            LabeledTextField(label: 'Model', controller: modelCtrl, hintText: 'llama3.2'),
            const SizedBox(height: 8),
            const Text(
              'Ports típics: 11414 (local 16GB), 11424 (local 24GB)',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel·lar')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _aiService.baseUrl = urlCtrl.text;
                _aiService.model = modelCtrl.text;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor Proxmox IA'),
        actions: [
          IconButton(
            icon: Icon(_showChat ? Icons.chat_bubble : Icons.chat_bubble_outline),
            onPressed: () => setState(() => _showChat = !_showChat),
            tooltip: 'Mostrar/Ocultar Chat',
          ),
          if (_ssh.isConnected)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _disconnect,
              tooltip: 'Desconnectar',
            ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar - Servidors (igual que antes)
          Container(
            width: 200,
            color: Colors.grey.shade100,
            child: ListView.builder(
              itemCount: _servers.length,
              itemBuilder: (ctx, i) {
                final server = _servers[i];
                return ListTile(
                  dense: true,
                  selected: server == _selectedServer,
                  leading: StatusIndicator(isActive: server == _selectedServer && _ssh.isConnected, size: 10),
                  title: Text(server.name),
                  onTap: () => _connectToServer(server),
                );
              },
            ),
          ),
          
          // Main content (Files)
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Path bar
                 if (_ssh.isConnected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.teal.shade50,
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.arrow_upward, size: 16), onPressed: () => _navigateToFolder('..')),
                        Expanded(child: Text(_ssh.currentPath, style: const TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),

                // File List
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : !_ssh.isConnected
                      ? const Center(child: Text('Connecta a un servidor o usa el chat'))
                      : ListView.builder(
                          itemCount: _files.length,
                          itemBuilder: (ctx, i) {
                            final file = _files[i];
                            return ListTile(
                              dense: true,
                              leading: Icon(file.isDirectory ? Icons.folder : Icons.insert_drive_file, 
                                           color: file.isDirectory ? Colors.amber : Colors.grey),
                              title: Text(file.name),
                              subtitle: Text(file.sizeFormatted),
                              selected: file == _selectedFile,
                              onTap: () => setState(() => _selectedFile = file),
                              onDoubleTap: () {
                                if (file.isDirectory) _navigateToFolder(file.name);
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, size: 16, color: Colors.grey),
                                onPressed: () {
                                  setState(() => _selectedFile = file);
                                  _deleteSelected();
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Chat Panel
          if (_showChat)
            Container(
              width: 350,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey.shade300)),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  // Chat Header
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey.shade50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Assistent IA', style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.settings, size: 16),
                          onPressed: _showConfigDialog,
                          tooltip: 'Configurar URL/Model',
                        ),
                      ],
                    ),
                  ),
                  
                  // Messages
                  Expanded(
                    child: ListView.builder(
                      controller: _chatScroll,
                      padding: const EdgeInsets.all(12),
                      itemCount: _chatHistory.length,
                      itemBuilder: (ctx, i) {
                        final msg = _chatHistory[i];
                        final isUser = msg['role'] == 'user';
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(10),
                            constraints: const BoxConstraints(maxWidth: 280),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.teal.shade100 : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: isUser 
                                ? Text(msg['content']!) 
                                : MarkdownBody(data: msg['content']!),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  if (_isAiLoading)
                    const LinearProgressIndicator(),
                  
                  // Input area
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            decoration: const InputDecoration(
                              hintText: 'Escriu un ordre...',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sendMessage,
                          color: Colors.teal,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
