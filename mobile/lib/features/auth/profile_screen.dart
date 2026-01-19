import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_bottom_sheet.dart';
import '../../ui/components/app_button.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_scaffold.dart';
import '../../ui/components/app_text_field.dart';
import 'auth_controller.dart';
import 'auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return AppScaffold(
      title: 'ChatriX • Profile',
      body: ListView(
        children: [
          Text(
            'Account & providers',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Link providers to unlock referrals and secure your account.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (user == null)
            AppCard(
              child: Text(
                'No active session. Please sign in again.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          else ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.email, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Plan: ${user.planCode}'),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Linked providers: ${user.providers.length}'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Linked providers',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            for (final provider in supportedAuthProviders)
              ProviderCard(
                provider: provider,
                isLinked: user.providers.any((linked) => linked.provider == provider.id),
              ),
          ],
          if (authState.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Text(
                authState.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Sign out',
            icon: Icons.logout,
            onPressed: authState.isLoading
                ? null
                : () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}

class ProviderCard extends ConsumerWidget {
  const ProviderCard({
    super.key,
    required this.provider,
    required this.isLinked,
  });

  final AuthProviderOption provider;
  final bool isLinked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(provider.icon),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(provider.label, style: Theme.of(context).textTheme.titleMedium),
                  Text(isLinked ? 'Linked' : 'Not linked'),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (isLinked)
              TextButton.icon(
                onPressed: () => ref
                    .read(authControllerProvider.notifier)
                    .unlinkProvider(provider: provider.id),
                icon: const Icon(Icons.link_off),
                label: const Text('Unlink'),
              )
            else
              FilledButton.icon(
                onPressed: () => _showLinkSheet(context, ref),
                icon: const Icon(Icons.link),
                label: const Text('Link'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLinkSheet(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showAppBottomSheet<void>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Link ${provider.label}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: 'Provider user id',
            hintText: 'Enter provider user id',
            controller: controller,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final providerUserId = controller.text.trim();
                    if (providerUserId.isNotEmpty) {
                      ref
                          .read(authControllerProvider.notifier)
                          .linkProvider(provider: provider.id, providerUserId: providerUserId);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Link provider'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
