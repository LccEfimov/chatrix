import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';

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
          _SectionHeader(title: 'Voice live'),
          const SizedBox(height: AppSpacing.md),
          for (final item in voiceModes) MediaCard(item: item),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: 'Video avatars'),
          const SizedBox(height: AppSpacing.md),
          for (final item in videoAvatars) MediaCard(item: item),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: 'Image tools'),
          const SizedBox(height: AppSpacing.md),
          for (final item in imageTools) MediaCard(item: item),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: 'Video tools'),
          const SizedBox(height: AppSpacing.md),
          for (final item in videoTools) MediaCard(item: item),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Start media session',
            icon: Icons.add_circle_outline,
            onPressed: () {},
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
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
      ),
    );
  }
}
