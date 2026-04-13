import 'dart:math';
import 'package:flutter/material.dart';
import 'app_data.dart';

class GamePainter extends CustomPainter {
  final AppData appData;
  final double screenWidth;
  final double screenHeight;

  GamePainter({
    required this.appData,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate scale to fit world in screen
    final scaleX = size.width / appData.worldWidth;
    final scaleY = size.height / appData.worldHeight;
    final scale = min(scaleX, scaleY);

    final offsetX = (size.width - appData.worldWidth * scale) / 2;
    final offsetY = (size.height - appData.worldHeight * scale) / 2;

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);

    // Draw world background
    final bgPaint = Paint()..color = const Color(0xFF16213E);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, appData.worldWidth, appData.worldHeight),
      bgPaint,
    );

    // Draw grid
    final gridPaint = Paint()
      ..color = const Color(0xFF1A1A3E)
      ..strokeWidth = 0.5;
    for (double x = 0; x < appData.worldWidth; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, appData.worldHeight), gridPaint);
    }
    for (double y = 0; y < appData.worldHeight; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(appData.worldWidth, y), gridPaint);
    }

    // Draw walls
    final wallPaint = Paint()..color = const Color(0xFF4A4A6A);
    final wallBorder = Paint()
      ..color = const Color(0xFF6A6A8A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final wall in appData.walls) {
      final rect = Rect.fromLTWH(
        (wall['x'] as num).toDouble(),
        (wall['y'] as num).toDouble(),
        (wall['w'] as num).toDouble(),
        (wall['h'] as num).toDouble(),
      );
      canvas.drawRect(rect, wallPaint);
      canvas.drawRect(rect, wallBorder);
    }

    // Draw health items
    for (final item in appData.healthItems) {
      final ix = (item['x'] as num).toDouble();
      final iy = (item['y'] as num).toDouble();
      final iw = (item['width'] as num).toDouble();
      final ih = (item['height'] as num).toDouble();

      // Glow effect
      final glowPaint = Paint()
        ..color = Colors.green.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(
        Offset(ix + iw / 2, iy + ih / 2),
        iw,
        glowPaint,
      );

      // Cross shape
      final crossPaint = Paint()
        ..color = Colors.greenAccent
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(ix + iw * 0.3, iy, iw * 0.4, ih),
        crossPaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(ix, iy + ih * 0.3, iw, ih * 0.4),
        crossPaint,
      );
    }

    // Draw bullets
    for (final bullet in appData.bullets) {
      final bx = (bullet['x'] as num).toDouble();
      final by = (bullet['y'] as num).toDouble();
      final bs = (bullet['size'] as num).toDouble();

      // Bullet trail glow
      final trailPaint = Paint()
        ..color = Colors.yellowAccent.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(bx, by), bs * 1.5, trailPaint);

      // Bullet core
      final bulletPaint = Paint()..color = Colors.yellowAccent;
      canvas.drawCircle(Offset(bx, by), bs / 2, bulletPaint);
    }

    // Draw all players
    final allPlayers = appData.getAllPlayers();
    for (final player in allPlayers) {
      _drawPlayer(canvas, player);
    }

    // Draw world border
    final borderPaint = Paint()
      ..color = Colors.redAccent.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, appData.worldWidth, appData.worldHeight),
      borderPaint,
    );

    canvas.restore();
  }

  void _drawPlayer(Canvas canvas, Map<String, dynamic> player) {
    final x = (player['x'] as num).toDouble();
    final y = (player['y'] as num).toDouble();
    final alive = player['alive'] as bool? ?? true;
    final health = (player['health'] as num?)?.toDouble() ?? 100;
    final maxHealth = (player['maxHealth'] as num?)?.toDouble() ?? 100;
    final color = _parseColor(player['color'] as String? ?? '#FFFFFF');
    final name = player['name'] as String? ?? '';
    final isMe = player['id'] == appData.myId;
    final size = 30.0;

    if (!alive) {
      // Dead player: draw X mark
      final deadPaint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.4)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(x, y), Offset(x + size, y + size), deadPaint);
      canvas.drawLine(Offset(x + size, y), Offset(x, y + size), deadPaint);
      return;
    }

    // Player shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 2, y + 2, size, size),
        const Radius.circular(4),
      ),
      shadowPaint,
    );

    // Player body (tank)
    final bodyPaint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, size, size),
        const Radius.circular(4),
      ),
      bodyPaint,
    );

    // Tank turret (darker)
    final turretPaint = Paint()..color = color.withValues(alpha: 0.7);
    canvas.drawCircle(
      Offset(x + size / 2, y + size / 2),
      size * 0.3,
      turretPaint,
    );

    // Highlight for self
    if (isMe) {
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 2, y - 2, size + 4, size + 4),
          const Radius.circular(6),
        ),
        highlightPaint,
      );
    }

    // Health bar background
    final hbY = y - 10;
    final hbWidth = size;
    final hbHeight = 4.0;
    final hbBgPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, hbY, hbWidth, hbHeight),
        const Radius.circular(2),
      ),
      hbBgPaint,
    );

    // Health bar fill
    final healthPct = health / maxHealth;
    final hbFillPaint = Paint()
      ..color = healthPct > 0.5
          ? Colors.green
          : healthPct > 0.25
              ? Colors.orange
              : Colors.red;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, hbY, hbWidth * healthPct, hbHeight),
        const Radius.circular(2),
      ),
      hbFillPaint,
    );

    // Player name
    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 9,
          fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x + (size - textPainter.width) / 2, hbY - 12),
    );
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceFirst('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
