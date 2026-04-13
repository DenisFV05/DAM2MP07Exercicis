import 'package:flutter/cupertino.dart';
import 'clock_painter.dart';

class ViewWidget extends StatefulWidget {
  const ViewWidget({super.key});

  @override
  ViewWidgetState createState() => ViewWidgetState();
}

class ViewWidgetState extends State<ViewWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late DateTime _lastDrawTime;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
    _lastDrawTime = DateTime.now();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _calculateFps() {
    final currentTime = DateTime.now();
    final elapsed = currentTime.difference(_lastDrawTime).inMilliseconds;
    double fps = 0.0;
    if (elapsed > 0) {
      fps = 1000 / elapsed;
    }
    _lastDrawTime = currentTime;
    return fps;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomPaint(
                painter: ClockPainter(_controller, _calculateFps),
                size: Size(constraints.maxWidth, constraints.maxHeight),
              );
            },
          ),
        ),
      ],
    );
  }
}
