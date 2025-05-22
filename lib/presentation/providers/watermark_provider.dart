// lib/presentation/providers/watermark_provider.dart
import 'dart:io';
import 'package:megapdf_client/data/repositories/pdf_repository_impl.dart';
import 'package:megapdf_client/data/services/recent_files_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/watermark_result.dart';
import '../../core/errors/api_exception.dart';

part 'watermark_provider.g.dart';

@riverpod
class WatermarkNotifier extends _$WatermarkNotifier {
  @override
  WatermarkState build() {
    return const WatermarkState();
  }

  void selectFile(File file) {
    state = state.copyWith(
      selectedFile: file,
      result: null,
      error: null,
    );
  }

  void selectWatermarkType(WatermarkType type) {
    state = state.copyWith(
      watermarkType: type,
      watermarkImage: null,
      result: null,
      error: null,
    );
  }

  void selectWatermarkImage(File image) {
    state = state.copyWith(
      watermarkImage: image,
      result: null,
      error: null,
    );
  }

  void updateTextOptions({
    String? text,
    String? textColor,
    int? fontSize,
    String? fontFamily,
  }) {
    state = state.copyWith(
      text: text ?? state.text,
      textColor: textColor ?? state.textColor,
      fontSize: fontSize ?? state.fontSize,
      fontFamily: fontFamily ?? state.fontFamily,
      result: null,
      error: null,
    );
  }

  void updatePositionOptions({
    WatermarkPosition? position,
    int? rotation,
    int? opacity,
    int? scale,
    int? customX,
    int? customY,
  }) {
    state = state.copyWith(
      position: position ?? state.position,
      rotation: rotation ?? state.rotation,
      opacity: opacity ?? state.opacity,
      scale: scale ?? state.scale,
      customX: customX ?? state.customX,
      customY: customY ?? state.customY,
      result: null,
      error: null,
    );
  }

  void updatePageOptions({
    String? pages,
    String? customPages,
  }) {
    state = state.copyWith(
      pages: pages ?? state.pages,
      customPages: customPages ?? state.customPages,
      result: null,
      error: null,
    );
  }

  Future<void> addWatermark() async {
    if (!state.canAddWatermark) {
      state = state.copyWith(
          error: 'Please select a file and configure watermark options');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      result: null,
    );

    try {
      final repository = ref.read(pdfRepositoryProvider);
      WatermarkResult result;

      if (state.watermarkType == WatermarkType.text) {
        result = await repository.addTextWatermark(
          state.selectedFile!,
          state.text,
          textColor: state.textColor,
          fontSize: state.fontSize,
          fontFamily: state.fontFamily,
          position: state.position.name,
          rotation: state.rotation,
          opacity: state.opacity,
          pages: state.pages,
          customPages: state.customPages,
          customX: state.customX,
          customY: state.customY,
        );
      } else {
        result = await repository.addImageWatermark(
          state.selectedFile!,
          state.watermarkImage!,
          position: state.position.name,
          rotation: state.rotation,
          opacity: state.opacity,
          scale: state.scale,
          pages: state.pages,
          customPages: state.customPages,
          customX: state.customX,
          customY: state.customY,
        );
      }

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
        customFileName: 'watermarked_${result.originalName ?? 'document'}',
        subfolder: 'watermarked',
      );

      // Track in recent files
      if (state.selectedFile != null) {
        final recentFilesService = ref.read(recentFilesServiceProvider);
        await recentFilesService.trackWatermark(
          originalFile: state.selectedFile!,
          resultFileName: result.filename!,
          resultFilePath: localPath,
          watermarkType: state.watermarkType.name,
          watermarkText:
              state.watermarkType == WatermarkType.text ? state.text : null,
          position: state.position.name,
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
    state = const WatermarkState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class WatermarkState {
  final File? selectedFile;
  final WatermarkType watermarkType;
  final File? watermarkImage;
  final String text;
  final String textColor;
  final int fontSize;
  final String fontFamily;
  final WatermarkPosition position;
  final int rotation;
  final int opacity;
  final int scale;
  final String pages;
  final String? customPages;
  final int? customX;
  final int? customY;
  final bool isLoading;
  final bool isSaving;
  final WatermarkResult? result;
  final String? error;
  final String? savedPath;

  const WatermarkState({
    this.selectedFile,
    this.watermarkType = WatermarkType.text,
    this.watermarkImage,
    this.text = 'WATERMARK',
    this.textColor = '#FF0000',
    this.fontSize = 48,
    this.fontFamily = 'Helvetica',
    this.position = WatermarkPosition.center,
    this.rotation = 0,
    this.opacity = 30,
    this.scale = 50,
    this.pages = 'all',
    this.customPages,
    this.customX,
    this.customY,
    this.isLoading = false,
    this.isSaving = false,
    this.result,
    this.error,
    this.savedPath,
  });

  WatermarkState copyWith({
    File? selectedFile,
    WatermarkType? watermarkType,
    File? watermarkImage,
    String? text,
    String? textColor,
    int? fontSize,
    String? fontFamily,
    WatermarkPosition? position,
    int? rotation,
    int? opacity,
    int? scale,
    String? pages,
    String? customPages,
    int? customX,
    int? customY,
    bool? isLoading,
    bool? isSaving,
    WatermarkResult? result,
    String? error,
    String? savedPath,
  }) {
    return WatermarkState(
      selectedFile: selectedFile ?? this.selectedFile,
      watermarkType: watermarkType ?? this.watermarkType,
      watermarkImage: watermarkImage,
      text: text ?? this.text,
      textColor: textColor ?? this.textColor,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      scale: scale ?? this.scale,
      pages: pages ?? this.pages,
      customPages: customPages,
      customX: customX,
      customY: customY,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      result: result ?? this.result,
      error: error,
      savedPath: savedPath,
    );
  }

  bool get hasFile => selectedFile != null;
  bool get hasWatermarkImage => watermarkImage != null;
  bool get hasText => text.isNotEmpty;
  bool get hasResult => result != null;
  bool get hasError => error != null;
  bool get isProcessing => isLoading || isSaving;

  bool get canAddWatermark {
    if (!hasFile || isProcessing) return false;
    if (watermarkType == WatermarkType.text) return hasText;
    if (watermarkType == WatermarkType.image) return hasWatermarkImage;
    return false;
  }

  bool get canSave => hasResult && !isSaving;
  bool get hasSavedFile => savedPath != null;
}
