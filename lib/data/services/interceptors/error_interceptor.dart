// lib/data/services/interceptors/error_interceptor.dart
import 'package:dio/dio.dart';
import '../../../core/errors/api_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = _handleDioError(err);
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: apiException,
      type: err.type,
      response: err.response,
    ));
  }

  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException.timeout(
          'Request timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return ApiException.cancelled('Request was cancelled');

      case DioExceptionType.connectionError:
        return ApiException.network(
          'Network error. Please check your internet connection.',
        );

      case DioExceptionType.badCertificate:
        return ApiException.network('SSL certificate error');

      case DioExceptionType.unknown:
      return ApiException.unknown(
          error.message ?? 'An unexpected error occurred',
        );
    }
  }

  ApiException _handleResponseError(Response? response) {
    if (response == null) {
      return ApiException.unknown('No response received from server');
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    // Extract error message from response
    String errorMessage = 'An error occurred';
    if (data is Map<String, dynamic>) {
      errorMessage = data['error'] ?? data['message'] ?? errorMessage;
    }

    switch (statusCode) {
      case 400:
        return ApiException.badRequest(errorMessage);
      case 401:
        return ApiException.unauthorized(errorMessage);
      case 402:
        return ApiException.paymentRequired(errorMessage, data);
      case 403:
        return ApiException.forbidden(errorMessage);
      case 404:
        return ApiException.notFound(errorMessage);
      case 422:
        return ApiException.validation(errorMessage, data);
      case 429:
        return ApiException.rateLimit(errorMessage);
      case 500:
      case 502:
      case 503:
      case 504:
        return ApiException.server(errorMessage);
      default:
        return ApiException.unknown('HTTP $statusCode: $errorMessage');
    }
  }
}
