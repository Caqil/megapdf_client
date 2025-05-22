// lib/presentation/providers/rotate_provider.dart
import 'dart:io';
import 'package:megapdf_client/data/repositories/pdf_repository_impl.dart';
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

  Future<void> downloadResult() async {
    final result = state.result;
    if (result?.fileUrl == null || result?.filename == null) return;

    state = state.copyWith(isDownloading: true);

    try {
      final repository = ref.read(pdfRepositoryProvider);
      
      final uri = Uri.parse(result!.fileUrl!);
      final folder = uri.queryParameters['folder'] ?? 'rotations';
      final filename = uri.queryParameters['filename'] ?? result.filename!;
      
      final localPath = await repository.downloadFile(
        folder: folder,
        filename: filename,
        customFileName: 'rotated_${result.originalName ?? 'document'}',
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
  final bool isDownloading;
  final RotateResult? result;
  final String? error;
  final String? downloadedPath;

  const RotateState({
    this.selectedFile,
    this.angle = 90,
    this.pages = 'all',
    this.isLoading = false,
    this.isDownloading = false,
    this.result,
    this.error,
    this.downloadedPath,
  });

  RotateState copyWith({
    File? selectedFile,
    int? angle,
    String? pages,
    bool? isLoading,
    bool? isDownloading,
    RotateResult? result,
    String? error,
    String? downloadedPath,
  }) {
    return RotateState(
      selectedFile: selectedFile ?? this.selectedFile,
      angle: angle ?? this.angle,
      pages: pages ?? this.pages,
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
  bool get canRotate => hasFile && !isProcessing && [90, 180, 270].contains(angle);
  bool get canDownload => hasResult && !isDownloading;
  
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
