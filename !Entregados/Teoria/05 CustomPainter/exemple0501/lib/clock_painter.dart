import 'package:flutter/cupertino.dart';
import 'dart:math';

class ClockPainter extends CustomPainter {
  final Animation<double> animation;
  final double Function() calculateFps;

  ClockPainter(this.animation, this.calculateFps) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final fps = calculateFps();
    final now = DateTime.now();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    final paintBackground = Paint()..color = CupertinoColors.black;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), paintBackground);

    final hourPaint = Paint()
      ..color = CupertinoColors.white
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final minutePaint = Paint()
      ..color = CupertinoColors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final secondPaint = Paint()
      ..color = CupertinoColors.systemRed
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Hours
    double hourAngle =
        (now.hour % 12 + now.minute / 60) * 30 * pi / 180 - pi / 2;
    canvas.drawLine(
        center,
        center +
            Offset(
                cos(hourAngle) * radius * 0.5, sin(hourAngle) * radius * 0.5),
        hourPaint);

    // Minutes
    double minuteAngle = (now.minute + now.second / 60) * 6 * pi / 180 - pi / 2;
    canvas.drawLine(
        center,
        center +
            Offset(cos(minuteAngle) * radius * 0.75,
                sin(minuteAngle) * radius * 0.75),
        minutePaint);

    // Seconds
    double secondAngle =
        (now.second + now.millisecond / 1000) * 6 * pi / 180 - pi / 2;
    canvas.drawLine(
        center,
        center +
            Offset(cos(secondAngle) * radius * 0.9,
                sin(secondAngle) * radius * 0.9),
        secondPaint);

    // Center
    canvas.drawCircle(center, 4, Paint()..color = CupertinoColors.black);

    // Number Markers
    final textPainter = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    final fontSize = radius / 8;

    for (int i = 1; i <= 12; i++) {
      double angle = i * 30 * pi / 180 - pi / 2;
      double x = center.dx + cos(angle) * radius * 0.8;
      double y = center.dy + sin(angle) * radius * 0.8;

      textPainter.text = TextSpan(
          text: '$i',
          style: TextStyle(color: CupertinoColors.white, fontSize: fontSize));
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - fontSize / 2, y - fontSize / 2));
    }

    // FPS
    textPainter.text = TextSpan(
        text: 'FPS: ${fps.toStringAsFixed(2)}',
        style: const TextStyle(color: CupertinoColors.systemRed, fontSize: 14));
    textPainter.layout();
    textPainter.paint(canvas, const Offset(8, 8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
