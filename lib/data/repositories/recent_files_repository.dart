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

  /// Add a new recent file record
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

  /// Get recent files with optional filtering by operation type
  Future<List<RecentFileModel>> getRecentFiles({
    int limit = 50,
    String? operationType,
  }) async {
    return await _dbHelper.getRecentFiles(
      limit: limit,
      operationType: operationType,
    );
  }

  /// Get a single recent file by ID
  Future<RecentFileModel?> getRecentFileById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'recent_files',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return RecentFileModel.fromMap(maps.first);
    }
    return null;
  }

  /// Get a recent file by result file path
  Future<RecentFileModel?> getRecentFileByPath(String path) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'recent_files',
      where: 'result_file_path = ?',
      whereArgs: [path],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return RecentFileModel.fromMap(maps.first);
    }
    return null;
  }

  /// Get statistics about recent file operations
  Future<Map<String, int>> getRecentFilesStats() async {
    return await _dbHelper.getRecentFilesStats();
  }

  /// Get counts of different operation types
  Future<Map<String, int>> getOperationStats() async {
    return await _dbHelper.getOperationStats();
  }

  /// Delete old recent files, keeping the specified number of days
  Future<int> deleteOldRecentFiles({int keepDays = 30}) async {
    return await _dbHelper.deleteOldRecentFiles(keepDays: keepDays);
  }

  /// Clear all recent files records
  Future<int> clearAllRecentFiles() async {
    return await _dbHelper.clearAllRecentFiles();
  }

  /// Delete a specific recent file by ID
  Future<int> deleteRecentFile(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'recent_files',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get recent files of a specific operation type
  Future<List<RecentFileModel>> getRecentFilesByType(
      String operationType) async {
    return await getRecentFiles(operationType: operationType);
  }

  /// Get all unique operation types
  Future<List<String>> getUniqueOperationTypes() async {
    final stats = await getOperationStats();
    return stats.keys.toList();
  }

  /// Update a recent file record
  Future<int> updateRecentFile(RecentFileModel file) async {
    if (file.id == null) return 0;

    final db = await _dbHelper.database;
    return await db.update(
      'recent_files',
      file.toMap(),
      where: 'id = ?',
      whereArgs: [file.id],
    );
  }

  /// Update the result file path for a recent file
  Future<int> updateResultFilePath(int id, String newPath) async {
    final db = await _dbHelper.database;
    return await db.update(
      'recent_files',
      {'result_file_path': newPath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
