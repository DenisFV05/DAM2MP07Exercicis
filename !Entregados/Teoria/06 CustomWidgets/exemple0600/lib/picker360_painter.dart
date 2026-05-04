import 'dart:math' as math;
import 'package:flutter/material.dart';

class Picker360Painter extends CustomPainter {
  final double angle;

  Picker360Painter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final angleInRadians = (math.pi / 180) * angle;

    // Dibuixar la sombra
    final shadowPaint = Paint()
      ..color = Colors.grey[800]!
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);
    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.drawShadow(circlePath, shadowPaint.color, 1, false);

    // Dibuixar el cercle principal
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.grey[50]!;
    canvas.drawCircle(center, radius, paint);

    final paintBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..color = Colors.grey[800]!;
    canvas.drawCircle(center, radius, paintBorder);

    // Dibuixar el punt que indica l'angle
    radius = radius - 3;
    final markerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.grey[800]!;
    final markerPosition = Offset(
      center.dx + radius * math.cos(angleInRadians),
      center.dy + radius * math.sin(angleInRadians),
    );
    canvas.drawCircle(markerPosition, 3, markerPaint);
  }

  @override
  bool shouldRepaint(covariant Picker360Painter oldDelegate) {
    return oldDelegate.angle != angle;
  }
}
