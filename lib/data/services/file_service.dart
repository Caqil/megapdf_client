import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/core/utils/permission_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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

  FileService(this._apiService) {
    _initializeDownloader();
  }

  void _initializeDownloader() {
    // Configure the downloader
    FileDownloader.setLogEnabled(true);
    FileDownloader.setMaximumParallelDownloads(5);
  }

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

      // Get file download URL from API
      final response = await _apiService.downloadFile(folder, filename);

      // Create safe filename with timestamp to avoid conflicts
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(filename);
      final baseName =
          customFileName ?? path.basenameWithoutExtension(filename);
      final safeBaseName = _createSafeFileName(baseName);
      final localFileName = '${safeBaseName}_$timestamp$extension';

      // Create subdirectory for organized downloads
      final subPath = 'MegaPDF/$folder';

      // Track download progress
      double currentProgress = 0.0;

      // Download file using flutter_file_downloader
      final File? downloadedFile = await FileDownloader.downloadFile(
        url: response.url,
        name: localFileName,
        subPath: subPath,
        downloadDestination: DownloadDestinations.publicDownloads,
        notificationType: NotificationType.progressOnly,
        onProgress: (String? fileName, double progress) {
          currentProgress = progress;
          onProgress?.call(progress);
        },
        onDownloadCompleted: (String filePath) {
          print('Download completed: $filePath');
        },
        onDownloadError: (String error) {
          print('Download error: $error');
          throw ApiException.unknown('Download failed: $error');
        },
      );

      if (downloadedFile == null || !await downloadedFile.exists()) {
        throw ApiException.unknown('Failed to download file');
      }

      return downloadedFile.path;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException.unknown('Failed to download file: ${e.toString()}');
    }
  }

  /// Download multiple files in bulk
  Future<List<String?>> downloadMultipleFiles({
    required List<DownloadRequest> requests,
    bool isParallel = true,
    Function(int completed, int total)? onBatchProgress,
    Function()? onAllDownloaded,
  }) async {
    try {
      await _requestStoragePermissions();

      // Prepare download URLs
      final List<String> urls = [];
      final List<String> fileNames = [];

      for (final request in requests) {
        final response =
            await _apiService.downloadFile(request.folder, request.filename);
        urls.add(response.url);

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = path.extension(request.filename);
        final baseName = request.customFileName ??
            path.basenameWithoutExtension(request.filename);
        final safeBaseName = _createSafeFileName(baseName);
        final localFileName = '${safeBaseName}_$timestamp$extension';
        fileNames.add(localFileName);
      }

      // Download all files
      final List<File?> downloadedFiles = await FileDownloader.downloadFiles(
        urls: urls,
        isParallel: isParallel,
        onAllDownloaded: onAllDownloaded,
      );

      // Convert to paths
      return downloadedFiles.map((file) => file?.path).toList();
    } catch (e) {
      throw ApiException.unknown('Failed to download files: ${e.toString()}');
    }
  }

  /// Download file to app's private directory (not visible in file manager)
  Future<String> downloadToAppDirectory({
    required String folder,
    required String filename,
    String? customFileName,
    Function(double progress)? onProgress,
  }) async {
    try {
      final response = await _apiService.downloadFile(folder, filename);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(filename);
      final baseName =
          customFileName ?? path.basenameWithoutExtension(filename);
      final safeBaseName = _createSafeFileName(baseName);
      final localFileName = '${safeBaseName}_$timestamp$extension';

      final File? downloadedFile = await FileDownloader.downloadFile(
        url: response.url,
        name: localFileName,
        subPath: 'MegaPDF/$folder',
        downloadDestination: DownloadDestinations.appFiles,
        notificationType: NotificationType.disabled,
        onProgress: (String? fileName, double progress) {
          onProgress?.call(progress);
        },
        onDownloadError: (String error) {
          throw ApiException.unknown('Download failed: $error');
        },
      );

      if (downloadedFile == null || !await downloadedFile.exists()) {
        throw ApiException.unknown('Failed to download file');
      }

      return downloadedFile.path;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
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

  /// Get all downloaded PDF files from public downloads
  Future<List<File>> getDownloadedFiles() async {
    try {
      // For public downloads, we need to scan the Downloads/MegaPDF directory
      if (Platform.isAndroid) {
        final downloadDir = Directory('/storage/emulated/0/Download/MegaPDF');
        return await _scanDirectoryForPDFs(downloadDir);
      } else if (Platform.isIOS) {
        // For iOS, files are in app directory
        final appDocDir = await getApplicationDocumentsDirectory();
        final downloadDir = Directory(path.join(appDocDir.path, 'Downloads'));
        return await _scanDirectoryForPDFs(downloadDir);
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get files downloaded to app directory
  Future<List<File>> getAppDirectoryFiles() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory(path.join(appDocDir.path, 'MegaPDF'));
      return await _scanDirectoryForPDFs(downloadDir);
    } catch (e) {
      return [];
    }
  }

  Future<List<File>> _scanDirectoryForPDFs(Directory directory) async {
    if (!await directory.exists()) {
      return [];
    }

    final files = <File>[];
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
        files.add(entity);
      }
    }

    // Sort by modification date (newest first)
    files.sort((a, b) {
      final aStat = a.statSync();
      final bStat = b.statSync();
      return bStat.modified.compareTo(aStat.modified);
    });

    return files;
  }

  /// Clean up old downloaded files (older than specified days)
  Future<void> cleanupOldFiles({int olderThanDays = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));

      // Clean public downloads
      final publicFiles = await getDownloadedFiles();
      for (final file in publicFiles) {
        final stat = file.statSync();
        if (stat.modified.isBefore(cutoffDate)) {
          await file.delete();
        }
      }

      // Clean app directory files
      final appFiles = await getAppDirectoryFiles();
      for (final file in appFiles) {
        final stat = file.statSync();
        if (stat.modified.isBefore(cutoffDate)) {
          await file.delete();
        }
      }
    } catch (e) {
      // Silently fail cleanup
      print('Cleanup failed: $e');
    }
  }

  /// Cancel an ongoing download
  Future<bool> cancelDownload(int downloadId) async {
    try {
      return await FileDownloader.cancelDownload(downloadId);
    } catch (e) {
      return false;
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
      final permissionManager = PermissionManager();

      // Check if permissions are already granted
      final hasPermissions = await permissionManager.hasDownloadPermissions();
      if (hasPermissions) return;

      // Request permissions (this will handle different Android versions)
      throw ApiException.forbidden(
        'Storage permission is required to download files. Please grant storage permission in app settings.',
      );
    }
  }

  String _createSafeFileName(String fileName) {
    // Remove or replace invalid characters
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(
            RegExp(r'_{2,}'), '_') // Replace multiple underscores with single
        .trim();
  }
}

// Helper class for bulk downloads
class DownloadRequest {
  final String folder;
  final String filename;
  final String? customFileName;

  const DownloadRequest({
    required this.folder,
    required this.filename,
    this.customFileName,
  });
}
