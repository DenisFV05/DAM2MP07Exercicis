import 'package:flutter/cupertino.dart';

class ShapePainter extends CustomPainter {
  final Rect greenSquare;
  final Rect blueCircle;
  final bool isCircleOnTop;

  ShapePainter({
    required this.greenSquare,
    required this.blueCircle,
    required this.isCircleOnTop,
  });

  void paintCircle(Canvas canvas) {
    final paint = Paint();
    paint.color = _isOverlapping(blueCircle, greenSquare) && isCircleOnTop
        ? CupertinoColors.activeOrange.withOpacity(0.5)
        : CupertinoColors.systemBlue;
    canvas.drawOval(blueCircle, paint);
  }

  void paintSquare(Canvas canvas) {
    final paint = Paint();
    paint.color = _isOverlapping(greenSquare, blueCircle) && !isCircleOnTop
        ? CupertinoColors.activeOrange.withOpacity(0.5)
        : CupertinoColors.systemGreen;
    canvas.drawRect(greenSquare, paint);
  }

  bool _isOverlapping(Rect circle, Rect square) {
    final double circleCenterX = circle.center.dx;
    final double circleCenterY = circle.center.dy;
    final double circleRadius = circle.width / 2;

    final double closestX = circleCenterX.clamp(square.left, square.right);
    final double closestY = circleCenterY.clamp(square.top, square.bottom);

    final double distanceX = circleCenterX - closestX;
    final double distanceY = circleCenterY - closestY;

    final double distanceSquared =
        distanceX * distanceX + distanceY * distanceY;
    return distanceSquared < (circleRadius * circleRadius);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (isCircleOnTop) {
      paintSquare(canvas);
      paintCircle(canvas);
    } else {
      paintCircle(canvas);
      paintSquare(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant ShapePainter oldDelegate) {
    return oldDelegate.greenSquare != greenSquare ||
        oldDelegate.blueCircle != blueCircle ||
        oldDelegate.isCircleOnTop != isCircleOnTop;
  }
}
