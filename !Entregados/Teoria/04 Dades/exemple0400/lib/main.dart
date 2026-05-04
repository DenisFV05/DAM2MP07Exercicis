import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_main.dart';
import 'app_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter JSON Editor',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const ViewMain(),
      ),
    );
  }
}
