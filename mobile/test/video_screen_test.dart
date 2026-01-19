import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatrix_mobile/features/media/video_screen.dart';
import 'package:chatrix_mobile/features/plans/plan_entitlements.dart';
import 'package:chatrix_mobile/features/plans/plan_models.dart';
import 'package:chatrix_mobile/features/plans/plan_providers.dart';
import 'package:chatrix_mobile/theme/app_theme.dart';

void main() {
  testWidgets('Video screen shows demo limits and creation form', (tester) async {
    const plan = Plan(
      code: 'CORE',
      name: 'Core',
      periodMonths: 1,
      priceRub: 150,
      isActive: true,
      limits: [],
      entitlements: [
        PlanEntitlement(key: PlanEntitlementKeys.video, isEnabled: true),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          entitlementStateProvider.overrideWithValue(
            const EntitlementState.ready({PlanEntitlementKeys.video: true}),
          ),
          subscriptionProvider.overrideWith((ref) async => plan),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const VideoScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Video Sessions'), findsOneWidget);
    expect(find.textContaining('10 sec demo'), findsOneWidget);
    expect(find.text('Generate video chat'), findsOneWidget);
  });
}
