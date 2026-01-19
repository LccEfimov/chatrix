import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';
import '../../ui/components/entitlement_gate.dart';
import '../plans/plan_entitlements.dart';

class DevboxScreen extends StatefulWidget {
  const DevboxScreen({super.key});

  @override
  State<DevboxScreen> createState() => _DevboxScreenState();
}

class _DevboxScreenState extends State<DevboxScreen> {
  static const packages = [
    DevboxPackage(
      name: 'DevBox S',
      specs: '1 vCPU • 2 GB RAM • 10 GB disk',
      monthlyPrice: 900,
      overage: '150 ₽ / extra 10 GB',
    ),
    DevboxPackage(
      name: 'DevBox M',
      specs: '2 vCPU • 4 GB RAM • 30 GB disk',
      monthlyPrice: 1900,
      overage: '120 ₽ / extra 10 GB',
    ),
    DevboxPackage(
      name: 'DevBox L',
      specs: '4 vCPU • 8 GB RAM • 80 GB disk',
      monthlyPrice: 3900,
      overage: '90 ₽ / extra 10 GB',
    ),
  ];

  static const stacks = [
    DevboxStack(
      name: 'Python',
      detail: 'FastAPI, data tooling, Jupyter',
    ),
    DevboxStack(
      name: 'Node.js',
      detail: 'Next.js, React, tooling',
    ),
    DevboxStack(
      name: 'Go',
      detail: 'API + CLI workflows',
    ),
    DevboxStack(
      name: 'Mobile',
      detail: 'Flutter, Android SDK, simulators',
    ),
  ];

  int _selectedPackage = 1;
  int _selectedStack = 0;
  bool _autoRenew = true;
  DevboxStatus _status = DevboxStatus.stopped;
  DateTime? _lastStartedAt;

  @override
  Widget build(BuildContext context) {
    final package = packages[_selectedPackage];
    final stack = stacks[_selectedStack];
    final statusLabel = _status.label;

    return AppScaffold(
      title: 'ChatriX • DevBox',
      body: ListView(
        children: [
          Text(
            'Developer DevBox',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Spin up a paid dev container with curated stacks, packages, and billing controls.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Status',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _status.icon,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        statusLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Chip(label: Text(_status.badge)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _status.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _StatusInfoRow(
                    label: 'Endpoint',
                    value: _status == DevboxStatus.running
                        ? 'devbox-${package.name.toLowerCase().replaceAll(' ', '-')}.chatrix.dev'
                        : 'Not allocated',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _StatusInfoRow(
                    label: 'Last started',
                    value: _lastStartedAt == null
                        ? 'Not started yet'
                        : _formatDateTime(_lastStartedAt!),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Packages',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final entry in packages.indexed)
            DevboxOptionCard(
              icon: Icons.storage_outlined,
              title: entry.$2.name,
              subtitle: entry.$2.specs,
              trailing: '${entry.$2.monthlyPrice} ₽ / 30 days',
              groupValue: _selectedPackage,
              value: entry.$1,
              onChanged: (value) {
                setState(() {
                  _selectedPackage = value;
                });
              },
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Stacks',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final entry in stacks.indexed)
            DevboxOptionCard(
              icon: Icons.layers_outlined,
              title: entry.$2.name,
              subtitle: entry.$2.detail,
              trailing: 'Preinstalled toolchain',
              groupValue: _selectedStack,
              value: entry.$1,
              onChanged: (value) {
                setState(() {
                  _selectedStack = value;
                });
              },
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Billing add-on',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected configuration',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _StatusInfoRow(label: 'Package', value: package.name),
                  const SizedBox(height: AppSpacing.sm),
                  _StatusInfoRow(label: 'Stack', value: stack.name),
                  const SizedBox(height: AppSpacing.sm),
                  _StatusInfoRow(
                    label: 'Monthly add-on',
                    value: '${package.monthlyPrice} ₽ + storage overage',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _StatusInfoRow(label: 'Overage', value: package.overage),
                  const Divider(height: AppSpacing.lg),
                  SwitchListTile.adaptive(
                    value: _autoRenew,
                    title: const Text('Auto-renew add-on'),
                    subtitle: const Text('Charge monthly until stopped.'),
                    onChanged: (value) {
                      setState(() {
                        _autoRenew = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          EntitlementGate(
            entitlementKey: PlanEntitlementKeys.devbox,
            lockedTitle: 'DevBox locked',
            lockedSubtitle: 'Upgrade to Developer • Gate to start DevBox.',
            child: Column(
              children: [
                AppPrimaryButton(
                  label: _status == DevboxStatus.running ? 'Restart DevBox' : 'Start DevBox',
                  icon: Icons.rocket_launch_outlined,
                  onPressed: () => _startDevbox(package),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _status == DevboxStatus.running ? _stopDevbox : null,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('Stop DevBox'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startDevbox(DevboxPackage package) {
    setState(() {
      _status = DevboxStatus.running;
      _lastStartedAt = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('DevBox ${package.name} is starting with ${stacks[_selectedStack].name}.'),
      ),
    );
  }

  void _stopDevbox() {
    setState(() {
      _status = DevboxStatus.stopped;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('DevBox stopped.')),
    );
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year;
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }
}

class DevboxPackage {
  const DevboxPackage({
    required this.name,
    required this.specs,
    required this.monthlyPrice,
    required this.overage,
  });

  final String name;
  final String specs;
  final int monthlyPrice;
  final String overage;
}

class DevboxStack {
  const DevboxStack({
    required this.name,
    required this.detail,
  });

  final String name;
  final String detail;
}

enum DevboxStatus {
  stopped(
    label: 'Stopped',
    badge: 'Offline',
    description: 'Select a package and start a DevBox when you are ready.',
    icon: Icons.pause_circle_outline,
  ),
  running(
    label: 'Running',
    badge: 'Live',
    description: 'Your container is live and ready for SSH or web IDE access.',
    icon: Icons.play_circle_outline,
  );

  const DevboxStatus({
    required this.label,
    required this.badge,
    required this.description,
    required this.icon,
  });

  final String label;
  final String badge;
  final String description;
  final IconData icon;
}

class DevboxOptionCard extends StatelessWidget {
  const DevboxOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.groupValue,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final int groupValue;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: RadioListTile<int>(
          contentPadding: EdgeInsets.zero,
          value: value,
          groupValue: groupValue,
          onChanged: (value) {
            if (value == null) {
              return;
            }
            onChanged(value);
          },
          secondary: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: Icon(icon),
          ),
          title: Row(
            children: [
              Expanded(child: Text(title)),
              Text(
                trailing,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          subtitle: Text(subtitle),
          dense: true,
        ),
      ),
    );
  }
}

class _StatusInfoRow extends StatelessWidget {
  const _StatusInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
