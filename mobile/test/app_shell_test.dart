import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatrix_mobile/app/app_status.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('AppShell shows offline banner', (tester) async {
    await pumpAppShell(
      tester,
      status: const AppStatus(isOffline: true, isLoading: false),
    );

    expect(
      find.text('Offline mode · Some features are paused.'),
      findsOneWidget,
    );
  });

  testWidgets('AppShell shows loading overlay', (tester) async {
    await pumpAppShell(
      tester,
      status: const AppStatus(isOffline: false, isLoading: true),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AppShell shows snackbars for messages', (tester) async {
    final controller = await pumpAppShell(tester);

    controller.showMessage('Hello!');
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Hello!'), findsOneWidget);
  });
}
