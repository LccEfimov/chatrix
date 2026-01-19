import 'package:flutter/material.dart';

void main() {
  runApp(const ChatriXApp());
}

class ChatriXApp extends StatelessWidget {
  const ChatriXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatriX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChatriX')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Skeleton is up.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
