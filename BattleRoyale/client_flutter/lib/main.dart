import 'package:flutter/material.dart';
import 'app_data.dart';
import 'connect_screen.dart';
import 'waiting_screen.dart';
import 'play_screen.dart';
import 'results_screen.dart';

void main() {
  runApp(const BattleRoyaleApp());
}

class BattleRoyaleApp extends StatelessWidget {
  const BattleRoyaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BattleRoyale',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final AppData _appData = AppData();

  @override
  void initState() {
    super.initState();
    _appData.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _appData.removeListener(_onDataChanged);
    _appData.disconnect();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_appData.isConnected) {
      return ConnectScreen(appData: _appData);
    }

    switch (_appData.phase) {
      case 'waiting':
        return WaitingScreen(appData: _appData);
      case 'playing':
        return PlayScreen(appData: _appData);
      case 'finished':
        return ResultsScreen(appData: _appData);
      default:
        return WaitingScreen(appData: _appData);
    }
  }
}
