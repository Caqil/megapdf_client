// lib/data/services/file_download_service.dart - Updated with better error handling

import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/file_download_result.dart';
import '../../core/constants/api_constants.dart';

class FileDownloadService {
  final Dio _dio;

  FileDownloadService(this._dio);

  /// Download file with comprehensive error handling and logging
  Future<FileDownloadResult> downloadFile(
      String folder, String filename) async {
    try {
      debugPrint('🔍 DOWNLOAD: Starting download');
      debugPrint('🔍 DOWNLOAD: Folder: $folder');
      debugPrint('🔍 DOWNLOAD: Filename: $filename');

      if (folder.isEmpty || filename.isEmpty) {
        debugPrint('🔍 DOWNLOAD: ERROR - Empty folder or filename');
        return FileDownloadResult(
          success: false,
          message: 'Invalid folder or filename',
          data: null,
        );
      }

      // Construct download URL
      final url = '${ApiConstants.baseUrl}${ApiConstants.serveFile}';
      debugPrint('🔍 DOWNLOAD: Base URL: $url');

      // Prepare query parameters
      final queryParams = {
        'folder': folder,
        'filename': filename,
      };
      debugPrint('🔍 DOWNLOAD: Query params: $queryParams');

      // Set up request options
      final options = Options(
        responseType: ResponseType.bytes,
        headers: {
          ApiConstants.apiKeyHeader: ApiConstants.apiKey,
          'Accept': '*/*',
        },
        validateStatus: (status) => status != null && status < 500,
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 10),
      );

      debugPrint('🔍 DOWNLOAD: Request headers: ${options.headers}');

      // Make the request
      debugPrint('🔍 DOWNLOAD: Making request...');
      final response = await _dio.get<List<int>>(
        url,
        queryParameters: queryParams,
        options: options,
      );

      debugPrint('🔍 DOWNLOAD: Response status: ${response.statusCode}');
      debugPrint('🔍 DOWNLOAD: Response headers: ${response.headers}');

      // Check response status
      if (response.statusCode == 200) {
        if (response.data != null && response.data!.isNotEmpty) {
          debugPrint(
              '🔍 DOWNLOAD: Success - Downloaded ${response.data!.length} bytes');
          return FileDownloadResult(
            success: true,
            message: 'File downloaded successfully',
            data: response.data!,
          );
        } else {
          debugPrint('🔍 DOWNLOAD: ERROR - Empty response data');
          return FileDownloadResult(
            success: false,
            message: 'Empty response data',
            data: null,
          );
        }
      } else if (response.statusCode == 404) {
        debugPrint('🔍 DOWNLOAD: File not found (404)');
        return FileDownloadResult(
          success: false,
          message: 'File not found in folder "$folder"',
          data: null,
        );
      } else if (response.statusCode == 403) {
        debugPrint('🔍 DOWNLOAD: Access denied (403)');
        return FileDownloadResult(
          success: false,
          message: 'Access denied - check API key',
          data: null,
        );
      } else {
        debugPrint('🔍 DOWNLOAD: HTTP error ${response.statusCode}');

        // Try to get error message from response
        String errorMessage = 'HTTP ${response.statusCode}';
        if (response.data != null) {
          try {
            final responseText = String.fromCharCodes(response.data!);
            if (responseText.isNotEmpty && responseText.length < 500) {
              errorMessage += ': $responseText';
            }
          } catch (e) {
            debugPrint('🔍 DOWNLOAD: Could not parse error response: $e');
          }
        }

        return FileDownloadResult(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } on DioException catch (e) {
      debugPrint('🔍 DOWNLOAD: DioException: ${e.type}');
      debugPrint('🔍 DOWNLOAD: DioException message: ${e.message}');
      debugPrint(
          '🔍 DOWNLOAD: DioException response: ${e.response?.statusCode}');

      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'Connection timeout';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = 'Send timeout';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Receive timeout';
          break;
        case DioExceptionType.badResponse:
          errorMessage = 'Bad response: ${e.response?.statusCode}';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Connection error';
          break;
        case DioExceptionType.unknown:
          errorMessage = 'Unknown error: ${e.message}';
          break;
        default:
          errorMessage = 'Network error: ${e.message}';
      }

      return FileDownloadResult(
        success: false,
        message: errorMessage,
        data: null,
      );
    } catch (e, stackTrace) {
      debugPrint('🔍 DOWNLOAD: Unexpected error: $e');
      debugPrint('🔍 DOWNLOAD: Stack trace: $stackTrace');

      return FileDownloadResult(
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  /// Save downloaded data to a file with verification
  Future<bool> saveToFile(List<int> data, String filePath) async {
    try {
      debugPrint('🔍 DOWNLOAD: Saving to file: $filePath');
      debugPrint('🔍 DOWNLOAD: Data size: ${data.length} bytes');

      if (data.isEmpty) {
        debugPrint('🔍 DOWNLOAD: ERROR - No data to save');
        return false;
      }

      // Ensure directory exists
      final file = File(filePath);
      final directory = file.parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        debugPrint('🔍 DOWNLOAD: Created directory: ${directory.path}');
      }

      // Write data to file
      await file.writeAsBytes(data);
      debugPrint('🔍 DOWNLOAD: File written');

      // Verify file was created and has correct size
      if (await file.exists()) {
        final fileSize = await file.length();
        if (fileSize == data.length) {
          debugPrint(
              '🔍 DOWNLOAD: File saved successfully, size: $fileSize bytes');
          return true;
        } else {
          debugPrint(
              '🔍 DOWNLOAD: ERROR - File size mismatch (expected: ${data.length}, actual: $fileSize)');
          return false;
        }
      } else {
        debugPrint('🔍 DOWNLOAD: ERROR - File was not created');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('🔍 DOWNLOAD: Error saving file: $e');
      debugPrint('🔍 DOWNLOAD: Stack trace: $stackTrace');
      return false;
    }
  }

  /// Test download connectivity
  Future<bool> testConnection() async {
    try {
      debugPrint('🔍 DOWNLOAD: Testing connection...');

      final response = await _dio.get(
        '${ApiConstants.baseUrl}/health',
        options: Options(
          headers: {ApiConstants.apiKeyHeader: ApiConstants.apiKey},
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      final isHealthy = response.statusCode == 200;
      debugPrint('🔍 DOWNLOAD: Connection test result: $isHealthy');
      return isHealthy;
    } catch (e) {
      debugPrint('🔍 DOWNLOAD: Connection test failed: $e');
      return false;
    }
  }

  /// Get server info for debugging
  Future<Map<String, dynamic>> getServerInfo() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/info',
        options: Options(
          headers: {ApiConstants.apiKeyHeader: ApiConstants.apiKey},
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      debugPrint('🔍 DOWNLOAD: Failed to get server info: $e');
    }

    return {
      'status': 'unknown',
      'error': 'Could not retrieve server info',
    };
  }
}

// lib/data/models/file_download_result.dart - Update this model if needed

class FileDownloadResult {
  final bool success;
  final String message;
  final List<int>? data;
  final Map<String, dynamic>? metadata;

  const FileDownloadResult({
    required this.success,
    required this.message,
    this.data,
    this.metadata,
  });

  @override
  String toString() {
    return 'FileDownloadResult(success: $success, message: $message, dataSize: ${data?.length ?? 0})';
  }
}
