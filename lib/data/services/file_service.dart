import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/errors/api_exception.dart';
import 'pdf_api_service.dart';

part 'file_service.g.dart';

@riverpod
FileService fileService(Ref ref) {
  final apiService = ref.watch(pdfApiServiceProvider);
  return FileService(apiService);
}

class FileService {
  final PdfApiService _apiService;

  FileService(this._apiService);

  /// Download a processed file and save it to device storage
  Future<String> downloadAndSaveFile({
    required String folder,
    required String filename,
    String? customFileName,
    Function(double progress)? onProgress,
  }) async {
    try {
      // Request storage permissions
      await _requestStoragePermissions();

      // Get download directory
      final downloadDir = await _getDownloadDirectory();

      // Create filename with timestamp to avoid conflicts
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(filename);
      final baseName =
          customFileName ?? path.basenameWithoutExtension(filename);
      final localFileName = '${baseName}_$timestamp$extension';
      final localFilePath = path.join(downloadDir.path, localFileName);

      // Download file metadata
      final response = await _apiService.downloadFile(folder, filename);

      // Fetch the file from the URL in FileDownloadResult
      final dio = Dio(); // Use a new Dio instance or inject one
      final fileResponse = await dio.get(
        response.url, // Assuming FileDownloadResult has a 'url' field
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      // Collect bytes from the response
      final bytes = fileResponse.data as Uint8List;

      // Save file to local storage
      final file = File(localFilePath);
      await file.writeAsBytes(bytes);

      return localFilePath;
    } catch (e) {
      throw ApiException.unknown('Failed to download file: ${e.toString()}');
    }
  }

  /// Open a downloaded file with default app
  Future<void> openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        throw ApiException.unknown('Could not open file: ${result.message}');
      }
    } catch (e) {
      throw ApiException.unknown('Failed to open file: ${e.toString()}');
    }
  }

  /// Share a file (platform specific implementation would be needed)
  Future<void> shareFile(String filePath) async {
    // This would require a platform-specific sharing plugin
    // For now, just open it
    await openFile(filePath);
  }

  /// Get file size in bytes
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      final stat = await file.stat();
      return stat.size;
    } catch (e) {
      return 0;
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Delete a file
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw ApiException.unknown('Failed to delete file: ${e.toString()}');
    }
  }

  /// Get all downloaded PDF files
  Future<List<File>> getDownloadedFiles() async {
    try {
      final downloadDir = await _getDownloadDirectory();
      if (!await downloadDir.exists()) {
        return [];
      }

      final files = downloadDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.toLowerCase().endsWith('.pdf'))
          .toList();

      // Sort by modification date (newest first)
      files.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return bStat.modified.compareTo(aStat.modified);
      });

      return files;
    } catch (e) {
      return [];
    }
  }

  /// Clean up old downloaded files (older than specified days)
  Future<void> cleanupOldFiles({int olderThanDays = 30}) async {
    try {
      final downloadDir = await _getDownloadDirectory();
      if (!await downloadDir.exists()) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));
      final files = downloadDir.listSync().whereType<File>();

      for (final file in files) {
        final stat = file.statSync();
        if (stat.modified.isBefore(cutoffDate)) {
          await file.delete();
        }
      }
    } catch (e) {
      // Silently fail cleanup
    }
  }

  Future<bool> validateFile(File file) async {
    try {
      // Check if file exists
      if (!await file.exists()) {
        throw ApiException.validation('File does not exist', null);
      }

      // Check file size (50MB limit)
      final stat = await file.stat();
      if (stat.size > 50 * 1024 * 1024) {
        throw ApiException.validation('File size exceeds 50MB limit', null);
      }

      // Check file extension for PDF operations
      final extension = path.extension(file.path).toLowerCase();
      if (extension != '.pdf') {
        // For PDF operations, we need PDF files
        // But for conversion, we might accept other formats
        // This validation can be made more specific per operation
        throw ApiException.validation('File must be a PDF', null);
      }

      return true;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.validation(
          'File validation failed: ${e.toString()}', null);
    }
  }

  /// Get file metadata
  Future<Map<String, dynamic>> getFileMetadata(File file) async {
    try {
      final stat = await file.stat();
      return {
        'name': path.basename(file.path),
        'size': stat.size,
        'modified': stat.modified.toIso8601String(),
        'extension': path.extension(file.path),
        'path': file.path,
      };
    } catch (e) {
      return {};
    }
  }

  // Private helper methods

  Future<void> _requestStoragePermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        if (!result.isGranted) {
          throw ApiException.forbidden(
              'Storage permission is required to download files');
        }
      }

      // For Android 11+ (API 30+), also request manage external storage
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }
    }
  }

  Future<Directory> _getDownloadDirectory() async {
    Directory directory;

    if (Platform.isAndroid) {
      // Try to get external storage directory
      directory = Directory('/storage/emulated/0/Download/MegaPDF');
    } else if (Platform.isIOS) {
      // For iOS, use documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      directory = Directory(path.join(appDocDir.path, 'Downloads'));
    } else {
      // Fallback to application documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      directory = Directory(path.join(appDocDir.path, 'Downloads'));
    }

    // Create directory if it doesn't exist
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }
}

// Extension to convert ResponseBody stream to bytes
extension ResponseBodyExtension on ResponseBody {
  Future<Uint8List> toBytes() async {
    final chunks = <int>[];
    await for (final chunk in stream) {
      chunks.addAll(chunk);
    }
    return Uint8List.fromList(chunks);
  }
}
