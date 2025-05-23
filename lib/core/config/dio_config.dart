import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/api_constants.dart';
import '../../data/services/interceptors/auth_interceptor.dart';
import '../../data/services/interceptors/logging_interceptor.dart';
import '../../data/services/interceptors/error_interceptor.dart';

part 'dio_config.g.dart';

@riverpod
Dio dio(Ref ref) {
  final dio = Dio();

  // Base configuration
  dio.options = BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
    receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
    sendTimeout: Duration(milliseconds: ApiConstants.sendTimeout),
    headers: {
      ApiConstants.contentTypeHeader: 'application/json',
      ApiConstants.acceptHeader: 'application/json',
    },
    followRedirects: true,
    maxRedirects: 3,
  );

  // Add interceptors
  dio.interceptors.addAll([
    // Auth interceptor (adds API key to requests)
    AuthInterceptor(),

    // Error interceptor (handles API errors)
    ErrorInterceptor(),

    // Logging interceptor (only in debug mode)
    if (kDebugMode) LoggingInterceptor(),
  ]);

  return dio;
}

@riverpod
Dio multipartDio(Ref ref) {
  final dio = Dio();

  // Configuration for multipart/form-data requests
  dio.options = BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
    receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
    sendTimeout: Duration(milliseconds: ApiConstants.sendTimeout),
    headers: {
      ApiConstants.acceptHeader: 'application/json',
      // Don't set Content-Type for multipart, let Dio handle it
    },
    followRedirects: true,
    maxRedirects: 3,
  );

  // Add interceptors
  dio.interceptors.addAll([
    AuthInterceptor(),
    ErrorInterceptor(),
    if (kDebugMode) LoggingInterceptor(),
  ]);

  return dio;
}
