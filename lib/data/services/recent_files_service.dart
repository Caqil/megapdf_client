// lib/data/services/recent_files_service.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/recent_files_repository.dart';
import '../../core/utils/file_utils.dart';

part 'recent_files_service.g.dart';

@riverpod
RecentFilesService recentFilesService(Ref ref) {
  final repository = ref.watch(recentFilesRepositoryProvider);
  return RecentFilesService(repository);
}

class RecentFilesService {
  final RecentFilesRepository _repository;

  RecentFilesService(this._repository);

  Future<void> trackScan({
    required String resultFilePath,
    required String resultFileName,
    required int originalSize,
    bool isImage = false,
  }) async {
    final originalFileName = isImage ? 'Scanned Image' : 'Scanned Document';
    final operation = isImage ? 'Scan to Image' : 'Scan to PDF';
    final resultSize =
        FileUtils.formatFileSize(File(resultFilePath).lengthSync());

    await _repository.addRecentFile(
      originalFileName: originalFileName,
      resultFileName: resultFileName,
      operation: operation,
      operationType: 'scan',
      originalFilePath: 'N/A', // No original file for scans
      resultFilePath: resultFilePath,
      originalSize: FileUtils.formatFileSize(originalSize),
      resultSize: resultSize,
      metadata: {
        'scan_type': isImage ? 'image' : 'pdf',
        'scan_date': DateTime.now().toIso8601String(),
      },
    );
  }

  // Existing methods for other operations...
  Future<void> trackCompress({
    required File originalFile,
    required String resultFileName,
    required String resultFilePath,
    String? compressionRatio,
    int? originalSizeBytes,
    int? compressedSizeBytes,
  }) async {
    final originalFileName = path.basename(originalFile.path);
    final originalSize = FileUtils.formatFileSize(originalFile.lengthSync());
    final resultSize = compressedSizeBytes != null
        ? FileUtils.formatFileSize(compressedSizeBytes)
        : 'Unknown';

    await _repository.addRecentFile(
      originalFileName: originalFileName,
      resultFileName: resultFileName,
      operation: 'Compress PDF',
      operationType: 'compress',
      originalFilePath: originalFile.path,
      resultFilePath: resultFilePath,
      originalSize: originalSize,
      resultSize: resultSize,
      metadata: {
        'compression_ratio': compressionRatio,
        'original_size_bytes': originalSizeBytes,
        'compressed_size_bytes': compressedSizeBytes,
      },
    );
  }

  Future<void> trackSplit({
    required File originalFile,
    required int splitCount,
    required List<String> splitFileNames,
  }) async {
    final originalFileName = path.basename(originalFile.path);
    final originalSize = FileUtils.formatFileSize(originalFile.lengthSync());

    await _repository.addRecentFile(
      originalFileName: originalFileName,
      resultFileName: 'Multiple Files',
      operation: 'Split PDF',
      operationType: 'split',
      originalFilePath: originalFile.path,
      resultFilePath: null, // Multiple files
      originalSize: originalSize,
      resultSize: null,
      metadata: {
        'split_count': splitCount,
        'split_file_names': splitFileNames,
      },
    );
  }

  Future<void> trackMerge({
    required List<File> originalFiles,
    required String resultFileName,
    required String resultFilePath,
    int? mergedSize,
    int? totalInputSize,
  }) async {
    final originalFileNames =
        originalFiles.map((f) => path.basename(f.path)).join(', ');
    final originalSize = totalInputSize != null
        ? FileUtils.formatFileSize(totalInputSize)
        : 'Unknown';
    final resultSize =
        mergedSize != null ? FileUtils.formatFileSize(mergedSize) : 'Unknown';

    await _repository.addRecentFile(
      originalFileName: originalFileNames,
      resultFileName: resultFileName,
      operation: 'Merge PDFs',
      operationType: 'merge',
      originalFilePath: originalFiles.first.path, // Use first file path
      resultFilePath: resultFilePath,
      originalSize: originalSize,
      resultSize: resultSize,
      metadata: {
        'file_count': originalFiles.length,
        'merged_size': mergedSize,
        'total_input_size': totalInputSize,
      },
    );
  }

  Future<void> trackWatermark({
    required File originalFile,
    required String resultFileName,
    required String resultFilePath,
    required String watermarkType,
    String? watermarkText,
    required String position,
  }) async {
    final originalFileName = path.basename(originalFile.path);
    final originalSize = FileUtils.formatFileSize(originalFile.lengthSync());
    final resultFile = File(resultFilePath);
    final resultSize = FileUtils.formatFileSize(resultFile.lengthSync());
    final operation =
        watermarkType == 'text' ? 'Add Text Watermark' : 'Add Image Watermark';

    await _repository.addRecentFile(
      originalFileName: originalFileName,
      resultFileName: resultFileName,
      operation: operation,
      operationType: 'watermark',
      originalFilePath: originalFile.path,
      resultFilePath: resultFilePath,
      originalSize: originalSize,
      resultSize: resultSize,
      metadata: {
        'watermark_type': watermarkType,
        'watermark_text': watermarkText,
        'position': position,
      },
    );
  }

  Future<void> trackConvert({
    required File originalFile,
    required String resultFileName,
    required String resultFilePath,
    required String inputFormat,
    required String outputFormat,
    required bool ocrEnabled,
    required int quality,
  }) async {
    final originalFileName = path.basename(originalFile.path);
    final originalSize = FileUtils.formatFileSize(originalFile.lengthSync());
    final resultFile = File(resultFilePath);
    final resultSize = FileUtils.formatFileSize(resultFile.lengthSync());
    final operation =
        'Convert ${inputFormat.toUpperCase()} to ${outputFormat.toUpperCase()}';

    await _repository.addRecentFile(
      originalFileName: originalFileName,
      resultFileName: resultFileName,
      operation: operation,
      operationType: 'convert',
      originalFilePath: originalFile.path,
      resultFilePath: resultFilePath,
      originalSize: originalSize,
      resultSize: resultSize,
      metadata: {
        'input_format': inputFormat,
        'output_format': outputFormat,
        'ocr_enabled': ocrEnabled,
        'quality': quality,
      },
    );
  }

  Future<void> trackProtect({
    required File originalFile,
    required String resultFileName,
    required String resultFilePath,
    required String permissionLevel,
  }) async {
    final originalFileName = path.basename(originalFile.path);
    final originalSize = FileUtils.formatFileSize(originalFile.lengthSync());
    final resultFile = File(resultFilePath);
    final resultSize = FileUtils.formatFileSize(resultFile.lengthSync());

    await _repository.addRecentFile(
      originalFileName: originalFileName,
      resultFileName: resultFileName,
      operation: 'Protect PDF',
      operationType: 'protect',
      originalFilePath: originalFile.path,
      resultFilePath: resultFilePath,
      originalSize: originalSize,
      resultSize: resultSize,
      metadata: {
        'permission_level': permissionLevel,
      },
    );
  }

  Future<void> trackUnlock({
    required File originalFile,
    required String resultFileName,
    required String resultFilePath,
  }) async {
    final originalFileName = path.basename(originalFile.path);
    final originalSize = FileUtils.formatFileSize(originalFile.lengthSync());
    final resultFile = File(resultFilePath);
    final resultSize = FileUtils.formatFileSize(resultFile.lengthSync());

    await _repository.addRecentFile(
      originalFileName: originalFileName,
      resultFileName: resultFileName,
      operation: 'Unlock PDF',
      operationType: 'unlock',
      originalFilePath: originalFile.path,
      resultFilePath: resultFilePath,
      originalSize: originalSize,
      resultSize: resultSize,
    );
  }

  Future<void> trackRotate({
    required File originalFile,
    required String resultFileName,
    required String resultFilePath,
    required int angle,
    String? pagesRotated,
  }) async {
    final originalFileName = path.basename(originalFile.path);
    final originalSize = FileUtils.formatFileSize(originalFile.lengthSync());
    final resultFile = File(resultFilePath);
    final resultSize = FileUtils.formatFileSize(resultFile.lengthSync());

    await _repository.addRecentFile(
      originalFileName: originalFileName,
      resultFileName: resultFileName,
      operation: 'Rotate PDF',
      operationType: 'rotate',
      originalFilePath: originalFile.path,
      resultFilePath: resultFilePath,
      originalSize: originalSize,
      resultSize: resultSize,
      metadata: {
        'angle': angle,
        'pages_rotated': pagesRotated ?? 'all',
      },
    );
  }

  Future<void> trackPageNumbers({
    required File originalFile,
    required String resultFileName,
    required String resultFilePath,
    required String position,
    required String format,
    int? totalPages,
    int? numberedPages,
  }) async {
    final originalFileName = path.basename(originalFile.path);
    final originalSize = FileUtils.formatFileSize(originalFile.lengthSync());
    final resultFile = File(resultFilePath);
    final resultSize = FileUtils.formatFileSize(resultFile.lengthSync());

    await _repository.addRecentFile(
      originalFileName: originalFileName,
      resultFileName: resultFileName,
      operation: 'Add Page Numbers',
      operationType: 'pagenumbers',
      originalFilePath: originalFile.path,
      resultFilePath: resultFilePath,
      originalSize: originalSize,
      resultSize: resultSize,
      metadata: {
        'position': position,
        'format': format,
        'total_pages': totalPages,
        'numbered_pages': numberedPages,
      },
    );
  }
}
