// lib/presentation/providers/split_provider.dart
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/split_options.dart';
import '../../data/models/split_result.dart';
import '../../data/models/job_status.dart';
import '../../data/repositories/pdf_repository_impl.dart';
import '../../data/services/recent_files_service.dart';

part 'split_provider.g.dart';

@riverpod
class SplitNotifier extends _$SplitNotifier {
  @override
  SplitState build() {
    return const SplitState();
  }

  void selectFile(File file) {
    state = state.copyWith(
      selectedFile: file,
      error: null,
      result: null,
      savedPaths: [],
    );

    // Default to range split method if not already set
    if (state.splitOptions == null) {
      updateSplitOptions(SplitOptions.byRange(''));
    }
  }

  void updateSplitOptions(SplitOptions options) {
    state = state.copyWith(splitOptions: options);
  }

  Future<void> splitPdf(File file, SplitOptions options) async {
    state = state.copyWith(isLoading: true, error: null, jobStatus: null);

    try {
      final repository = ref.read(pdfRepositoryProvider);
      final result = await repository.splitPdf(file, options);

      print('Split result received: ${result.toString()}');

      // Check if this is an async job that needs to be polled
      if (result.isLargeJob == true && result.jobId != null) {
        state = state.copyWith(
          isLoading: false,
          isAsyncJob: true,
          jobId: result.jobId,
        );
        // Start polling for job status
        _pollJobStatus(result.jobId!);
      } else {
        // Handle immediate result - this is the important part for single-page PDFs
        if (result.success &&
            result.splitParts != null &&
            result.splitParts!.isNotEmpty) {
          print('Successful split with ${result.splitParts!.length} parts');

          // Save the split parts
          await _saveSplitParts(file, result);

          // Track the operation
          final recentFilesService = ref.read(recentFilesServiceProvider);
          await recentFilesService.trackSplit(
            originalFile: file,
            splitCount: result.splitParts!.length,
            splitFileNames: result.splitParts!
                .map((part) => part.filename )
                .toList(),
          );

          // Update state with result
          state = state.copyWith(
            isLoading: false,
            result: result,
          );
        } else {
          // Handle error case
          state = state.copyWith(
            isLoading: false,
            error: result.message ,
          );
        }
      }
    } catch (e) {
      print('Error splitting PDF: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _saveSplitParts(File originalFile, SplitResult result) async {
    if (result.splitParts == null || result.splitParts!.isEmpty) return;

    final repository = ref.read(pdfRepositoryProvider);
    final savedPaths = <String>[];

    for (final part in result.splitParts!) {
      try {
        final savedPath = await repository.saveProcessedFile(
          fileUrl: part.fileUrl,
          filename: part.filename ,
          customFileName: 'Split_${part.filename }',
          subfolder: 'Split',
        );

        if (savedPath.isNotEmpty) {
          savedPaths.add(savedPath);
        }
      } catch (e) {
        print('Error saving split part: $e');
      }
        }

    // Update saved paths in state if any were saved
    if (savedPaths.isNotEmpty) {
      state = state.copyWith(
        savedPaths: savedPaths,
      );
    }
  }

  Future<void> _pollJobStatus(String jobId) async {
    bool isComplete = false;
    int attempts = 0;
    const maxAttempts = 60; // 5 minutes with 5-second interval

    while (!isComplete && attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 5));

      try {
        final repository = ref.read(pdfRepositoryProvider);
        final status = await repository.getSplitJobStatus(jobId);

        state = state.copyWith(
          jobStatus: status,
        );

        // if (status.isCompleted || status.isError) {
        //   isComplete = true;

        //   if (status.isCompleted) {
        //     // Process completed job result
        //     final result = status.splitResult!;

        //     if (state.selectedFile != null) {
        //       await _saveSplitParts(state.selectedFile!, result);
        //     }

        //     state = state.copyWith(
        //       result: result,
        //     );
        //   }
        // }
      } catch (e) {
        print('Error polling job status: $e');
        attempts++;
      }
    }

    if (!isComplete) {
      state = state.copyWith(
        error: 'Operation timed out. Please try again.',
      );
    }
  }

  void reset() {
    state = const SplitState();
  }
}

class SplitState {
  final File? selectedFile;
  final SplitOptions? splitOptions;
  final SplitResult? result;
  final String? error;
  final bool isLoading;
  final bool isAsyncJob;
  final String? jobId;
  final JobStatus? jobStatus;
  final List<String> savedPaths;

  const SplitState({
    this.selectedFile,
    this.splitOptions,
    this.result,
    this.error,
    this.isLoading = false,
    this.isAsyncJob = false,
    this.jobId,
    this.jobStatus,
    this.savedPaths = const [],
  });

  SplitState copyWith({
    File? selectedFile,
    SplitOptions? splitOptions,
    SplitResult? result,
    String? error,
    bool? isLoading,
    bool? isAsyncJob,
    String? jobId,
    JobStatus? jobStatus,
    List<String>? savedPaths,
  }) {
    return SplitState(
      selectedFile: selectedFile ?? this.selectedFile,
      splitOptions: splitOptions ?? this.splitOptions,
      result: result ?? this.result,
      error: error,
      isLoading: isLoading ?? this.isLoading,
      isAsyncJob: isAsyncJob ?? this.isAsyncJob,
      jobId: jobId ?? this.jobId,
      jobStatus: jobStatus ?? this.jobStatus,
      savedPaths: savedPaths ?? this.savedPaths,
    );
  }

  bool get hasFile => selectedFile != null;
  bool get hasResult => result != null && result!.success;
  bool get hasError => error != null;
  bool get canSplit => hasFile && splitOptions != null && !isLoading;
}
