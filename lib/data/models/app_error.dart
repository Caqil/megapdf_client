// lib/data/models/app_error.dart
import 'package:equatable/equatable.dart';

class AppError extends Equatable {
  final String message;
  final String? code;
  final String? details;
  final AppErrorType type;

  const AppError({
    required this.message,
    this.code,
    this.details,
    this.type = AppErrorType.unknown,
  });

  factory AppError.network(String message, {String? details}) {
    return AppError(
      message: message,
      details: details,
      type: AppErrorType.network,
    );
  }

  factory AppError.server(String message, {String? code, String? details}) {
    return AppError(
      message: message,
      code: code,
      details: details,
      type: AppErrorType.server,
    );
  }

  factory AppError.validation(String message, {String? details}) {
    return AppError(
      message: message,
      details: details,
      type: AppErrorType.validation,
    );
  }

  factory AppError.fileOperation(String message, {String? details}) {
    return AppError(
      message: message,
      details: details,
      type: AppErrorType.fileOperation,
    );
  }

  @override
  List<Object?> get props => [message, code, details, type];
}

enum AppErrorType {
  network,
  server,
  validation,
  fileOperation,
  unknown,
}
