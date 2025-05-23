// lib/presentation/providers/merge_provider.dart
import 'dart:io';
import 'package:megapdf_client/data/repositories/pdf_repository_impl.dart';
import 'package:megapdf_client/data/services/recent_files_service.dart';
import 'package:megapdf_client/presentation/providers/file_operation_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/merge_result.dart';
import '../../core/errors/api_exception.dart';

part 'merge_provider.g.dart';

@riverpod
class MergeNotifier extends _$MergeNotifier {
  @override
  MergeState build() {
    return const MergeState();
  }

  void addFiles(List<File> files) {
    final allFiles = [...state.selectedFiles, ...files];
    state = state.copyWith(
      selectedFiles: allFiles,
      result: null,
      error: null,
    );
  }

  void removeFile(int index) {
    final files = [...state.selectedFiles];
    files.removeAt(index);
    state = state.copyWith(
      selectedFiles: files,
      result: null,
      error: null,
    );
  }

  void reorderFiles(int oldIndex, int newIndex) {
    final files = [...state.selectedFiles];
    if (newIndex > oldIndex) newIndex--;
    final file = files.removeAt(oldIndex);
    files.insert(newIndex, file);
    state = state.copyWith(
      selectedFiles: files,
      result: null,
      error: null,
    );
  }

  Future<void> mergePdfs() async {
    if (state.selectedFiles.length < 2) {
      state = state.copyWith(error: 'Please select at least 2 PDF files');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      result: null,
    );

    try {
      final repository = ref.read(pdfRepositoryProvider);
      final result = await repository.mergePdfs(state.selectedFiles);

      state = state.copyWith(
        isLoading: false,
        result: result,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.userFriendlyMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<void> saveResult() async {
    final result = state.result;
    if (result?.fileUrl == null || result?.filename == null) return;

    state = state.copyWith(isSaving: true);

    try {
      final repository = ref.read(pdfRepositoryProvider);

      final localPath = await repository.saveProcessedFile(
        fileUrl: result!.fileUrl!,
        filename: result.filename!,
        customFileName: 'merged_${DateTime.now().millisecondsSinceEpoch}.pdf',
        subfolder: 'merged',
      );

      // Track in recent files
      if (state.selectedFiles.isNotEmpty) {
        final recentFilesService = ref.read(recentFilesServiceProvider);
        await recentFilesService.trackMerge(
          originalFiles: state.selectedFiles,
          resultFileName: result.filename!,
          resultFilePath: localPath,
          mergedSizeBytes: result.mergedSize,
          totalInputSizeBytes: result.totalInputSize,
        );
        ref
            .read(fileOperationNotifierProvider.notifier)
            .notifyFileOperationCompleted();
      }

      state = state.copyWith(
        isSaving: false,
        savedPath: localPath,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.userFriendlyMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to save file: ${e.toString()}',
      );
    }
  }

  void reset() {
    state = const MergeState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class MergeState {
  final List<File> selectedFiles;
  final bool isLoading;
  final bool isSaving;
  final MergeResult? result;
  final String? error;
  final String? savedPath;

  const MergeState({
    this.selectedFiles = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.result,
    this.error,
    this.savedPath,
  });

  MergeState copyWith({
    List<File>? selectedFiles,
    bool? isLoading,
    bool? isSaving,
    MergeResult? result,
    String? error,
    String? savedPath,
  }) {
    return MergeState(
      selectedFiles: selectedFiles ?? this.selectedFiles,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      result: result ?? this.result,
      error: error,
      savedPath: savedPath,
    );
  }

  bool get hasFiles => selectedFiles.isNotEmpty;
  bool get hasEnoughFiles => selectedFiles.length >= 2;
  bool get hasResult => result != null;
  bool get hasError => error != null;
  bool get isProcessing => isLoading || isSaving;
  bool get canMerge => hasEnoughFiles && !isProcessing;
  bool get canSave => hasResult && !isSaving;
  bool get hasSavedFile => savedPath != null;
}
