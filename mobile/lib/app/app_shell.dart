import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_spacing.dart';
import 'app_status.dart';

class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(appStatusProvider);
    final messengerKey = ref.watch(_scaffoldMessengerKeyProvider);

    ref.listen(appStatusProvider, (previous, next) {
      final message = next.message;
      if (message != null && message != previous?.message) {
        messengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });

    return ScaffoldMessenger(
      key: messengerKey,
      child: Stack(
        children: [
          child,
          if (status.isOffline)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: SafeArea(
                child: MaterialBanner(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  leading: const Icon(Icons.wifi_off_outlined),
                  content: const Text('Offline mode · Some features are paused.'),
                  actions: const [SizedBox.shrink()],
                ),
              ),
            ),
          IgnorePointer(
            ignoring: !status.isLoading,
            child: AnimatedOpacity(
              opacity: status.isLoading ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final _scaffoldMessengerKeyProvider =
    Provider<GlobalKey<ScaffoldMessengerState>>(
  (ref) => GlobalKey<ScaffoldMessengerState>(),
);
