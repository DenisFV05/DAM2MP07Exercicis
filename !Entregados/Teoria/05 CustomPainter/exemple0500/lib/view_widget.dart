import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'shape.dart';
import 'shape_painter.dart';

class ViewWidget extends StatefulWidget {
  const ViewWidget({super.key});

  @override
  ViewWidgetState createState() => ViewWidgetState();
}

class ViewWidgetState extends State<ViewWidget> {
  final Random random = Random();
  final List<Shape> shapes = [];

  @override
  void initState() {
    super.initState();
  }

  void addShapeAtPosition(double x, double y) {
    final double size = 20 + random.nextInt(31).toDouble();
    final Color color = getRandomColor();
    final bool isSquare = random.nextBool();

    setState(() {
      shapes.add(Shape(
        type: isSquare ? ShapeType.rectangle : ShapeType.circle,
        color: color,
        x: x - size / 2,
        y: y - size / 2,
        size: size,
      ));
    });
  }

  void addShape() {
    final double size = 20 + random.nextInt(31).toDouble();
    final double x = random.nextDouble() * 300;
    final double y = random.nextDouble() * 300;
    final Color color = getRandomColor();
    final bool isSquare = random.nextBool();

    setState(() {
      shapes.add(Shape(
        type: isSquare ? ShapeType.rectangle : ShapeType.circle,
        color: color,
        x: x,
        y: y,
        size: size,
      ));
    });
  }

  void clearShapes() {
    setState(() {
      shapes.clear();
    });
  }

  Color getRandomColor() {
    const colors = [
      Colors.red,
      Colors.cyan,
      Colors.purple, // Substitute for magenta
      Colors.yellow,
      Colors.orange,
      Colors.black,
      Colors.white,
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('CustomPaint App'),
      ),
      child: SafeArea(
        child: Row(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTapDown: (details) {
                  final RenderBox renderBox =
                      context.findRenderObject() as RenderBox;
                  final Offset localPosition =
                      renderBox.globalToLocal(details.globalPosition);
                  addShapeAtPosition(
                      localPosition.dx,
                      localPosition.dy -
                          56); // 56 is the height of CupertinoNavigationBar
                },
                child: Container(
                  color: CupertinoColors.lightBackgroundGray,
                  child: CustomPaint(
                    painter: ShapePainter(shapes),
                    child: Container(),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CupertinoButton(
                  onPressed: addShape,
                  child: const Text('Add Shape'),
                ),
                CupertinoButton(
                  onPressed: clearShapes,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
