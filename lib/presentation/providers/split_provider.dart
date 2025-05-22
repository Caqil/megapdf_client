import 'dart:io';
import 'dart:async';
import 'package:megapdf_client/data/repositories/pdf_repository_impl.dart';
import 'package:megapdf_client/data/services/recent_files_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/split_result.dart';
import '../../data/models/split_options.dart';
import '../../data/models/job_status.dart';
import '../../core/errors/api_exception.dart';

part 'split_provider.g.dart';

@riverpod
class SplitNotifier extends _$SplitNotifier {
  Timer? _jobStatusTimer;

  @override
  SplitState build() {
    return const SplitState();
  }

  Future<void> splitPdf(File file, SplitOptions options) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      result: null,
      jobStatus: null,
    );

    try {
      final repository = ref.read(pdfRepositoryProvider);
      final result = await repository.splitPdf(file, options);

      if (result.isAsyncJob) {
        // Start polling for job status
        state = state.copyWith(
          isLoading: false,
          result: result,
          selectedFile: file,
          splitOptions: options,
        );
        _startJobStatusPolling(result.jobId!);
      } else {
        // Immediate result
        state = state.copyWith(
          isLoading: false,
          result: result,
          selectedFile: file,
          splitOptions: options,
        );
      }
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

  void _startJobStatusPolling(String jobId) {
    _jobStatusTimer?.cancel();
    _jobStatusTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkJobStatus(jobId),
    );
  }

  Future<void> _checkJobStatus(String jobId) async {
    try {
      final repository = ref.read(pdfRepositoryProvider);
      final jobStatus = await repository.getSplitJobStatus(jobId);

      state = state.copyWith(jobStatus: jobStatus);

      if (jobStatus.isCompleted || jobStatus.isError) {
        _jobStatusTimer?.cancel();
        _jobStatusTimer = null;
      }
    } catch (e) {
      // Continue polling on error, but update error state
      state = state.copyWith(
        error: 'Failed to check job status: ${e.toString()}',
      );
    }
  }

  Future<void> saveSplitPart(SplitPart part) async {
    state = state.copyWith(isSaving: true);

    try {
      final repository = ref.read(pdfRepositoryProvider);

      final localPath = await repository.saveProcessedFile(
        fileUrl: part.fileUrl,
        filename: part.filename,
        customFileName: part.filename,
        subfolder: 'split',
      );

      // Add to saved parts
      final savedParts = Map<String, String>.from(state.savedParts);
      savedParts[part.filename] = localPath;

      state = state.copyWith(
        isSaving: false,
        savedParts: savedParts,
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

  Future<void> saveAllParts() async {
    final splitParts = state.finalSplitParts;
    if (splitParts.isEmpty) return;

    state = state.copyWith(isSaving: true);

    try {
      for (final part in splitParts) {
        await saveSplitPart(part);
      }

      // Track in recent files
      if (state.selectedFile != null) {
        final recentFilesService = ref.read(recentFilesServiceProvider);
        await recentFilesService.trackSplit(
          originalFile: state.selectedFile!,
          splitCount: splitParts.length,
          splitFileNames: splitParts.map((p) => p.filename).toList(),
        );
      }
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  void updateSplitOptions(SplitOptions options) {
    state = state.copyWith(
      splitOptions: options,
      result: null,
      jobStatus: null,
      error: null,
    );
  }

  void selectFile(File file) {
    state = state.copyWith(
      selectedFile: file,
      result: null,
      jobStatus: null,
      error: null,
      savedParts: {},
    );
  }

  void reset() {
    _jobStatusTimer?.cancel();
    _jobStatusTimer = null;
    state = const SplitState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void dispose() {
    _jobStatusTimer?.cancel();
  }
}

class SplitState {
  final File? selectedFile;
  final SplitOptions? splitOptions;
  final bool isLoading;
  final bool isSaving;
  final SplitResult? result;
  final JobStatus? jobStatus;
  final String? error;
  final Map<String, String> savedParts;

  const SplitState({
    this.selectedFile,
    this.splitOptions,
    this.isLoading = false,
    this.isSaving = false,
    this.result,
    this.jobStatus,
    this.error,
    this.savedParts = const {},
  });

  SplitState copyWith({
    File? selectedFile,
    SplitOptions? splitOptions,
    bool? isLoading,
    bool? isSaving,
    SplitResult? result,
    JobStatus? jobStatus,
    String? error,
    Map<String, String>? savedParts,
  }) {
    return SplitState(
      selectedFile: selectedFile ?? this.selectedFile,
      splitOptions: splitOptions ?? this.splitOptions,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      result: result ?? this.result,
      jobStatus: jobStatus,
      error: error,
      savedParts: savedParts ?? this.savedParts,
    );
  }

  bool get hasFile => selectedFile != null;
  bool get hasOptions => splitOptions != null;
  bool get hasResult => result != null;
  bool get hasError => error != null;
  bool get isProcessing => isLoading || isSaving;
  bool get canSplit => hasFile && hasOptions && !isProcessing;
  bool get isAsyncJob => result?.isAsyncJob == true;
  bool get isJobCompleted => jobStatus?.isCompleted == true;
  bool get isJobError => jobStatus?.isError == true;

  List<SplitPart> get finalSplitParts {
    if (isAsyncJob && jobStatus != null) {
      return jobStatus!.results;
    }
    return result?.splitParts ?? [];
  }

  double? get jobProgress {
    if (jobStatus != null) {
      return jobStatus!.progressPercentage;
    }
    return null;
  }
}
