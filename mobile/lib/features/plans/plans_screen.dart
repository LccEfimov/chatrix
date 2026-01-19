import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  static const plans = [
    PlanCardData('ZERO', 'Zero', 'Free', 'Default on signup'),
    PlanCardData('CORE', 'Core', '150 ₽ / month', 'Entry plan'),
    PlanCardData('START', 'Start', '500 ₽ / 3 months', 'Starter bundle'),
    PlanCardData('PRIME', 'Prime', '800 ₽ / 3 months', 'Higher limits'),
    PlanCardData('ADVANCED', 'Advanced', '1100 ₽ / 3 months', 'Pro usage'),
    PlanCardData('STUDIO', 'Studio', '1400 ₽ / 3 months', 'Creator suite'),
    PlanCardData('BUSINESS', 'Business', '2000 ₽ / 3 months', 'Team ready'),
    PlanCardData('BLD_DIALOGUE', 'Builder • Dialogue', 'from 700 ₽', 'Text + Audio'),
    PlanCardData('BLD_MEDIA', 'Builder • Media', 'from 700 ₽', 'Media tools'),
    PlanCardData('BLD_DOCS', 'Builder • Docs', 'from 700 ₽', 'Docs & files'),
    PlanCardData('VIP', 'VIP • Signature', '15000 ₽', 'One-time'),
    PlanCardData('DEV', 'Developer • Gate', '5000 ₽ / year', 'DevBox access'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ChatriX • Plans',
      body: ListView(
        children: [
          Text(
            'Plans & Entitlements',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pick a plan to unlock limits, tools, and sections.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final plan in plans) PlanCard(plan: plan),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Policy engine',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Limits and entitlements are enforced on the server for every request.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: const AppPrimaryButton(
        label: 'Select plan',
        icon: Icons.check_circle_outline,
        onPressed: null,
      ),
    );
  }
}

class PlanCardData {
  const PlanCardData(this.code, this.name, this.price, this.tagline);

  final String code;
  final String name;
  final String price;
  final String tagline;
}

class PlanCard extends StatelessWidget {
  const PlanCard({super.key, required this.plan});

  final PlanCardData plan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(plan.code.substring(0, 1)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(plan.price),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    plan.tagline,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
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
