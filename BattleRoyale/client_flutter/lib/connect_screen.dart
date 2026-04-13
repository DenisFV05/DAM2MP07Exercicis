import 'package:flutter/material.dart';
import 'app_data.dart';

class ConnectScreen extends StatefulWidget {
  final AppData appData;
  const ConnectScreen({super.key, required this.appData});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final _serverController = TextEditingController(text: 'localhost:3000');
  final _nameController = TextEditingController(text: '');
  bool _connecting = false;

  void _connect() {
    setState(() => _connecting = true);
    widget.appData.connect(
      _serverController.text.trim(),
      _nameController.text.trim(),
    );
    // Connection status will be updated via AppData listener
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !widget.appData.isConnected) {
        setState(() => _connecting = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade900,
              Colors.red.shade900.withValues(alpha: 0.5),
              Colors.grey.shade900,
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade800.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '⚔️',
                  style: TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 8),
                const Text(
                  'BATTLE ROYALE',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tanks Edition',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom del jugador',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _serverController,
                  decoration: InputDecoration(
                    labelText: 'Servidor',
                    prefixIcon: const Icon(Icons.dns),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _connecting ? null : _connect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _connecting
                        ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white,
                            ),
                          )
                        : const Text(
                            'CONNECTAR',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
