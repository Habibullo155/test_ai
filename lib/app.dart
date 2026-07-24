import 'package:flutter/material.dart';

import 'screens/chat_screen.dart';
import 'state/chat_store.dart';

class GlassChatApp extends StatefulWidget {
  const GlassChatApp({super.key});

  @override
  State<GlassChatApp> createState() => _GlassChatAppState();
}

class _GlassChatAppState extends State<GlassChatApp> {
  final ChatStore _store = ChatStore();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _store.init().then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Glass Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Roboto', //  Correct: Pass it directly to ThemeData
        scaffoldBackgroundColor: const Color(0xFF0B0F1E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.dark,
        ),
      ),

      home: _ready
          ? ChatScreen(store: _store)
          : const Scaffold(
              backgroundColor: Color(0xFF0B0F1E),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
              ),
            ),
    );
  }
}
