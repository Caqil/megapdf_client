// lib/presentation/providers/page_numbers_provider.dart
import 'dart:io';
import 'package:megapdf_client/data/models/rotate_result.dart';
import 'package:megapdf_client/data/repositories/pdf_repository_impl.dart';
import 'package:megapdf_client/data/services/recent_files_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/errors/api_exception.dart';

part 'page_numbers_provider.g.dart';

@riverpod
class PageNumbersNotifier extends _$PageNumbersNotifier {
  @override
  PageNumbersState build() {
    return const PageNumbersState();
  }

  void selectFile(File file) {
    state = state.copyWith(
      selectedFile: file,
      result: null,
      error: null,
    );
  }

  void updatePosition(String position) {
    state = state.copyWith(
      position: position,
      result: null,
      error: null,
    );
  }

  void updateFormat(String format) {
    state = state.copyWith(
      format: format,
      result: null,
      error: null,
    );
  }

  void updateFontOptions({
    String? fontFamily,
    int? fontSize,
    String? color,
  }) {
    state = state.copyWith(
      fontFamily: fontFamily ?? state.fontFamily,
      fontSize: fontSize ?? state.fontSize,
      color: color ?? state.color,
      result: null,
      error: null,
    );
  }

  void updateNumberingOptions({
    int? startNumber,
    String? prefix,
    String? suffix,
  }) {
    state = state.copyWith(
      startNumber: startNumber ?? state.startNumber,
      prefix: prefix ?? state.prefix,
      suffix: suffix ?? state.suffix,
      result: null,
      error: null,
    );
  }

  void updateMargins({
    int? marginX,
    int? marginY,
  }) {
    state = state.copyWith(
      marginX: marginX ?? state.marginX,
      marginY: marginY ?? state.marginY,
      result: null,
      error: null,
    );
  }

  void updatePageSelection({
    String? selectedPages,
    bool? skipFirstPage,
  }) {
    state = state.copyWith(
      selectedPages: selectedPages ?? state.selectedPages,
      skipFirstPage: skipFirstPage ?? state.skipFirstPage,
      result: null,
      error: null,
    );
  }

  Future<void> addPageNumbers() async {
    if (!state.canAddPageNumbers) {
      state = state.copyWith(error: 'Please select a PDF file');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      result: null,
    );

    try {
      final repository = ref.read(pdfRepositoryProvider);
      final result = await repository.addPageNumbers(
        state.selectedFile!,
        position: state.position,
        format: state.format,
        fontFamily: state.fontFamily,
        fontSize: state.fontSize,
        color: state.color,
        startNumber: state.startNumber,
        prefix: state.prefix.isEmpty ? null : state.prefix,
        suffix: state.suffix.isEmpty ? null : state.suffix,
        marginX: state.marginX,
        marginY: state.marginY,
        selectedPages: state.selectedPages.isEmpty ? null : state.selectedPages,
        skipFirstPage: state.skipFirstPage,
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
    if (result?.fileUrl == null || result?.fileName == null) return;

    state = state.copyWith(isSaving: true);

    try {
      final repository = ref.read(pdfRepositoryProvider);

      final localPath = await repository.saveProcessedFile(
        fileUrl: result!.fileUrl!,
        filename: result.fileName!,
        customFileName: 'numbered_${result.originalName ?? 'document'}',
        subfolder: 'numbered',
      );

      // Track in recent files
      if (state.selectedFile != null) {
        final recentFilesService = ref.read(recentFilesServiceProvider);
        await recentFilesService.trackPageNumbers(
          originalFile: state.selectedFile!,
          resultFileName: result.fileName!,
          resultFilePath: localPath,
          position: state.position,
          format: state.format,
          totalPages: result.totalPages,
          numberedPages: result.numberedPages,
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
    state = const PageNumbersState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class PageNumbersState {
  final File? selectedFile;
  final String position;
  final String format;
  final String fontFamily;
  final int fontSize;
  final String color;
  final int startNumber;
  final String prefix;
  final String suffix;
  final int marginX;
  final int marginY;
  final String selectedPages;
  final bool skipFirstPage;
  final bool isLoading;
  final bool isSaving;
  final PageNumbersResult? result;
  final String? error;
  final String? savedPath;

  const PageNumbersState({
    this.selectedFile,
    this.position = 'bottom-center',
    this.format = 'numeric',
    this.fontFamily = 'Helvetica',
    this.fontSize = 12,
    this.color = '#000000',
    this.startNumber = 1,
    this.prefix = '',
    this.suffix = '',
    this.marginX = 40,
    this.marginY = 30,
    this.selectedPages = '',
    this.skipFirstPage = false,
    this.isLoading = false,
    this.isSaving = false,
    this.result,
    this.error,
    this.savedPath,
  });

  PageNumbersState copyWith({
    File? selectedFile,
    String? position,
    String? format,
    String? fontFamily,
    int? fontSize,
    String? color,
    int? startNumber,
    String? prefix,
    String? suffix,
    int? marginX,
    int? marginY,
    String? selectedPages,
    bool? skipFirstPage,
    bool? isLoading,
    bool? isSaving,
    PageNumbersResult? result,
    String? error,
    String? savedPath,
  }) {
    return PageNumbersState(
      selectedFile: selectedFile ?? this.selectedFile,
      position: position ?? this.position,
      format: format ?? this.format,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      startNumber: startNumber ?? this.startNumber,
      prefix: prefix ?? this.prefix,
      suffix: suffix ?? this.suffix,
      marginX: marginX ?? this.marginX,
      marginY: marginY ?? this.marginY,
      selectedPages: selectedPages ?? this.selectedPages,
      skipFirstPage: skipFirstPage ?? this.skipFirstPage,
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
  bool get canAddPageNumbers => hasFile && !isProcessing;
  bool get canSave => hasResult && !isSaving;
  bool get hasSavedFile => savedPath != null;

  String get positionDisplayName {
    switch (position) {
      case 'top-left':
        return 'Top Left';
      case 'top-center':
        return 'Top Center';
      case 'top-right':
        return 'Top Right';
      case 'bottom-left':
        return 'Bottom Left';
      case 'bottom-center':
        return 'Bottom Center';
      case 'bottom-right':
        return 'Bottom Right';
      default:
        return position;
    }
  }

  String get formatDisplayName {
    switch (format) {
      case 'numeric':
        return 'Numbers (1, 2, 3...)';
      case 'roman':
        return 'Roman (I, II, III...)';
      case 'alphabetic':
        return 'Letters (A, B, C...)';
      default:
        return format;
    }
  }

  String get previewText {
    String number;
    switch (format) {
      case 'roman':
        number = 'I';
        break;
      case 'alphabetic':
        number = 'A';
        break;
      default:
        number = startNumber.toString();
    }
    return '$prefix$number$suffix';
  }
}
