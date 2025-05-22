// lib/core/utils/download_manager.dart
import 'dart:io';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:path/path.dart' as path;

/// Centralized download manager for handling PDF file downloads
class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal() {
    _initialize();
  }

  void _initialize() {
    // Configure the downloader
    FileDownloader.setLogEnabled(true);
    FileDownloader.setMaximumParallelDownloads(3); // Conservative for PDF files
  }

  /// Download a single PDF file with progress tracking
  Future<String?> downloadPdfFile({
    required String url,
    required String fileName,
    String? subFolder,
    Function(double progress)? onProgress,
    Function(int downloadId)? onDownloadIdReceived,
    Function(String error)? onError,
  }) async {
    try {
      final safeFileName = _createSafeFileName(fileName);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final finalFileName =
          '${path.basenameWithoutExtension(safeFileName)}_$timestamp${path.extension(safeFileName)}';

      int? downloadId;

      final File? downloadedFile = await FileDownloader.downloadFile(
        url: url,
        name: finalFileName,
        subPath: subFolder != null ? 'MegaPDF/$subFolder' : 'MegaPDF',
        downloadDestination: DownloadDestinations.publicDownloads,
        notificationType: NotificationType.progressOnly,
        onDownloadRequestIdReceived: (id) {
          downloadId = id;
          onDownloadIdReceived?.call(id);
        },
        onProgress: (String? fileName, double progress) {
          onProgress?.call(progress);
        },
        onDownloadCompleted: (String filePath) {
          print('PDF Download completed: $filePath');
        },
        onDownloadError: (String error) {
          print('PDF Download error: $error');
          onError?.call(error);
        },
      );

      return downloadedFile?.path;
    } catch (e) {
      onError?.call(e.toString());
      return null;
    }
  }

  /// Download multiple PDF files in batch
  Future<List<String?>> downloadMultiplePdfFiles({
    required List<String> urls,
    required List<String> fileNames,
    String? subFolder,
    bool isParallel = false, // Conservative for PDFs
    Function()? onAllDownloaded,
  }) async {
    try {
      // Prepare safe file names
      final List<String> safeFileNames = fileNames.map((name) {
        final safeName = _createSafeFileName(name);
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        return '${path.basenameWithoutExtension(safeName)}_$timestamp${path.extension(safeName)}';
      }).toList();

      final List<File?> downloadedFiles = await FileDownloader.downloadFiles(
        urls: urls,
        downloadDestination: DownloadDestinations.publicDownloads,
        notificationType: NotificationType.progressOnly,
        isParallel: isParallel,
        onAllDownloaded: onAllDownloaded,
      );

      return downloadedFiles.map((file) => file?.path).toList();
    } catch (e) {
      print('Batch download error: $e');
      return List.filled(urls.length, null);
    }
  }

  /// Download to app's private directory (not visible in file manager)
  Future<String?> downloadToAppDirectory({
    required String url,
    required String fileName,
    String? subFolder,
    Function(double progress)? onProgress,
    Function(String error)? onError,
  }) async {
    try {
      final safeFileName = _createSafeFileName(fileName);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final finalFileName =
          '${path.basenameWithoutExtension(safeFileName)}_$timestamp${path.extension(safeFileName)}';

      final File? downloadedFile = await FileDownloader.downloadFile(
        url: url,
        name: finalFileName,
        subPath: subFolder != null ? 'MegaPDF/$subFolder' : 'MegaPDF',
        downloadDestination: DownloadDestinations.appFiles,
        notificationType: NotificationType.disabled,
        onProgress: (String? fileName, double progress) {
          onProgress?.call(progress);
        },
        onDownloadError: (String error) {
          onError?.call(error);
        },
      );

      return downloadedFile?.path;
    } catch (e) {
      onError?.call(e.toString());
      return null;
    }
  }

  /// Cancel an ongoing download
  Future<bool> cancelDownload(int downloadId) async {
    try {
      return await FileDownloader.cancelDownload(downloadId);
    } catch (e) {
      print('Cancel download error: $e');
      return false;
    }
  }

  /// Get estimated file size for download planning
  Future<int?> getFileSize(String url) async {
    try {
      // This would require additional HTTP request to get Content-Length
      // For now, return null to indicate unknown size
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Configure download settings
  void configureDownloader({
    int? maxParallelDownloads,
    bool? enableLogging,
    NotificationType? defaultNotificationType,
  }) {
    if (maxParallelDownloads != null) {
      FileDownloader.setMaximumParallelDownloads(maxParallelDownloads);
    }

    if (enableLogging != null) {
      FileDownloader.setLogEnabled(enableLogging);
    }
  }

  /// Get download statistics
  Map<String, dynamic> getDownloadStats() {
    // This would require tracking downloads in a local database
    // For now, return basic info
    return {
      'maxParallelDownloads': 3,
      'totalDownloads': 0, // Would need to track this
      'activeDownloads': 0, // Would need to track this
    };
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

  /// Validate URL before download
  bool isValidDownloadUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Get recommended subfolder based on operation type
  String getSubfolderForOperation(String operationType) {
    switch (operationType.toLowerCase()) {
      case 'compress':
        return 'Compressed';
      case 'merge':
        return 'Merged';
      case 'split':
        return 'Split';
      case 'convert':
        return 'Converted';
      case 'protect':
        return 'Protected';
      case 'unlock':
        return 'Unlocked';
      case 'rotate':
        return 'Rotated';
      case 'watermark':
        return 'Watermarked';
      case 'page_numbers':
        return 'PageNumbers';
      default:
        return 'Processed';
    }
  }
}
