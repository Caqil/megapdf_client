// lib/data/repositories/recent_files_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database_helper.dart';
import '../models/recent_file_model.dart';

part 'recent_files_repository.g.dart';

@riverpod
RecentFilesRepository recentFilesRepository(Ref ref) {
  return RecentFilesRepository();
}

class RecentFilesRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> addRecentFile({
    required String originalFileName,
    required String resultFileName,
    required String operation,
    required String operationType,
    required String originalFilePath,
    String? resultFilePath,
    required String originalSize,
    String? resultSize,
    Map<String, dynamic>? metadata,
  }) async {
    final recentFile = RecentFileModel(
      originalFileName: originalFileName,
      resultFileName: resultFileName,
      operation: operation,
      operationType: operationType,
      originalFilePath: originalFilePath,
      resultFilePath: resultFilePath,
      originalSize: originalSize,
      resultSize: resultSize,
      processedAt: DateTime.now(),
      metadata: metadata,
    );

    return await _dbHelper.insertRecentFile(recentFile);
  }

  Future<List<RecentFileModel>> getRecentFiles({
    int limit = 50,
    String? operationType,
  }) async {
    return await _dbHelper.getRecentFiles(
      limit: limit,
      operationType: operationType,
    );
  }

  Future<Map<String, int>> getRecentFilesStats() async {
    return await _dbHelper.getRecentFilesStats();
  }

  Future<Map<String, int>> getOperationStats() async {
    return await _dbHelper.getOperationStats();
  }

  Future<int> deleteOldRecentFiles({int keepDays = 30}) async {
    return await _dbHelper.deleteOldRecentFiles(keepDays: keepDays);
  }

  Future<int> clearAllRecentFiles() async {
    return await _dbHelper.clearAllRecentFiles();
  }

  Future<List<RecentFileModel>> getRecentFilesByType(
      String operationType) async {
    return await getRecentFiles(operationType: operationType);
  }

  Future<List<String>> getUniqueOperationTypes() async {
    final stats = await getOperationStats();
    return stats.keys.toList();
  }
}
