import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'picker360_painter.dart';

class Picker360 extends StatefulWidget {
  final double value;
  final double size;
  final bool enabled;
  final Function(double)? onChanged;

  const Picker360(
      {super.key,
      required this.value,
      this.enabled = true,
      this.size = 32,
      required this.onChanged});

  @override
  Picker360State createState() => Picker360State();
}

class Picker360State extends State<Picker360> {
  void _onPanUpdate(DragUpdateDetails details) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final halfSize = widget.size / 2;
    final position = renderBox.globalToLocal(details.globalPosition);
    final double angle =
        (math.atan2(position.dy - halfSize, position.dx - halfSize) *
                180 /
                math.pi) %
            360;

    widget.onChanged?.call(angle);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: !widget.enabled ? null : _onPanUpdate,
      child: CustomPaint(
        painter: Picker360Painter(widget.value),
        size: Size(widget.size, widget.size),
      ),
    );
  }
}
