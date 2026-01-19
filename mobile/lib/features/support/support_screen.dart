import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const insights = [
    SupportInsight('Daily active minutes', '48 min • last 7 days'),
    SupportInsight('Top tool', 'Text chat (62% of usage)'),
    SupportInsight('Storage usage', '320 MB of 1 GB'),
  ];

  static const supportTopics = [
    SupportTopic('Billing', 'Payments, refunds, and receipts'),
    SupportTopic('Account', 'Login, providers, and security'),
    SupportTopic('AI Tools', 'Chat, media, and files'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ChatriX • Support',
      body: ListView(
        children: [
          Text(
            'Analytics & support',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Track usage trends, then open a ticket if you need help.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Usage insights',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final insight in insights) SupportInsightCard(insight: insight),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Support topics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final topic in supportTopics) SupportTopicCard(topic: topic),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Profile & linked providers',
            icon: Icons.manage_accounts_outlined,
            onPressed: () => context.push('/profile'),
          ),
          const SizedBox(height: AppSpacing.md),
          AppPrimaryButton(
            label: 'Open support ticket',
            icon: Icons.chat_bubble_outline,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class SupportInsight {
  const SupportInsight(this.title, this.detail);

  final String title;
  final String detail;
}

class SupportTopic {
  const SupportTopic(this.title, this.detail);

  final String title;
  final String detail;
}

class SupportInsightCard extends StatelessWidget {
  const SupportInsightCard({super.key, required this.insight});

  final SupportInsight insight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: const Icon(Icons.analytics_outlined),
          ),
          title: Text(insight.title),
          subtitle: Text(insight.detail),
        ),
      ),
    );
  }
}

class SupportTopicCard extends StatelessWidget {
  const SupportTopicCard({super.key, required this.topic});

  final SupportTopic topic;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: const Icon(Icons.support_agent_outlined),
          ),
          title: Text(topic.title),
          subtitle: Text(topic.detail),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
