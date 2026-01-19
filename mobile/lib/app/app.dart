import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import 'app_router.dart';

class ChatriXApp extends ConsumerWidget {
  const ChatriXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'ChatriX',
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
