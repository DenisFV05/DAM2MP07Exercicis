import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'services.dart';

class AIService {
  String baseUrl = 'http://localhost:11414/api/chat'; // Default tunnel
  String model = 'llama3.2'; // Default model

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
            //toolResults += "Tool $name executed. Result: $result\n";
             // IMPORTANTE: En un flujo real de chat, deberíamos devolver el resultado a la IA 
             // para que genere la respuesta final. Aquí simplificamos devolviendo el resultado directo.
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
             // Esperamos un poco para asegurar la conexión antes de responder
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
          
        default:
          return "Función desconocida: $name";
      }
    } catch (e) {
      return "Error ejecutando $name: $e";
    }
  }
}
