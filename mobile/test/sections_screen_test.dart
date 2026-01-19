import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatrix_mobile/features/plans/plan_entitlements.dart';
import 'package:chatrix_mobile/features/plans/plan_providers.dart';
import 'package:chatrix_mobile/features/sections/sections_screen.dart';
import 'package:chatrix_mobile/theme/app_theme.dart';

void main() {
  testWidgets('Sections screen shows categories and brief sheet', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          entitlementStateProvider.overrideWithValue(
            const EntitlementState.ready({PlanEntitlementKeys.sections: true}),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SectionsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sections Builder'), findsOneWidget);
    expect(find.text('Hobby'), findsOneWidget);
    expect(find.text('Study'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Paid section required'), findsOneWidget);

    await tester.tap(find.text('Create new section'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Section brief'), findsOneWidget);
    expect(find.text('Create with fee'), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);
  });
}
