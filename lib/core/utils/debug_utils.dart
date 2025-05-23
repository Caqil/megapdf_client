// lib/core/utils/debug_utils.dart
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class DebugUtils {
  static void log(String message, {String? name, Object? error}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: name ?? 'MegaPDF',
        error: error,
      );
      print('🔧 ${name ?? 'DEBUG'}: $message');
      if (error != null) {
        print('🔧 ERROR: $error');
      }
    }
  }

  static void logFileOperation(String operation, Map<String, dynamic> details) {
    if (kDebugMode) {
      log('$operation operation started', name: 'FILE_OP');
      details.forEach((key, value) {
        log('  $key: $value', name: 'FILE_OP');
      });
    }
  }

  static void logDatabaseOperation(
      String operation, Map<String, dynamic> details) {
    if (kDebugMode) {
      log('$operation database operation', name: 'DB');
      details.forEach((key, value) {
        log('  $key: $value', name: 'DB');
      });
    }
  }

  static void logError(String context, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      log('Error in $context: $error', name: 'ERROR', error: error);
      if (stackTrace != null) {
        log('Stack trace: $stackTrace', name: 'ERROR');
      }
    }
  }
}
