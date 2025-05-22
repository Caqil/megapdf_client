// lib/presentation/providers/convert_provider.dart
import 'dart:io';
import 'package:megapdf_client/data/repositories/pdf_repository_impl.dart';
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

  Future<void> downloadResult() async {
    final result = state.result;
    if (result?.fileUrl == null || result?.filename == null) return;

    state = state.copyWith(isDownloading: true);

    try {
      final repository = ref.read(pdfRepositoryProvider);
      
      final uri = Uri.parse(result!.fileUrl!);
      final folder = uri.queryParameters['folder'] ?? 'conversions';
      final filename = uri.queryParameters['filename'] ?? result.filename!;
      
      final localPath = await repository.downloadFile(
        folder: folder,
        filename: filename,
        customFileName: 'converted_${result.originalName ?? 'document'}',
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
  final bool isDownloading;
  final ConvertResult? result;
  final String? error;
  final String? downloadedPath;

  const ConvertState({
    this.selectedFile,
    this.inputFormat = 'pdf',
    this.outputFormat = 'docx',
    this.enableOcr = false,
    this.quality = 90,
    this.password,
    this.isLoading = false,
    this.isDownloading = false,
    this.result,
    this.error,
    this.downloadedPath,
  });

  ConvertState copyWith({
    File? selectedFile,
    String? inputFormat,
    String? outputFormat,
    bool? enableOcr,
    int? quality,
    String? password,
    bool? isLoading,
    bool? isDownloading,
    ConvertResult? result,
    String? error,
    String? downloadedPath,
  }) {
    return ConvertState(
      selectedFile: selectedFile ?? this.selectedFile,
      inputFormat: inputFormat ?? this.inputFormat,
      outputFormat: outputFormat ?? this.outputFormat,
      enableOcr: enableOcr ?? this.enableOcr,
      quality: quality ?? this.quality,
      password: password,
      isLoading: isLoading ?? this.isLoading,
      isDownloading: isDownloading ?? this.isDownloading,
      result: result ?? this.result,
      error: error,
      downloadedPath: downloadedPath,
    );
  }

  bool get hasFile => selectedFile != null;
  bool get hasResult => result != null;
  bool get hasError => error != null;
  bool get isProcessing => isLoading || isDownloading;
  bool get canConvert => hasFile && !isProcessing && inputFormat != outputFormat;
  bool get canDownload => hasResult && !isDownloading;
}
