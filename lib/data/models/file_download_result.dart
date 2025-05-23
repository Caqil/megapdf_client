// lib/data/models/file_download_result.dart
import 'dart:typed_data';

class FileDownloadResult {
  final bool success;
  final String? message;
  final String? fileName;
  final Uint8List? data;
  final int? fileSize;

  FileDownloadResult({
    required this.success,
    this.message,
    this.fileName,
    this.data,
    this.fileSize,
  });

  factory FileDownloadResult.fromJson(Map<String, dynamic> json) {
    return FileDownloadResult(
      success: json['success'] ?? false,
      message: json['message'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
    );
  }

  // Add a factory method to handle raw binary response
  factory FileDownloadResult.fromBytes(Uint8List bytes, {String? fileName}) {
    return FileDownloadResult(
      success: bytes.isNotEmpty,
      fileName: fileName,
      data: bytes,
      fileSize: bytes.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'fileName': fileName,
      'fileSize': fileSize,
    };
  }
}
