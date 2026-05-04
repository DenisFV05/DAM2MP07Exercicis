import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'view_widget.dart';

// https://pub.dev/packages/flutter_cupertino_desktop_kit

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppData()..initializeDatabase(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CDKApp(
        defaultAppearance: "system", // system, light, dark
        defaultColor: "systemBlue",
        child: ViewWidget());
  }
}
