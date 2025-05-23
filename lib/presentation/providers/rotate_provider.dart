// lib/presentation/providers/rotate_provider.dart
import 'dart:io';
import 'package:megapdf_client/data/repositories/pdf_repository_impl.dart';
import 'package:megapdf_client/data/services/recent_files_service.dart';
import 'package:megapdf_client/presentation/providers/file_operation_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/rotate_result.dart';
import '../../core/errors/api_exception.dart';

part 'rotate_provider.g.dart';

@riverpod
class RotateNotifier extends _$RotateNotifier {
  @override
  RotateState build() {
    return const RotateState();
  }

  void selectFile(File file) {
    state = state.copyWith(
      selectedFile: file,
      result: null,
      error: null,
    );
  }

  void updateAngle(int angle) {
    state = state.copyWith(
      angle: angle,
      result: null,
      error: null,
    );
  }

  void updatePages(String pages) {
    state = state.copyWith(
      pages: pages,
      result: null,
      error: null,
    );
  }

  Future<void> rotatePdf() async {
    if (!state.canRotate) {
      state = state.copyWith(error: 'Please select a file and rotation angle');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      result: null,
    );

    try {
      final repository = ref.read(pdfRepositoryProvider);
      final result = await repository.rotatePdf(
        state.selectedFile!,
        state.angle,
        pages: state.pages == 'all' ? null : state.pages,
      );

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
        customFileName: 'rotated_${result.originalName ?? 'document'}',
        subfolder: 'rotated',
      );

      // Track in recent files
      if (state.selectedFile != null) {
        final recentFilesService = ref.read(recentFilesServiceProvider);
        await recentFilesService.trackRotate(
          originalFile: state.selectedFile!,
          resultFileName: result.filename!,
          resultFilePath: localPath,
          angle: state.angle,
          pagesRotated: state.pages == 'all' ? null : state.pages,
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
    state = const RotateState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class RotateState {
  final File? selectedFile;
  final int angle;
  final String pages;
  final bool isLoading;
  final bool isSaving;
  final RotateResult? result;
  final String? error;
  final String? savedPath;

  const RotateState({
    this.selectedFile,
    this.angle = 90,
    this.pages = 'all',
    this.isLoading = false,
    this.isSaving = false,
    this.result,
    this.error,
    this.savedPath,
  });

  RotateState copyWith({
    File? selectedFile,
    int? angle,
    String? pages,
    bool? isLoading,
    bool? isSaving,
    RotateResult? result,
    String? error,
    String? savedPath,
  }) {
    return RotateState(
      selectedFile: selectedFile ?? this.selectedFile,
      angle: angle ?? this.angle,
      pages: pages ?? this.pages,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      result: result ?? this.result,
      error: error,
      savedPath: savedPath,
    );
  }

  bool get hasFile => selectedFile != null;
  bool get hasResult => result != null;
  bool get hasError => error != null;
  bool get isProcessing => isLoading || isSaving;
  bool get canRotate =>
      hasFile && !isProcessing && [90, 180, 270].contains(angle);
  bool get canSave => hasResult && !isSaving;
  bool get hasSavedFile => savedPath != null;

  String get angleDescription {
    switch (angle) {
      case 90:
        return '90° Clockwise';
      case 180:
        return '180° Flip';
      case 270:
        return '270° Clockwise (90° Counter-clockwise)';
      default:
        return '$angle°';
    }
  }
}
