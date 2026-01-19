import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatrix_mobile/features/chat/chat_screen.dart';
import 'package:chatrix_mobile/features/plans/plan_entitlements.dart';
import 'package:chatrix_mobile/features/plans/plan_providers.dart';
import 'package:chatrix_mobile/theme/app_theme.dart';

void main() {
  testWidgets('Chat screen golden', (tester) async {
    final entitlements = EntitlementState.ready({
      PlanEntitlementKeys.chat: true,
      PlanEntitlementKeys.voice: true,
      PlanEntitlementKeys.video: false,
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          entitlementStateProvider.overrideWithValue(entitlements),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const ChatScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ChatScreen),
      matchesGoldenFile('goldens/chat_screen.png'),
    );
  }, skip: 'Golden baseline needs to be generated with Flutter.');
}
