import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';
import '../../ui/components/entitlement_gate.dart';
import '../plans/plan_entitlements.dart';

class VideoToolsScreen extends StatelessWidget {
  const VideoToolsScreen({super.key});

  static const tools = [
    VideoTool(
      title: 'Storyboard builder',
      subtitle: 'Turn scenes into a shot list with timing hints.',
      icon: Icons.view_carousel_outlined,
    ),
    VideoTool(
      title: 'Motion templates',
      subtitle: 'Pick a motion style and auto-fit your script.',
      icon: Icons.movie_filter_outlined,
    ),
    VideoTool(
      title: 'Avatar overlays',
      subtitle: 'Add a presenter layer on top of footage.',
      icon: Icons.face_retouching_natural,
    ),
    VideoTool(
      title: 'Video polish',
      subtitle: 'Upscale, stabilize, and balance color quickly.',
      icon: Icons.auto_fix_high_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ChatriX • Video Tools',
      body: ListView(
        children: [
          Text(
            'Video Tools',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Queue enhancement jobs and build storyboards for polished videos.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final tool in tools)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: EntitlementGate(
                entitlementKey: PlanEntitlementKeys.toolsVideo,
                lockedTitle: 'Video tools locked',
                lockedSubtitle: 'Upgrade your plan to unlock video tools.',
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

class VideoTool {
  const VideoTool({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
