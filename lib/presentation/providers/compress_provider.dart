import 'dart:io';
import 'package:megapdf_client/data/repositories/pdf_repository_impl.dart';
import 'package:megapdf_client/data/services/recent_files_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/compress_result.dart';
import '../../core/errors/api_exception.dart';

part 'compress_provider.g.dart';

@riverpod
class CompressNotifier extends _$CompressNotifier {
  @override
  CompressState build() {
    return const CompressState();
  }

  Future<void> compressPdf(File file) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      result: null,
    );

    try {
      final repository = ref.read(pdfRepositoryProvider);
      final result = await repository.compressPdf(file);

      state = state.copyWith(
        isLoading: false,
        result: result,
        selectedFile: file,
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
        customFileName: 'compressed_${result.originalName ?? 'document'}',
        subfolder: 'compressed',
      );

      // Track in recent files
      if (state.selectedFile != null) {
        final recentFilesService = ref.read(recentFilesServiceProvider);
        await recentFilesService.trackCompress(
          originalFile: state.selectedFile!,
          resultFileName: result.filename ?? 'compressed.pdf',
          resultFilePath: localPath,
          compressionRatio: result.compressionRatio,
          originalSizeBytes: result.originalSize,
          compressedSizeBytes: result.compressedSize,
        );
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

  void selectFile(File file) {
    state = state.copyWith(
      selectedFile: file,
      result: null,
      error: null,
      savedPath: null,
    );
  }

  void reset() {
    state = const CompressState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class CompressState {
  final File? selectedFile;
  final bool isLoading;
  final bool isSaving;
  final CompressResult? result;
  final String? error;
  final String? savedPath;

  const CompressState({
    this.selectedFile,
    this.isLoading = false,
    this.isSaving = false,
    this.result,
    this.error,
    this.savedPath,
  });

  CompressState copyWith({
    File? selectedFile,
    bool? isLoading,
    bool? isSaving,
    CompressResult? result,
    String? error,
    String? savedPath,
  }) {
    return CompressState(
      selectedFile: selectedFile ?? this.selectedFile,
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
  bool get canCompress => hasFile && !isProcessing;
  bool get canSave => hasResult && !isSaving;
  bool get hasSavedFile => savedPath != null;
}
