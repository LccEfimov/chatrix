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
      home: const PlansScreen(),
    );
  }
}

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  static const plans = [
    _PlanCardData('ZERO', 'Zero', 'Free', 'Default on signup'),
    _PlanCardData('CORE', 'Core', '150 ₽ / month', 'Entry plan'),
    _PlanCardData('START', 'Start', '500 ₽ / 3 months', 'Starter bundle'),
    _PlanCardData('PRIME', 'Prime', '800 ₽ / 3 months', 'Higher limits'),
    _PlanCardData('ADVANCED', 'Advanced', '1100 ₽ / 3 months', 'Pro usage'),
    _PlanCardData('STUDIO', 'Studio', '1400 ₽ / 3 months', 'Creator suite'),
    _PlanCardData('BUSINESS', 'Business', '2000 ₽ / 3 months', 'Team ready'),
    _PlanCardData('BLD_DIALOGUE', 'Builder • Dialogue', 'from 700 ₽', 'Text + Audio'),
    _PlanCardData('BLD_MEDIA', 'Builder • Media', 'from 700 ₽', 'Media tools'),
    _PlanCardData('BLD_DOCS', 'Builder • Docs', 'from 700 ₽', 'Docs & files'),
    _PlanCardData('VIP', 'VIP • Signature', '15000 ₽', 'One-time'),
    _PlanCardData('DEV', 'Developer • Gate', '5000 ₽ / year', 'DevBox access'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChatriX • Plans')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Plans & Entitlements',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a plan to unlock limits, tools, and sections.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          for (final plan in plans) _PlanCard(plan: plan),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Policy engine'),
                  SizedBox(height: 8),
                  Text(
                    'Limits and entitlements are enforced on the server for every request.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCardData {
  const _PlanCardData(this.code, this.name, this.price, this.tagline);

  final String code;
  final String name;
  final String price;
  final String tagline;
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});

  final _PlanCardData plan;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(plan.code.substring(0, 1)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(plan.price),
                  const SizedBox(height: 4),
                  Text(
                    plan.tagline,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Select'),
            ),
          ],
        ),
      ),
    );
  }
}
