// lib/presentation/providers/unlock_provider.dart
import 'dart:io';
import 'package:megapdf_client/data/repositories/pdf_repository_impl.dart';
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

  Future<void> downloadResult() async {
    final result = state.result;
    if (result?.fileUrl == null || result?.filename == null) return;

    state = state.copyWith(isDownloading: true);

    try {
      final repository = ref.read(pdfRepositoryProvider);

      final uri = Uri.parse(result!.fileUrl!);
      final folder = uri.queryParameters['folder'] ?? 'unlocked';
      final filename = uri.queryParameters['filename'] ?? result.filename!;

      final localPath = await repository.downloadFile(
        folder: folder,
        filename: filename,
        customFileName: 'unlocked_${result.originalName ?? 'document'}',
      );

      state = state.copyWith(
        isDownloading: false,
        downloadedPath: localPath,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isDownloading: false,
        error: e.userFriendlyMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isDownloading: false,
        error: 'Failed to download file: ${e.toString()}',
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
  final bool isDownloading;
  final UnlockResult? result;
  final String? error;
  final String? downloadedPath;

  const UnlockState({
    this.selectedFile,
    this.password = '',
    this.isLoading = false,
    this.isDownloading = false,
    this.result,
    this.error,
    this.downloadedPath,
  });

  UnlockState copyWith({
    File? selectedFile,
    String? password,
    bool? isLoading,
    bool? isDownloading,
    UnlockResult? result,
    String? error,
    String? downloadedPath,
  }) {
    return UnlockState(
      selectedFile: selectedFile ?? this.selectedFile,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      isDownloading: isDownloading ?? this.isDownloading,
      result: result ?? this.result,
      error: error,
      downloadedPath: downloadedPath,
    );
  }

  bool get hasFile => selectedFile != null;
  bool get hasPassword => password.isNotEmpty;
  bool get hasResult => result != null;
  bool get hasError => error != null;
  bool get isProcessing => isLoading || isDownloading;
  bool get canUnlock => hasFile && hasPassword && !isProcessing;
  bool get canDownload => hasResult && !isDownloading;
}
