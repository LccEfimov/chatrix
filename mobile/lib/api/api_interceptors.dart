import 'dart:async';

import 'package:dio/dio.dart';

import '../features/auth/auth_models.dart';
import '../features/auth/auth_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio client,
    required AuthTokenStorage tokenStorage,
    required TokenRefresher tokenRefresher,
  })  : _client = client,
        _tokenStorage = tokenStorage,
        _tokenRefresher = tokenRefresher;

  final Dio _client;
  final AuthTokenStorage _tokenStorage;
  final TokenRefresher _tokenRefresher;
  Completer<TokenPair?>? _refreshCompleter;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 || err.requestOptions.extra['retried'] == true) {
      handler.next(err);
      return;
    }

    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) {
      handler.next(err);
      return;
    }

    final tokens = await _refreshTokens(refreshToken);
    if (tokens == null) {
      handler.next(err);
      return;
    }

    await _tokenStorage.saveTokens(tokens);
    final options = err.requestOptions;
    options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    options.extra['retried'] = true;

    try {
      final response = await _client.fetch(options);
      handler.resolve(response);
    } catch (error) {
      if (error is DioException) {
        handler.next(error);
      } else {
        handler.next(err);
      }
    }
  }

  Future<TokenPair?> _refreshTokens(String refreshToken) async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer<TokenPair?>();
    try {
      final tokens = await _tokenRefresher.refresh(refreshToken);
      _refreshCompleter?.complete(tokens);
      return tokens;
    } catch (_) {
      _refreshCompleter?.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }
}

class TokenRefresher {
  TokenRefresher({required String baseUrl, Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl));

  final Dio _dio;

  Future<TokenPair?> refresh(String refreshToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      return TokenPair.fromJson(response.data!);
    } catch (_) {
      return null;
    }
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Keep logs lightweight for now.
    handler.next(options);
  }
}
