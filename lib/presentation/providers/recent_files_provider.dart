// lib/presentation/providers/recent_files_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/recent_file_model.dart';
import '../../data/repositories/recent_files_repository.dart';

part 'recent_files_provider.g.dart';

@riverpod
class RecentFilesNotifier extends _$RecentFilesNotifier {
  @override
  RecentFilesState build() {
    return const RecentFilesState();
  }

  Future<void> loadRecentFiles({String? operationType}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(recentFilesRepositoryProvider);
      final recentFiles = await repository.getRecentFiles(
        operationType: operationType,
      );

      // Also load operation types for filtering
      final operationStats = await repository.getOperationStats();
      final operationTypes = operationStats.keys.toList();

      state = state.copyWith(
        isLoading: false,
        recentFiles: recentFiles,
        operationTypes: operationTypes,
        currentFilter: operationType,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadStats() async {
    try {
      final repository = ref.read(recentFilesRepositoryProvider);
      final stats = await repository.getRecentFilesStats();

      state = state.copyWith(stats: stats);
    } catch (e) {
      // Don't update error state for stats failure
      print('Failed to load stats: $e');
    }
  }

  Future<void> clearAllRecentFiles() async {
    try {
      final repository = ref.read(recentFilesRepositoryProvider);
      await repository.clearAllRecentFiles();

      // Reload to show empty state
      await loadRecentFiles();
      await loadStats();
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear recent files: $e');
    }
  }

  Future<void> deleteOldRecentFiles({int keepDays = 30}) async {
    try {
      final repository = ref.read(recentFilesRepositoryProvider);
      await repository.deleteOldRecentFiles(keepDays: keepDays);

      // Reload to show updated list
      await loadRecentFiles();
      await loadStats();
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete old files: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
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
