// lib/core/utils/file_utils.dart
import 'dart:io';
import 'package:path/path.dart' as path;

class FileUtils {
  /// Get file extension without dot
  static String getExtension(String filePath) {
    return path.extension(filePath).toLowerCase().replaceFirst('.', '');
  }

  /// Check if file is PDF
  static bool isPdf(String filePath) {
    return getExtension(filePath) == 'pdf';
  }

  /// Check if file is image
  static bool isImage(String filePath) {
    final ext = getExtension(filePath);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  /// Check if file is document
  static bool isDocument(String filePath) {
    final ext = getExtension(filePath);
    return ['pdf', 'docx', 'doc', 'xlsx', 'xls', 'pptx', 'txt', 'rtf', 'html']
        .contains(ext);
  }

  /// Get file size in human readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get file name without extension
  static String getFileNameWithoutExtension(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  /// Get safe filename for download
  static String getSafeFileName(String fileName) {
    // Remove or replace invalid characters
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  /// Validate file for upload
  static String? validateFile(File file, {int? maxSizeInMB}) {
    if (!file.existsSync()) {
      return 'File does not exist';
    }

    final stat = file.statSync();
    final maxSize = (maxSizeInMB ?? 50) * 1024 * 1024; // Default 50MB

    if (stat.size > maxSize) {
      return 'File size exceeds ${maxSizeInMB ?? 50}MB limit';
    }

    if (stat.size == 0) {
      return 'File is empty';
    }

    return null; // Valid file
  }
}
