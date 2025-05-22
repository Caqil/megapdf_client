import 'package:equatable/equatable.dart';

class ApiException extends Equatable implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? details;
  final ApiExceptionType type;

  const ApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.details,
    required this.type,
  });

  // Factory constructors for different error types
  factory ApiException.network(String message) {
    return ApiException(
      message: message,
      type: ApiExceptionType.network,
    );
  }

  factory ApiException.timeout(String message) {
    return ApiException(
      message: message,
      type: ApiExceptionType.timeout,
    );
  }

  factory ApiException.cancelled(String message) {
    return ApiException(
      message: message,
      type: ApiExceptionType.cancelled,
    );
  }

  factory ApiException.badRequest(String message) {
    return ApiException(
      message: message,
      statusCode: 400,
      type: ApiExceptionType.badRequest,
    );
  }

  factory ApiException.unauthorized(String message) {
    return ApiException(
      message: message,
      statusCode: 401,
      type: ApiExceptionType.unauthorized,
    );
  }

  factory ApiException.paymentRequired(
      String message, Map<String, dynamic>? details) {
    return ApiException(
      message: message,
      statusCode: 402,
      details: details,
      type: ApiExceptionType.paymentRequired,
    );
  }

  factory ApiException.forbidden(String message) {
    return ApiException(
      message: message,
      statusCode: 403,
      type: ApiExceptionType.forbidden,
    );
  }

  factory ApiException.notFound(String message) {
    return ApiException(
      message: message,
      statusCode: 404,
      type: ApiExceptionType.notFound,
    );
  }

  factory ApiException.validation(
      String message, Map<String, dynamic>? details) {
    return ApiException(
      message: message,
      statusCode: 422,
      details: details,
      type: ApiExceptionType.validation,
    );
  }

  factory ApiException.rateLimit(String message) {
    return ApiException(
      message: message,
      statusCode: 429,
      type: ApiExceptionType.rateLimit,
    );
  }

  factory ApiException.server(String message) {
    return ApiException(
      message: message,
      statusCode: 500,
      type: ApiExceptionType.server,
    );
  }

  factory ApiException.unknown(String message) {
    return ApiException(
      message: message,
      type: ApiExceptionType.unknown,
    );
  }

  // Convenience getters
  bool get isNetworkError => type == ApiExceptionType.network;
  bool get isTimeoutError => type == ApiExceptionType.timeout;
  bool get isPaymentRequired => type == ApiExceptionType.paymentRequired;
  bool get isValidationError => type == ApiExceptionType.validation;
  bool get isServerError => type == ApiExceptionType.server;

  String get userFriendlyMessage {
    switch (type) {
      case ApiExceptionType.network:
        return 'Please check your internet connection and try again.';
      case ApiExceptionType.timeout:
        return 'Request timed out. Please try again.';
      case ApiExceptionType.cancelled:
        return 'Request was cancelled.';
      case ApiExceptionType.badRequest:
        return message;
      case ApiExceptionType.unauthorized:
        return 'Invalid API key or unauthorized access.';
      case ApiExceptionType.paymentRequired:
        return message;
      case ApiExceptionType.forbidden:
        return 'Access denied.';
      case ApiExceptionType.notFound:
        return 'Resource not found.';
      case ApiExceptionType.validation:
        return message;
      case ApiExceptionType.rateLimit:
        return 'Too many requests. Please try again later.';
      case ApiExceptionType.server:
        return 'Server error. Please try again later.';
      case ApiExceptionType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  List<Object?> get props => [message, code, statusCode, details, type];

  @override
  String toString() {
    return 'ApiException(message: $message, code: $code, statusCode: $statusCode, type: $type)';
  }
}

enum ApiExceptionType {
  network,
  timeout,
  cancelled,
  badRequest,
  unauthorized,
  paymentRequired,
  forbidden,
  notFound,
  validation,
  rateLimit,
  server,
  unknown,
}
