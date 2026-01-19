import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';

class ReferralsScreen extends StatelessWidget {
  const ReferralsScreen({super.key});

  static const tiers = [
    ReferralTier('Level 1', 'Core 3% • Start 5% • Prime 5.5%'),
    ReferralTier('Level 2', 'Core 2.7% • Start 4.5% • Prime 5.0%'),
    ReferralTier('Level 3', 'Core 2.4% • Start 4.0% • Prime 4.5%'),
  ];

  static const rewards = [
    ReferralReward('Invitee upgraded to Start', 'Level 1 • 1500 ₽'),
    ReferralReward('Invitee upgraded to Prime', 'Level 2 • 2000 ₽'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ChatriX • Referrals',
      body: ListView(
        children: [
          Text(
            'Referral Program',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Earn rewards when your referrals activate paid plans and link two providers.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your link',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                const SelectableText('https://chatrix.app/r/your-code'),
                const SizedBox(height: AppSpacing.md),
                const AppPrimaryButton(
                  label: 'Copy link',
                  icon: Icons.copy,
                  onPressed: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Tier highlights',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final tier in tiers) ReferralTierCard(tier: tier),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Recent rewards',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final reward in rewards) ReferralRewardCard(reward: reward),
        ],
      ),
    );
  }
}

class ReferralTier {
  const ReferralTier(this.title, this.detail);

  final String title;
  final String detail;
}

class ReferralReward {
  const ReferralReward(this.title, this.detail);

  final String title;
  final String detail;
}

class ReferralTierCard extends StatelessWidget {
  const ReferralTierCard({super.key, required this.tier});

  final ReferralTier tier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: const Icon(Icons.trending_up),
          ),
          title: Text(tier.title),
          subtitle: Text(tier.detail),
        ),
      ),
    );
  }
}

class ReferralRewardCard extends StatelessWidget {
  const ReferralRewardCard({super.key, required this.reward});

  final ReferralReward reward;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            child: const Icon(Icons.redeem),
          ),
          title: Text(reward.title),
          subtitle: Text(reward.detail),
        ),
      ),
    );
  }
}
