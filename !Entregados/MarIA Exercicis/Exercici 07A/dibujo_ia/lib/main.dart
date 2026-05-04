import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;
import 'ai_service.dart';
import 'canvas_painter.dart';
// import 'widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 800),
      center: true,
      title: 'Dibujo Vectorial IA',
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => AIService(),
      child: const DrawingApp(),
    ),
  );
}

class DrawingApp extends StatelessWidget {
  const DrawingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dibujo IA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _chatHistory = [];
  bool _showConfig = false;

  void _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    final aiService = Provider.of<AIService>(context, listen: false);
    
    setState(() {
      _chatHistory.add({"role": "user", "content": text});
      _chatController.clear();
    });
    
    // Scroll
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    aiService.setLoading(true);
    
    final response = await aiService.sendMessage(text, _chatHistory);
    
    if (mounted) {
      setState(() {
        _chatHistory.add({"role": "assistant", "content": response});
      });
      aiService.setLoading(false);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiService = Provider.of<AIService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dibujo IA con MarIA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => setState(() => _showConfig = !_showConfig),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => aiService.clearCanvas(),
            tooltip: 'Borrar todo',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showConfig)
            Container(
              color: Colors.purple.shade50,
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'URL API', border: OutlineInputBorder()),
                      controller: TextEditingController(text: aiService.baseUrl),
                      onChanged: (v) => aiService.baseUrl = v,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'Modelo', border: OutlineInputBorder()),
                      controller: TextEditingController(text: aiService.model),
                      onChanged: (v) => aiService.model = v,
                    ),
                  ),
                ],
              ),
            ),
            
          Expanded(
            child: Row(
              children: [
                // Canvas Area
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey.withOpacity(0.2))],
                    ),
                    child: ClipRect(
                      child: CustomPaint(
                        painter: CanvasPainter(aiService.drawables),
                        child: Container(width: double.infinity, height: double.infinity),
                      ),
                    ),
                  ),
                ),
                
                // Chat Area
                SizedBox(
                  width: 350,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.purple.shade50,
                        child: const Row(
                          children: [
                            Icon(Icons.chat), 
                            SizedBox(width: 8), 
                            Text('Xat amb IA', style: TextStyle(fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(10),
                          itemCount: _chatHistory.length,
                          itemBuilder: (ctx, i) {
                            final msg = _chatHistory[i];
                            final isUser = msg['role'] == 'user';
                            return Align(
                              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(10),
                                constraints: const BoxConstraints(maxWidth: 280),
                                decoration: BoxDecoration(
                                  color: isUser ? Colors.purple.shade100 : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: isUser 
                                  ? Text(msg['content']!) 
                                  : MarkdownBody(data: msg['content']!),
                              ),
                            );
                          },
                        ),
                      ),
                      if (aiService.isLoading)
                        const LinearProgressIndicator(),
                      if (aiService.error != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(aiService.error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _chatController,
                                decoration: const InputDecoration(
                                  hintText: 'Dibuixa un cercle vermell...',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.purple),
                              onPressed: _sendMessage,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
