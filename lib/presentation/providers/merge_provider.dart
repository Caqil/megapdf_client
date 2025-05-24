import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/merge_result.dart';
import '../../data/repositories/pdf_repository_impl.dart';
import 'file_path_provider.dart';
import 'file_operation_notifier.dart';

part 'merge_provider.g.dart';

@riverpod
class MergeNotifier extends _$MergeNotifier {
  @override
  MergeState build() {
    return const MergeState();
  }

  void addFiles(List<File> files) {
    // Combine with existing files (if any)
    final currentFiles = List<File>.from(state.selectedFiles);
    currentFiles.addAll(files);

    state = state.copyWith(
      selectedFiles: currentFiles,
      error: null,
    );

    _validateFiles();
  }

  void removeFile(int index) {
    if (index < 0 || index >= state.selectedFiles.length) return;

    final updatedFiles = List<File>.from(state.selectedFiles);
    updatedFiles.removeAt(index);

    state = state.copyWith(
      selectedFiles: updatedFiles,
      error: null,
    );

    _validateFiles();
  }

  void reorderFiles(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.selectedFiles.length) return;
    if (newIndex < 0 || newIndex >= state.selectedFiles.length) return;

    // Handle the reorder index adjustment needed by ReorderableListView
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final updatedFiles = List<File>.from(state.selectedFiles);
    final file = updatedFiles.removeAt(oldIndex);
    updatedFiles.insert(newIndex, file);

    state = state.copyWith(
      selectedFiles: updatedFiles,
      error: null,
    );
  }

  void _validateFiles() {
    // Check file count
    if (state.selectedFiles.length < 2) {
      // It's okay to have less than 2 files while still selecting
      return;
    }

    // Check file sizes
    for (final file in state.selectedFiles) {
      final fileSize = file.lengthSync();
      final fileSizeMB = fileSize / (1024 * 1024);

      if (fileSizeMB > 50) {
        state = state.copyWith(
          error: 'File ${file.path.split('/').last} exceeds the 50MB limit',
        );
        return;
      }
    }

    // Calculate total size
    int totalSize = 0;
    for (final file in state.selectedFiles) {
      totalSize += file.lengthSync();
    }

    final totalSizeMB = totalSize / (1024 * 1024);
    if (totalSizeMB > 100) {
      state = state.copyWith(
        error:
            'Total file size (${totalSizeMB.toStringAsFixed(1)}MB) exceeds the 100MB limit',
      );
      return;
    }
  }

  Future<void> mergePdfs() async {
    if (state.selectedFiles.length < 2) {
      state = state.copyWith(
        error: 'Please select at least 2 PDF files to merge',
      );
      return;
    }

    // Clear any previous errors
    state = state.copyWith(
      isLoading: true,
      error: null,
      result: null,
      savedPath: null,
    );

    try {
      // Define file order if needed
      final order = List<int>.generate(state.selectedFiles.length, (i) => i);

      // Get repository
      final repository = ref.read(pdfRepositoryProvider);

      // Perform merge operation
      final result =
          await repository.mergePdfs(state.selectedFiles, order: order);

      state = state.copyWith(
        isLoading: false,
        result: result,
      );

      // Auto-save if result is successful
      if (result.success && result.fileUrl != null) {
        await saveResult();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to merge PDFs: ${e.toString()}',
      );
    }
  }

  Future<void> saveResult() async {
    if (state.result == null ||
        !state.result!.success ||
        state.result!.fileUrl == null) {
      state = state.copyWith(
        error: 'No valid result to save',
      );
      return;
    }

    state = state.copyWith(
      isSaving: true,
      error: null,
    );

    try {
      final repository = ref.read(pdfRepositoryProvider);

      // Define custom filename based on input files
      String customFileName = 'Merged';
      if (state.selectedFiles.isNotEmpty) {
        final firstFileName = state.selectedFiles.first.path.split('/').last;
        final baseName = firstFileName.split('.').first;

        if (state.selectedFiles.length == 2) {
          final secondFileName = state.selectedFiles[1].path.split('/').last;
          final secondBaseName = secondFileName.split('.').first;
          customFileName = '${baseName}_and_${secondBaseName}_merged';
        } else if (state.selectedFiles.length > 2) {
          customFileName =
              '${baseName}_and_${state.selectedFiles.length - 1}_others_merged';
        } else {
          customFileName = '${baseName}_merged';
        }
      }

      // Save the file
      final savedPath = await repository.saveProcessedFile(
        fileUrl: state.result!.fileUrl!,
        filename: state.result!.filename ?? 'merged.pdf',
        customFileName: customFileName,
        subfolder: 'merged',
      );

      state = state.copyWith(
        isSaving: false,
        savedPath: savedPath,
      );

      // Notify file operation completed
      ref
          .read(fileOperationNotifierProvider.notifier)
          .notifyOperationCompleted('merge');

      // Also notify with file details
      ref.read(lastOperationNotifierProvider.notifier).setLastOperation(
            type: 'merge',
            name: 'Merged PDF',
            timestamp: DateTime.now(),
            filePath: savedPath,
          );

      // Notify file save system
      ref.read(fileSaveNotifierProvider.notifier).fileSaved(savedPath, 'merge');
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to save merged PDF: ${e.toString()}',
      );
    }
  }

  void reset() {
    state = const MergeState();
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
      savedPath: savedPath ?? this.savedPath,
    );
  }

  bool get hasFiles => selectedFiles.isNotEmpty;
  bool get hasEnoughFiles => selectedFiles.length >= 2;
  bool get hasError => error != null && error!.isNotEmpty;
  bool get hasResult => result != null && result!.success;
  bool get canMerge => hasEnoughFiles && !isLoading && !isSaving;
  bool get canSave => hasResult && !isSaving && !isLoading;
}
