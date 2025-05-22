// lib/presentation/providers/protect_provider.dart
import 'dart:io';
import 'package:megapdf_client/data/repositories/pdf_repository_impl.dart';
import 'package:megapdf_client/data/services/recent_files_service.dart';
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

  Future<void> saveResult() async {
    final result = state.result;
    if (result?.fileUrl == null || result?.filename == null) return;

    state = state.copyWith(isSaving: true);

    try {
      final repository = ref.read(pdfRepositoryProvider);

      final localPath = await repository.saveProcessedFile(
        fileUrl: result!.fileUrl!,
        filename: result.filename!,
        customFileName: 'protected_${result.originalName ?? 'document'}',
        subfolder: 'protected',
      );

      // Track in recent files
      if (state.selectedFile != null) {
        final recentFilesService = ref.read(recentFilesServiceProvider);
        await recentFilesService.trackProtect(
          originalFile: state.selectedFile!,
          resultFileName: result.filename!,
          resultFilePath: localPath,
          permissionLevel: state.permission,
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
  final bool isSaving;
  final ProtectResult? result;
  final String? error;
  final String? savedPath;

  const ProtectState({
    this.selectedFile,
    this.password = '',
    this.permission = 'restricted',
    this.allowPrinting = false,
    this.allowCopying = false,
    this.allowEditing = false,
    this.isLoading = false,
    this.isSaving = false,
    this.result,
    this.error,
    this.savedPath,
  });

  ProtectState copyWith({
    File? selectedFile,
    String? password,
    String? permission,
    bool? allowPrinting,
    bool? allowCopying,
    bool? allowEditing,
    bool? isLoading,
    bool? isSaving,
    ProtectResult? result,
    String? error,
    String? savedPath,
  }) {
    return ProtectState(
      selectedFile: selectedFile ?? this.selectedFile,
      password: password ?? this.password,
      permission: permission ?? this.permission,
      allowPrinting: allowPrinting ?? this.allowPrinting,
      allowCopying: allowCopying ?? this.allowCopying,
      allowEditing: allowEditing ?? this.allowEditing,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      result: result ?? this.result,
      error: error,
      savedPath: savedPath,
    );
  }

  bool get hasFile => selectedFile != null;
  bool get hasPassword => password.length >= 4;
  bool get hasResult => result != null;
  bool get hasError => error != null;
  bool get isProcessing => isLoading || isSaving;
  bool get canProtect => hasFile && hasPassword && !isProcessing;
  bool get canSave => hasResult && !isSaving;
  bool get hasSavedFile => savedPath != null;
}
