import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'models.dart';
import 'services.dart';

class AIService {
  String baseUrl = 'http://localhost:11434/api/chat'; // Default Ollama port
  String model = 'qwen2.5-coder:7b'; // Default model

  final SSHService _ssh;
  final ConfigService _config;
  final Function(ServerConfig) onConnect;

  AIService({
    required SSHService ssh, 
    required ConfigService config,
    required this.onConnect,
  }) : _ssh = ssh, _config = config;

  // Definición de herramientas
  List<Map<String, dynamic>> get _tools => [
    {
      "type": "function",
      "function": {
        "name": "list_files",
        "description": "Lista los archivos y carpetas del directorio actual o uno específico",
        "parameters": {
          "type": "object",
          "properties": {
            "path": {"type": "string", "description": "Ruta opcional. Si no se indica, usa la actual."}
          }
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "change_directory",
        "description": "Cambia el directorio actual",
        "parameters": {
          "type": "object",
          "properties": {
            "path": {"type": "string", "description": "Ruta a la que cambiar (puede ser relativa o absoluta)"}
          },
          "required": ["path"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "create_folder",
        "description": "Crea una nueva carpeta",
        "parameters": {
          "type": "object",
          "properties": {
            "name": {"type": "string", "description": "Nombre de la carpeta"}
          },
          "required": ["name"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "delete_file",
        "description": "Elimina un archivo o carpeta",
        "parameters": {
          "type": "object",
          "properties": {
            "name": {"type": "string", "description": "Nombre del archivo/carpeta a eliminar"}
          },
          "required": ["name"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "extract_zip",
        "description": "Extrae un archivo ZIP en el directorio actual",
        "parameters": {
          "type": "object",
          "properties": {
            "name": {"type": "string", "description": "Nombre del archivo ZIP"}
          },
          "required": ["name"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "get_disk_usage",
        "description": "Muestra el uso de disco del directorio actual o uno específico",
        "parameters": {
          "type": "object",
          "properties": {
            "path": {"type": "string", "description": "Ruta opcional"}
          }
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "list_servers",
        "description": "Lista los servidores configurados guardados",
        "parameters": {"type": "object", "properties": {}}
      }
    },
    {
      "type": "function",
      "function": {
        "name": "connect_server",
        "description": "Conecta a un servidor por su nombre",
        "parameters": {
          "type": "object",
          "properties": {
            "name": {"type": "string", "description": "Nombre del servidor tal como aparece en la lista"}
          },
          "required": ["name"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "get_server_status",
        "description": "Comprueba el estado de un servidor Node.js o Java en una ruta",
        "parameters": {
          "type": "object",
          "properties": {
            "path": {"type": "string", "description": "Ruta donde buscar el servidor"}
          },
          "required": ["path"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "start_node_server",
        "description": "Inicia un servidor Node.js",
        "parameters": {
          "type": "object",
          "properties": {
            "path": {"type": "string", "description": "Ruta del proyecto Node.js"}
          },
          "required": ["path"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "stop_node_server",
        "description": "Detiene un servidor Node.js",
        "parameters": {
          "type": "object",
          "properties": {
            "path": {"type": "string", "description": "Ruta del proyecto Node.js"}
          },
          "required": ["path"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "restart_node_server",
        "description": "Reinicia un servidor Node.js",
        "parameters": {
          "type": "object",
          "properties": {
            "path": {"type": "string", "description": "Ruta del proyecto Node.js"}
          },
          "required": ["path"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "download_file",
        "description": "Descarga un archivo del servidor a la carpeta de Descargas del usuario",
        "parameters": {
          "type": "object",
          "properties": {
            "name": {"type": "string", "description": "Nombre del archivo o carpeta a descargar"}
          },
          "required": ["name"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "rename_file",
        "description": "Cambia el nombre de un archivo o carpeta",
        "parameters": {
          "type": "object",
          "properties": {
            "old_name": {"type": "string", "description": "Nombre actual"},
            "new_name": {"type": "string", "description": "Nuevo nombre"}
          },
          "required": ["old_name", "new_name"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "get_file_info",
        "description": "Obtiene información detallada (stat) de un archivo",
        "parameters": {
          "type": "object",
          "properties": {
            "name": {"type": "string", "description": "Nombre del archivo"}
          },
          "required": ["name"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "setup_port_redirect",
        "description": "Configura una redirección de puerto (requiere sudo)",
        "parameters": {
          "type": "object",
          "properties": {
            "from_port": {"type": "integer", "description": "Puerto origen (ej: 80)"},
            "to_port": {"type": "integer", "description": "Puerto destino (ej: 3000)"}
          },
          "required": ["from_port", "to_port"]
        }
      }
    }
  ];

  Future<String> sendMessage(String userMessage, List<Map<String, String>> history) async {
    final messages = [
      ...history.map((h) => {"role": h["role"]!, "content": h["content"]!}),
      {"role": "user", "content": userMessage}
    ];

    print("Enviando a IA ($baseUrl): $userMessage");

    final body = {
      "model": model,
      "stream": false,
      "messages": messages,
      "tools": _tools
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final message = jsonResponse['message'];
        
        if (message['tool_calls'] != null) {
          final toolCalls = message['tool_calls'] as List;
          String toolResults = "";
          
          for (var toolCall in toolCalls) {
            final function = toolCall['function'];
            final name = function['name'];
            final args = function['arguments'] is String 
                ? jsonDecode(function['arguments']) 
                : function['arguments'];
            
            print("Ejecutando tool: $name con args: $args");
            final result = await _executeTool(name, args);
            toolResults += "$result\n";
          }
          return toolResults.isEmpty ? "Acción completada." : toolResults;
        }
        
        return message['content'] ?? "No he entendido la respuesta.";
      } else {
        return "Error en la API (${response.statusCode}): ${response.body}";
      }
    } catch (e) {
      return "Error de conexión con IA: $e\nAsegúrate de tener el túnel abierto o estar en la red correcta.";
    }
  }

  Future<String> _executeTool(String name, Map<String, dynamic> args) async {
    try {
      switch (name) {
        case 'list_files':
          final path = args['path'];
          final files = await _ssh.listDirectory(path);
          return files.map((f) => "${f.name} (${f.isDirectory ? 'DIR' : f.sizeFormatted})").join('\n');
          
        case 'change_directory':
          await _ssh.changeDirectory(args['path']);
          return "Directorio cambiado a: ${_ssh.currentPath}";
          
        case 'create_folder':
          await _ssh.createDirectory(args['name']);
          return "Carpeta '${args['name']}' creada.";
          
        case 'delete_file':
          await _ssh.deleteFile(args['name']);
          return "Elemento '${args['name']}' eliminado.";

        case 'extract_zip':
          await _ssh.extractZip(args['name']);
          return "Archivo '${args['name']}' extraído.";

        case 'get_disk_usage':
          final path = args['path'] ?? _ssh.currentPath;
          final usage = await _ssh.getDiskUsage(path);
          String res = "Uso de disco en ${usage.name}: ${usage.sizeFormatted}\n";
          for (var child in usage.children) {
            res += "  - ${child.name}: ${child.sizeFormatted}\n";
          }
          return res;
          
        case 'list_servers':
          final servers = await _config.loadServers();
          if (servers.isEmpty) return "No hay servidores configurados.";
          return servers.map((s) => "- ${s.name} (${s.host})").join('\n');
          
        case 'connect_server':
          final serverName = args['name'];
          final servers = await _config.loadServers();
          try {
            final server = servers.firstWhere(
              (s) => s.name.toLowerCase() == serverName.toLowerCase()
            );
            await onConnect(server);
            await Future.delayed(const Duration(seconds: 1));
            return "Conectado a ${server.name}. Ruta inicial: ${_ssh.currentPath}";
          } catch (e) {
            return "Servidor '$serverName' no encontrado.";
          }
          
        case 'get_server_status':
          final status = await _ssh.detectServer(args['path']);
          if (status == null) return "No se detectó ningún servidor en esa ruta.";
          return "Servidor ${status.type} (${status.name}). Estado: ${status.isRunning ? 'Running' : 'Stopped'}";
          
        case 'start_node_server':
          await _ssh.startNodeServer(args['path']);
          return "Comando de inicio enviado.";
          
        case 'stop_node_server':
          await _ssh.stopNodeServer(args['path']);
          return "Comando de parada enviado.";
          
        case 'restart_node_server':
          await _ssh.restartNodeServer(args['path']);
          return "Servidor reiniciado.";

        case 'download_file':
          final name = args['name'];
          final dir = await getDownloadsDirectory() ?? await getTemporaryDirectory();
          // Determinar si es carpeta o archivo (tendríamos que listarlo o usar stat)
          // Simplificación: si no tiene extensión asumimos carpeta, o simplemente dejamos que el service decida
          final files = await _ssh.listDirectory();
          final isDir = files.any((f) => f.name == name && f.isDirectory);
          
          if (isDir) {
            final localPath = '${dir.path}/${name}.zip';
            await _ssh.downloadFolderAsZip(name, localPath);
            return "Carpeta '$name' descargada como ZIP en: $localPath";
          } else {
            final localPath = '${dir.path}/$name';
            await _ssh.downloadFile(name, localPath);
            return "Archivo '$name' descargado en: $localPath";
          }

        case 'rename_file':
          await _ssh.renameFile(args['old_name'], args['new_name']);
          return "Renombrado de '${args['old_name']}' a '${args['new_name']}' completado.";

        case 'get_file_info':
          return await _ssh.getFileInfo(args['name']);

        case 'setup_port_redirect':
          await _ssh.setupPortRedirect(args['from_port'], args['to_port']);
          return "Redirección de puerto ${args['from_port']} -> ${args['to_port']} configurada.";
          
        default:
          return "Función desconocida: $name";
      }
    } catch (e) {
      return "Error ejecutando $name: $e";
    }
  }
}
