import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ExamplesDrawer {
  static const styleNormal = TextStyle(
      color: ui.Color.fromARGB(255, 59, 59, 59),
      fontSize: 14,
      fontFamily: 'Arial');
  static const styleKeywordTypes = TextStyle(
      color: ui.Color.fromARGB(255, 6, 80, 126),
      fontSize: 14,
      fontFamily: 'Arial');
  static const styleKeywordAttributes = TextStyle(
      color: ui.Color.fromARGB(255, 33, 140, 161),
      fontSize: 14,
      fontFamily: 'Arial');
  static const styleKeywordMethods = TextStyle(
      color: ui.Color.fromARGB(255, 118, 13, 159),
      fontSize: 14,
      fontFamily: 'Arial');
  static const styleComment = TextStyle(
      color: ui.Color.fromARGB(255, 50, 113, 52),
      fontSize: 14,
      fontFamily: 'Arial');
  static const styleKeywordObjects = TextStyle(
      color: ui.Color.fromARGB(255, 3, 84, 171),
      fontSize: 14,
      fontFamily: 'Arial');

  List<TextSpan> spans = [];
  String word = '';
  bool isComment = false;
  bool lastCharWasDot = false;

// Lists of words to be highlighted in specific colors
  static const Set<String> keywordsTypes = {
    'void',
    'final',
    'double',
    'const',
    'class',
    'import',
    'if',
    'else',
    'for',
    'while'
  };
  static const Set<String> keywordsAttributes = {
    'color',
    'style',
    'height',
    'width',
    'strokeWidth',
    'strokeJoin',
    'strokeCap',
    'circular',
    'fill',
    'stroke',
    'round',
    'square',
    'miter',
    'topLeft',
    'bottomRight',
    'bottomCenter',
    'centerLeft',
    'center',
    'infinity',
    'ltr',
    'alphabetic',
  };
  static const Set<String> keywordsMethods = {
    'drawLine',
    'drawRect',
    'drawRRect',
    'fromRectAndRadius',
    'fromRGBO',
    'drawImageRect',
    'fromLTWH',
    'close',
    'lineTo',
    'moveTo',
    'createShader',
    'drawArc',
    'drawPath',
    'drawOval',
    'save',
    'translate',
    'scale',
    'rotate',
    'restore',
    'toDouble',
    'layout',
    'computeDistanceToActualBaseline',
    'paint',
    'linear',
    'shader'
  };
  static const Set<String> keywordsObjects = {
    'Canvas',
    'Radius',
    'RRect',
    'Path',
    'Rect',
    'TextPainter',
    'TextSpan',
    'TextDirection',
    'Offset',
    'Color',
    'Colors',
    'StrokeCap',
    'PaintingStyle',
    'StrokeJoin',
    'Paint',
    'Gradient',
    'LinearGradient',
    'Alignment',
    'RadialGradient',
    'Size',
    'Image',
    'TextAlign',
    'TextStyle'
  };

  static const Map<String, Color> colorMap = {
    'orange': Color.fromARGB(255, 255, 165, 0),
    'green': Color.fromARGB(255, 0, 128, 0),
    'blue': Color.fromARGB(255, 0, 0, 255),
    'purple': Color.fromARGB(255, 128, 0, 128),
    'red': Color.fromARGB(255, 255, 0, 0),
    'grey': Color.fromARGB(255, 128, 128, 128),
  };

  static List<TextSpan> syntaxHighlight(String text) {
    List<TextSpan> spans = [];
    String word = '';
    bool isComment = false;
    String lastWord = '';
    bool lastCharWasDot = false;

    void addSpan(String text, TextStyle style) {
      if (text.isNotEmpty) {
        spans.add(TextSpan(text: text, style: style));
      }
    }

    List<String> lines = text.split('\n');
    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      String line = lines[lineIndex];
      isComment = false;
      word = '';
      lastCharWasDot = false;

      for (int i = 0; i < line.length; i++) {
        if (!isComment && line.startsWith('//', i)) {
          addSpan(word, styleNormal);
          word = '';
          addSpan(line.substring(i), styleComment);
          isComment = true;
          break;
        }

        if (RegExp(r'\w').hasMatch(line[i])) {
          word += line[i];
        } else {
          if (word.isNotEmpty) {
            TextStyle style = styleNormal;
            if (lastWord == 'Colors' &&
                colorMap.containsKey(word.toLowerCase())) {
              style = TextStyle(
                color: colorMap[word.toLowerCase()]!,
                fontSize: 14,
                fontFamily: 'Arial',
              );
            } else if (keywordsTypes.contains(word)) {
              style = styleKeywordTypes;
            } else if (lastCharWasDot && keywordsAttributes.contains(word)) {
              style = styleKeywordAttributes;
            } else if (lastCharWasDot && keywordsMethods.contains(word)) {
              style = styleKeywordMethods;
            } else if (keywordsObjects.contains(word)) {
              style = styleKeywordObjects;
            }
            addSpan(word, style);
            lastWord = word;
            word = '';
          }
          addSpan(line[i], styleNormal);
          lastCharWasDot = line[i] == '.';
          if (!lastCharWasDot) {
            lastWord = '';
          }
        }
      }

      if (word.isNotEmpty) {
        TextStyle style = styleNormal;
        if (lastWord == 'Colors' && colorMap.containsKey(word.toLowerCase())) {
          style = TextStyle(
            color: colorMap[word.toLowerCase()]!,
            fontSize: 14,
            fontFamily: 'Arial',
          );
        } else if (lastCharWasDot && keywordsAttributes.contains(word)) {
          style = styleKeywordAttributes;
        } else if (lastCharWasDot && keywordsMethods.contains(word)) {
          style = styleKeywordMethods;
        }
        addSpan(word, style);
      }

      if (lineIndex < lines.length - 1) {
        addSpan('\n', styleNormal);
      }
    }

    return spans;
  }

// Function to draw syntax highlighted text
  static void drawText(Canvas canvas, String text, double x, double y) {
    final textPainter = TextPainter(
      text: TextSpan(children: syntaxHighlight(text.replaceAll("      ", ""))),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: double.infinity);
    textPainter.paint(canvas, Offset(x, y));
  }

  static void lines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // 0
    canvas.drawLine(const Offset(50, 60), const Offset(100, 75), paint);
    drawText(
        canvas,
        '''
      paint.color = Colors.blue;
      paint.strokeWidth = 2;
      paint.strokeCap = StrokeCap.round;
      canvas.drawLine(
        const Offset(50, 60), 
        const Offset(100, 75), paint);
    ''',
        125,
        50);

    // 1
    paint.color = Colors.green;
    canvas.drawLine(const Offset(50, 260), const Offset(100, 275), paint);
    canvas.drawLine(const Offset(100, 275), const Offset(125, 300), paint);
    canvas.drawLine(const Offset(125, 300), const Offset(75, 300), paint);
    canvas.drawLine(const Offset(75, 300), const Offset(100, 325), paint);
    drawText(
        canvas,
        '''
      paint.color = Colors.green;
      canvas.drawLine(
        const Offset(50, 260), 
        const Offset(100, 275), paint);
      canvas.drawLine(
        const Offset(100, 275), 
        const Offset(125, 300), paint);
      canvas.drawLine(
        const Offset(125, 300), 
        const Offset(75, 300), paint);
      canvas.drawLine(
        const Offset(75, 300), 
        const Offset(100, 325), paint);
    ''',
        125,
        250);

    // 2
    paint.color = Colors.red;
    paint.strokeWidth = 10;
    paint.strokeCap = StrokeCap.square;
    canvas.drawLine(const Offset(400, 50), const Offset(430, 80), paint);
    drawText(
        canvas,
        '''
      paint.color = Colors.red;
      paint.strokeWidth = 10;
      paint.strokeCap = StrokeCap.square;
      canvas.drawLine(
        const Offset(400, 50), 
        const Offset(430, 80), paint);
    ''',
        450,
        50);

    // 3
    paint.color = Colors.purple;
    paint.strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(400, 250), const Offset(430, 280), paint);
    drawText(
        canvas,
        '''
      paint.color = Colors.purple;
      paint.strokeCap = StrokeCap.round;
      canvas.drawLine(
        const Offset(400, 250), 
        const Offset(430, 280), paint);
    ''',
        450,
        250);
  }

  static void squaresAndCircles(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // 0
    canvas.drawRect(const Rect.fromLTWH(50, 60, 40, 20), paint);

    paint.color = Colors.green;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(50, 110, 60, 30), const Radius.circular(25)),
      paint,
    );

    drawText(
      canvas,
      '''
      final paint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      // 0
      canvas.drawRect(
          const Rect.fromLTWH(50, 60, 40, 20), paint);
      paint.color = Colors.green;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(50, 110, 60, 30), 
            const Radius.circular(25)), paint);
    ''',
      120,
      50,
    );

    // 1
    paint.color = Colors.orange;
    paint.style = PaintingStyle.fill;
    canvas.drawRect(const Rect.fromLTWH(50, 300, 40, 20), paint);

    paint.color = Colors.pink;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(50, 350, 30, 60), const Radius.circular(25)),
      paint,
    );

    drawText(
      canvas,
      '''
      paint.color = Colors.orange;
      paint.style = PaintingStyle.fill;
      canvas.drawRect(
          const Rect.fromLTWH(50, 300, 40, 20), paint);

      paint.color = Colors.pink;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(50, 350, 30, 60), 
            const Radius.circular(25)), paint);
    ''',
      120,
      300,
    );

    // 2
    paint.color = Colors.blue;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    paint.color = Colors.purple;
    canvas.drawOval(const Rect.fromLTWH(400, 60, 40, 20), paint);

    paint.style = PaintingStyle.stroke;
    canvas.drawOval(const Rect.fromLTWH(400, 60, 40, 20), paint);

    drawText(
      canvas,
      '''
      paint.color = Colors.blue;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      paint.color = Colors.purple;
      canvas.drawOval(
          const Rect.fromLTWH(400, 60, 40, 20), paint);

      paint.style = PaintingStyle.stroke;
      canvas.drawOval(
          const Rect.fromLTWH(400, 60, 40, 20), paint);
    ''',
      450,
      50,
    );

    // 3
    paint.color = Colors.blue;
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 5;

    canvas.drawArc(
      const Rect.fromLTWH(370, 300, 60, 30),
      0,
      -90 * (3.141592653589793 / 180),
      true,
      paint,
    );

    paint.color = Colors.grey;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 5;

    canvas.drawArc(
      const Rect.fromLTWH(370, 300, 60, 30),
      0,
      -90 * (3.141592653589793 / 180),
      true,
      paint,
    );

    drawText(
      canvas,
      '''
        paint.color = Colors.blue;
        paint.style = PaintingStyle.fill;
        paint.strokeWidth = 5;

        canvas.drawArc(
          const Rect.fromLTWH(370, 300, 60, 30),
          0, -90 * (3.141592653589793 / 180), true, paint);

        paint.color = Colors.grey;
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 5;

        canvas.drawArc(
          const Rect.fromLTWH(370, 300, 60, 30),
          0, -90 * (3.141592653589793 / 180), true, paint);
    ''',
      450,
      260,
    );
  }

  static void polygons(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    // 0
    final path0 = Path();
    path0.moveTo(50, 60);
    path0.lineTo(100, 75);
    path0.lineTo(50, 100);
    canvas.drawPath(path0, paint);
    drawText(
        canvas,
        '''
      paint.color = Colors.blue;
      paint.strokeWidth = 2;
      paint.strokeCap = StrokeCap.round;
      paint.strokeJoin = StrokeJoin.round;
      final path0 = Path();
      path0.moveTo(50, 60);
      path0.lineTo(100, 75);
      path0.lineTo(50, 100);
      canvas.drawPath(path0, paint);
    ''',
        125,
        50);

    // 1
    paint.color = Colors.green;
    final path1 = Path();
    path1.moveTo(50, 260);
    path1.lineTo(100, 275);
    path1.lineTo(125, 300);
    path1.moveTo(75, 300);
    path1.lineTo(100, 325);
    canvas.drawPath(path1, paint);
    drawText(
        canvas,
        '''
      paint.color = Colors.green;
      final path1 = Path();
      path1.moveTo(50, 260);
      path1.lineTo(100, 275);
      path1.lineTo(125, 300);
      path1.moveTo(75, 300);
      path1.lineTo(100, 325);
      canvas.drawPath(path1, paint);
    ''',
        125,
        260);

    // 2
    paint.color = Colors.red;
    paint.strokeWidth = 10;
    paint.strokeCap = StrokeCap.square;
    paint.strokeJoin = StrokeJoin.round;
    final path2 = Path();
    path2.moveTo(400, 50);
    path2.lineTo(430, 80);
    path2.lineTo(400, 110);
    canvas.drawPath(path2, paint);
    drawText(
        canvas,
        '''
      paint.color = Colors.red;
      paint.strokeWidth = 10;
      paint.strokeCap = StrokeCap.square;
      paint.strokeJoin = StrokeJoin.round;
      final path2 = Path();
      path2.moveTo(400, 50);
      path2.lineTo(430, 80);
      path2.lineTo(400, 110);
      canvas.drawPath(path2, paint);
    ''',
        450,
        50);

    // 3
    paint.color = Colors.purple;
    paint.strokeCap = StrokeCap.round;
    paint.strokeJoin = StrokeJoin.miter;
    final path3 = Path();
    path3.moveTo(400, 250);
    path3.lineTo(430, 280);
    path3.lineTo(400, 310);
    canvas.drawPath(path3, paint);
    drawText(
        canvas,
        '''
      paint.color = Colors.purple;
      paint.strokeCap = StrokeCap.round;
      paint.strokeJoin = StrokeJoin.miter;
      final path3 = Path();
      path3.moveTo(400, 250);
      path3.lineTo(430, 280);
      path3.lineTo(400, 310);
      canvas.drawPath(path3, paint);
    ''',
        450,
        260);
  }

  static void filledPolygons(Canvas canvas, Size size) {
    // 0
    final paintFill = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = Colors.orange
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(50, 60)
      ..lineTo(100, 75)
      ..lineTo(75, 100)
      ..lineTo(50, 75);

    canvas.drawPath(path, paintFill);
    canvas.drawPath(path, paintStroke);
    drawText(
      canvas,
      '''
      final paintFill = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill;
      final paintStroke = Paint()
        ..color = Colors.orange
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final path = Path()
        ..moveTo(50, 60)..lineTo(100, 75)
        ..lineTo(75, 100)..lineTo(50, 75);
      canvas.drawPath(path, paintFill);
      canvas.drawPath(path, paintStroke);
    ''',
      120,
      30,
    );

    // 1
    final paint1 = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    final borderPaint1 = Paint()
      ..color = Colors.green
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(50, 260)
      ..lineTo(100, 275)
      ..lineTo(100, 300)
      ..lineTo(50, 275);
    canvas.drawPath(path1, borderPaint1);
    canvas.drawPath(path1, paint1);
    drawText(
      canvas,
      '''
      final paint1 = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.fill;
      final borderPaint1 = Paint()
        ..color = Colors.green
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path1 = Path()
        ..moveTo(50, 260)..lineTo(100, 275)
        ..lineTo(100, 300)..lineTo(50, 275);
      canvas.drawPath(path1, borderPaint1);
      canvas.drawPath(path1, paint1);
    ''',
      120,
      260,
    );

    // 2
    final paint2 = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(400, 60)
      ..lineTo(440, 70)
      ..lineTo(420, 100)
      ..lineTo(410, 90)
      ..close();
    canvas.drawPath(path2, paint2);
    drawText(
      canvas,
      '''
      final paint2 = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;

      final path2 = Path()
        ..moveTo(400, 60)..lineTo(440, 70)
        ..lineTo(420, 100)..lineTo(410, 90)..close();
      canvas.drawPath(path2, paint2);
    ''',
      450,
      30,
    );

    // 3
    final paint3 = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    final semiTransparentPaint = Paint()
      ..color = const Color.fromRGBO(128, 255, 128, 0.5)
      ..style = PaintingStyle.fill;

    final path3 = Path()
      ..moveTo(400, 250)
      ..lineTo(440, 290)
      ..lineTo(390, 280)
      ..close();
    canvas.drawPath(path3, paint3);

    final path4 = Path()
      ..moveTo(400, 260)
      ..lineTo(440, 300)
      ..lineTo(390, 290)
      ..close();
    canvas.drawPath(path4, semiTransparentPaint);
    drawText(
      canvas,
      '''
      final paint3 = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      final semiTransparentPaint = Paint()
        ..color = Color.fromRGBO(128, 255, 128, 0.5)
        ..style = PaintingStyle.fill;
      final path3 = Path()
        ..moveTo(400, 250)..lineTo(440, 290)
        ..lineTo(390, 280)..close();
      canvas.drawPath(path3, paint3);
      final path4 = Path()
        ..moveTo(400, 260)..lineTo(440, 300)
        ..lineTo(390, 290)..close();
      canvas.drawPath(path4, semiTransparentPaint);
    ''',
      450,
      260,
    );
  }

  static void linearGradients(Canvas canvas, Size size) {
    // 0
    const rect0 = Rect.fromLTWH(50, 40, 80, 50);
    const gradient0 = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.topRight,
        colors: [Colors.orange, Colors.green, Colors.blue],
        stops: [0.2, 0.5, 0.8]);
    final paint0 = Paint()..shader = gradient0.createShader(rect0);
    canvas.drawRect(rect0, paint0);
    drawText(
      canvas,
      '''
      const rect0 = Rect.fromLTWH(50, 40, 80, 50);
      const gradient0 = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: [Colors.orange, Colors.green, Colors.blue],
          stops: [0.2, 0.5, 0.8]);
      final paint0 = Paint()..shader = gradient0.createShader(rect0);
      canvas.drawRect(rect0, paint0);
    ''',
      150,
      30,
    );

    // 1
    const rect1 = Rect.fromLTWH(50, 210, 80, 50);
    const gradient1 = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.red, Colors.orange, Colors.purple],
        stops: [0, 0.25, 0.8]);
    final paint1 = Paint()..shader = gradient1.createShader(rect1);
    canvas.drawRect(rect1, paint1);
    drawText(
      canvas,
      '''
      final rect1 = Rect.fromLTWH(50, 210, 80, 50);
      final gradient1 = LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Colors.red, Colors.orange, Colors.purple], stops: [0, 0.25, 0.8]);
      );
      final paint1 = Paint()..shader = gradient1.createShader(rect1);
      canvas.drawRect(rect1, paint1);
    ''',
      150,
      200,
    );

    // 2
    const rect2 = Rect.fromLTWH(50, 380, 80, 50);
    const gradient2 = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.blue, Colors.grey, Colors.purple],
      stops: [0.2, 0.7, 1],
    );
    final paint2 = Paint()..shader = gradient2.createShader(rect2);
    canvas.drawRect(rect2, paint2);
    drawText(
      canvas,
      '''
      final rect2 = Rect.fromLTWH(50, 380, 80, 50);
      final gradient2 = LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomCenter,
        colors: [Colors.blue, Colors.grey, Colors.purple], stops: [0.2, 0.7, 1]);
      final paint2 = Paint()..shader = gradient2.createShader(rect2);
      canvas.drawRect(rect2, paint2);
    ''',
      150,
      360,
    );
  }

  static void radialGradients(Canvas canvas, Size size) {
    // 0
    const rect0 = Rect.fromLTWH(50, 40, 80, 50);
    const gradient0 = RadialGradient(
      center: Alignment.center, // Centrat dins del rectangle
      radius: 0.8,
      colors: [Colors.orange, Colors.green, Colors.blue],
      stops: [0.2, 0.5, 0.8],
    );

    final paint0 = Paint()..shader = gradient0.createShader(rect0);
    canvas.drawRect(rect0, paint0);

    drawText(
      canvas,
      '''
      const rect0 = Rect.fromLTWH(50, 40, 80, 50);
      const gradient0 = RadialGradient(
        center: Alignment.center, radius: 0.8,
        colors: [Colors.orange, Colors.green, Colors.blue],
        stops: [0.2, 0.5, 0.8],
      );
      final paint0 = Paint()..shader = gradient0.createShader(rect0);
      canvas.drawRect(rect0, paint0);
    ''',
      150,
      30,
    );

    // 1
    const rect1 = Rect.fromLTWH(50, 210, 80, 50);
    const gradient1 = RadialGradient(
        center: Alignment.centerLeft,
        radius: 1.5,
        colors: [Colors.red, Colors.orange, Colors.purple],
        stops: [0, 0.25, 0.8]);
    final paint1 = Paint()..shader = gradient1.createShader(rect1);
    canvas.drawRect(rect1, paint1);
    drawText(
      canvas,
      '''
        const rect1 = Rect.fromLTWH(50, 210, 80, 50);
        const gradient1 = RadialGradient(
          center: Alignment.centerLeft, radius: 1.5,
          colors: [Colors.red, Colors.orange, Colors.purple],
          stops: [0, 0.25, 0.8]);
        final paint1 = Paint()..shader = gradient1.createShader(rect1);
        canvas.drawRect(rect1, paint1);
    ''',
      150,
      200,
    );

    // 2
    const rect2 = Rect.fromLTWH(50, 380, 80, 50);
    const gradient2 = RadialGradient(
      center: Alignment(0, 1),
      radius: 1,
      colors: [Colors.blue, Colors.grey, Colors.purple],
      stops: [0.2, 0.7, 1],
    );
    final paint2 = Paint()..shader = gradient2.createShader(rect2);
    canvas.drawRect(rect2, paint2);
    drawText(
      canvas,
      '''
      final rect2 = Rect.fromLTWH(50, 380, 80, 50);
      final gradient2 = RadialGradient(
        center: Alignment(0, 1), radius: 1,
        colors: [Colors.blue, Colors.grey, Colors.purple], stops: [0.2, 0.7, 1]);
      final paint2 = Paint()..shader = gradient2.createShader(rect2);
      canvas.drawRect(rect2, paint2);
    ''',
      150,
      360,
    );
  }

  static Future<void> images(
      Canvas canvas, Size size, ui.Image imgMario) async {
    final paint = Paint();

    // 0
    canvas.drawImageRect(
      imgMario,
      Rect.fromLTWH(
          0, 0, imgMario.width.toDouble(), imgMario.height.toDouble()),
      const Rect.fromLTWH(50, 50, 50, 50),
      paint,
    );

    drawText(
      canvas,
      '''
      canvas.drawImageRect(
        imgMario,
        Rect.fromLTWH(
          0, 0, 
          imgMario.width.toDouble(), 
          imgMario.height.toDouble()),
        const Rect.fromLTWH(50, 50, 50, 50),
        paint,
      );
      // No manté la proporció
      ''',
      110,
      30,
    );

    // 1
    canvas.drawImageRect(
      imgMario,
      Rect.fromLTWH(
          0, 0, imgMario.width.toDouble(), imgMario.height.toDouble()),
      const Rect.fromLTWH(50, 300, 50, 100),
      paint,
    );

    drawText(
      canvas,
      '''
      canvas.drawImageRect(
        imgMario,
        Rect.fromLTWH(
          0, 0, 
          imgMario.width.toDouble(), 
          imgMario.height.toDouble()),
        Rect.fromLTWH(50, 300, 50, 100),
        paint,
      );
      // No manté la proporció
      ''',
      110,
      285,
    );

    // 2
    double alt = imgMario.height.toDouble();
    double ample = imgMario.width.toDouble();
    double prpAmple = 50;
    double prpAlt = prpAmple * (alt / ample);
    canvas.drawImageRect(
      imgMario,
      Rect.fromLTWH(
          0, 0, imgMario.width.toDouble(), imgMario.height.toDouble()),
      Rect.fromLTWH(400, 50, prpAmple, prpAlt),
      paint,
    );

    drawText(
      canvas,
      '''
      double alt = imgMario.height.toDouble();
      double ample = imgMario.width.toDouble();
      double prpAmple = 50;
      double prpAlt = prpAmple * (alt / ample);
      canvas.drawImageRect(
        imgMario,
        Rect.fromLTWH(
          0, 0, 
          imgMario.width.toDouble(), 
          imgMario.height.toDouble()),
        Rect.fromLTWH(400, 50, prpAmple, prpAlt),
        paint,
      );
      // Manté la proporció correcta amb ample = 50
      ''',
      460,
      30,
    );

    // 3
    prpAlt = 50;
    prpAmple = prpAlt * (ample / alt);
    canvas.drawImageRect(
      imgMario,
      Rect.fromLTWH(
          0, 0, imgMario.width.toDouble(), imgMario.height.toDouble()),
      Rect.fromLTWH(400, 300, prpAmple, prpAlt),
      paint,
    );

    drawText(
      canvas,
      '''
      prpAlt = 50;
      prpAmple = prpAlt * (ample / alt);
      canvas.drawImageRect(
        imgMario,
        Rect.fromLTWH(
          0, 0, 
          imgMario.width.toDouble(), 
          imgMario.height.toDouble()),
        Rect.fromLTWH(400, 300, prpAmple, prpAlt),
        paint,
      );
      // Manté la proporció correcta amb alt = 50
      ''',
      460,
      285,
    );
  }

  static Future<void> transformations(
      Canvas canvas, Size size, ui.Image imgMario) async {
    final paint = Paint();

    // 0
    canvas.save();
    double alt = imgMario.height.toDouble();
    double ample = imgMario.width.toDouble();
    double prpAmple = 50;
    double prpAlt = prpAmple * (alt / ample);
    canvas.drawImageRect(
      imgMario,
      Rect.fromLTWH(
          0, 0, imgMario.width.toDouble(), imgMario.height.toDouble()),
      Rect.fromLTWH(50, 30, prpAmple, prpAlt),
      paint,
    );
    canvas.restore();

    drawText(
      canvas,
      '''
      canvas.save();
      double alt = imgMario.height.toDouble();
      double ample = imgMario.width.toDouble();
      double prpAmple = 50;
      double prpAlt = prpAmple * (alt / ample);
      canvas.drawImageRect(
        imgMario,
        Rect.fromLTWH(0, 0, imgMario.width.toDouble(), imgMario.height.toDouble()),
        Rect.fromLTWH(50, 30, prpAmple, prpAlt), paint);
      canvas.restore();
      ''',
      140,
      20,
    );

    // 1
    canvas.save();
    canvas.translate(50, 200);
    canvas.save();
    canvas.scale(1.5, 0.5);
    canvas.drawImageRect(
      imgMario,
      Rect.fromLTWH(
          0, 0, imgMario.width.toDouble(), imgMario.height.toDouble()),
      Rect.fromLTWH(0, 0, prpAmple, prpAlt),
      paint,
    );
    canvas.restore();
    canvas.restore();

    drawText(
      canvas,
      '''
      canvas.save();
      canvas.translate(50, 200);
      canvas.save();
      canvas.scale(1.5, 0.5);
      canvas.drawImageRect(
        imgMario,
        Rect.fromLTWH(0, 0, imgMario.width.toDouble(), imgMario.height.toDouble()),
        Rect.fromLTWH(0, 0, prpAmple, prpAlt), paint);
      canvas.restore(); canvas.restore();
      ''',
      140,
      195,
    );

    // 2
    canvas.save();
    canvas.translate(50, 375);
    canvas.save();
    canvas.rotate(-45 * 3.1415927 / 180);
    canvas.drawImageRect(
      imgMario,
      Rect.fromLTWH(
          0, 0, imgMario.width.toDouble(), imgMario.height.toDouble()),
      Rect.fromLTWH(0, 0, prpAmple, prpAlt),
      paint,
    );
    canvas.restore();
    canvas.restore();

    drawText(
      canvas,
      '''
      canvas.save();
      canvas.translate(50, 375);
      canvas.save();
      canvas.rotate(-45 * 3.1415927 / 180);
      canvas.drawImageRect(
        imgMario,
        Rect.fromLTWH(0, 0, imgMario.width.toDouble(), imgMario.height.toDouble()),
        Rect.fromLTWH(0, 0, prpAmple, prpAlt), paint);
      canvas.restore(); canvas.restore();
      ''',
      140,
      350,
    );
  }

  static void texts0(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(50, 50), const Offset(100, 50), paint);
    canvas.drawLine(const Offset(50, 30), const Offset(50, 50), paint);

    final textPainter0 = TextPainter(
      text: const TextSpan(
        text: "Agc",
        style: TextStyle(
          color: Colors.blue,
          fontSize: 25,
          fontFamily: 'Arial',
        ),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter0.layout(minWidth: 0, maxWidth: double.infinity);

    // Calcula la posició vertical perquè la línia de base coincideixi amb la línia vermella
    final offsetY = 50 -
        textPainter0.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    textPainter0.paint(canvas, Offset(50, offsetY));

    drawText(
      canvas,
      '''
      final paint = Paint()
        ..color = Colors.red
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        const Offset(50, 50), const Offset(100, 50), paint);
      canvas.drawLine(
        const Offset(50, 30), const Offset(50, 50), paint);

      final textPainter0 = TextPainter(
        text: const TextSpan(
          text: "Agc",
          style: TextStyle(
            color: Colors.blue,
            fontSize: 25,
            fontFamily: 'Arial',
          ),
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      textPainter0.layout(minWidth: 0, maxWidth: double.infinity);

      // Calcula la posició vertical perquè la línia de 
      // base coincideixi amb la línia vermella
      final offsetY = 50 -
          textPainter0.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      textPainter0.paint(canvas, Offset(50, offsetY));
      ''',
      120,
      30,
    );

    // 1
    canvas.drawLine(const Offset(450, 50), const Offset(500, 50), paint);
    canvas.drawLine(const Offset(450, 50), const Offset(450, 80), paint);

    final textPainter2 = TextPainter(
      text: const TextSpan(
        text: "Àgc",
        style: TextStyle(
          color: Colors.blue,
          fontSize: 25,
          fontFamily: 'Arial',
        ),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter2.layout(minWidth: 0, maxWidth: double.infinity);
    textPainter2.paint(canvas, const Offset(450, 50));

    drawText(
      canvas,
      '''
      canvas.drawLine(
          const Offset(450, 50), 
          const Offset(500, 50), paint);
      canvas.drawLine(
          const Offset(450, 50), 
          const Offset(450, 80), paint);

      final textPainter2 = TextPainter(
        text: const TextSpan(
          text: "Àgc",
          style: TextStyle(
            color: Colors.blue,
            fontSize: 25,
            fontFamily: 'Arial',
          ),
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      textPainter2.layout(
          minWidth: 0, 
          maxWidth: double.infinity);
      textPainter2.paint(
          canvas, 
          const Offset(450, 50));
      ''',
      520,
      30,
    );
  }

  static void texts1(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(50, 250), const Offset(100, 250), paint);
    canvas.drawLine(const Offset(100, 225), const Offset(100, 250), paint);

    final textPainter1 = TextPainter(
      text: const TextSpan(
        text: "Agc",
        style: TextStyle(
          color: Colors.blue,
          fontSize: 25,
          fontFamily: 'Verdana',
        ),
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );
    textPainter1.layout(minWidth: 100, maxWidth: 100);

    // Posicionar respecte la caixa (layout) del textPainter
    final yPosition = 250 -
        textPainter1.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    textPainter1.paint(canvas, Offset(0, yPosition));

    drawText(
      canvas,
      '''
      final paint = Paint()
        ..color = Colors.red
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        const Offset(50, 250), 
        const Offset(100, 250), paint);
      canvas.drawLine(
        const Offset(100, 225), 
        const Offset(100, 250), paint);

      final textPainter1 = TextPainter(
        text: const TextSpan(
          text: "Agc",
          style: TextStyle(
            color: Colors.blue, fontSize: 25,
            fontFamily: 'Verdana',
          ),
        ),
        textAlign: TextAlign.right,
        textDirection: TextDirection.ltr,
      );
      textPainter1.layout(minWidth: 100, maxWidth: 100);

      // Posicionar respecte la caixa (layout) del textPainter
      final yPosition = 250 -
          textPainter1.computeDistanceToActualBaseline(
            TextBaseline.alphabetic);
      textPainter1.paint(canvas, Offset(0, yPosition));
    ''',
      120,
      30,
    );

    // 1

    // Dibuixar les línies horitzontal i vertical de la creu
    canvas.drawLine(const Offset(425, 250), const Offset(475, 250), paint);
    canvas.drawLine(const Offset(450, 225), const Offset(450, 275), paint);

    final textPainter3 = TextPainter(
      text: const TextSpan(
        text: "Agc",
        style: TextStyle(
          color: Colors.blue,
          fontSize: 25,
          fontFamily: 'Verdana',
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter3.layout(minWidth: 0, maxWidth: double.infinity);

    // Calcular la posició per centrar el text a la creu
    final xOffset = 450.0 - (textPainter3.width / 2);
    final yOffset = 250.0 -
        textPainter3.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    textPainter3.paint(canvas, Offset(xOffset, yOffset));

    drawText(
      canvas,
      '''
      canvas.drawLine(
        const Offset(450, 250), 
        const Offset(500, 250), paint);
      canvas.drawLine(
        const Offset(475, 225), 
        const Offset(475, 275), paint);

      final textPainter3 = TextPainter(
        text: const TextSpan(
          text: "Agc",
          style: TextStyle(
            color: Colors.blue, fontSize: 25,
            fontFamily: 'Verdana',
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter3.layout(
        minWidth: 0, 
        maxWidth: double.infinity);

      // Calcular la posició
      final xOffset = 475.0 - (textPainter3.width / 2);
      final yOffset = 250.0 -
        textPainter3.computeDistanceToActualBaseline(
          TextBaseline.alphabetic);
      textPainter3.paint(canvas, 
        Offset(xOffset, yOffset));
      ''',
      490,
      30,
    );
  }

  static void textMultiline(Canvas canvas, Size size) async {
    String str =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";

    final textStyle = TextStyle(
      fontSize: 20,
      foreground: Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(size.width, 0),
          [
            Colors.orange,
            Colors.green,
            Colors.blue,
          ],
          [0.2, 0.5, 0.8],
        ),
    );

    final textSpan = TextSpan(
      text: str,
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.justify,
      textDirection: TextDirection.ltr,
      maxLines: null,
    );

    textPainter.layout(maxWidth: 600);
    textPainter.paint(canvas, const Offset(50, 25));

    drawText(
      canvas,
      '''
      // Crea un TextSpan amb un ample màxim i pinta el text al canvas
      String str = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
      
      final textStyle = TextStyle(
        fontSize: 20,
        foreground: Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, 0), 
            Offset(size.width, 0),
            [Colors.orange, Colors.green, Colors.blue,],
            [0.2, 0.5, 0.8]));

      final textSpan = TextSpan(
        text: str,
        style: textStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.justify,
        textDirection: TextDirection.ltr,
        maxLines: null,
      );

      textPainter.layout(maxWidth: 600);
      textPainter.paint(canvas, Offset(50, 25));
      ''',
      50,
      80,
    );
  }
}
