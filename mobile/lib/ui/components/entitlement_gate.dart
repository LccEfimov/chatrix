import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/plans/plan_providers.dart';
import '../../theme/app_spacing.dart';
import 'app_card.dart';

class EntitlementGate extends ConsumerWidget {
  const EntitlementGate({
    super.key,
    required this.entitlementKey,
    required this.child,
    required this.lockedTitle,
    required this.lockedSubtitle,
    this.lockedIcon = Icons.lock_outline,
  });

  final String entitlementKey;
  final Widget child;
  final String lockedTitle;
  final String lockedSubtitle;
  final IconData lockedIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(entitlementStateProvider);
    if (!state.isReady) {
      return child;
    }

    if (state.isEnabled(entitlementKey)) {
      return child;
    }

    return LockedFeatureCard(
      title: lockedTitle,
      subtitle: lockedSubtitle,
      icon: lockedIcon,
    );
  }
}

class LockedFeatureCard extends StatelessWidget {
  const LockedFeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
