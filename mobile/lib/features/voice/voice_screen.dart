import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';
import '../../ui/components/entitlement_gate.dart';
import '../plans/plan_entitlements.dart';
import '../plans/plan_models.dart';
import '../plans/plan_providers.dart';

class VoiceScreen extends ConsumerStatefulWidget {
  const VoiceScreen({super.key});

  @override
  ConsumerState<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends ConsumerState<VoiceScreen> {
  bool _isLive = false;
  String _selectedVoiceId = voicePresets.first.id;

  @override
  Widget build(BuildContext context) {
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return AppScaffold(
      title: 'ChatriX • Voice',
      body: ListView(
        children: [
          Text(
            'Voice Sessions',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start low-latency conversations with curated voices and clear usage limits.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PlanLimitCard(subscriptionAsync: subscriptionAsync),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Session controls',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          EntitlementGate(
            entitlementKey: PlanEntitlementKeys.voice,
            lockedTitle: 'Voice locked',
            lockedSubtitle: 'Upgrade your plan to unlock voice sessions.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _VoiceStatusCard(isLive: _isLive),
                const SizedBox(height: AppSpacing.sm),
                AppPrimaryButton(
                  label: _isLive ? 'Stop session' : 'Start session',
                  icon: _isLive ? Icons.stop_circle_outlined : Icons.play_circle_outline,
                  onPressed: () {
                    setState(() {
                      _isLive = !_isLive;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Choose your voice',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          EntitlementGate(
            entitlementKey: PlanEntitlementKeys.voice,
            lockedTitle: 'Voices locked',
            lockedSubtitle: 'Upgrade your plan to access premium voices.',
            child: Column(
              children: [
                for (final preset in voicePresets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: VoicePresetCard(
                      preset: preset,
                      isSelected: preset.id == _selectedVoiceId,
                      onTap: () {
                        setState(() {
                          _selectedVoiceId = preset.id;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanLimitCard extends StatelessWidget {
  const _PlanLimitCard({required this.subscriptionAsync});

  final AsyncValue<Plan> subscriptionAsync;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: subscriptionAsync.when(
        data: (plan) {
          final voiceLimit = plan.limitsMap['voice_minutes_per_day'];
          final limitLabel = voiceLimit == null || voiceLimit == 0
              ? 'Unlimited minutes (no limit configured)'
              : '$voiceLimit min / day';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current plan: ${plan.name}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Daily voice limit: $limitLabel',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Usage is metered per minute across live and studio sessions.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
        loading: () => Row(
          children: [
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Loading plan limits…',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        error: (error, stackTrace) => Text(
          'Unable to load plan limits yet.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _VoiceStatusCard extends StatelessWidget {
  const _VoiceStatusCard({required this.isLive});

  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final statusColor = isLive
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.outline;
    final statusLabel = isLive ? 'Live now' : 'Idle';

    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.2),
            child: Icon(
              isLive ? Icons.waves_outlined : Icons.mic_none_outlined,
              color: statusColor,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VoicePreset {
  const VoicePreset({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
}

const voicePresets = [
  VoicePreset(
    id: 'aurora',
    title: 'Aurora',
    description: 'Warm, expressive narration for long-form responses.',
    icon: Icons.auto_awesome_outlined,
  ),
  VoicePreset(
    id: 'atlas',
    title: 'Atlas',
    description: 'Crisp studio delivery for concise updates.',
    icon: Icons.graphic_eq_outlined,
  ),
];

class VoicePresetCard extends StatelessWidget {
  const VoicePresetCard({
    super.key,
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  final VoicePreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(preset.icon),
        ),
        title: Text(preset.title),
        subtitle: Text(preset.description),
        trailing: Icon(
          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
