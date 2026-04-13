import 'package:flutter/cupertino.dart';
import 'view0.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Cupertino Navigation Demo',
      home: View0(),
    );
  }
}
