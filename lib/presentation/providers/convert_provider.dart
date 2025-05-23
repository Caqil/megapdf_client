// lib/presentation/providers/convert_provider.dart
import 'dart:io';
import 'package:megapdf_client/data/repositories/pdf_repository_impl.dart';
import 'package:megapdf_client/data/services/recent_files_service.dart';
import 'package:megapdf_client/presentation/providers/file_operation_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/convert_result.dart';
import '../../core/errors/api_exception.dart';

part 'convert_provider.g.dart';

@riverpod
class ConvertNotifier extends _$ConvertNotifier {
  @override
  ConvertState build() {
    return const ConvertState();
  }

  void selectFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    state = state.copyWith(
      selectedFile: file,
      inputFormat: extension,
      result: null,
      error: null,
    );
  }

  void updateFormats({
    String? inputFormat,
    String? outputFormat,
  }) {
    state = state.copyWith(
      inputFormat: inputFormat ?? state.inputFormat,
      outputFormat: outputFormat ?? state.outputFormat,
      result: null,
      error: null,
    );
  }

  void updateOptions({
    bool? enableOcr,
    int? quality,
    String? password,
  }) {
    state = state.copyWith(
      enableOcr: enableOcr ?? state.enableOcr,
      quality: quality ?? state.quality,
      password: password ?? state.password,
      result: null,
      error: null,
    );
  }

  Future<void> convertFile() async {
    if (!state.canConvert) {
      state = state.copyWith(error: 'Please select a file and output format');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      result: null,
    );

    try {
      final repository = ref.read(pdfRepositoryProvider);
      final result = await repository.convertFile(
        state.selectedFile!,
        state.inputFormat,
        state.outputFormat,
        enableOcr: state.enableOcr,
        quality: state.quality,
        password: state.password?.isNotEmpty == true ? state.password : null,
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
        customFileName: 'converted_${result.originalName ?? 'document'}',
        subfolder: 'converted',
      );

      // Track in recent files
      if (state.selectedFile != null) {
        final recentFilesService = ref.read(recentFilesServiceProvider);
        await recentFilesService.trackConvert(
          originalFile: state.selectedFile!,
          resultFileName: result.filename!,
          resultFilePath: localPath,
          inputFormat: state.inputFormat,
          outputFormat: state.outputFormat,
          ocrEnabled: state.enableOcr,
          quality: state.quality,
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
    state = const ConvertState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class ConvertState {
  final File? selectedFile;
  final String inputFormat;
  final String outputFormat;
  final bool enableOcr;
  final int quality;
  final String? password;
  final bool isLoading;
  final bool isSaving;
  final ConvertResult? result;
  final String? error;
  final String? savedPath;

  const ConvertState({
    this.selectedFile,
    this.inputFormat = 'pdf',
    this.outputFormat = 'docx',
    this.enableOcr = false,
    this.quality = 90,
    this.password,
    this.isLoading = false,
    this.isSaving = false,
    this.result,
    this.error,
    this.savedPath,
  });

  ConvertState copyWith({
    File? selectedFile,
    String? inputFormat,
    String? outputFormat,
    bool? enableOcr,
    int? quality,
    String? password,
    bool? isLoading,
    bool? isSaving,
    ConvertResult? result,
    String? error,
    String? savedPath,
  }) {
    return ConvertState(
      selectedFile: selectedFile ?? this.selectedFile,
      inputFormat: inputFormat ?? this.inputFormat,
      outputFormat: outputFormat ?? this.outputFormat,
      enableOcr: enableOcr ?? this.enableOcr,
      quality: quality ?? this.quality,
      password: password,
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
  bool get canConvert =>
      hasFile && !isProcessing && inputFormat != outputFormat;
  bool get canSave => hasResult && !isSaving;
  bool get hasSavedFile => savedPath != null;
}
