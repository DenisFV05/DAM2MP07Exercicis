import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'shape.dart';

class ShapePainter extends CustomPainter {
  final List<Shape> shapes;

  ShapePainter(this.shapes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var shape in shapes) {
      paint.color = shape.color;

      switch (shape.type) {
        case ShapeType.rectangle:
          canvas.drawRect(
              Rect.fromLTWH(shape.x, shape.y, shape.size, shape.size), paint);
          break;
        case ShapeType.circle:
          canvas.drawOval(
              Rect.fromLTWH(shape.x, shape.y, shape.size, shape.size), paint);
          break;
        case ShapeType.line:
          paint.strokeWidth = 2.0;
          canvas.drawLine(Offset(shape.x, shape.y),
              Offset(shape.x + shape.size, shape.y + shape.size), paint);
          break;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
