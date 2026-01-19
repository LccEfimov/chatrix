import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatrix_mobile/app/app_router.dart';
import 'package:chatrix_mobile/features/auth/auth_controller.dart';
import 'package:chatrix_mobile/features/auth/auth_models.dart';
import 'package:chatrix_mobile/features/auth/auth_repository.dart';
import 'package:chatrix_mobile/features/auth/auth_storage.dart';
import 'package:chatrix_mobile/theme/app_theme.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({required this.user});

  final UserMe user;
  final TokenPair tokens = const TokenPair(
    accessToken: 'access',
    refreshToken: 'refresh',
  );

  @override
  Future<AuthResponse> loginWithProvider({
    required String provider,
    required String email,
    required String providerUserId,
  }) async {
    return AuthResponse(user: user, tokens: tokens);
  }

  @override
  Future<TokenPair> refreshTokens(String refreshToken) async => tokens;

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<UserMe> me() async => user;

  @override
  Future<UserMe> linkProvider({
    required String provider,
    required String providerUserId,
  }) async {
    return user;
  }

  @override
  Future<UserMe> unlinkProvider({required String provider}) async => user;
}

class FakeAuthTokenStorage implements AuthTokenStorage {
  FakeAuthTokenStorage({TokenPair? tokens}) : _tokens = tokens;

  TokenPair? _tokens;

  @override
  Future<TokenPair?> readTokens() async => _tokens;

  @override
  Future<String?> readAccessToken() async => _tokens?.accessToken;

  @override
  Future<String?> readRefreshToken() async => _tokens?.refreshToken;

  @override
  Future<void> saveTokens(TokenPair tokens) async {
    _tokens = tokens;
  }

  @override
  Future<void> clearTokens() async {
    _tokens = null;
  }
}

void main() {
  testWidgets('Referrals tab is hidden for ZERO plan', (tester) async {
    final repository = FakeAuthRepository(
      user: const UserMe(
        id: 'user-1',
        email: 'zero@chatrix.app',
        planCode: 'ZERO',
        providers: [],
      ),
    );
    final storage = FakeAuthTokenStorage(tokens: repository.tokens);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) {
            return AuthController(repository: repository, storage: storage);
          }),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final router = ref.watch(appRouterProvider);
            return MaterialApp.router(
              routerConfig: router,
              theme: AppTheme.light(),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Referrals'), findsNothing);
  });
}
