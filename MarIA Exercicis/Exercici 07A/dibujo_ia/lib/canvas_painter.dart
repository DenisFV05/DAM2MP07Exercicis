import 'package:flutter/material.dart';

abstract class Drawable {
  void draw(Canvas canvas, Paint paint);
}

class Circle implements Drawable {
  final Offset center;
  final double radius;
  final Color? color;
  final bool filled;

  Circle({required this.center, required this.radius, this.color, this.filled = false});

  @override
  void draw(Canvas canvas, Paint paint) {
    paint.color = color ?? Colors.black;
    paint.style = filled ? PaintingStyle.fill : PaintingStyle.stroke;
    canvas.drawCircle(center, radius, paint);
  }
}

class Line implements Drawable {
  final Offset start;
  final Offset end;
  final Color? color;
  final double width;

  Line({required this.start, required this.end, this.color, this.width = 1.0});

  @override
  void draw(Canvas canvas, Paint paint) {
    paint.color = color ?? Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = width;
    canvas.drawLine(start, end, paint);
    paint.strokeWidth = 1.0; // Reset
  }
}

class Rectangle implements Drawable {
  final Offset topLeft;
  final Offset bottomRight;
  final Color? color;
  final bool filled;

  Rectangle({required this.topLeft, required this.bottomRight, this.color, this.filled = false});

  @override
  void draw(Canvas canvas, Paint paint) {
    paint.color = color ?? Colors.black;
    paint.style = filled ? PaintingStyle.fill : PaintingStyle.stroke;
    final rect = Rect.fromPoints(topLeft, bottomRight);
    canvas.drawRect(rect, paint);
  }
}

class TextDrawable implements Drawable {
  final Offset position;
  final String text;
  final Color? color;
  final double fontSize;

  TextDrawable({required this.position, required this.text, this.color, this.fontSize = 14.0});

  @override
  void draw(Canvas canvas, Paint paint) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color ?? Colors.black,
        fontSize: fontSize,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }
}

class CanvasPainter extends CustomPainter {
  final List<Drawable> drawables;

  CanvasPainter(this.drawables);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (var drawable in drawables) {
      drawable.draw(canvas, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Siempre repintar si hay cambios
  }
}

Color? parseColor(dynamic color) {
  if (color == null) return null;
  if (color is String) {
    if (color.startsWith('#')) {
      final hex = color.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('0xFF$hex'));
      }
    }
    // Colores básicos
    switch (color.toLowerCase()) {
      case 'red': return Colors.red;
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'yellow': return Colors.yellow;
      case 'black': return Colors.black;
      case 'white': return Colors.white;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'grey': return Colors.grey;
    }
  }
  return null;
}
