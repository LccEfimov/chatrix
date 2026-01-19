import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';
import '../../ui/components/entitlement_gate.dart';
import '../plans/plan_entitlements.dart';

class SectionsScreen extends StatefulWidget {
  const SectionsScreen({super.key});

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  final List<SectionEntry> _sections = [
    SectionEntry(
      id: 'sec-hobby-001',
      category: SectionCategory.hobby,
      title: 'Morning creative flow',
      goal: 'Plan a daily creative routine with prompts and reflections.',
      uiBlocks: const ['Feed', 'Timeline'],
      isPaid: false,
      createdAt: DateTime(2026, 1, 24),
    ),
    SectionEntry(
      id: 'sec-study-002',
      category: SectionCategory.study,
      title: 'Exam revision hub',
      goal: 'Summarize lecture notes and track weak topics.',
      uiBlocks: const ['Cards', 'Tables'],
      isPaid: false,
      createdAt: DateTime(2026, 1, 25),
    ),
    SectionEntry(
      id: 'sec-work-003',
      category: SectionCategory.work,
      title: 'Client delivery tracker',
      goal: 'Track deliverables, approvals, and deadlines.',
      uiBlocks: const ['Kanban', 'Files'],
      isPaid: false,
      createdAt: DateTime(2026, 1, 26),
    ),
  ];

  SectionCategory _selectedCategory = SectionCategory.hobby;

  @override
  Widget build(BuildContext context) {
    final totalSections = _sections.length;
    final paidNeeded = totalSections >= freeSectionQuota;
    final categorySections = _sections
        .where((section) => section.category == _selectedCategory)
        .toList();

    return AppScaffold(
      title: 'ChatriX • Sections',
      actions: [
        IconButton(
          tooltip: 'Section brief',
          onPressed: () => _openBriefSheet(context, _selectedCategory),
          icon: const Icon(Icons.note_add_outlined),
        ),
      ],
      body: ListView(
        children: [
          Text(
            'Sections Builder',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create Hobby, Study, and Work sections from structured briefs and reusable UI blocks.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionQuotaCard(
            used: totalSections,
            limit: freeSectionQuota,
          ),
          if (paidNeeded) ...[
            const SizedBox(height: AppSpacing.sm),
            const SectionPaywallBanner(),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Categories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: SectionCategory.values
                .map(
                  (category) => ChoiceChip(
                    label: Text(category.label),
                    selected: _selectedCategory == category,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '${_selectedCategory.label} sections',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Run workflows, update briefs, or open outputs from here.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          if (categorySections.isEmpty)
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'No sections yet. Tap “Create new section” to draft a brief.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
            for (final section in categorySections)
              SectionEntryCard(
                section: section,
                onRun: () => _runSection(section),
              ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'UI building blocks',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pick from the component library when preparing the brief.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final block in sectionUiBlocks) SectionUiBlockCard(block: block),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Brief checklist',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final item in sectionChecklist) SectionChecklistCard(item: item),
          const SizedBox(height: AppSpacing.lg),
          EntitlementGate(
            entitlementKey: PlanEntitlementKeys.sections,
            lockedTitle: 'Sections locked',
            lockedSubtitle: 'Upgrade your plan to create new sections.',
            child: AppPrimaryButton(
              label: 'Create new section',
              icon: Icons.add_circle_outline,
              onPressed: () => _openBriefSheet(context, _selectedCategory),
            ),
          ),
        ],
      ),
    );
  }

  void _runSection(SectionEntry section) {
    setState(() {
      section.lastRunAt = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Running workflow for ${section.title}')),
    );
  }

  Future<void> _openBriefSheet(BuildContext context, SectionCategory category) async {
    final result = await showModalBottomSheet<SectionBriefResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SectionBriefSheet(
        category: category,
        totalSections: _sections.length,
      ),
    );
    if (!mounted || result == null) {
      return;
    }

    if (result.requiresPayment) {
      final shouldProceed = await _showPaywallDialog(context);
      if (!shouldProceed) {
        return;
      }
    }

    setState(() {
      _sections.add(
        SectionEntry(
          id: 'sec-${DateTime.now().millisecondsSinceEpoch}',
          category: category,
          title: result.brief.title,
          goal: result.brief.goal,
          uiBlocks: result.brief.uiBlocks,
          isPaid: result.requiresPayment,
          createdAt: DateTime.now(),
          note: result.requiresPayment
              ? 'Payment required: 300 ₽ / 3 months'
              : null,
        ),
      );
    });
  }

  Future<bool> _showPaywallDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Additional section paywall'),
            content: const Text(
              'You have used the 3 free sections. Creating another section adds a 300 ₽ / 3 months fee.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm & create'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class SectionBriefSheet extends StatefulWidget {
  const SectionBriefSheet({
    super.key,
    required this.category,
    required this.totalSections,
  });

  final SectionCategory category;
  final int totalSections;

  @override
  State<SectionBriefSheet> createState() => _SectionBriefSheetState();
}

class _SectionBriefSheetState extends State<SectionBriefSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _goalController = TextEditingController();
  final _scenariosController = TextEditingController();
  final _inputsController = TextEditingController();
  final _outputsController = TextEditingController();
  final _aiOperationsController = TextEditingController();
  final _constraintsController = TextEditingController();
  final _updatePolicyController = TextEditingController();
  final _limitsController = TextEditingController();

  final Set<String> _selectedBlocks = {};

  @override
  void dispose() {
    _titleController.dispose();
    _goalController.dispose();
    _scenariosController.dispose();
    _inputsController.dispose();
    _outputsController.dispose();
    _aiOperationsController.dispose();
    _constraintsController.dispose();
    _updatePolicyController.dispose();
    _limitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requiresPayment = widget.totalSections >= freeSectionQuota;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              'Section brief • ${widget.category.label}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Complete the 10-point brief to create a new section.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildField(
              controller: _titleController,
              label: '1) Section name',
              hint: 'Example: Morning creative flow',
            ),
            _buildField(
              controller: _goalController,
              label: '2) Goal',
              hint: 'Describe what outcome the section should produce.',
              maxLines: 2,
            ),
            _buildField(
              controller: _scenariosController,
              label: '3) User scenarios (one per line)',
              hint: 'Draft ideas\nWeekly review\nFeedback loop',
              maxLines: 3,
            ),
            _buildField(
              controller: _inputsController,
              label: '4) Inputs (one per line)',
              hint: 'Text notes\nLinks\nFiles',
              maxLines: 3,
            ),
            _buildField(
              controller: _outputsController,
              label: '5) Outputs (one per line)',
              hint: 'Checklist\nSummary\nExport',
              maxLines: 3,
            ),
            _buildField(
              controller: _aiOperationsController,
              label: '6) AI operations (one per line)',
              hint: 'Summarize\nGenerate plan\nClassify topics',
              maxLines: 3,
            ),
            _buildField(
              controller: _constraintsController,
              label: '7) Constraints and tone',
              hint: 'Formal tone, avoid sensitive topics.',
              maxLines: 2,
              isRequired: false,
            ),
            _buildField(
              controller: _updatePolicyController,
              label: '8) Updates',
              hint: 'Manual or weekly refresh every Monday.',
              maxLines: 2,
              isRequired: false,
            ),
            Text(
              '9) UI blocks',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: sectionUiBlocks
                  .map(
                    (block) => FilterChip(
                      label: Text(block.title),
                      selected: _selectedBlocks.contains(block.title),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedBlocks.add(block.title);
                          } else {
                            _selectedBlocks.remove(block.title);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildField(
              controller: _limitsController,
              label: '10) Limits',
              hint: 'Time, budget, or quality constraints.',
              maxLines: 2,
              isRequired: false,
            ),
            const SizedBox(height: AppSpacing.md),
            if (requiresPayment) const SectionPaywallBanner(),
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(
              label: requiresPayment ? 'Create with fee' : 'Create section',
              icon: Icons.check_circle_outline,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextFormField(
        key: ValueKey(label),
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        validator: (value) {
          if (!isRequired) {
            return null;
          }
          if (value == null || value.trim().isEmpty) {
            return 'Required';
          }
          return null;
        },
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBlocks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one UI block.')),
      );
      return;
    }

    final requiresPayment = widget.totalSections >= freeSectionQuota;

    Navigator.of(context).pop(
      SectionBriefResult(
        brief: SectionBriefData(
          title: _titleController.text.trim(),
          goal: _goalController.text.trim(),
          scenarios: _splitLines(_scenariosController.text),
          inputs: _splitLines(_inputsController.text),
          outputs: _splitLines(_outputsController.text),
          aiOperations: _splitLines(_aiOperationsController.text),
          constraints: _constraintsController.text.trim(),
          updatePolicy: _updatePolicyController.text.trim(),
          uiBlocks: _selectedBlocks.toList(),
          limits: _limitsController.text.trim(),
        ),
        requiresPayment: requiresPayment,
      ),
    );
  }

  List<String> _splitLines(String value) {
    return value
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }
}

class SectionBriefResult {
  const SectionBriefResult({
    required this.brief,
    required this.requiresPayment,
  });

  final SectionBriefData brief;
  final bool requiresPayment;
}

class SectionBriefData {
  const SectionBriefData({
    required this.title,
    required this.goal,
    required this.scenarios,
    required this.inputs,
    required this.outputs,
    required this.aiOperations,
    required this.constraints,
    required this.updatePolicy,
    required this.uiBlocks,
    required this.limits,
  });

  final String title;
  final String goal;
  final List<String> scenarios;
  final List<String> inputs;
  final List<String> outputs;
  final List<String> aiOperations;
  final String constraints;
  final String updatePolicy;
  final List<String> uiBlocks;
  final String limits;
}

class SectionQuotaCard extends StatelessWidget {
  const SectionQuotaCard({super.key, required this.used, required this.limit});

  final int used;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final remaining = (limit - used).clamp(0, limit);
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: const Icon(Icons.stacked_bar_chart),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free sections used',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$used of $limit used • $remaining free slots remaining',
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

class SectionPaywallBanner extends StatelessWidget {
  const SectionPaywallBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            child: const Icon(Icons.lock_outline),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paid section required',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Additional sections cost 300 ₽ / 3 months and will be billed as add-ons.',
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

class SectionEntryCard extends StatelessWidget {
  const SectionEntryCard({super.key, required this.section, required this.onRun});

  final SectionEntry section;
  final VoidCallback onRun;

  @override
  Widget build(BuildContext context) {
    final lastRun = section.lastRunAt;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                child: Icon(section.category.icon),
              ),
              title: Text(section.title),
              subtitle: Text(section.goal),
              trailing: section.isPaid
                  ? _TagChip(
                      label: 'Paid',
                      color: Theme.of(context).colorScheme.tertiary,
                    )
                  : _TagChip(
                      label: 'Free',
                      color: Theme.of(context).colorScheme.primary,
                    ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                _InfoChip(label: section.category.label),
                _InfoChip(label: section.uiBlocks.join(' • ')),
                if (lastRun != null)
                  _InfoChip(label: 'Last run ${_formatDate(lastRun)}'),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRun,
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Run workflow'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit brief'),
                  ),
                ),
              ],
            ),
            if (section.note != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                section.note!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}';
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

class SectionUiBlockCard extends StatelessWidget {
  const SectionUiBlockCard({super.key, required this.block});

  final SectionUiBlock block;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(block.icon),
          ),
          title: Text(block.title),
          subtitle: Text(block.subtitle),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final chipColor = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: chipColor),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class SectionEntry {
  SectionEntry({
    required this.id,
    required this.category,
    required this.title,
    required this.goal,
    required this.uiBlocks,
    required this.isPaid,
    required this.createdAt,
    this.lastRunAt,
    this.note,
  });

  final String id;
  final SectionCategory category;
  final String title;
  final String goal;
  final List<String> uiBlocks;
  final bool isPaid;
  final DateTime createdAt;
  DateTime? lastRunAt;
  final String? note;
}

enum SectionCategory {
  hobby('Hobby', Icons.self_improvement_outlined),
  study('Study', Icons.school_outlined),
  work('Work', Icons.work_outline);

  const SectionCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

class SectionChecklistItem {
  const SectionChecklistItem(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

class SectionUiBlock {
  const SectionUiBlock({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

const int freeSectionQuota = 3;

const sectionChecklist = [
  SectionChecklistItem('Brief required', 'Complete the 10-point section brief.'),
  SectionChecklistItem('3 sections free', 'Across Hobby, Study, and Work combined.'),
  SectionChecklistItem('300 ₽ / 3 months', 'Per additional section above the free quota.'),
];

const sectionUiBlocks = [
  SectionUiBlock(
    title: 'Feed',
    subtitle: 'Scrollable cards with quick actions.',
    icon: Icons.view_agenda_outlined,
  ),
  SectionUiBlock(
    title: 'Tables',
    subtitle: 'Structured rows for data-heavy workflows.',
    icon: Icons.table_chart_outlined,
  ),
  SectionUiBlock(
    title: 'Kanban',
    subtitle: 'Column-based task tracking.',
    icon: Icons.view_kanban_outlined,
  ),
  SectionUiBlock(
    title: 'Editor',
    subtitle: 'Rich text writing with inline prompts.',
    icon: Icons.edit_note_outlined,
  ),
  SectionUiBlock(
    title: 'Timeline',
    subtitle: 'Milestones and calendar checkpoints.',
    icon: Icons.timeline_outlined,
  ),
  SectionUiBlock(
    title: 'Chat',
    subtitle: 'Conversational workflow cards.',
    icon: Icons.chat_bubble_outline,
  ),
  SectionUiBlock(
    title: 'Files',
    subtitle: 'Uploads and document previews.',
    icon: Icons.folder_open_outlined,
  ),
  SectionUiBlock(
    title: 'Charts',
    subtitle: 'Insight dashboards and progress graphs.',
    icon: Icons.insights_outlined,
  ),
];
