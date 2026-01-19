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
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  static const providers = [
    'Google',
    'Apple',
    'Yandex',
    'Telegram',
    'Discord',
    'TikTok',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChatriX • Sign in')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Auth & Accounts',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Connect one or more providers to your account.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          for (final provider in providers)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FilledButton(
                onPressed: () {},
                child: Text('Continue with $provider'),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Why link providers?'),
                  SizedBox(height: 8),
                  Text(
                    'Multiple providers improve security and unlock referrals.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
