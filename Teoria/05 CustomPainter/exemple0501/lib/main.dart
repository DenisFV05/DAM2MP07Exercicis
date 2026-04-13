import 'package:flutter/cupertino.dart';
import 'view_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Cupertino Clock'),
        ),
        child: SafeArea(
          child: ViewWidget(),
        ),
      ),
    );
  }
}
