import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';
import 'referrals_data.dart';
import 'referrals_models.dart';

class ReferralsScreen extends StatefulWidget {
  const ReferralsScreen({super.key});

  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen> {
  int _visibleCount = referralPageSize;

  @override
  Widget build(BuildContext context) {
    final visibleNodes = referralTree.take(_visibleCount).toList();
    return AppScaffold(
      title: 'ChatriX • Referrals',
      body: ListView(
        children: [
          Text(
            'Referral program',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Earn rewards when your referrals activate paid plans and link two providers.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ReferralLinkCard(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Tier highlights',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final tier in referralTiers) ReferralTierCard(tier: tier),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Referral tree (up to $referralMaxDepth levels)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Track active referrals, provider links, and eligibility status.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final node in visibleNodes) ReferralNodeCard(node: node),
          if (_visibleCount < referralTree.length)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: AppPrimaryButton(
                label: 'Load more levels',
                icon: Icons.expand_more,
                onPressed: () {
                  setState(() {
                    _visibleCount = (_visibleCount + referralPageSize)
                        .clamp(0, referralTree.length);
                  });
                },
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Recent rewards',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final reward in referralRewards)
            ReferralRewardCard(reward: reward),
        ],
      ),
    );
  }
}

class _ReferralLinkCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invite link & QR',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_rounded,
                      size: 40,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      referralLink.qrLabel,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share your link',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SelectableText(referralLink.url),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Invite code',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SelectableText(referralLink.code),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              AppPrimaryButton(
                label: 'Copy link',
                icon: Icons.copy,
                onPressed: () {},
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share code'),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
            child: Text('L${tier.level}'),
          ),
          title: Text('Level ${tier.level}'),
          subtitle: Text(tier.detail),
        ),
      ),
    );
  }
}

class ReferralNodeCard extends StatelessWidget {
  const ReferralNodeCard({super.key, required this.node});

  final ReferralNode node;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context, node.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(node.name.substring(0, 1)),
              ),
              title: Text(node.name),
              subtitle: Text('Plan ${node.planCode} • ${node.providerCount} providers'),
              trailing: Text(
                'L${node.level}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _InfoChip(label: _statusLabel(node.status), color: statusColor),
                _InfoChip(label: '${node.totalReferrals} referrals'),
                _InfoChip(label: 'Last active ${_formatDate(node.lastActiveAt)}'),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening chat with ${node.id}')),
                  );
                  context.go('/chat?referral=${node.id}');
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Open chat'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, ReferralNodeStatus status) {
    switch (status) {
      case ReferralNodeStatus.pending:
        return Theme.of(context).colorScheme.outline;
      case ReferralNodeStatus.eligible:
        return Theme.of(context).colorScheme.primary;
      case ReferralNodeStatus.paid:
        return Theme.of(context).colorScheme.tertiary;
    }
  }

  String _statusLabel(ReferralNodeStatus status) {
    switch (status) {
      case ReferralNodeStatus.pending:
        return 'Pending eligibility';
      case ReferralNodeStatus.eligible:
        return 'Eligible for rewards';
      case ReferralNodeStatus.paid:
        return 'Paid out';
    }
  }

  String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: chipColor),
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
          subtitle: Text('${reward.detail} • ${_formatDate(reward.earnedAt)}'),
          trailing: Text(
            '+${reward.amountRub} ₽',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}';
  }
}
