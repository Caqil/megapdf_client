// lib/core/extensions/file_extensions.dart
import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/file_utils.dart';

extension FileExtensions on File {
  /// Get file extension without dot
  String get extension => FileUtils.getExtension(this.path);

  /// Check if file is PDF
  bool get isPdf => FileUtils.isPdf(this.path);

  /// Check if file is image
  bool get isImage => FileUtils.isImage(this.path);

  /// Check if file is document
  bool get isDocument => FileUtils.isDocument(this.path);

  /// Get formatted file size
  String get formattedSize {
    final stat = this.statSync();
    return FileUtils.formatFileSize(stat.size);
  }

  /// Get file name without extension
  String get nameWithoutExtension {
    return FileUtils.getFileNameWithoutExtension(this.path);
  }

  /// Get base file name
  String get baseName => path.basename(this.path);

  /// Validate file for upload
  String? validate({int? maxSizeInMB}) {
    return FileUtils.validateFile(this, maxSizeInMB: maxSizeInMB);
  }
}
