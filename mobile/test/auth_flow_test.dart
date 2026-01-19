import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chatrix_mobile/app/app.dart';
import 'package:chatrix_mobile/features/auth/auth_controller.dart';
import 'package:chatrix_mobile/features/auth/auth_models.dart';
import 'package:chatrix_mobile/features/auth/auth_repository.dart';
import 'package:chatrix_mobile/features/auth/auth_storage.dart';

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
  FakeAuthRepository({required this.user});

  final UserMe user;
  bool loginCalled = false;
  bool meCalled = false;

  @override
  Future<AuthResponse> loginWithProvider({
    required String provider,
    required String email,
    required String providerUserId,
  }) async {
    loginCalled = true;
    return AuthResponse(
      user: user,
      tokens: const TokenPair(accessToken: 'access', refreshToken: 'refresh'),
    );
  }

  @override
  Future<UserMe> me() async {
    meCalled = true;
    return user;
  }

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<TokenPair> refreshTokens(String refreshToken) async {
    return const TokenPair(accessToken: 'access', refreshToken: 'refresh');
  }

  @override
  Future<UserMe> linkProvider({
    required String provider,
    required String providerUserId,
  }) async {
    return user;
  }

  @override
  Future<UserMe> unlinkProvider({required String provider}) async {
    return user;
  }
}

void main() {
  testWidgets('Login flows into /me and lands on chat screen', (tester) async {
    final fakeUser = UserMe(
      id: 'user-1',
      email: 'tester@chatrix.app',
      planCode: 'CORE',
      providers: const [],
    );
    final fakeRepository = FakeAuthRepository(user: fakeUser);
    final storage = InMemoryAuthTokenStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepository),
          authTokenStorageProvider.overrideWithValue(storage),
        ],
        child: const ChatriXApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome to ChatriX'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'tester@chatrix.app');
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(fakeRepository.loginCalled, isTrue);
    expect(fakeRepository.meCalled, isTrue);
    expect(find.text('ChatriX • Chat'), findsOneWidget);
  });
}
