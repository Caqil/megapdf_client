// lib/presentation/providers/recent_files_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/recent_file_model.dart';
import '../../data/repositories/recent_files_repository.dart';
import '../../data/database/database_helper.dart';
import 'file_operation_notifier.dart';
import 'file_path_provider.dart';
import 'dart:convert';

part 'recent_files_provider.g.dart';

@riverpod
class RecentFilesNotifier extends _$RecentFilesNotifier {
  static const int _pageSize = 20;
  static const int _initialLoadSize = 10;

  @override
  RecentFilesState build() {
    print('🔧 PROVIDER: Building RecentFilesNotifier');

    // Listen to file operations and refresh when they complete
    ref.listen<int>(fileOperationNotifierProvider, (previous, next) {
      print('🔧 PROVIDER: File operation notification: $previous -> $next');
      if (previous != null && next > previous) {
        print('🔧 PROVIDER: New file operation, refreshing...');
        Future.delayed(const Duration(milliseconds: 500), () {
          refreshRecentFiles();
        });
      }
    });

    // Also listen to file save notifications
    ref.listen<FileSaveState>(fileSaveNotifierProvider, (previous, next) {
      if (next.hasLastSaved &&
          (previous == null ||
              previous.lastSavedFilePath != next.lastSavedFilePath)) {
        print('🔧 PROVIDER: New file saved, refreshing...');
        Future.delayed(const Duration(milliseconds: 500), () {
          refreshRecentFiles();
          _immediateRefresh();
        });
      }
    });

    // Auto-load recent files when provider is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔧 PROVIDER: Auto-loading recent files');
      loadRecentFiles(isInitial: true);
      loadStats();
    });
    return const RecentFilesState();
  }

  // Immediate refresh without delay
  void _immediateRefresh() {
    Future.microtask(() async {
      await refreshRecentFiles();
      // Force UI rebuild
      ref.invalidateSelf();
    });
  }

  Future<void> loadRecentFiles({
    String? operationType,
    bool isInitial = false,
    bool showAllFiles = false,
  }) async {
    print(
        '🔧 PROVIDER: loadRecentFiles called with filter: $operationType, isInitial: $isInitial, showAll: $showAllFiles');

    // For initial load or when changing filters, reset pagination
    if (isInitial || state.currentFilter != operationType) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentFilter: operationType,
        currentPage: 0,
        hasMoreFiles: true,
        showingAllFiles: showAllFiles,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      // Get count for verification
      String countQuery = "SELECT COUNT(*) as count FROM recent_files";
      List<dynamic> countArgs = [];

      if (operationType != null) {
        countQuery += " WHERE operation_type = ?";
        countArgs.add(operationType);
      }

      final countResult = await db.rawQuery(countQuery, countArgs);
      final totalCount = countResult.first['count'] as int;
      print('🔧 PROVIDER: Database contains $totalCount files');

      // Determine limit based on mode
      int limit;
      int offset = 0;

      if (showAllFiles) {
        // Load all files when showing all
        limit = totalCount;
        offset = 0;
      } else if (isInitial) {
        // Load initial smaller set
        limit = _initialLoadSize;
        offset = 0;
      } else {
        // Load up to current page
        final currentPage = state.currentPage;
        limit = _initialLoadSize + (currentPage * _pageSize);
        offset = 0;
      }

      // Get files with proper ordering
      List<Map<String, dynamic>> rawFiles;
      if (operationType != null) {
        rawFiles = await db.query(
          'recent_files',
          where: 'operation_type = ?',
          whereArgs: [operationType],
          orderBy: 'processed_at DESC',
          limit: limit,
          offset: offset,
        );
      } else {
        rawFiles = await db.query(
          'recent_files',
          orderBy: 'processed_at DESC',
          limit: limit,
          offset: offset,
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

      // Verify file existence and accessibility
      final verifiedFiles = <RecentFileModel>[];
      for (final file in recentFiles) {
        if (file.resultFilePath != null) {
          try {
            final physicalFile = File(file.resultFilePath!);
            if (await physicalFile.exists()) {
              verifiedFiles.add(file);
              print(
                  '🔧 PROVIDER: Verified file exists: ${file.resultFilePath}');
            } else {
              // File doesn't exist but still add it to the list
              // just mark it as inaccessible in the metadata
              final updatedMetadata =
                  Map<String, dynamic>.from(file.metadata ?? {});
              updatedMetadata['file_missing'] = true;

              final updatedFile = RecentFileModel(
                id: file.id,
                originalFileName: file.originalFileName,
                resultFileName: file.resultFileName,
                operation: file.operation,
                operationType: file.operationType,
                originalFilePath: file.originalFilePath,
                resultFilePath: file.resultFilePath,
                originalSize: file.originalSize,
                resultSize: file.resultSize,
                processedAt: file.processedAt,
                metadata: updatedMetadata,
              );

              verifiedFiles.add(updatedFile);
              print('🔧 PROVIDER: File not found: ${file.resultFilePath}');
            }
          } catch (e) {
            print('🔧 PROVIDER: Error checking file: $e');
            // Still add it but mark as error
            final updatedMetadata =
                Map<String, dynamic>.from(file.metadata ?? {});
            updatedMetadata['file_error'] = e.toString();

            final updatedFile = RecentFileModel(
              id: file.id,
              originalFileName: file.originalFileName,
              resultFileName: file.resultFileName,
              operation: file.operation,
              operationType: file.operationType,
              originalFilePath: file.originalFilePath,
              resultFilePath: file.resultFilePath,
              originalSize: file.originalSize,
              resultSize: file.resultSize,
              processedAt: file.processedAt,
              metadata: updatedMetadata,
            );

            verifiedFiles.add(updatedFile);
          }
        } else {
          // No result path, just add as is
          verifiedFiles.add(file);
        }
      }

      // Get operation types for filtering
      final operationResult = await db.rawQuery('''
        SELECT DISTINCT operation_type FROM recent_files 
        WHERE operation_type IS NOT NULL AND operation_type != ''
      ''');
      final operationTypes = operationResult
          .map((row) => row['operation_type'] as String)
          .toList();

      print('🔧 PROVIDER: Found operation types: $operationTypes');

      // Determine if there are more files to load
      bool hasMoreFiles = false;
      if (!showAllFiles) {
        hasMoreFiles =
            verifiedFiles.length >= limit && verifiedFiles.length < totalCount;
      }

      // Force state update
      final newState = state.copyWith(
        isLoading: false,
        recentFiles: verifiedFiles,
        operationTypes: operationTypes,
        currentFilter: operationType,
        error: null,
        totalCount: totalCount,
        hasMoreFiles: hasMoreFiles,
        showingAllFiles: showAllFiles,
      );

      state = newState;
      print(
          '🔧 PROVIDER: State updated! New state has ${state.recentFiles.length} files, hasMore: ${state.hasMoreFiles}');

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

  Future<void> loadMoreFiles() async {
    if (state.isLoadingMore || !state.hasMoreFiles || state.showingAllFiles) {
      print(
          '🔧 PROVIDER: Cannot load more - isLoadingMore: ${state.isLoadingMore}, hasMore: ${state.hasMoreFiles}, showingAll: ${state.showingAllFiles}');
      return;
    }

    print(
        '🔧 PROVIDER: Loading more files, current page: ${state.currentPage}');

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      final nextPage = state.currentPage + 1;
      final offset = _initialLoadSize + (state.currentPage * _pageSize);
      final limit = _pageSize;

      print(
          '🔧 PROVIDER: Loading page $nextPage with offset $offset and limit $limit');

      // Get additional files
      List<Map<String, dynamic>> rawFiles;
      if (state.currentFilter != null) {
        rawFiles = await db.query(
          'recent_files',
          where: 'operation_type = ?',
          whereArgs: [state.currentFilter],
          orderBy: 'processed_at DESC',
          limit: limit,
          offset: offset,
        );
      } else {
        rawFiles = await db.query(
          'recent_files',
          orderBy: 'processed_at DESC',
          limit: limit,
          offset: offset,
        );
      }

      print('🔧 PROVIDER: Load more query returned ${rawFiles.length} files');

      // Parse additional files
      final List<RecentFileModel> additionalFiles = [];
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
              print(
                  '🔧 PROVIDER: Failed to parse metadata for additional file $i: $e');
              fileMap['metadata'] = null;
            }
          }

          final recentFile = RecentFileModel.fromMap(fileMap);
          additionalFiles.add(recentFile);
        } catch (e) {
          print('🔧 PROVIDER: Failed to parse additional file $i: $e');
        }
      }

      // Verify additional files
      final verifiedAdditionalFiles = <RecentFileModel>[];
      for (final file in additionalFiles) {
        if (file.resultFilePath != null) {
          try {
            final physicalFile = File(file.resultFilePath!);
            if (await physicalFile.exists()) {
              verifiedAdditionalFiles.add(file);
            } else {
              // Add with missing file flag
              final updatedMetadata =
                  Map<String, dynamic>.from(file.metadata ?? {});
              updatedMetadata['file_missing'] = true;

              final updatedFile = RecentFileModel(
                id: file.id,
                originalFileName: file.originalFileName,
                resultFileName: file.resultFileName,
                operation: file.operation,
                operationType: file.operationType,
                originalFilePath: file.originalFilePath,
                resultFilePath: file.resultFilePath,
                originalSize: file.originalSize,
                resultSize: file.resultSize,
                processedAt: file.processedAt,
                metadata: updatedMetadata,
              );

              verifiedAdditionalFiles.add(updatedFile);
            }
          } catch (e) {
            // Add with error flag
            final updatedMetadata =
                Map<String, dynamic>.from(file.metadata ?? {});
            updatedMetadata['file_error'] = e.toString();

            final updatedFile = RecentFileModel(
              id: file.id,
              originalFileName: file.originalFileName,
              resultFileName: file.resultFileName,
              operation: file.operation,
              operationType: file.operationType,
              originalFilePath: file.originalFilePath,
              resultFilePath: file.resultFilePath,
              originalSize: file.originalSize,
              resultSize: file.resultSize,
              processedAt: file.processedAt,
              metadata: updatedMetadata,
            );

            verifiedAdditionalFiles.add(updatedFile);
          }
        } else {
          verifiedAdditionalFiles.add(file);
        }
      }

      // Combine with existing files
      final allFiles = [...state.recentFiles, ...verifiedAdditionalFiles];

      // Check if there are more files to load
      final hasMoreFiles = verifiedAdditionalFiles.length >= _pageSize;

      state = state.copyWith(
        isLoadingMore: false,
        recentFiles: allFiles,
        currentPage: nextPage,
        hasMoreFiles: hasMoreFiles,
      );

      print(
          '🔧 PROVIDER: Load more completed. Total files: ${allFiles.length}, page: $nextPage, hasMore: $hasMoreFiles');
    } catch (e, stackTrace) {
      print('🔧 PROVIDER: Error in loadMoreFiles: $e');
      print('🔧 PROVIDER: Stack trace: $stackTrace');
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> showAllFiles() async {
    print('🔧 PROVIDER: Showing all files');
    await loadRecentFiles(
      operationType: state.currentFilter,
      showAllFiles: true,
    );
  }

  Future<void> showLimitedFiles() async {
    print('🔧 PROVIDER: Showing limited files');
    await loadRecentFiles(
      operationType: state.currentFilter,
      isInitial: true,
      showAllFiles: false,
    );
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
    await loadRecentFiles(
      operationType: state.currentFilter,
      isInitial: true,
      showAllFiles: state.showingAllFiles,
    );
    await loadStats();
  }

  Future<void> clearAllRecentFiles() async {
    try {
      print('🔧 PROVIDER: Clearing all recent files');
      final repository = ref.read(recentFilesRepositoryProvider);
      await repository.clearAllRecentFiles();

      // Reload
      await loadRecentFiles(isInitial: true);
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
      await loadRecentFiles(isInitial: true);
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

  // Get a specific recent file by its path
  RecentFileModel? getRecentFileByPath(String path) {
    try {
      for (final file in state.recentFiles) {
        if (file.resultFilePath == path) {
          return file;
        }
      }
      return null;
    } catch (e) {
      print('Error finding recent file: $e');
      return null;
    }
  }

  // Delete a specific recent file
  Future<bool> deleteRecentFile(int fileId) async {
    try {
      final dbHelper = DatabaseHelper();

      // Delete from database
      await dbHelper.database.then((db) async {
        await db.delete(
          'recent_files',
          where: 'id = ?',
          whereArgs: [fileId],
        );
      });

      // Refresh the list
      await refreshRecentFiles();
      return true;
    } catch (e) {
      print('Error deleting recent file: $e');
      return false;
    }
  }
}

/// State class for recent files
class RecentFilesState {
  final List<RecentFileModel> recentFiles;
  final List<String> operationTypes;
  final Map<String, int> stats;
  final String? currentFilter;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMoreFiles;
  final int totalCount;
  final bool showingAllFiles;

  const RecentFilesState({
    this.recentFiles = const [],
    this.operationTypes = const [],
    this.stats = const {},
    this.currentFilter,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 0,
    this.hasMoreFiles = true,
    this.totalCount = 0,
    this.showingAllFiles = false,
  });

  RecentFilesState copyWith({
    List<RecentFileModel>? recentFiles,
    List<String>? operationTypes,
    Map<String, int>? stats,
    String? currentFilter,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMoreFiles,
    int? totalCount,
    bool? showingAllFiles,
  }) {
    return RecentFilesState(
      recentFiles: recentFiles ?? this.recentFiles,
      operationTypes: operationTypes ?? this.operationTypes,
      stats: stats ?? this.stats,
      currentFilter: currentFilter ?? this.currentFilter,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMoreFiles: hasMoreFiles ?? this.hasMoreFiles,
      totalCount: totalCount ?? this.totalCount,
      showingAllFiles: showingAllFiles ?? this.showingAllFiles,
    );
  }

  bool get hasRecentFiles => recentFiles.isNotEmpty;
  bool get hasError => error != null;
  bool get canLoadMore =>
      hasMoreFiles && !isLoading && !isLoadingMore && !showingAllFiles;

  // Get files filtered by operation type
  List<RecentFileModel> getFilteredFiles(String operationType) {
    return recentFiles
        .where((file) => file.operationType == operationType)
        .toList();
  }

  // Get recently saved files (with paths that exist)
  List<RecentFileModel> get recentlySavedFiles {
    return recentFiles
        .where((file) =>
            file.resultFilePath != null &&
            !file.metadata!.containsKey('file_missing'))
        .toList();
  }

  // Get most recent file of a specific type
  RecentFileModel? getMostRecentFileOfType(String operationType) {
    final filtered = getFilteredFiles(operationType);
    if (filtered.isNotEmpty) {
      return filtered.first;
    }
    return null;
  }

  // Get display text for load more/view all buttons
  String get loadMoreButtonText {
    if (showingAllFiles) {
      return 'Show Less';
    } else if (hasMoreFiles) {
      final remaining = totalCount - recentFiles.length;
      return 'Load More ($remaining remaining)';
    } else {
      return 'No More Files';
    }
  }

  String get viewAllButtonText {
    if (showingAllFiles) {
      return 'Show Less';
    } else {
      return 'View All ($totalCount)';
    }
  }
}
