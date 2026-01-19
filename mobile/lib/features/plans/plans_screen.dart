import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';
import 'plan_entitlements.dart';
import 'plan_models.dart';
import 'plan_providers.dart';

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  static const planTaglines = {
    'ZERO': 'Default plan with basic access.',
    'CORE': 'Entry plan for everyday prompts.',
    'START': 'Starter bundle for 3-month flow.',
    'PRIME': 'More models and higher quotas.',
    'ADVANCED': 'Advanced tool limits for creators.',
    'STUDIO': 'Studio-grade workflows for teams.',
    'BUSINESS': 'Business-ready usage with scale.',
    'BLD_DIALOGUE': 'Build a custom text + audio stack.',
    'BLD_MEDIA': 'Compose image + video + audio tools.',
    'BLD_DOCS': 'Document-first workflows and storage.',
    'VIP': 'Signature tier with maximum access.',
    'DEV': 'Developer access with DevBox add-ons.',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(planActivationProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to activate plan. Try again.')),
        );
      } else if (previous?.isLoading == true && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan updated successfully.')),
        );
      }
    });

    final plansAsync = ref.watch(plansProvider);
    final subscriptionAsync = ref.watch(subscriptionProvider);
    final activationState = ref.watch(planActivationProvider);

    return AppScaffold(
      title: 'ChatriX • Plans',
      body: ListView(
        children: [
          Text(
            'Plans & entitlements',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Review your current plan, usage limits, and upgrade options.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          _CurrentPlanSection(subscriptionAsync: subscriptionAsync),
          const SizedBox(height: AppSpacing.lg),
          _FeatureAccessSection(subscriptionAsync: subscriptionAsync),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Upgrade plans',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          plansAsync.when(
            data: (plans) {
              final currentPlanCode = subscriptionAsync.valueOrNull?.code;
              return Column(
                children: [
                  for (final plan in plans)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: PlanCard(
                        plan: plan,
                        tagline: planTaglines[plan.code] ?? 'Flexible access.',
                        isCurrent: plan.code == currentPlanCode,
                        isBusy: activationState.isLoading,
                        onSelect: activationState.isLoading
                            ? null
                            : () {
                                ref
                                    .read(planActivationProvider.notifier)
                                    .activatePlan(plan.code);
                              },
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unable to load plans',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Check your connection and try again.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AppPrimaryButton(
        label: 'Refresh plans',
        icon: Icons.refresh,
        onPressed: () {
          ref.invalidate(plansProvider);
          ref.invalidate(subscriptionProvider);
        },
      ),
    );
  }
}

class _CurrentPlanSection extends StatelessWidget {
  const _CurrentPlanSection({required this.subscriptionAsync});

  final AsyncValue<Plan> subscriptionAsync;

  @override
  Widget build(BuildContext context) {
    return subscriptionAsync.when(
      data: (plan) {
        final limitEntries = plan.limitsMap.entries.toList();
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My plan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _PlanChip(label: plan.name),
                  _PlanChip(label: plan.code),
                  _PlanChip(label: _priceLabel(plan)),
                  if (plan.periodMonths != null)
                    _PlanChip(label: '${plan.periodMonths} months'),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Limits',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (limitEntries.isEmpty)
                Text(
                  'No limits configured yet for this plan.',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              else
                Column(
                  children: [
                    for (final entry in limitEntries)
                      _LimitRow(
                        title: _limitLabel(entry.key),
                        value: _formatLimitValue(entry.key, entry.value),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
      loading: () => const AppCard(
        child: SizedBox(
          height: 140,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unable to load subscription',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Sign in again or refresh to retry.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureAccessSection extends StatelessWidget {
  const _FeatureAccessSection({required this.subscriptionAsync});

  final AsyncValue<Plan> subscriptionAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feature access',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        subscriptionAsync.when(
          data: (plan) {
            if (plan.entitlements.isEmpty) {
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entitlements not configured',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Server has not provided entitlements for this plan yet.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }

            final statuses = buildFeatureGateStatuses(plan.entitlementsMap);
            return Column(
              children: [
                for (final status in statuses)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          status.isEnabled
                              ? Icons.check_circle_outline
                              : Icons.lock_outline,
                          color: status.isEnabled
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                        title: Text(status.definition.label),
                        subtitle: Text(status.definition.description),
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unable to load entitlements',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Refresh to sync your feature access.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.tagline,
    required this.isCurrent,
    required this.isBusy,
    required this.onSelect,
  });

  final Plan plan;
  final String tagline;
  final bool isCurrent;
  final bool isBusy;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (isCurrent)
                      Chip(
                        label: const Text('Current'),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _priceLabel(plan),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  tagline,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: isCurrent || isBusy ? null : onSelect,
                        child: isBusy
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(isCurrent ? 'Active' : 'Select'),
                      ),
                    ),
                    if (plan.periodMonths != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text('${plan.periodMonths} mo'),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}

class _LimitRow extends StatelessWidget {
  const _LimitRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

String _priceLabel(Plan plan) {
  if (plan.priceRub == 0) {
    return 'Free';
  }
  final base = plan.code.startsWith('BLD_') ? 'from ' : '';
  final price = '${plan.priceRub} ₽';
  if (plan.periodMonths == null) {
    return '$base$price';
  }
  return '$base$price / ${plan.periodMonths} months';
}

String _limitLabel(String key) {
  const labels = {
    'storage_bytes': 'Storage quota',
    'chat_messages_per_day': 'Chat messages per day',
    'voice_minutes_per_day': 'Voice minutes per day',
    'video_minutes_per_day': 'Video minutes per day',
    'sections_free': 'Free sections',
  };
  return labels[key] ?? key.replaceAll('_', ' ');
}

String _formatLimitValue(String key, int value) {
  if (key.contains('bytes')) {
    return _formatBytes(value);
  }
  return value.toString();
}

String _formatBytes(int bytes) {
  const kb = 1024;
  const mb = kb * 1024;
  const gb = mb * 1024;

  if (bytes >= gb) {
    return '${(bytes / gb).toStringAsFixed(1)} GB';
  }
  if (bytes >= mb) {
    return '${(bytes / mb).toStringAsFixed(1)} MB';
  }
  if (bytes >= kb) {
    return '${(bytes / kb).toStringAsFixed(1)} KB';
  }
  return '$bytes B';
}
