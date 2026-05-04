import 'package:flutter/cupertino.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: MyHomePage(
        title: 'Flutter Cupertino Demo',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _firstNumber = 0;
  int _secondNumber = 0;

  void _incrementFirstNumber() {
    setState(() {
      _firstNumber++;
    });
  }

  void _decrementSecondNumber() {
    setState(() {
      _secondNumber--;
    });
  }

  void _resetNumbers() {
    setState(() {
      _firstNumber = 0;
      _secondNumber = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('$_firstNumber'),
                const SizedBox(width: 20),
                Text('$_secondNumber'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CupertinoButton.filled(
                  onPressed: _incrementFirstNumber,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: const Text('Increment First Number'),
                ),
                const SizedBox(width: 10),
                CupertinoButton.filled(
                  onPressed: _decrementSecondNumber,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: const Text('Decrement Second'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CupertinoButton(
              onPressed: _resetNumbers,
              child: const Text('Reset Numbers'),
            ),
          ],
        ),
      ),
    );
  }
}
