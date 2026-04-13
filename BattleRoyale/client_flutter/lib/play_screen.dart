import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_data.dart';
import 'game_painter.dart';

class PlayScreen extends StatefulWidget {
  final AppData appData;
  const PlayScreen({super.key, required this.appData});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onKeyEvent(KeyEvent event) {
    final key = event.logicalKey;
    String? keyName;

    if (key == LogicalKeyboardKey.keyW || key == LogicalKeyboardKey.arrowUp) {
      keyName = 'w';
    } else if (key == LogicalKeyboardKey.keyS || key == LogicalKeyboardKey.arrowDown) {
      keyName = 's';
    } else if (key == LogicalKeyboardKey.keyA || key == LogicalKeyboardKey.arrowLeft) {
      keyName = 'a';
    } else if (key == LogicalKeyboardKey.keyD || key == LogicalKeyboardKey.arrowRight) {
      keyName = 'd';
    }

    if (keyName != null) {
      if (event is KeyDownEvent || event is KeyRepeatEvent) {
        widget.appData.onKeyDown(keyName);
      } else if (event is KeyUpEvent) {
        widget.appData.onKeyUp(keyName);
      }
    }
  }

  void _onTapDown(TapDownDetails details, BoxConstraints constraints) {
    // Calculate game coordinates from screen tap
    final scaleX = widget.appData.worldWidth / constraints.maxWidth;
    final scaleY = widget.appData.worldHeight / constraints.maxHeight;
    final scale = max(scaleX, scaleY);

    final offsetX = (constraints.maxWidth - widget.appData.worldWidth / scale) / 2;
    final offsetY = (constraints.maxHeight - widget.appData.worldHeight / scale) / 2;

    final gameX = (details.localPosition.dx - offsetX) * scale;
    final gameY = (details.localPosition.dy - offsetY) * scale;

    final angle = widget.appData.calculateShootAngle(gameX, gameY);
    widget.appData.sendShoot(angle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _onKeyEvent,
        child: GestureDetector(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapDown: (details) => _onTapDown(details, constraints),
                child: Container(
                  color: const Color(0xFF1A1A2E),
                  child: Stack(
                    children: [
                      // Game canvas
                      CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: GamePainter(
                          appData: widget.appData,
                          screenWidth: constraints.maxWidth,
                          screenHeight: constraints.maxHeight,
                        ),
                      ),
                      // HUD - Health bar
                      if (widget.appData.selfPlayer != null)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: _buildHUD(),
                        ),
                      // Mini ranking
                      Positioned(
                        top: 16,
                        right: 16,
                        child: _buildMiniRanking(),
                      ),
                      // Controls hint
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            'WASD / Fletxes per moure · Clic per disparar',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHUD() {
    final sp = widget.appData.selfPlayer!;
    final health = (sp['health'] as num).toDouble();
    final maxHealth = (sp['maxHealth'] as num).toDouble();
    final healthPct = health / maxHealth;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sp['name'] as String? ?? 'Jugador',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 150,
            height: 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: healthPct,
                backgroundColor: Colors.grey.shade800,
                valueColor: AlwaysStoppedAnimation(
                  healthPct > 0.5
                      ? Colors.green
                      : healthPct > 0.25
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '❤️ ${health.toInt()} / ${maxHealth.toInt()}',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 11,
            ),
          ),
          Text(
            '💀 ${sp['kills'] ?? 0} kills',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniRanking() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Ranking',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          ...widget.appData.ranking.take(5).map((r) {
            final isMe = r['id'] == widget.appData.myId;
            final alive = r['alive'] as bool? ?? false;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Text(
                '${r['rank']}. ${alive ? '' : '💀'}${r['name']} (${r['kills']}k)',
                style: TextStyle(
                  color: isMe ? Colors.yellowAccent : Colors.white54,
                  fontSize: 10,
                  fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                  decoration: alive ? null : TextDecoration.lineThrough,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
