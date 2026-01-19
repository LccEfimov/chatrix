import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatrix_mobile/features/wallet/wallet_screen.dart';
import 'package:chatrix_mobile/theme/app_theme.dart';

void main() {
  testWidgets('Wallet screen shows balance and ledger entries', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const WalletScreen(),
      ),
    );

    expect(find.text('Current balance'), findsOneWidget);
    expect(find.text('125 430,75 ₽'), findsOneWidget);
    expect(find.text('Top-up via Google Pay'), findsOneWidget);
    expect(find.text('Chat usage'), findsOneWidget);
  });

  testWidgets('Wallet top-up flow goes through provider, amount, confirm', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const WalletScreen(),
      ),
    );

    await tester.tap(find.text('Add funds'));
    await tester.pumpAndSettle();

    expect(find.text('Top up balance'), findsOneWidget);

    await tester.tap(find.text('Google Pay'));
    await tester.pump();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '1500');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm top-up'), findsOneWidget);

    await tester.tap(find.text('Confirm top-up'));
    await tester.pumpAndSettle();

    expect(find.text('Top-up request sent. Awaiting confirmation.'), findsOneWidget);
  });
}
