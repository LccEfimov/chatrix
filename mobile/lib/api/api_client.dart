import 'package:dio/dio.dart';

import 'api_interceptors.dart';

class ApiClient {
  ApiClient({
    Dio? dio,
    String baseUrl = 'https://api.chatrix.app/v1',
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl)) {
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
    ]);
  }

  final Dio _dio;

  Dio get dio => _dio;
}
