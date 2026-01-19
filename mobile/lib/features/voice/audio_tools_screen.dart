import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';
import '../../ui/components/entitlement_gate.dart';
import '../plans/plan_entitlements.dart';

class AudioToolsScreen extends StatelessWidget {
  const AudioToolsScreen({super.key});

  static const tools = [
    AudioTool(
      title: 'Speech to text',
      subtitle: 'Turn recordings into searchable transcripts.',
      icon: Icons.keyboard_voice_outlined,
    ),
    AudioTool(
      title: 'Text to speech',
      subtitle: 'Generate narration in multiple voices.',
      icon: Icons.record_voice_over_outlined,
    ),
    AudioTool(
      title: 'Noise cleanup',
      subtitle: 'Reduce background noise and boost clarity.',
      icon: Icons.hearing_outlined,
    ),
    AudioTool(
      title: 'Audio summary',
      subtitle: 'Summarize long recordings into highlights.',
      icon: Icons.spatial_audio_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ChatriX • Audio Tools',
      body: ListView(
        children: [
          Text(
            'Audio Tools',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Process recordings and generate studio-ready audio with a single tap.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final tool in tools)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: EntitlementGate(
                entitlementKey: PlanEntitlementKeys.toolsAudio,
                lockedTitle: 'Audio tools locked',
                lockedSubtitle: 'Upgrade your plan to unlock audio tools.',
                child: AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(tool.icon),
                    ),
                    title: Text(tool.title),
                    subtitle: Text(tool.subtitle),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AudioTool {
  const AudioTool({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
