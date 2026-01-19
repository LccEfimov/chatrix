import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatrix_mobile/features/auth/auth_controller.dart';
import 'package:chatrix_mobile/features/auth/auth_models.dart';
import 'package:chatrix_mobile/features/auth/auth_repository.dart';
import 'package:chatrix_mobile/features/auth/auth_storage.dart';
import 'package:chatrix_mobile/features/auth/login_screen.dart';
import 'package:chatrix_mobile/theme/app_theme.dart';

class InMemoryAuthTokenStorage implements AuthTokenStorage {
  TokenPair? _tokens;

  @override
  Future<void> clearTokens() async {
    _tokens = null;
  }

  @override
  Future<String?> readAccessToken() async => _tokens?.accessToken;

  @override
  Future<String?> readRefreshToken() async => _tokens?.refreshToken;

  @override
  Future<TokenPair?> readTokens() async => _tokens;

  @override
  Future<void> saveTokens(TokenPair tokens) async {
    _tokens = tokens;
  }
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthResponse> loginWithProvider({
    required String provider,
    required String email,
    required String providerUserId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UserMe> me() async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout(String refreshToken) async {
    throw UnimplementedError();
  }

  @override
  Future<TokenPair> refreshTokens(String refreshToken) async {
    throw UnimplementedError();
  }

  @override
  Future<UserMe> linkProvider({
    required String provider,
    required String providerUserId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UserMe> unlinkProvider({required String provider}) async {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('Login screen shows provider buttons and error state', (tester) async {
    final controller = AuthController(
      repository: FakeAuthRepository(),
      storage: InMemoryAuthTokenStorage(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWithValue(controller),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const LoginScreen(),
        ),
      ),
    );
    controller.state = const AuthState(
      status: AuthStatus.unauthenticated,
      errorMessage: 'Invalid provider token',
    );
    await tester.pump();

    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Invalid provider token'), findsOneWidget);
  });

  testWidgets('Login screen disables buttons when loading', (tester) async {
    final controller = AuthController(
      repository: FakeAuthRepository(),
      storage: InMemoryAuthTokenStorage(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWithValue(controller),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const LoginScreen(),
        ),
      ),
    );
    controller.state = const AuthState(
      status: AuthStatus.unauthenticated,
      isLoading: true,
    );
    await tester.pump();

    final button = tester.widget<FilledButton>(find.byType(FilledButton).first);
    expect(button.onPressed, isNull);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
