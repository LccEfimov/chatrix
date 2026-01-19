import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';
import '../../ui/components/app_text_field.dart';
import '../../ui/components/entitlement_gate.dart';
import '../plans/plan_entitlements.dart';

class DocsScreen extends StatefulWidget {
  const DocsScreen({super.key});

  @override
  State<DocsScreen> createState() => _DocsScreenState();
}

class _DocsScreenState extends State<DocsScreen> {
  int _selectedIndex = 0;

  static const supportedFormats = [
    'txt · md · csv',
    'doc · docx · pdf',
    'xls · xlsx · ods',
    'epub · mobi · fb2',
  ];

  static const docs = [
    DocInsight(
      title: 'Project brief',
      filename: 'brief.pdf',
      preview:
          'Goal: craft a premium onboarding for ChatriX with crisp micro-interactions and a clear upgrade path.',
      summary: [
        'Premium onboarding tone established in first 3 screens.',
        'Key risks: subscription messaging and provider linking.',
        'Recommended CTA: “Start with ZERO, upgrade later”.',
      ],
      questions: [
        DocQuestion('What is the primary goal?', 'Ship a premium onboarding flow.'),
        DocQuestion('Any blockers?', 'Subscription messaging requires legal review.'),
      ],
    ),
    DocInsight(
      title: 'Roadmap export',
      filename: 'roadmap.csv',
      preview:
          'Milestone 09 covers storage UX: file upload, parsing status, and docs analysis.',
      summary: [
        'Files screen must show quota usage and recent uploads.',
        'Docs screen focuses on preview, summary, and Q&A.',
        'Server remains the source of truth for entitlements.',
      ],
      questions: [
        DocQuestion('What is due next?', 'Finalize Files and Docs screens.'),
        DocQuestion('Which teams?', 'Mobile + backend coordination.'),
      ],
    ),
    DocInsight(
      title: 'Research notes',
      filename: 'notes.md',
      preview:
          'Users expect instant previews with fallback summary cards while parsing runs.',
      summary: [
        'Instant preview reduces perceived latency.',
        'Show parsing progress with clear status chips.',
        'Offer 1-tap QA prompts for common queries.',
      ],
      questions: [
        DocQuestion('Why preview?', 'It reduces time-to-value.'),
        DocQuestion('UX expectation?', 'Status chips + quick answers.'),
      ],
    ),
  ];

  final TextEditingController _questionController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = docs[_selectedIndex];
    return AppScaffold(
      title: 'ChatriX • Docs',
      actions: [
        IconButton(
          onPressed: () => context.go('/docs'),
          icon: const Icon(Icons.folder_open_outlined),
          tooltip: 'Files',
        ),
      ],
      body: ListView(
        children: [
          Text(
            'Docs insights',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pick a file, preview its content, and run AI summaries or Q&A workflows.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Selected file',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final entry in docs.indexed)
                ChoiceChip(
                  selected: _selectedIndex == entry.$1,
                  label: Text(entry.$2.title),
                  onSelected: (_) {
                    setState(() {
                      _selectedIndex = entry.$1;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selected.filename,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  selected.preview,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final format in supportedFormats)
                      Chip(
                        label: Text(format),
                        avatar: const Icon(Icons.description_outlined),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'AI summary',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final bullet in selected.summary)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(bullet)),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Generated 3 minutes ago',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Ask a question',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Question about the document',
            hintText: 'e.g. Summarize key risks',
            controller: _questionController,
          ),
          const SizedBox(height: AppSpacing.sm),
          EntitlementGate(
            entitlementKey: PlanEntitlementKeys.docs,
            lockedTitle: 'Docs access locked',
            lockedSubtitle: 'Upgrade your plan to run AI Q&A on documents.',
            child: AppPrimaryButton(
              label: 'Ask AI',
              icon: Icons.search,
              onPressed: () {},
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Recent answers',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final item in selected.questions)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.question,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.answer,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DocInsight {
  const DocInsight({
    required this.title,
    required this.filename,
    required this.preview,
    required this.summary,
    required this.questions,
  });

  final String title;
  final String filename;
  final String preview;
  final List<String> summary;
  final List<DocQuestion> questions;
}

class DocQuestion {
  const DocQuestion(this.question, this.answer);

  final String question;
  final String answer;
}
