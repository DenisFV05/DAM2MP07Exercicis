import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'examples_drawer.dart';

class DrawingPainter extends CustomPainter {
  final String selectedOption;
  final ui.Image imgMario;

  DrawingPainter(this.selectedOption, this.imgMario);

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    switch (selectedOption) {
      case 'Linies':
        ExamplesDrawer.lines(canvas, size);
        break;
      case 'Quadrats i cercles':
        ExamplesDrawer.squaresAndCircles(canvas, size);
        break;
      case 'Poligons':
        ExamplesDrawer.polygons(canvas, size);
      case 'Poligons emplenats':
        ExamplesDrawer.filledPolygons(canvas, size);
      case 'Gradients lineals':
        ExamplesDrawer.linearGradients(canvas, size);
      case 'Gradients radials':
        ExamplesDrawer.radialGradients(canvas, size);
      case 'Imatges':
        ExamplesDrawer.images(canvas, size, imgMario);
        break;
      case 'Transformacions':
        ExamplesDrawer.transformations(canvas, size, imgMario);
      case 'Texts posicionats 0':
        ExamplesDrawer.texts0(canvas, size);
        break;
      case 'Texts posicionats 1':
        ExamplesDrawer.texts1(canvas, size);
        break;
      case 'Texts multilínia':
        ExamplesDrawer.textMultiline(canvas, size);
        break;
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CupertinoColors.lightBackgroundGray
      ..strokeWidth = 1;

    const textStyle =
        TextStyle(color: CupertinoColors.systemGrey, fontSize: 10);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    const lineDark = ui.Color.fromARGB(255, 210, 210, 210);
    const lineLight = ui.Color.fromARGB(255, 220, 220, 220);

    // Primer dibuixem totes les línies
    for (double x = 0; x <= size.width; x += 10) {
      if (x % 50 == 0) {
        paint.strokeWidth = 1.5;
        paint.color = lineDark;
      } else {
        paint.strokeWidth = 1;
        paint.color = lineLight;
      }
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += 10) {
      if (y % 50 == 0) {
        paint.strokeWidth = 1.5;
        paint.color = lineDark;
      } else {
        paint.strokeWidth = 1;
        paint.color = lineLight;
      }
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Després dibuixem els números
    for (double x = 0; x <= size.width; x += 50) {
      textPainter.text = TextSpan(text: x.toInt().toString(), style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 2, 2));
    }

    for (double y = 0; y <= size.height; y += 50) {
      textPainter.text = TextSpan(text: y.toInt().toString(), style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(2, y + 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
