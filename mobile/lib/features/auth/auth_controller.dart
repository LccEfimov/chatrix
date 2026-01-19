import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_client.dart';
import '../../api/api_interceptors.dart';
import 'auth_models.dart';
import 'auth_repository.dart';
import 'auth_storage.dart';

const _defaultApiBaseUrl = 'https://api.chatrix.app/v1';

final apiBaseUrlProvider = Provider<String>((ref) => _defaultApiBaseUrl);

final authTokenStorageProvider = Provider<AuthTokenStorage>((ref) {
  return SecureAuthTokenStorage();
});

final tokenRefresherProvider = Provider<TokenRefresher>((ref) {
  return TokenRefresher(baseUrl: ref.watch(apiBaseUrlProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: ref.watch(apiBaseUrlProvider),
    tokenStorage: ref.watch(authTokenStorageProvider),
    tokenRefresher: ref.watch(tokenRefresherProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository(ref.watch(apiClientProvider));
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    repository: ref.watch(authRepositoryProvider),
    storage: ref.watch(authTokenStorageProvider),
  );
});

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  final AuthStatus status;
  final UserMe? user;
  final String? errorMessage;
  final bool isLoading;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isZeroPlan => user?.planCode == 'ZERO';

  AuthState copyWith({
    AuthStatus? status,
    UserMe? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.unknown);
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required AuthRepository repository,
    required AuthTokenStorage storage,
  })  : _repository = repository,
        _storage = storage,
        super(AuthState.initial()) {
    _bootstrap();
  }

  final AuthRepository _repository;
  final AuthTokenStorage _storage;

  Future<void> _bootstrap() async {
    final tokens = await _storage.readTokens();
    if (tokens == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final user = await _repository.me();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      await _storage.clearTokens();
      state = state.copyWith(status: AuthStatus.unauthenticated, isLoading: false);
    }
  }

  Future<void> loginWithProvider({
    required String provider,
    required String email,
    required String providerUserId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _repository.loginWithProvider(
        provider: provider,
        email: email,
        providerUserId: providerUserId,
      );
      await _storage.saveTokens(response.tokens);
      final user = await _repository.me();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: parseAuthError(error),
      );
    }
  }

  Future<void> refreshSession() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final tokens = await _repository.refreshTokens(refreshToken);
      await _storage.saveTokens(tokens);
      final user = await _repository.me();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (error) {
      await _storage.clearTokens();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: parseAuthError(error),
      );
    }
  }

  Future<void> logout() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken != null) {
      try {
        await _repository.logout(refreshToken);
      } catch (_) {}
    }
    await _storage.clearTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> linkProvider({
    required String provider,
    required String providerUserId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.linkProvider(
        provider: provider,
        providerUserId: providerUserId,
      );
      state = state.copyWith(isLoading: false, user: user);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: parseAuthError(error),
      );
    }
  }

  Future<void> unlinkProvider({
    required String provider,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.unlinkProvider(provider: provider);
      state = state.copyWith(isLoading: false, user: user);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: parseAuthError(error),
      );
    }
  }
}
