import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatrix_mobile/app/app_shell.dart';
import 'package:chatrix_mobile/app/app_status.dart';
import 'package:chatrix_mobile/theme/app_theme.dart';

class TestAppStatusController extends AppStatusController {
  TestAppStatusController(AppStatus status) {
    state = status;
  }
}

Future<TestAppStatusController> pumpAppShell(
  WidgetTester tester, {
  AppStatus status = const AppStatus.idle(),
  Widget? child,
}) async {
  final controller = TestAppStatusController(status);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appStatusProvider.overrideWith((ref) => controller),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: AppShell(
          child: child ?? const Scaffold(body: SizedBox.expand()),
        ),
      ),
    ),
  );

  return controller;
}
