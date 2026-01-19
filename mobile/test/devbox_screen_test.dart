import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatrix_mobile/features/devbox/devbox_screen.dart';
import 'package:chatrix_mobile/features/plans/plan_entitlements.dart';
import 'package:chatrix_mobile/features/plans/plan_providers.dart';
import 'package:chatrix_mobile/theme/app_theme.dart';

void main() {
  testWidgets('DevBox screen toggles status and shows billing', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          entitlementStateProvider.overrideWithValue(
            const EntitlementState.ready({PlanEntitlementKeys.devbox: true}),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const DevboxScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Developer DevBox'), findsOneWidget);
    expect(find.text('Packages'), findsOneWidget);
    expect(find.text('Stacks'), findsOneWidget);
    expect(find.text('Billing add-on'), findsOneWidget);
    expect(find.text('Stopped'), findsOneWidget);

    await tester.tap(find.text('Start DevBox'));
    await tester.pumpAndSettle();

    expect(find.text('Running'), findsOneWidget);
    expect(find.text('Restart DevBox'), findsOneWidget);

    await tester.tap(find.text('Stop DevBox'));
    await tester.pumpAndSettle();

    expect(find.text('Stopped'), findsWidgets);
  });
}
