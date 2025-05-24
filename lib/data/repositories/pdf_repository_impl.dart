// lib/data/repositories/pdf_repository_impl.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/data/models/compress_result.dart';
import 'package:megapdf_client/data/models/convert_result.dart';
import 'package:megapdf_client/data/models/file_download_result.dart';
import 'package:megapdf_client/data/models/job_status.dart';
import 'package:megapdf_client/data/models/merge_result.dart';
import 'package:megapdf_client/data/models/protect_result.dart';
import 'package:megapdf_client/data/models/rotate_result.dart';
import 'package:megapdf_client/data/models/split_options.dart';
import 'package:megapdf_client/data/models/split_result.dart';
import 'package:megapdf_client/data/models/unlock_result.dart';
import 'package:megapdf_client/data/models/watermark_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/api_constants.dart';
import '../services/pdf_api_service.dart';
import '../services/file_download_service.dart';
import '../../core/utils/storage_manager.dart';
import 'pdf_repository.dart';

part 'pdf_repository_impl.g.dart';

@riverpod
PdfRepository pdfRepository(Ref ref) {
  final apiService = ref.watch(pdfApiServiceProvider);
  final storageManager = ref.watch(storageManagerProvider);
  return PdfRepositoryImpl(apiService, storageManager);
}

class PdfRepositoryImpl implements PdfRepository {
  final PdfApiService _apiService;
  final StorageManager _storageManager;

  PdfRepositoryImpl(this._apiService, this._storageManager);

  @override
  Future<CompressResult> compressPdf(File file) async {
    return await _apiService.compressPdf(file);
  }

  @override
  Future<SplitResult> splitPdf(File file, SplitOptions options) async {
    try {
      // Make sure options are properly checked
      final method = options.splitMethod.value;
      final pageRanges = options.pageRanges; // Could be null
      final everyNPages = options.everyNPages; // Could be null

      return await _apiService.splitPdf(
        file,
        method,
        pageRanges, // Make sure API can handle null
        everyNPages, // Make sure API can handle null
      );
    } catch (e) {
      // Proper error handling with specific error messages
      if (e is DioException) {
        // Handle API errors
      }
      // Re-throw with context
      throw 'Failed to split PDF: $e';
    }
  }

  @override
  Future<JobStatus> getSplitJobStatus(String jobId) async {
    return await _apiService.getSplitStatus(jobId);
  }

  @override
  Future<MergeResult> mergePdfs(List<File> files, {List<int>? order}) async {
    String? orderJson;
    if (order != null && order.isNotEmpty) {
      orderJson = order.join(',');
    }
    return await _apiService.mergePdfs(files, orderJson);
  }

  @override
  Future<WatermarkResult> addTextWatermark(
    File file,
    String text, {
    String? textColor,
    int? fontSize,
    String? fontFamily,
    String? position,
    int? rotation,
    int? opacity,
    String? pages,
    String? customPages,
    int? customX,
    int? customY,
  }) async {
    return await _apiService.watermarkPdf(
      file,
      'text',
      text,
      textColor,
      fontSize,
      fontFamily,
      null, // watermarkImage
      null, // content
      position,
      rotation,
      opacity,
      null, // scale
      pages,
      customPages,
      customX,
      customY,
      null, // description
    );
  }

  @override
  Future<WatermarkResult> addImageWatermark(
    File file,
    File imageFile, {
    String? position,
    int? rotation,
    int? opacity,
    int? scale,
    String? pages,
    String? customPages,
    int? customX,
    int? customY,
  }) async {
    return await _apiService.watermarkPdf(
      file,
      'image',
      null, // text
      null, // textColor
      null, // fontSize
      null, // fontFamily
      imageFile,
      null, // content
      position,
      rotation,
      opacity,
      scale,
      pages,
      customPages,
      customX,
      customY,
      null, // description
    );
  }

  @override
  Future<ConvertResult> convertFile(
    File file,
    String inputFormat,
    String outputFormat, {
    bool? enableOcr,
    int? quality,
    String? password,
  }) async {
    return await _apiService.convertPdf(
      file,
      inputFormat,
      outputFormat,
      enableOcr,
      quality,
      password,
    );
  }

  @override
  Future<ProtectResult> protectPdf(
    File file,
    String password, {
    String? permission,
    bool? allowPrinting,
    bool? allowCopying,
    bool? allowEditing,
  }) async {
    return await _apiService.protectPdf(
      file,
      password,
      permission,
      allowPrinting,
      allowCopying,
      allowEditing,
    );
  }

  @override
  Future<UnlockResult> unlockPdf(File file, String password) async {
    return await _apiService.unlockPdf(file, password);
  }

  @override
  Future<RotateResult> rotatePdf(
    File file,
    int angle, {
    String? pages,
  }) async {
    return await _apiService.rotatePdf(file, angle, pages);
  }

  @override
  Future<PageNumbersResult> addPageNumbers(
    File file, {
    String? position,
    String? format,
    String? fontFamily,
    int? fontSize,
    String? color,
    int? startNumber,
    String? prefix,
    String? suffix,
    int? marginX,
    int? marginY,
    String? selectedPages,
    bool? skipFirstPage,
  }) async {
    return await _apiService.addPageNumbers(
      file,
      position,
      format,
      fontFamily,
      fontSize,
      color,
      startNumber,
      prefix,
      suffix,
      marginX,
      marginY,
      selectedPages,
      skipFirstPage,
    );
  }

  @override
  Future<String> saveProcessedFile({
    required String fileUrl,
    required String filename,
    String? customFileName,
    String? subfolder,
  }) async {
    try {
      debugPrint('🔍 Starting saveProcessedFile');
      debugPrint('🔍 fileUrl: $fileUrl');
      debugPrint('🔍 filename: $filename');

      // Create a temporary file path to download to
      final tempDir = await Directory.systemTemp.createTemp('megapdf_temp');
      final tempFilePath = '${tempDir.path}/$filename';
      debugPrint('🔍 tempFilePath: $tempFilePath');

      // Create the file download service directly
      final fileDownloadService = FileDownloadService(Dio()
        ..options.headers = {
          ApiConstants.apiKeyHeader: ApiConstants.apiKey,
        });

      // Extract relevant information from the fileUrl
      String folder = 'sessions'; // Default folder

      // Parse the fileUrl to extract any useful information
      if (fileUrl.isNotEmpty) {
        // Log the fileUrl for debugging
        debugPrint('🔍 Analyzing fileUrl: $fileUrl');

        // Look for folder information in the URL
        final Uri uri = Uri.parse(fileUrl);
        final pathSegments = uri.pathSegments;

        if (pathSegments.isNotEmpty) {
          debugPrint('🔍 URL path segments: $pathSegments');

          // Try to find a folder name in the path segments
          for (final segment in pathSegments) {
            if (segment == 'file' ||
                segment == 'sessions' ||
                segment == 'uploads') {
              folder = segment;
              debugPrint('🔍 Found folder in URL: $folder');
              break;
            }
          }
        }

        // Check query parameters
        if (uri.queryParameters.containsKey('folder')) {
          folder = uri.queryParameters['folder']!;
          debugPrint('🔍 Found folder in query parameters: $folder');
        }
      }

      debugPrint('🔍 Using folder: $folder for file: $filename');

      // Download the file - try both 'sessions' and 'file' folders if needed
      FileDownloadResult? result;

      // First try with the parsed/default folder
      debugPrint('🔍 Attempting download with folder: $folder');
      result = await fileDownloadService.downloadFile(folder, filename);

      // If that fails, try with 'sessions'
      if (!result.success && folder != 'sessions') {
        debugPrint('🔍 First attempt failed. Trying with folder: sessions');
        result = await fileDownloadService.downloadFile('sessions', filename);
      }

      // If that still fails, try with 'file'
      if (!result.success && folder != 'file') {
        debugPrint('🔍 Second attempt failed. Trying with folder: file');
        result = await fileDownloadService.downloadFile('file', filename);
      }

      if (!result.success || result.data == null) {
        throw Exception('Failed to download file: ${result.message}');
      }

      // Save downloaded data to temp file
      debugPrint(
          '🔍 Download successful. Saving ${result.data!.length} bytes to temp file');
      await fileDownloadService.saveToFile(result.data!, tempFilePath);

      // Verify temp file exists and has content
      final tempFile = File(tempFilePath);
      if (await tempFile.exists()) {
        final fileSize = await tempFile.length();
        debugPrint('🔍 Temp file created successfully. Size: $fileSize bytes');
      } else {
        debugPrint('🔍 ERROR: Temp file was not created!');
        throw Exception('Temp file was not created');
      }

      // Save the file to permanent storage using our storage manager
      debugPrint('🔍 Saving to permanent storage. Subfolder: $subfolder');
      final savedPath = await _storageManager.saveProcessedFile(
        sourceFilePath: tempFilePath,
        fileName: filename,
        customFileName: customFileName,
        subfolder: subfolder,
      );

      if (savedPath == null || savedPath.isEmpty) {
        debugPrint('🔍 ERROR: Failed to save file to permanent storage');
        throw Exception('Failed to save file to permanent storage');
      }

      debugPrint('🔍 File saved successfully to: $savedPath');

      // Clean up the temporary file
      try {
        if (await tempFile.exists()) {
          await tempFile.delete();
          debugPrint('🔍 Temp file deleted');
        }
        await tempDir.delete(recursive: true);
        debugPrint('🔍 Temp directory deleted');
      } catch (e) {
        debugPrint('🔍 Error cleaning up temporary files: $e');
      }

      return savedPath;
    } catch (e) {
      debugPrint('🔍 ERROR in saveProcessedFile: $e');
      // Return an empty string or throw the exception based on your error handling strategy
      return '';
    }
  }
}
