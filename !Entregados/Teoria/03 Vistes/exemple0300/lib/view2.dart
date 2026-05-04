import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class View2 extends StatefulWidget {
  const View2({super.key});

  @override
  View2State createState() => View2State();
}

class View2State extends State<View2> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding =
        MediaQuery.of(context).padding.top + kMinInteractiveDimensionCupertino;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('View 2'),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(height: topPadding),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('This is view 2', style: TextStyle(fontSize: 24)),
          ),
          Expanded(
            child: Center(
              child: ScaleTransition(
                scale: _animation,
                child: Container(
                  width: 200.0,
                  height: 200.0,
                  color: Colors.blueGrey,
                  child: const Center(
                    child: Text(
                      'Animated 🚀',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
