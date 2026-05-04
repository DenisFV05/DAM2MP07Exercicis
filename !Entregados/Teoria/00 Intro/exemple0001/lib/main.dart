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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
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
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    CupertinoIcons.bell_fill,
                    color: Color(0xFF00AA00),
                    size: 25.0,
                  ),
                  const Text(
                    'Button pushed:',
                  ),
                  Text(
                    ' $_counter',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            CupertinoButton(
              onPressed: _incrementCounter,
              child: const Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}
