import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Animation Demo',
      home: MainAnimationScreen(),
    );
  }
}

class MainAnimationScreen extends StatefulWidget {
  const MainAnimationScreen({super.key});

  @override
  MainAnimationScreenState createState() => MainAnimationScreenState();
}

class MainAnimationScreenState extends State<MainAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isAnimating = false;
  bool _wasGrowing = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
      lowerBound: 0.15, // Valor mínim de l'animació
    );
    // Tipus d'animació
    _animation = CurvedAnimation(parent: _controller, curve: Curves.ease)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _wasGrowing = false;
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _wasGrowing = true;
          _controller.forward();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (!_isAnimating) {
      if (_wasGrowing) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      setState(() {
        _isAnimating = true;
      });
    }
  }

  void _pauseAnimation() {
    if (_isAnimating) {
      _controller.stop();
      setState(() {
        _isAnimating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Animation Demo'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ScaleTransition(
              scale: _animation,
              child: Container(
                width: 200.0,
                height: 200.0,
                color: Colors.blue,
                child: const Center(
                  child: Text(
                    'Flutter',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  onPressed: _isAnimating ? null : _startAnimation,
                  child: const Text('Start'),
                ),
                const SizedBox(width: 10),
                CupertinoButton(
                  onPressed: _isAnimating ? _pauseAnimation : null,
                  child: const Text('Pause'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
