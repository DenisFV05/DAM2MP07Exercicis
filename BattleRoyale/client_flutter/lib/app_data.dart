import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AppData extends ChangeNotifier {
  WebSocketChannel? _channel;
  bool isConnected = false;
  String myId = '';
  String playerName = '';

  // Game phase: waiting, playing, finished
  String phase = 'waiting';
  int countdownSeconds = 0;
  String winnerId = '';
  String winnerName = '';

  // Snapshot data (static, sent once)
  double worldWidth = 800;
  double worldHeight = 600;
  List<Map<String, dynamic>> walls = [];
  Map<String, Map<String, dynamic>> snapshotPlayers = {};

  // Gameplay data (dynamic, sent every frame)
  Map<String, dynamic>? selfPlayer;
  List<Map<String, dynamic>> otherPlayers = [];
  List<Map<String, dynamic>> bullets = [];
  List<Map<String, dynamic>> healthItems = [];
  List<Map<String, dynamic>> ranking = [];

  // Local direction state
  String currentDirection = 'none';
  final Set<String> _pressedKeys = {};

  void connect(String serverUrl, String name) {
    playerName = name.isEmpty ? 'Jugador' : name;
    try {
      final wsUrl = serverUrl.startsWith('ws') ? serverUrl : 'ws://$serverUrl';
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel!.stream.listen(
        _onMessage,
        onError: (e) {
          debugPrint('WebSocket error: $e');
          disconnect();
        },
        onDone: () {
          debugPrint('WebSocket closed');
          disconnect();
        },
      );
    } catch (e) {
      debugPrint('Connection error: $e');
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    isConnected = false;
    myId = '';
    phase = 'waiting';
    notifyListeners();
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String);
      final type = data['type'] as String?;

      switch (type) {
        case 'welcome':
          myId = data['id'] as String;
          isConnected = true;
          // Register player name
          _send({'type': 'register', 'playerName': playerName});
          notifyListeners();
          break;

        case 'snapshot':
          final snapshot = data['snapshot'] as Map<String, dynamic>;
          worldWidth = (snapshot['worldWidth'] as num).toDouble();
          worldHeight = (snapshot['worldHeight'] as num).toDouble();
          walls = List<Map<String, dynamic>>.from(snapshot['walls'] ?? []);
          final players = snapshot['players'] as List? ?? [];
          snapshotPlayers = {};
          for (final p in players) {
            snapshotPlayers[p['id']] = Map<String, dynamic>.from(p);
          }
          notifyListeners();
          break;

        case 'gameplay':
          final gs = data['gameState'] as Map<String, dynamic>;
          phase = gs['phase'] as String? ?? 'waiting';
          countdownSeconds = gs['countdownSeconds'] as int? ?? 0;
          winnerId = gs['winnerId'] as String? ?? '';
          winnerName = gs['winnerName'] as String? ?? '';

          if (gs['selfPlayer'] != null) {
            selfPlayer = Map<String, dynamic>.from(gs['selfPlayer']);
          }
          if (gs['otherPlayers'] != null) {
            otherPlayers = List<Map<String, dynamic>>.from(gs['otherPlayers']);
          }
          if (gs['bullets'] != null) {
            bullets = List<Map<String, dynamic>>.from(gs['bullets']);
          }
          if (gs['healthItems'] != null) {
            healthItems = List<Map<String, dynamic>>.from(gs['healthItems']);
          }
          if (gs['ranking'] != null) {
            ranking = List<Map<String, dynamic>>.from(gs['ranking']);
          }
          notifyListeners();
          break;
      }
    } catch (e) {
      debugPrint('Error parsing message: $e');
    }
  }

  void _send(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  void sendDirection(String direction) {
    if (currentDirection != direction) {
      currentDirection = direction;
      _send({'type': 'direction', 'value': direction});
    }
  }

  void sendShoot(double angle) {
    _send({'type': 'shoot', 'angle': angle});
  }

  void sendRestart() {
    _send({'type': 'restartMatch'});
  }

  // Keyboard handling for direction
  void onKeyDown(String key) {
    _pressedKeys.add(key);
    _updateDirection();
  }

  void onKeyUp(String key) {
    _pressedKeys.remove(key);
    _updateDirection();
  }

  void _updateDirection() {
    final up = _pressedKeys.contains('w') || _pressedKeys.contains('ArrowUp');
    final down = _pressedKeys.contains('s') || _pressedKeys.contains('ArrowDown');
    final left = _pressedKeys.contains('a') || _pressedKeys.contains('ArrowLeft');
    final right = _pressedKeys.contains('d') || _pressedKeys.contains('ArrowRight');

    String direction = 'none';
    if (up && left) {
      direction = 'upLeft';
    } else if (up && right) {
      direction = 'upRight';
    } else if (down && left) {
      direction = 'downLeft';
    } else if (down && right) {
      direction = 'downRight';
    } else if (up) {
      direction = 'up';
    } else if (down) {
      direction = 'down';
    } else if (left) {
      direction = 'left';
    } else if (right) {
      direction = 'right';
    }

    sendDirection(direction);
  }

  // Get all players (self + others) for rendering
  List<Map<String, dynamic>> getAllPlayers() {
    final all = <Map<String, dynamic>>[];
    if (selfPlayer != null) all.add(selfPlayer!);
    all.addAll(otherPlayers);
    return all;
  }

  // Calculate shoot angle from player center to a point
  double calculateShootAngle(double targetX, double targetY) {
    if (selfPlayer == null) return 0;
    final px = (selfPlayer!['x'] as num).toDouble() + 15; // center
    final py = (selfPlayer!['y'] as num).toDouble() + 15;
    return atan2(targetY - py, targetX - px);
  }
}
