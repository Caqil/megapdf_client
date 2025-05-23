import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/recent_file_model.dart';
import '../../data/repositories/recent_files_repository.dart';
import '../../data/database/database_helper.dart';
import 'file_operation_notifier.dart';
import 'dart:convert';

part 'recent_files_provider.g.dart';

@riverpod
class RecentFilesNotifier extends _$RecentFilesNotifier {
  @override
  RecentFilesState build() {
    print('🔧 PROVIDER: Building RecentFilesNotifier');

    // Listen to file operations and refresh when they complete
    ref.listen<int>(fileOperationNotifierProvider, (previous, next) {
      print('🔧 PROVIDER: File operation notification: $previous -> $next');
      if (previous != null && next > previous) {
        print('🔧 PROVIDER: New file operation, refreshing...');
        Future.delayed(const Duration(milliseconds: 500), () {
          loadRecentFiles(operationType: state.currentFilter);
          loadStats();
        });
      }
    });

    // Auto-load recent files when provider is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔧 PROVIDER: Auto-loading recent files');
      loadRecentFiles();
      loadStats();
    });
    return const RecentFilesState();
  }

  Future<void> loadRecentFiles({String? operationType}) async {
    print('🔧 PROVIDER: loadRecentFiles called with filter: $operationType');

    state = state.copyWith(isLoading: true, error: null);
    print('🔧 PROVIDER: Set loading state');

    try {
      // Direct database access to ensure we get the data
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      // Get count for verification
      final countResult =
          await db.rawQuery("SELECT COUNT(*) as count FROM recent_files");
      final totalCount = countResult.first['count'] as int;
      print('🔧 PROVIDER: Database contains $totalCount files');

      // Get files with proper ordering
      List<Map<String, dynamic>> rawFiles;
      if (operationType != null) {
        rawFiles = await db.query(
          'recent_files',
          where: 'operation_type = ?',
          whereArgs: [operationType],
          orderBy: 'processed_at DESC',
          limit: 50,
        );
      } else {
        rawFiles = await db.query(
          'recent_files',
          orderBy: 'processed_at DESC',
          limit: 50,
        );
      }

      print('🔧 PROVIDER: Query returned ${rawFiles.length} files');

      // Parse files manually to ensure success
      final List<RecentFileModel> recentFiles = [];
      for (int i = 0; i < rawFiles.length; i++) {
        try {
          final rawFile = rawFiles[i];
          final Map<String, dynamic> fileMap =
              Map<String, dynamic>.from(rawFile);

          // Handle metadata parsing
          if (fileMap['metadata'] != null &&
              fileMap['metadata'].toString().isNotEmpty) {
            try {
              fileMap['metadata'] = jsonDecode(fileMap['metadata'].toString());
            } catch (e) {
              print('🔧 PROVIDER: Failed to parse metadata for file $i: $e');
              fileMap['metadata'] = null;
            }
          }

          final recentFile = RecentFileModel.fromMap(fileMap);
          recentFiles.add(recentFile);
          print(
              '🔧 PROVIDER: Successfully added file $i: ${recentFile.originalFileName}');
        } catch (e) {
          print('🔧 PROVIDER: Failed to parse file $i: $e');
        }
      }

      print('🔧 PROVIDER: Successfully parsed ${recentFiles.length} files');

      // Get operation types for filtering
      final operationResult = await db.rawQuery('''
        SELECT DISTINCT operation_type FROM recent_files 
        WHERE operation_type IS NOT NULL AND operation_type != ''
      ''');
      final operationTypes = operationResult
          .map((row) => row['operation_type'] as String)
          .toList();

      print('🔧 PROVIDER: Found operation types: $operationTypes');

      // Force state update
      final newState = state.copyWith(
        isLoading: false,
        recentFiles: recentFiles,
        operationTypes: operationTypes,
        currentFilter: operationType,
        error: null,
      );

      state = newState;
      print(
          '🔧 PROVIDER: State updated! New state has ${state.recentFiles.length} files');

      // Force a rebuild by accessing the state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print(
            '🔧 PROVIDER: Post-frame callback - State has ${state.recentFiles.length} files');
      });
    } catch (e, stackTrace) {
      print('🔧 PROVIDER: Error in loadRecentFiles: $e');
      print('🔧 PROVIDER: Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadStats() async {
    print('🔧 PROVIDER: Loading stats');

    try {
      final dbHelper = DatabaseHelper();
      final stats = await dbHelper.getRecentFilesStats();
      print('🔧 PROVIDER: Stats loaded: $stats');

      state = state.copyWith(stats: stats);
      print('🔧 PROVIDER: Stats updated in state');
    } catch (e) {
      print('🔧 PROVIDER: Failed to load stats: $e');
    }
  }

  Future<void> refreshRecentFiles() async {
    print('🔧 PROVIDER: Manual refresh requested');
    await loadRecentFiles(operationType: state.currentFilter);
    await loadStats();
  }

  Future<void> clearAllRecentFiles() async {
    try {
      print('🔧 PROVIDER: Clearing all recent files');
      final repository = ref.read(recentFilesRepositoryProvider);
      await repository.clearAllRecentFiles();

      // Reload
      await loadRecentFiles();
      await loadStats();
    } catch (e) {
      print('🔧 PROVIDER: Error clearing files: $e');
      state = state.copyWith(error: 'Failed to clear recent files: $e');
    }
  }

  Future<void> deleteOldRecentFiles({int keepDays = 30}) async {
    try {
      print('🔧 PROVIDER: Deleting old files (>${keepDays} days)');
      final repository = ref.read(recentFilesRepositoryProvider);
      await repository.deleteOldRecentFiles(keepDays: keepDays);

      // Reload
      await loadRecentFiles();
      await loadStats();
    } catch (e) {
      print('🔧 PROVIDER: Error deleting old files: $e');
      state = state.copyWith(error: 'Failed to delete old files: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Add this method for debugging
  void forceRefresh() {
    print('🔧 PROVIDER: Force refresh triggered');
    // Trigger a complete rebuild
    ref.invalidateSelf();
  }
}

class RecentFilesState {
  final List<RecentFileModel> recentFiles;
  final List<String> operationTypes;
  final Map<String, int> stats;
  final String? currentFilter;
  final bool isLoading;
  final String? error;

  const RecentFilesState({
    this.recentFiles = const [],
    this.operationTypes = const [],
    this.stats = const {},
    this.currentFilter,
    this.isLoading = false,
    this.error,
  });

  RecentFilesState copyWith({
    List<RecentFileModel>? recentFiles,
    List<String>? operationTypes,
    Map<String, int>? stats,
    String? currentFilter,
    bool? isLoading,
    String? error,
  }) {
    return RecentFilesState(
      recentFiles: recentFiles ?? this.recentFiles,
      operationTypes: operationTypes ?? this.operationTypes,
      stats: stats ?? this.stats,
      currentFilter: currentFilter ?? this.currentFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasRecentFiles => recentFiles.isNotEmpty;
  bool get hasError => error != null;
}
