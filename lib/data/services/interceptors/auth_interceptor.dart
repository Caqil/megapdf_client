// lib/data/services/interceptors/auth_interceptor.dart
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add API key to all requests
    options.headers[ApiConstants.apiKeyHeader] = ApiConstants.apiKey;
    
    super.onRequest(options, handler);
  }
}
