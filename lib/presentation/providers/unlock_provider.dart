// lib/presentation/providers/unlock_provider.dart
import 'dart:io';
import 'package:megapdf_client/data/repositories/pdf_repository_impl.dart';
import 'package:megapdf_client/data/services/recent_files_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/unlock_result.dart';
import '../../core/errors/api_exception.dart';

part 'unlock_provider.g.dart';

@riverpod
class UnlockNotifier extends _$UnlockNotifier {
  @override
  UnlockState build() {
    return const UnlockState();
  }

  void selectFile(File file) {
    state = state.copyWith(
      selectedFile: file,
      result: null,
      error: null,
    );
  }

  void updatePassword(String password) {
    state = state.copyWith(
      password: password,
      result: null,
      error: null,
    );
  }

  Future<void> unlockPdf() async {
    if (!state.canUnlock) {
      state =
          state.copyWith(error: 'Please select a file and enter the password');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      result: null,
    );

    try {
      final repository = ref.read(pdfRepositoryProvider);
      final result = await repository.unlockPdf(
        state.selectedFile!,
        state.password,
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
        customFileName: 'unlocked_${result.originalName ?? 'document'}',
        subfolder: 'unlocked',
      );

      // Track in recent files
      if (state.selectedFile != null) {
        final recentFilesService = ref.read(recentFilesServiceProvider);
        await recentFilesService.trackUnlock(
          originalFile: state.selectedFile!,
          resultFileName: result.filename!,
          resultFilePath: localPath,
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

  void reset() {
    state = const UnlockState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class UnlockState {
  final File? selectedFile;
  final String password;
  final bool isLoading;
  final bool isSaving;
  final UnlockResult? result;
  final String? error;
  final String? savedPath;

  const UnlockState({
    this.selectedFile,
    this.password = '',
    this.isLoading = false,
    this.isSaving = false,
    this.result,
    this.error,
    this.savedPath,
  });

  UnlockState copyWith({
    File? selectedFile,
    String? password,
    bool? isLoading,
    bool? isSaving,
    UnlockResult? result,
    String? error,
    String? savedPath,
  }) {
    return UnlockState(
      selectedFile: selectedFile ?? this.selectedFile,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      result: result ?? this.result,
      error: error,
      savedPath: savedPath,
    );
  }

  bool get hasFile => selectedFile != null;
  bool get hasPassword => password.isNotEmpty;
  bool get hasResult => result != null;
  bool get hasError => error != null;
  bool get isProcessing => isLoading || isSaving;
  bool get canUnlock => hasFile && hasPassword && !isProcessing;
  bool get canSave => hasResult && !isSaving;
  bool get hasSavedFile => savedPath != null;
}
