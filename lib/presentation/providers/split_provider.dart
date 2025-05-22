import 'dart:io';
import 'dart:async';
import 'package:megapdf_client/data/repositories/pdf_repository_impl.dart';
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

  Future<void> downloadSplitPart(SplitPart part) async {
    state = state.copyWith(isDownloading: true);

    try {
      final repository = ref.read(pdfRepositoryProvider);

      // Extract folder and filename from fileUrl
      final uri = Uri.parse(part.fileUrl);
      final folder = uri.queryParameters['folder'] ?? 'splits';
      final filename = uri.queryParameters['filename'] ?? part.filename;

      final localPath = await repository.downloadFile(
        folder: folder,
        filename: filename,
        customFileName: part.filename,
      );

      // Add to downloaded parts
      final downloadedParts = Map<String, String>.from(state.downloadedParts);
      downloadedParts[part.filename] = localPath;

      state = state.copyWith(
        isDownloading: false,
        downloadedParts: downloadedParts,
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

  Future<void> downloadAllParts() async {
    final splitParts = state.finalSplitParts;
    if (splitParts.isEmpty) return;

    state = state.copyWith(isDownloading: true);

    try {
      for (final part in splitParts) {
        await downloadSplitPart(part);
      }
    } finally {
      state = state.copyWith(isDownloading: false);
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
      downloadedParts: {},
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
  final bool isDownloading;
  final SplitResult? result;
  final JobStatus? jobStatus;
  final String? error;
  final Map<String, String> downloadedParts;

  const SplitState({
    this.selectedFile,
    this.splitOptions,
    this.isLoading = false,
    this.isDownloading = false,
    this.result,
    this.jobStatus,
    this.error,
    this.downloadedParts = const {},
  });

  SplitState copyWith({
    File? selectedFile,
    SplitOptions? splitOptions,
    bool? isLoading,
    bool? isDownloading,
    SplitResult? result,
    JobStatus? jobStatus,
    String? error,
    Map<String, String>? downloadedParts,
  }) {
    return SplitState(
      selectedFile: selectedFile ?? this.selectedFile,
      splitOptions: splitOptions ?? this.splitOptions,
      isLoading: isLoading ?? this.isLoading,
      isDownloading: isDownloading ?? this.isDownloading,
      result: result ?? this.result,
      jobStatus: jobStatus,
      error: error,
      downloadedParts: downloadedParts ?? this.downloadedParts,
    );
  }

  bool get hasFile => selectedFile != null;
  bool get hasOptions => splitOptions != null;
  bool get hasResult => result != null;
  bool get hasError => error != null;
  bool get isProcessing => isLoading || isDownloading;
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
