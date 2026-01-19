import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';

class DocsScreen extends StatelessWidget {
  const DocsScreen({super.key});

  static const supportedFormats = [
    'txt · md · csv',
    'doc · docx · pdf',
    'xls · xlsx · ods',
    'epub · mobi · fb2',
  ];

  static const recentFiles = [
    DocFile('Project brief', 'brief.pdf', 'Pending upload'),
    DocFile('Research notes', 'notes.md', 'Parsed'),
    DocFile('Budget', 'finance.xlsx', 'Stored'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ChatriX • Docs',
      body: ListView(
        children: [
          Text(
            'Docs & files',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Upload documents, parse content, and keep everything within your plan quota.',
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
                const SizedBox(height: AppSpacing.md),
                const LinearProgressIndicator(value: 0.32),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '320 MB of 1 GB used',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Supported formats',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
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
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Recent uploads',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final file in recentFiles) DocFileCard(file: file),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Upload file',
            icon: Icons.upload_file_outlined,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class DocFile {
  const DocFile(this.title, this.filename, this.status);

  final String title;
  final String filename;
  final String status;
}

class DocFileCard extends StatelessWidget {
  const DocFileCard({super.key, required this.file});

  final DocFile file;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.insert_drive_file_outlined),
          title: Text(file.title),
          subtitle: Text(file.filename),
          trailing: Text(file.status),
        ),
      ),
    );
  }
}
