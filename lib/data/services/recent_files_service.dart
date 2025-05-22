// lib/data/services/recent_files_service.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/recent_files_repository.dart';
import '../../core/utils/file_utils.dart';

part 'recent_files_service.g.dart';

@riverpod
RecentFilesService recentFilesService(Ref ref) {
  return RecentFilesService(ref.read(recentFilesRepositoryProvider));
}

class RecentFilesService {
  final RecentFilesRepository _repository;

  RecentFilesService(this._repository);

  Future<void> trackFileOperation({
    required File originalFile,
    required String operation,
    required String operationType,
    String? resultFileName,
    String? resultFilePath,
    String? resultSize,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final originalFileName = originalFile.path.split('/').last;
      final originalSize = FileUtils.formatFileSize(originalFile.lengthSync());

      await _repository.addRecentFile(
        originalFileName: originalFileName,
        resultFileName: resultFileName ?? originalFileName,
        operation: operation,
        operationType: operationType,
        originalFilePath: originalFile.path,
        resultFilePath: resultFilePath,
        originalSize: originalSize,
        resultSize: resultSize,
        metadata: metadata,
      );
    } catch (e) {
      // Log error but don't throw to avoid disrupting main operations
      print('Failed to track file operation: $e');
    }
  }

  Future<void> trackCompress({
    required File originalFile,
    required String resultFileName,
    String? resultFilePath,
    String? compressionRatio,
    int? originalSizeBytes,
    int? compressedSizeBytes,
  }) async {
    final metadata = <String, dynamic>{
      'compression_ratio': compressionRatio,
      'original_size_bytes': originalSizeBytes,
      'compressed_size_bytes': compressedSizeBytes,
    };

    String? resultSize;
    if (compressedSizeBytes != null) {
      resultSize = FileUtils.formatFileSize(compressedSizeBytes);
    }

    await trackFileOperation(
      originalFile: originalFile,
      operation: 'Compressed',
      operationType: 'compress',
      resultFileName: resultFileName,
      resultFilePath: resultFilePath,
      resultSize: resultSize,
      metadata: metadata,
    );
  }

  Future<void> trackMerge({
    required List<File> originalFiles,
    required String resultFileName,
    String? resultFilePath,
    int? mergedSizeBytes,
    int? totalInputSizeBytes,
  }) async {
    final metadata = <String, dynamic>{
      'file_count': originalFiles.length,
      'file_names': originalFiles.map((f) => f.path.split('/').last).toList(),
      'merged_size_bytes': mergedSizeBytes,
      'total_input_size_bytes': totalInputSizeBytes,
    };

    String? resultSize;
    if (mergedSizeBytes != null) {
      resultSize = FileUtils.formatFileSize(mergedSizeBytes);
    }

    // Use first file as primary, but track all files in metadata
    await trackFileOperation(
      originalFile: originalFiles.first,
      operation: 'Merged',
      operationType: 'merge',
      resultFileName: resultFileName,
      resultFilePath: resultFilePath,
      resultSize: resultSize,
      metadata: metadata,
    );
  }

  Future<void> trackSplit({
    required File originalFile,
    required int splitCount,
    List<String>? splitFileNames,
  }) async {
    final metadata = <String, dynamic>{
      'split_count': splitCount,
      'split_file_names': splitFileNames,
    };

    await trackFileOperation(
      originalFile: originalFile,
      operation: 'Split',
      operationType: 'split',
      resultFileName: '$splitCount parts',
      metadata: metadata,
    );
  }

  Future<void> trackConvert({
    required File originalFile,
    required String resultFileName,
    String? resultFilePath,
    required String inputFormat,
    required String outputFormat,
    bool? ocrEnabled,
    int? quality,
  }) async {
    final metadata = <String, dynamic>{
      'input_format': inputFormat,
      'output_format': outputFormat,
      'ocr_enabled': ocrEnabled,
      'quality': quality,
    };

    await trackFileOperation(
      originalFile: originalFile,
      operation: 'Converted',
      operationType: 'convert',
      resultFileName: resultFileName,
      resultFilePath: resultFilePath,
      metadata: metadata,
    );
  }

  Future<void> trackProtect({
    required File originalFile,
    required String resultFileName,
    String? resultFilePath,
    String? permissionLevel,
  }) async {
    final metadata = <String, dynamic>{
      'permission_level': permissionLevel,
    };

    await trackFileOperation(
      originalFile: originalFile,
      operation: 'Protected',
      operationType: 'protect',
      resultFileName: resultFileName,
      resultFilePath: resultFilePath,
      metadata: metadata,
    );
  }

  Future<void> trackUnlock({
    required File originalFile,
    required String resultFileName,
    String? resultFilePath,
  }) async {
    await trackFileOperation(
      originalFile: originalFile,
      operation: 'Unlocked',
      operationType: 'unlock',
      resultFileName: resultFileName,
      resultFilePath: resultFilePath,
    );
  }

  Future<void> trackRotate({
    required File originalFile,
    required String resultFileName,
    String? resultFilePath,
    required int angle,
    String? pagesRotated,
  }) async {
    final metadata = <String, dynamic>{
      'rotation_angle': angle,
      'pages_rotated': pagesRotated,
    };

    await trackFileOperation(
      originalFile: originalFile,
      operation: 'Rotated',
      operationType: 'rotate',
      resultFileName: resultFileName,
      resultFilePath: resultFilePath,
      metadata: metadata,
    );
  }

  Future<void> trackWatermark({
    required File originalFile,
    required String resultFileName,
    String? resultFilePath,
    required String watermarkType,
    String? watermarkText,
    String? position,
  }) async {
    final metadata = <String, dynamic>{
      'watermark_type': watermarkType,
      'watermark_text': watermarkText,
      'position': position,
    };

    await trackFileOperation(
      originalFile: originalFile,
      operation: 'Watermarked',
      operationType: 'watermark',
      resultFileName: resultFileName,
      resultFilePath: resultFilePath,
      metadata: metadata,
    );
  }

  Future<void> trackPageNumbers({
    required File originalFile,
    required String resultFileName,
    String? resultFilePath,
    String? position,
    String? format,
    int? totalPages,
    int? numberedPages,
  }) async {
    final metadata = <String, dynamic>{
      'position': position,
      'format': format,
      'total_pages': totalPages,
      'numbered_pages': numberedPages,
    };

    await trackFileOperation(
      originalFile: originalFile,
      operation: 'Page Numbers Added',
      operationType: 'page_numbers',
      resultFileName: resultFileName,
      resultFilePath: resultFilePath,
      metadata: metadata,
    );
  }
}
