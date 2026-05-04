import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Shape {
  final ShapeType type;
  final Color color;
  final double x;
  final double y;
  final double size;

  Shape(
      {required this.type,
      required this.color,
      required this.x,
      required this.y,
      required this.size});
}

enum ShapeType { rectangle, circle, line }
