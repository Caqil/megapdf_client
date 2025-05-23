import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/file_download_result.dart';
import '../../core/constants/api_constants.dart';

part 'file_download_service.g.dart';

@riverpod
FileDownloadService fileDownloadService(Ref ref) {
  final dio = Dio();
  // Add API key to headers
  dio.options.headers[ApiConstants.apiKeyHeader] = ApiConstants.apiKey;
  return FileDownloadService(dio);
}

class FileDownloadService {
  final Dio _dio;

  FileDownloadService(this._dio);

  /// Download a file from the API server
  Future<FileDownloadResult> downloadFile(
      String folder, String filename) async {
    try {
      final String url = '${ApiConstants.baseUrl}${ApiConstants.serveFile}';

      debugPrint('🔍 Downloading file from: $url');
      debugPrint('🔍 Query parameters: folder=$folder, filename=$filename');

      // Configure request for binary data
      final options = Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        headers: {
          ApiConstants.apiKeyHeader: ApiConstants.apiKey,
          'Accept': '*/*', // Accept any content type
        },
        validateStatus: (status) =>
            true, // Accept any status code for debugging
      );

      // Make the request
      debugPrint('🔍 Sending download request...');
      final response = await _dio.get(
        url,
        queryParameters: {
          'folder': folder,
          'filename': filename,
        },
        options: options,
      );

      debugPrint('🔍 Response status code: ${response.statusCode}');

      // Log headers for debugging
      debugPrint('🔍 Response headers: ${response.headers}');

      // Log content type if available
      final contentType = response.headers.value('content-type');
      debugPrint('🔍 Content-Type: $contentType');

      // Check if the request was successful
      if (response.statusCode == 200 && response.data != null) {
        // Check if response is binary data (bytes)
        if (response.data is List<int>) {
          final Uint8List fileData = Uint8List.fromList(response.data);
          debugPrint(
              '🔍 Download successful, received ${fileData.length} bytes');

          return FileDownloadResult(
            success: true,
            fileName: filename,
            data: fileData,
            fileSize: fileData.length,
          );
        } else {
          // If not binary, try to get error message
          debugPrint(
              '🔍 Unexpected response type: ${response.data.runtimeType}');
          String errorMsg = 'Unexpected response format';

          if (response.data is Map) {
            errorMsg = response.data['message'] ?? errorMsg;
            debugPrint('🔍 Response data: ${response.data}');
          } else if (response.data is String) {
            errorMsg = response.data
                .toString()
                .substring(0, min(100, response.data.toString().length));
            debugPrint('🔍 Response text: $errorMsg');
          }

          return FileDownloadResult(
            success: false,
            message: 'Invalid response format: $errorMsg',
          );
        }
      } else {
        // Handle error responses
        String errorMessage =
            'Failed to download file: HTTP ${response.statusCode}';

        debugPrint('🔍 Download failed with status: ${response.statusCode}');

        if (response.data != null) {
          try {
            // Try to parse error message from response
            if (response.data is Map) {
              errorMessage +=
                  ' - ${response.data['message'] ?? "Unknown error"}';
              debugPrint('🔍 Error data: ${response.data}');
            } else if (response.data is String) {
              final previewLength = min(200, response.data.toString().length);
              final preview =
                  response.data.toString().substring(0, previewLength);
              errorMessage += ' - $preview';
              debugPrint('🔍 Error text: $preview');
            } else if (response.data is List<int> && response.data.isNotEmpty) {
              // Try to convert bytes to string if possible
              try {
                final String textData = String.fromCharCodes(response.data);
                final preview =
                    textData.substring(0, min(200, textData.length));
                errorMessage += ' - $preview';
                debugPrint('🔍 Error bytes as text: $preview');
              } catch (e) {
                debugPrint(
                    '🔍 Error data is binary but not text: ${response.data.length} bytes');
              }
            }
          } catch (e) {
            debugPrint('🔍 Error parsing response data: $e');
          }
        }

        return FileDownloadResult(
          success: false,
          message: errorMessage,
        );
      }
    } on DioException catch (e) {
      // Handle Dio specific exceptions
      debugPrint('🔍 DioException: ${e.message}');
      debugPrint('🔍 DioException type: ${e.type}');
      debugPrint('🔍 DioException error: ${e.error}');

      if (e.response != null) {
        debugPrint('🔍 Response status: ${e.response?.statusCode}');
        debugPrint('🔍 Response data: ${e.response?.data}');
      }

      return FileDownloadResult(
        success: false,
        message: 'Error downloading file: ${e.message}',
      );
    } catch (e) {
      // Handle generic exceptions
      debugPrint('🔍 General exception: $e');
      return FileDownloadResult(
        success: false,
        message: 'Error downloading file: $e',
      );
    }
  }

  /// Save downloaded file data to a local file
  Future<String?> saveToFile(Uint8List data, String filePath) async {
    try {
      final file = File(filePath);
      await file.writeAsBytes(data);
      return filePath;
    } catch (e) {
      debugPrint('Error saving file: $e');
      return null;
    }
  }

  /// Download and save file in one operation
  Future<String?> downloadAndSaveFile(
    String folder,
    String filename,
    String destinationPath,
  ) async {
    try {
      final result = await downloadFile(folder, filename);

      if (result.success && result.data != null) {
        return await saveToFile(result.data!, destinationPath);
      } else {
        debugPrint('Download failed: ${result.message}');
        return null;
      }
    } catch (e) {
      debugPrint('Error in downloadAndSaveFile: $e');
      return null;
    }
  }
}
