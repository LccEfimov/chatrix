import 'package:dio/dio.dart';

import '../features/auth/auth_storage.dart';
import 'api_interceptors.dart';

class ApiClient {
  ApiClient({
    required AuthTokenStorage tokenStorage,
    required TokenRefresher tokenRefresher,
    Dio? dio,
    String baseUrl = 'https://api.chatrix.app/v1',
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl)) {
    _dio.interceptors.addAll([
      AuthInterceptor(
        client: _dio,
        tokenStorage: tokenStorage,
        tokenRefresher: tokenRefresher,
      ),
      LoggingInterceptor(),
    ]);
  }

  final Dio _dio;

  Dio get dio => _dio;
}
