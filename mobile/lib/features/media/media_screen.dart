import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';
import '../../ui/components/entitlement_gate.dart';
import '../plans/plan_entitlements.dart';

class MediaScreen extends StatelessWidget {
  const MediaScreen({super.key});

  static const voiceModes = [
    MediaCardData('Live voice', 'Low-latency sessions', Icons.mic_outlined),
    MediaCardData('Studio voice', 'Prompt-driven voice replies', Icons.headset_mic_outlined),
  ];

  static const videoAvatars = [
    MediaCardData('Avatar host', 'Photo-to-video persona', Icons.face_retouching_natural),
    MediaCardData('Scripted presenter', 'Prompt-based narration', Icons.smart_display_outlined),
  ];

  static const imageTools = [
    MediaCardData('Image generation', 'Create branded visuals', Icons.image_outlined),
    MediaCardData('Style remix', 'Apply visual styles', Icons.auto_awesome_motion_outlined),
  ];

  static const videoTools = [
    MediaCardData('Video generation', 'Storyboard to motion', Icons.videocam_outlined),
    MediaCardData('Avatar video', 'Talking head clips', Icons.movie_creation_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ChatriX • Media',
      body: ListView(
        children: [
          Text(
            'Voice, Video & Tools',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Launch live voice, manage avatar sessions, and queue media jobs.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: 'Quick actions'),
          const SizedBox(height: AppSpacing.md),
          EntitlementGate(
            entitlementKey: PlanEntitlementKeys.voice,
            lockedTitle: 'Voice access locked',
            lockedSubtitle: 'Upgrade your plan to unlock voice sessions.',
            child: AppCard(
              onTap: () => context.push('/media/voice'),
              child: const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  child: Icon(Icons.mic_outlined),
                ),
                title: Text('Voice sessions'),
                subtitle: Text('Start or resume a live voice session.'),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          EntitlementGate(
            entitlementKey: PlanEntitlementKeys.toolsAudio,
            lockedTitle: 'Audio tools locked',
            lockedSubtitle: 'Upgrade your plan to unlock audio tools.',
            child: AppCard(
              onTap: () => context.push('/media/audio-tools'),
              child: const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  child: Icon(Icons.graphic_eq_outlined),
                ),
                title: Text('Audio tools'),
                subtitle: Text('Transcribe, clean up, and enhance audio.'),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: 'Voice live'),
          const SizedBox(height: AppSpacing.md),
          for (final item in voiceModes)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: EntitlementGate(
                entitlementKey: PlanEntitlementKeys.voice,
                lockedTitle: 'Voice access locked',
                lockedSubtitle: 'Upgrade your plan to unlock voice sessions.',
                child: MediaCard(item: item),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: 'Video avatars'),
          const SizedBox(height: AppSpacing.md),
          for (final item in videoAvatars)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: EntitlementGate(
                entitlementKey: PlanEntitlementKeys.video,
                lockedTitle: 'Video access locked',
                lockedSubtitle: 'Upgrade your plan to unlock video avatars.',
                child: MediaCard(item: item),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: 'Image tools'),
          const SizedBox(height: AppSpacing.md),
          for (final item in imageTools)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: EntitlementGate(
                entitlementKey: PlanEntitlementKeys.toolsImage,
                lockedTitle: 'Image tools locked',
                lockedSubtitle: 'Upgrade your plan to unlock image tools.',
                child: MediaCard(item: item),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: 'Video tools'),
          const SizedBox(height: AppSpacing.md),
          for (final item in videoTools)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: EntitlementGate(
                entitlementKey: PlanEntitlementKeys.toolsVideo,
                lockedTitle: 'Video tools locked',
                lockedSubtitle: 'Upgrade your plan to unlock video tools.',
                child: MediaCard(item: item),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          EntitlementGate(
            entitlementKey: PlanEntitlementKeys.video,
            lockedTitle: 'Media sessions locked',
            lockedSubtitle: 'Upgrade your plan to start media sessions.',
            child: AppPrimaryButton(
              label: 'Start media session',
              icon: Icons.add_circle_outline,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

class MediaCardData {
  const MediaCardData(this.title, this.subtitle, this.icon);

  final String title;
  final String subtitle;
  final IconData icon;
}

class MediaCard extends StatelessWidget {
  const MediaCard({super.key, required this.item});

  final MediaCardData item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(item.icon),
        ),
        title: Text(item.title),
        subtitle: Text(item.subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
