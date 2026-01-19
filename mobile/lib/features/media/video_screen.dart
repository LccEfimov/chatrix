import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';
import '../../ui/components/app_text_field.dart';
import '../../ui/components/entitlement_gate.dart';
import '../plans/plan_entitlements.dart';
import '../plans/plan_models.dart';
import '../plans/plan_providers.dart';

class VideoScreen extends ConsumerStatefulWidget {
  const VideoScreen({super.key});

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> {
  final _titleController = TextEditingController();
  final _promptController = TextEditingController();
  String _selectedMediaId = mediaPresets.first.id;
  String _selectedVoiceId = voicePresets.first.id;

  @override
  void dispose() {
    _titleController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return AppScaffold(
      title: 'ChatriX • Video',
      body: ListView(
        children: [
          Text(
            'Video Sessions',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create short-form avatar clips or longer scenes with guided prompts.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          _VideoLimitCard(subscriptionAsync: subscriptionAsync),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Recent video chats',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final chat in videoChats)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: EntitlementGate(
                entitlementKey: PlanEntitlementKeys.video,
                lockedTitle: 'Video locked',
                lockedSubtitle: 'Upgrade your plan to unlock video sessions.',
                child: VideoChatCard(chat: chat),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Create a video chat',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          EntitlementGate(
            entitlementKey: PlanEntitlementKeys.video,
            lockedTitle: 'Video locked',
            lockedSubtitle: 'Upgrade your plan to unlock video sessions.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Session title',
                  hintText: 'Weekly recap avatar update',
                  controller: _titleController,
                ),
                const SizedBox(height: AppSpacing.sm),
                _SelectionCard(
                  label: 'Media style',
                  value: _selectedMediaId,
                  options: [
                    for (final preset in mediaPresets)
                      DropdownMenuItem(
                        value: preset.id,
                        child: Text(preset.title),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedMediaId = value;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _SelectionCard(
                  label: 'Voice preset',
                  value: _selectedVoiceId,
                  options: [
                    for (final preset in voicePresets)
                      DropdownMenuItem(
                        value: preset.id,
                        child: Text(preset.title),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedVoiceId = value;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  label: 'Prompt',
                  hintText: 'Summarize the key wins, add a call to action, 10 sec.',
                  controller: _promptController,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppPrimaryButton(
                  label: 'Generate video chat',
                  icon: Icons.auto_awesome_outlined,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoLimitCard extends StatelessWidget {
  const _VideoLimitCard({required this.subscriptionAsync});

  final AsyncValue<Plan> subscriptionAsync;

  static const _topPlans = {'VIP', 'DEV', 'BUSINESS'};

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: subscriptionAsync.when(
        data: (plan) {
          final isUnlimited = _topPlans.contains(plan.code);
          final limitLabel =
              isUnlimited ? 'Unlimited demo time' : '10 sec demo clips for starter plans';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current plan: ${plan.name}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Demo length: $limitLabel',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Long-form renders are available on top plans and builder media bundles.',
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
              'Loading plan details…',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        error: (error, stackTrace) => Text(
          'Unable to load plan details yet.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<DropdownMenuItem<String>> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: DropdownButtonFormField<String>(
        value: value,
        items: options,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class VideoChat {
  const VideoChat({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String status;
  final IconData icon;
}

const videoChats = [
  VideoChat(
    title: 'Morning update avatar',
    subtitle: 'Prompt + portrait upload',
    status: 'Draft',
    icon: Icons.face_retouching_natural,
  ),
  VideoChat(
    title: 'Product demo reel',
    subtitle: 'Storyboard render',
    status: 'Rendering',
    icon: Icons.movie_filter_outlined,
  ),
  VideoChat(
    title: 'Founder voiceover clip',
    subtitle: 'Voice + B-roll',
    status: 'Ready',
    icon: Icons.smart_display_outlined,
  ),
];

class VideoChatCard extends StatelessWidget {
  const VideoChatCard({super.key, required this.chat});

  final VideoChat chat;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(chat.icon),
        ),
        title: Text(chat.title),
        subtitle: Text(chat.subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              chat.status,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }
}

class MediaPreset {
  const MediaPreset({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}

const mediaPresets = [
  MediaPreset(id: 'avatar_photo', title: 'Avatar from photo'),
  MediaPreset(id: 'avatar_video', title: 'Avatar from video'),
  MediaPreset(id: 'scripted_scene', title: 'Scripted scene'),
];

class VoicePreset {
  const VoicePreset({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}

const voicePresets = [
  VoicePreset(id: 'vivid', title: 'Vivid'),
  VoicePreset(id: 'calm', title: 'Calm'),
  VoicePreset(id: 'studio', title: 'Studio'),
];
