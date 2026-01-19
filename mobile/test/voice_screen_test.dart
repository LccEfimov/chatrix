import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatrix_mobile/features/plans/plan_entitlements.dart';
import 'package:chatrix_mobile/features/plans/plan_models.dart';
import 'package:chatrix_mobile/features/plans/plan_providers.dart';
import 'package:chatrix_mobile/features/voice/voice_screen.dart';
import 'package:chatrix_mobile/theme/app_theme.dart';

void main() {
  testWidgets('Voice screen shows limit and toggles session state', (tester) async {
    const plan = Plan(
      code: 'CORE',
      name: 'Core',
      periodMonths: 1,
      priceRub: 150,
      isActive: true,
      limits: [
        PlanLimit(key: 'voice_minutes_per_day', limitValue: 30),
      ],
      entitlements: [
        PlanEntitlement(key: PlanEntitlementKeys.voice, isEnabled: true),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          entitlementStateProvider.overrideWithValue(
            const EntitlementState.ready({PlanEntitlementKeys.voice: true}),
          ),
          subscriptionProvider.overrideWith((ref) async => plan),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const VoiceScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Voice Sessions'), findsOneWidget);
    expect(find.textContaining('30 min / day'), findsOneWidget);
    expect(find.text('Start session'), findsOneWidget);

    await tester.tap(find.text('Start session'));
    await tester.pumpAndSettle();

    expect(find.text('Stop session'), findsOneWidget);
  });
}
