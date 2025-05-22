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

  Future<void> downloadResult() async {
    final result = state.result;
    if (result?.fileUrl == null || result?.filename == null) return;

    state = state.copyWith(isDownloading: true);

    try {
      final repository = ref.read(pdfRepositoryProvider);

      // Extract folder and filename from fileUrl
      final uri = Uri.parse(result!.fileUrl!);
      final folder = uri.queryParameters['folder'] ?? 'compressions';
      final filename = uri.queryParameters['filename'] ?? result.filename!;

      final localPath = await repository.downloadFile(
        folder: folder,
        filename: filename,
        customFileName: 'compressed_${result.originalName ?? 'document'}',
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

  void selectFile(File file) {
    state = state.copyWith(
      selectedFile: file,
      result: null,
      error: null,
      downloadedPath: null,
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
  final bool isDownloading;
  final CompressResult? result;
  final String? error;
  final String? downloadedPath;

  const CompressState({
    this.selectedFile,
    this.isLoading = false,
    this.isDownloading = false,
    this.result,
    this.error,
    this.downloadedPath,
  });

  CompressState copyWith({
    File? selectedFile,
    bool? isLoading,
    bool? isDownloading,
    CompressResult? result,
    String? error,
    String? downloadedPath,
  }) {
    return CompressState(
      selectedFile: selectedFile ?? this.selectedFile,
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
  bool get canCompress => hasFile && !isProcessing;
  bool get canDownload => hasResult && !isDownloading;
}
