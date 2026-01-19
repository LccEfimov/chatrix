import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';

class DevboxScreen extends StatelessWidget {
  const DevboxScreen({super.key});

  static const packages = [
    DevboxPackage('DevBox S', '1 vCPU • 2 GB RAM • 10 GB disk', '900 ₽ / 30 days'),
    DevboxPackage('DevBox M', '2 vCPU • 4 GB RAM • 30 GB disk', '1900 ₽ / 30 days'),
    DevboxPackage('DevBox L', '4 vCPU • 8 GB RAM • 80 GB disk', '3900 ₽ / 30 days'),
  ];

  static const stacks = [
    DevboxStack('Python', 'FastAPI, data tooling'),
    DevboxStack('Node.js', 'Next.js, React, tooling'),
    DevboxStack('Go', 'API + CLI workflows'),
  ];

  @override
  Widget build(BuildContext context) {
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
            'Spin up a paid dev container with curated stacks and resource packages.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Packages',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final package in packages) DevboxPackageCard(package: package),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Stacks',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final stack in stacks) DevboxStackCard(stack: stack),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Start DevBox',
            icon: Icons.rocket_launch_outlined,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class DevboxPackage {
  const DevboxPackage(this.name, this.specs, this.price);

  final String name;
  final String specs;
  final String price;
}

class DevboxStack {
  const DevboxStack(this.name, this.detail);

  final String name;
  final String detail;
}

class DevboxPackageCard extends StatelessWidget {
  const DevboxPackageCard({super.key, required this.package});

  final DevboxPackage package;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: const Icon(Icons.storage_outlined),
          ),
          title: Text(package.name),
          subtitle: Text(package.specs),
          trailing: Text(package.price),
        ),
      ),
    );
  }
}

class DevboxStackCard extends StatelessWidget {
  const DevboxStackCard({super.key, required this.stack});

  final DevboxStack stack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: const Icon(Icons.layers_outlined),
          ),
          title: Text(stack.name),
          subtitle: Text(stack.detail),
        ),
      ),
    );
  }
}
