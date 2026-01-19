import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';
import '../../ui/components/entitlement_gate.dart';
import '../plans/plan_entitlements.dart';

class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});

  static const files = [
    FileAsset('Product brief', 'brief.pdf', 'PDF', '2.4 MB', 'Parsed'),
    FileAsset('Meeting transcript', 'call.txt', 'TXT', '540 KB', 'Stored'),
    FileAsset('Roadmap export', 'roadmap.csv', 'CSV', '1.1 MB', 'Processing'),
    FileAsset('Persona notes', 'persona.docx', 'DOCX', '860 KB', 'Stored'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ChatriX • Files',
      actions: [
        IconButton(
          onPressed: () => context.push('/docs/insights'),
          icon: const Icon(Icons.auto_awesome_outlined),
          tooltip: 'Docs insights',
        ),
      ],
      body: ListView(
        children: [
          Text(
            'Storage & files',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Upload files with multipart sessions, track parsing status, and stay within your plan quota.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Storage usage',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                const LinearProgressIndicator(value: 0.42),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '840 MB used',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Limit 2 GB',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '4 files synced · Last update 2 minutes ago',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Upload queue',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final file in files)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: FileAssetCard(file: file),
            ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Multipart upload',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Start an upload, send file chunks, then confirm completion to unlock parsing.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: const [
                    Chip(label: Text('init upload')),
                    Chip(label: Text('multipart chunks')),
                    Chip(label: Text('complete')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          EntitlementGate(
            entitlementKey: PlanEntitlementKeys.docs,
            lockedTitle: 'Docs access locked',
            lockedSubtitle: 'Upgrade your plan to upload files and parse docs.',
            child: AppPrimaryButton(
              label: 'Upload file',
              icon: Icons.upload_file_outlined,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class FileAsset {
  const FileAsset(this.title, this.filename, this.format, this.size, this.status);

  final String title;
  final String filename;
  final String format;
  final String size;
  final String status;
}

class FileAssetCard extends StatelessWidget {
  const FileAssetCard({super.key, required this.file});

  final FileAsset file;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          child: Text(file.format),
        ),
        title: Text(file.title),
        subtitle: Text('${file.filename} · ${file.size}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              file.status,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Open',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
