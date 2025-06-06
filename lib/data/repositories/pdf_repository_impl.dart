// lib/data/repositories/pdf_repository_impl.dart - Updated with robust file handling

import 'dart:io';
import 'dart:typed_data';

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
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
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
      final method = options.splitMethod.value;
      final pageRanges = options.pageRanges;
      final everyNPages = options.everyNPages;

      return await _apiService.splitPdf(
        file,
        method,
        pageRanges,
        everyNPages,
      );
    } catch (e) {
      if (e is DioException) {
        debugPrint('🔍 API: Split PDF API error: ${e.message}');
      }
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
    Directory? tempDir;
    String? tempFilePath;

    try {
      debugPrint('🔍 REPO: Starting saveProcessedFile');
      debugPrint('🔍 REPO: fileUrl: $fileUrl');
      debugPrint('🔍 REPO: filename: $filename');
      debugPrint('🔍 REPO: customFileName: $customFileName');
      debugPrint('🔍 REPO: subfolder: $subfolder');

      // Step 1: Create a secure temporary directory
      debugPrint('🔍 REPO: Creating temporary directory...');
      final systemTempDir = await getTemporaryDirectory();
      tempDir = await Directory(path.join(systemTempDir.path,
              'megapdf_download_${DateTime.now().millisecondsSinceEpoch}'))
          .create(recursive: true);

      tempFilePath = path.join(tempDir.path, filename);
      debugPrint('🔍 REPO: Temp directory: ${tempDir.path}');
      debugPrint('🔍 REPO: Temp file path: $tempFilePath');

      // Step 2: Download file with multiple retry strategies
      Uint8List? fileData;

      // Try direct URL download first
      if (fileUrl.startsWith('http')) {
        debugPrint('🔍 REPO: Attempting direct URL download...');
        fileData = await _downloadFromUrl(fileUrl);
      }

      // If direct download fails, try API download with different folders
      if (fileData == null) {
        debugPrint('🔍 REPO: Direct download failed, trying API download...');
        fileData = await _downloadViaApi(fileUrl, filename);
      }

      if (fileData == null) {
        throw Exception('Failed to download file from both URL and API');
      }

      debugPrint(
          '🔍 REPO: Download successful, size: ${fileData.length} bytes');

      // Step 3: Write data to temporary file
      debugPrint('🔍 REPO: Writing data to temporary file...');
      final tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(fileData);

      // Verify temp file was written correctly
      if (!await tempFile.exists()) {
        throw Exception('Temporary file was not created');
      }

      final tempFileSize = await tempFile.length();
      if (tempFileSize != fileData.length) {
        throw Exception(
            'Temporary file size mismatch (expected: ${fileData.length}, actual: $tempFileSize)');
      }

      debugPrint(
          '🔍 REPO: Temporary file created successfully, size: $tempFileSize bytes');

      // Step 4: Move to permanent storage
      debugPrint('🔍 REPO: Moving to permanent storage...');
      final savedPath = await _storageManager.saveProcessedFile(
        sourceFilePath: tempFilePath,
        fileName: filename,
        customFileName: customFileName,
        subfolder: subfolder,
      );

      if (savedPath == null || savedPath.isEmpty) {
        throw Exception('Storage manager failed to save file');
      }

      // Step 5: Verify final file
      final finalFile = File(savedPath);
      if (!await finalFile.exists()) {
        throw Exception('Final file does not exist at: $savedPath');
      }

      final finalFileSize = await finalFile.length();
      if (finalFileSize != fileData.length) {
        throw Exception(
            'Final file size mismatch (expected: ${fileData.length}, actual: $finalFileSize)');
      }

      debugPrint('🔍 REPO: File saved successfully to: $savedPath');
      debugPrint('🔍 REPO: Final file size: $finalFileSize bytes');

      return savedPath;
    } catch (e, stackTrace) {
      debugPrint('🔍 REPO: ERROR in saveProcessedFile: $e');
      debugPrint('🔍 REPO: Stack trace: $stackTrace');
      rethrow;
    } finally {
      // Clean up temporary files
      try {
        if (tempFilePath != null) {
          final tempFile = File(tempFilePath);
          if (await tempFile.exists()) {
            await tempFile.delete();
            debugPrint('🔍 REPO: Temporary file deleted');
          }
        }
        if (tempDir != null && await tempDir.exists()) {
          await tempDir.delete(recursive: true);
          debugPrint('🔍 REPO: Temporary directory deleted');
        }
      } catch (e) {
        debugPrint('🔍 REPO: Error cleaning up temporary files: $e');
      }
    }
  }

  /// Download file directly from URL
  Future<Uint8List?> _downloadFromUrl(String url) async {
    try {
      debugPrint('🔍 REPO: Downloading from URL: $url');

      final dio = Dio();
      dio.options.headers = {
        ApiConstants.apiKeyHeader: ApiConstants.apiKey,
      };

      final response = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data != null) {
        debugPrint('🔍 REPO: Direct URL download successful');
        return Uint8List.fromList(response.data!);
      } else {
        debugPrint(
            '🔍 REPO: Direct URL download failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('🔍 REPO: Direct URL download error: $e');
      return null;
    }
  }

  /// Download file via API with folder detection
  Future<Uint8List?> _downloadViaApi(String fileUrl, String filename) async {
    try {
      final fileDownloadService = FileDownloadService(Dio()
        ..options.headers = {
          ApiConstants.apiKeyHeader: ApiConstants.apiKey,
        });

      // Extract folder information from URL or use common folders
      final foldersToTry = <String>[];

      // Parse URL for folder hints
      if (fileUrl.isNotEmpty) {
        final Uri uri = Uri.parse(fileUrl);

        // Check path segments
        for (final segment in uri.pathSegments) {
          if (['sessions', 'uploads', 'files', 'processed'].contains(segment)) {
            foldersToTry.add(segment);
          }
        }

        // Check query parameters
        if (uri.queryParameters.containsKey('folder')) {
          foldersToTry.insert(0, uri.queryParameters['folder']!);
        }
      }

      // Add default folders if none found
      if (foldersToTry.isEmpty) {
        foldersToTry.addAll(['sessions', 'uploads', 'files', 'processed']);
      }

      // Remove duplicates
      final uniqueFolders = foldersToTry.toSet().toList();

      debugPrint('🔍 REPO: Trying API download with folders: $uniqueFolders');

      // Try each folder
      for (final folder in uniqueFolders) {
        try {
          debugPrint('🔍 REPO: Trying folder: $folder');
          final result =
              await fileDownloadService.downloadFile(folder, filename);

          if (result.success &&
              result.data != null &&
              result.data!.isNotEmpty) {
            debugPrint('🔍 REPO: API download successful with folder: $folder');
            return Uint8List.fromList(result.data!);
          } else {
            debugPrint(
                '🔍 REPO: API download failed for folder $folder: ${result.message}');
          }
        } catch (e) {
          debugPrint('🔍 REPO: API download error for folder $folder: $e');
        }
      }

      debugPrint('🔍 REPO: All API download attempts failed');
      return null;
    } catch (e) {
      debugPrint('🔍 REPO: API download setup error: $e');
      return null;
    }
  }
}
