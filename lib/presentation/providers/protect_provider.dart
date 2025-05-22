// lib/presentation/providers/protect_provider.dart
import 'dart:io';
import 'package:megapdf_client/data/repositories/pdf_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/protect_result.dart';
import '../../core/errors/api_exception.dart';

part 'protect_provider.g.dart';

@riverpod
class ProtectNotifier extends _$ProtectNotifier {
  @override
  ProtectState build() {
    return const ProtectState();
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

  void updatePermissions({
    String? permission,
    bool? allowPrinting,
    bool? allowCopying,
    bool? allowEditing,
  }) {
    state = state.copyWith(
      permission: permission ?? state.permission,
      allowPrinting: allowPrinting ?? state.allowPrinting,
      allowCopying: allowCopying ?? state.allowCopying,
      allowEditing: allowEditing ?? state.allowEditing,
      result: null,
      error: null,
    );
  }

  Future<void> protectPdf() async {
    if (!state.canProtect) {
      state =
          state.copyWith(error: 'Please select a file and enter a password');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      result: null,
    );

    try {
      final repository = ref.read(pdfRepositoryProvider);
      final result = await repository.protectPdf(
        state.selectedFile!,
        state.password,
        permission: state.permission,
        allowPrinting: state.allowPrinting,
        allowCopying: state.allowCopying,
        allowEditing: state.allowEditing,
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
      final folder = uri.queryParameters['folder'] ?? 'protected';
      final filename = uri.queryParameters['filename'] ?? result.filename!;

      final localPath = await repository.downloadFile(
        folder: folder,
        filename: filename,
        customFileName: 'protected_${result.originalName ?? 'document'}',
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
    state = const ProtectState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class ProtectState {
  final File? selectedFile;
  final String password;
  final String permission;
  final bool allowPrinting;
  final bool allowCopying;
  final bool allowEditing;
  final bool isLoading;
  final bool isDownloading;
  final ProtectResult? result;
  final String? error;
  final String? downloadedPath;

  const ProtectState({
    this.selectedFile,
    this.password = '',
    this.permission = 'restricted',
    this.allowPrinting = false,
    this.allowCopying = false,
    this.allowEditing = false,
    this.isLoading = false,
    this.isDownloading = false,
    this.result,
    this.error,
    this.downloadedPath,
  });

  ProtectState copyWith({
    File? selectedFile,
    String? password,
    String? permission,
    bool? allowPrinting,
    bool? allowCopying,
    bool? allowEditing,
    bool? isLoading,
    bool? isDownloading,
    ProtectResult? result,
    String? error,
    String? downloadedPath,
  }) {
    return ProtectState(
      selectedFile: selectedFile ?? this.selectedFile,
      password: password ?? this.password,
      permission: permission ?? this.permission,
      allowPrinting: allowPrinting ?? this.allowPrinting,
      allowCopying: allowCopying ?? this.allowCopying,
      allowEditing: allowEditing ?? this.allowEditing,
      isLoading: isLoading ?? this.isLoading,
      isDownloading: isDownloading ?? this.isDownloading,
      result: result ?? this.result,
      error: error,
      downloadedPath: downloadedPath,
    );
  }

  bool get hasFile => selectedFile != null;
  bool get hasPassword => password.length >= 4;
  bool get hasResult => result != null;
  bool get hasError => error != null;
  bool get isProcessing => isLoading || isDownloading;
  bool get canProtect => hasFile && hasPassword && !isProcessing;
  bool get canDownload => hasResult && !isDownloading;
}
