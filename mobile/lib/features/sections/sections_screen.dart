import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';

class SectionsScreen extends StatelessWidget {
  const SectionsScreen({super.key});

  static const categories = [
    SectionCategory('Hobby', 'Personal experiments and creative routines.'),
    SectionCategory('Study', 'Learning paths, notes, and revision flows.'),
    SectionCategory('Work', 'Professional workflows and deliverables.'),
  ];

  static const checklist = [
    SectionChecklistItem('Brief required', 'Complete the 10-point section brief.'),
    SectionChecklistItem('3 sections free', 'Across Hobby, Study, and Work combined.'),
    SectionChecklistItem('300 ₽ / 3 months', 'Per additional section above the free quota.'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ChatriX • Sections',
      body: ListView(
        children: [
          Text(
            'Sections Builder',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create custom Hobby, Study, and Work spaces from structured briefs.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Categories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final category in categories) SectionCategoryCard(category: category),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Requirements',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final item in checklist) SectionChecklistCard(item: item),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Start new section',
            icon: Icons.add_circle_outline,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class SectionCategory {
  const SectionCategory(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

class SectionChecklistItem {
  const SectionChecklistItem(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

class SectionCategoryCard extends StatelessWidget {
  const SectionCategoryCard({super.key, required this.category});

  final SectionCategory category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: const Icon(Icons.dashboard_customize_outlined),
          ),
          title: Text(category.title),
          subtitle: Text(category.subtitle),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

class SectionChecklistCard extends StatelessWidget {
  const SectionChecklistCard({super.key, required this.item});

  final SectionChecklistItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: const Icon(Icons.rule_folder_outlined),
          ),
          title: Text(item.title),
          subtitle: Text(item.subtitle),
        ),
      ),
    );
  }
}
