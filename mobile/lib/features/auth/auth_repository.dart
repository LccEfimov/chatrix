import 'package:dio/dio.dart';

import '../../api/api_client.dart';
import 'auth_models.dart';

abstract class AuthRepository {
  Future<AuthResponse> loginWithProvider({
    required String provider,
    required String email,
    required String providerUserId,
  });

  Future<TokenPair> refreshTokens(String refreshToken);

  Future<void> logout(String refreshToken);

  Future<UserMe> me();

  Future<UserMe> linkProvider({
    required String provider,
    required String providerUserId,
  });

  Future<UserMe> unlinkProvider({
    required String provider,
  });
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._client);

  final ApiClient _client;

  @override
  Future<AuthResponse> loginWithProvider({
    required String provider,
    required String email,
    required String providerUserId,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/auth/oauth/$provider/callback',
      data: {
        'provider_user_id': providerUserId,
        'email': email,
      },
    );
    return AuthResponse.fromJson(response.data!);
  }

  @override
  Future<TokenPair> refreshTokens(String refreshToken) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {
        'refresh_token': refreshToken,
      },
    );
    return TokenPair.fromJson(response.data!);
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _client.dio.post<Map<String, dynamic>>(
      '/auth/logout',
      data: {
        'refresh_token': refreshToken,
      },
    );
  }

  @override
  Future<UserMe> me() async {
    final response = await _client.dio.get<Map<String, dynamic>>('/me');
    return UserMe.fromJson(response.data!);
  }

  @override
  Future<UserMe> linkProvider({
    required String provider,
    required String providerUserId,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/me/link/$provider',
      data: {
        'provider_user_id': providerUserId,
      },
    );
    return UserMe.fromJson(response.data!);
  }

  @override
  Future<UserMe> unlinkProvider({
    required String provider,
  }) async {
    final response = await _client.dio.delete<Map<String, dynamic>>(
      '/me/link/$provider',
    );
    return UserMe.fromJson(response.data!);
  }
}

String parseAuthError(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['detail'] is String) {
      return data['detail'] as String;
    }
  }
  return 'Something went wrong. Please try again.';
}
