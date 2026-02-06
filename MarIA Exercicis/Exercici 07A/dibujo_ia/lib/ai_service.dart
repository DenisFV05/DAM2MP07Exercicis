import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'canvas_painter.dart';

class AIService extends ChangeNotifier {
  String baseUrl = 'http://localhost:11414/api/chat';
  String model = 'llama3.2';
  
  final List<Drawable> drawables = [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void clearCanvas() {
    drawables.clear();
    notifyListeners();
  }

  Future<String> sendMessage(String userMessage, List<Map<String, String>> history) async {
    _error = null;
    
    final messages = [
      ...history.map((h) => {"role": h["role"]!, "content": h["content"]!}),
      {"role": "user", "content": userMessage}
    ];

    print("Enviando a IA: $userMessage");

    final body = {
      "model": model,
      "stream": false,
      "messages": messages,
      "tools": tools
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
          String toolInfo = "";
          
          for (var toolCall in toolCalls) {
            final function = toolCall['function'];
            final name = function['name'];
            final args = function['arguments'] is String 
                ? jsonDecode(function['arguments']) 
                : function['arguments'];
            
            _executeTool(name, _fixArgs(args));
            toolInfo += "Executed $name\n";
          }
          notifyListeners();
          return toolInfo.isEmpty ? "Dibuix actualitzat." : toolInfo;
        }
        
        return message['content'] ?? "No s'ha generat cap acció.";
      } else {
        _error = "Error API: ${response.statusCode}";
        notifyListeners();
        return _error!;
      }
    } catch (e) {
      _error = "Error connexió: $e";
      notifyListeners();
      return _error!;
    }
  }

  // Ollama a veces devuelve argumentos como strings numéricos
  Map<String, dynamic> _fixArgs(Map<String, dynamic> args) {
    final newArgs = <String, dynamic>{};
    args.forEach((key, value) {
      if (value is String) {
        final numValue = double.tryParse(value);
        newArgs[key] = numValue ?? value;
      } else {
        newArgs[key] = value;
      }
    });
    return newArgs;
  }

  void _executeTool(String name, Map<String, dynamic> args) {
    print("Executing $name with $args");
    
    switch (name) {
      case 'draw_circle':
        final x = (args['x'] as num).toDouble();
        final y = (args['y'] as num).toDouble();
        final radius = (args['radius'] as num).toDouble();
        final color = parseColor(args['color']);
        final filled = args['filled'] == true;
        drawables.add(Circle(center: Offset(x, y), radius: radius, color: color, filled: filled));
        break;
        
      case 'draw_line':
        final startX = (args['startX'] as num).toDouble();
        final startY = (args['startY'] as num).toDouble();
        final endX = (args['endX'] as num).toDouble();
        final endY = (args['endY'] as num).toDouble();
        final color = parseColor(args['color']);
        final width = (args['width'] as num?)?.toDouble() ?? 1.0;
        drawables.add(Line(start: Offset(startX, startY), end: Offset(endX, endY), color: color, width: width));
        break;
        
      case 'draw_rectangle':
        final tlx = (args['topLeftX'] as num).toDouble();
        final tly = (args['topLeftY'] as num).toDouble();
        final brx = (args['bottomRightX'] as num).toDouble();
        final bry = (args['bottomRightY'] as num).toDouble();
        final color = parseColor(args['color']);
        final filled = args['filled'] == true;
        drawables.add(Rectangle(topLeft: Offset(tlx, tly), bottomRight: Offset(brx, bry), color: color, filled: filled));
        break;
        
      case 'draw_text':
        final x = (args['x'] as num).toDouble();
        final y = (args['y'] as num).toDouble();
        final text = args['text'].toString();
        final color = parseColor(args['color']);
        final fs = (args['fontSize'] as num?)?.toDouble() ?? 14.0;
        drawables.add(TextDrawable(position: Offset(x, y), text: text, color: color, fontSize: fs));
        break;
        
      case 'clear_canvas':
        drawables.clear();
        break;
    }
  }
}
