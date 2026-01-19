import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_spacing.dart';
import '../../ui/components/app_card.dart';
import '../../ui/components/app_text_field.dart';
import 'auth_controller.dart';
import 'auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleProviderTap(String providerId) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {});
      return;
    }
    final providerUserId = '${providerId}_${DateTime.now().millisecondsSinceEpoch}';
    await ref.read(authControllerProvider.notifier).loginWithProvider(
          provider: providerId,
          email: email,
          providerUserId: providerUserId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final isEmailValid = _emailController.text.trim().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to ChatriX',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Sign in to sync your AI workspace, tokens, and active plan.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Email',
                      hintText: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'We use the email for the current OAuth stub callback.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (authState.errorMessage != null)
              AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        authState.errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            if (authState.errorMessage != null)
              const SizedBox(height: AppSpacing.md),
            Text(
              'Continue with',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            for (final provider in supportedAuthProviders)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: SocialLoginButton(
                  label: provider.label,
                  icon: provider.icon,
                  isEnabled: !isLoading && isEmailValid,
                  onPressed: () => _handleProviderTap(provider.id),
                ),
              ),
            if (!isEmailValid)
              Text(
                'Enter your email to enable provider sign-in.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (isLoading)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'By continuing you agree to ChatriX Terms and Privacy Policy.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isEnabled,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: isEnabled ? onPressed : null,
      icon: Icon(icon),
      label: Text('Continue with $label'),
    );
  }
}
