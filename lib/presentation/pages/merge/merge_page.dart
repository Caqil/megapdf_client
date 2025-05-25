import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/merge_provider.dart';
import '../../widgets/common/app_bar_widget.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/download_button.dart';
import 'widgets/file_list_widget.dart';
import 'widgets/merge_result.dart';

class MergePage extends ConsumerStatefulWidget {
  final String? initialFilePath;
  final String? initialFileName;

  const MergePage({
    super.key,
    this.initialFilePath,
    this.initialFileName,
  });

  @override
  ConsumerState<MergePage> createState() => _MergePageState();
}

class _MergePageState extends ConsumerState<MergePage> {
  @override
  void initState() {
    super.initState();

    // Check for parameters in route and load file if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialFileIfAvailable();
    });
  }

  void _loadInitialFileIfAvailable() {
    if (widget.initialFilePath != null && widget.initialFilePath!.isNotEmpty) {
      try {
        final file = File(widget.initialFilePath!);
        if (file.existsSync()) {
          // Add the file to the merge list
          ref.read(mergeNotifierProvider.notifier).addFiles([file]);

          // Show a notification to the user
          CustomSnackbar.show(
            context: context,
            message: 'Added ${widget.initialFileName ?? "file"} to merge list',
            type: SnackbarType.success,
          );
        } else {
          CustomSnackbar.show(
            context: context,
            message: 'Could not find the selected file',
            type: SnackbarType.failure,
          );
        }
      } catch (e) {
        CustomSnackbar.show(
          context: context,
          message: 'Error loading file: $e',
          type: SnackbarType.failure,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mergeNotifierProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Merge PDFs',
        subtitle: 'Combine multiple PDF files into one',
        onBack: () => context.pop('/'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // File Selection Section
              _buildFileSelectionSection(context, ref, state),

              if (state.hasFiles) ...[
                const SizedBox(height: 24),
                FileListWidget(
                  files: state.selectedFiles,
                  onRemoveFile: (index) => ref
                      .read(mergeNotifierProvider.notifier)
                      .removeFile(index),
                  onReorderFiles: (oldIndex, newIndex) => ref
                      .read(mergeNotifierProvider.notifier)
                      .reorderFiles(oldIndex, newIndex),
                ),
              ],

              if (state.hasResult) ...[
                const SizedBox(height: 24),
                MergeResultWidget(result: state.result!),
              ],

              if (state.hasError) ...[
                const SizedBox(height: 24),
                CustomErrorWidget(
                  message: state.error!,
                  onRetry: state.canMerge
                      ? () =>
                          ref.read(mergeNotifierProvider.notifier).mergePdfs()
                      : null,
                ),
              ],

              const SizedBox(height: 24),
              _buildActionButtons(context, ref, state),

              const SizedBox(height: 24),
              _buildInfoSection(context),
            ],
          ),
        ),
      ),
      floatingActionButton: state.hasFiles && !state.hasResult
          ? FloatingActionButton.extended(
              onPressed: () => _pickPdfFiles(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add Files'),
              backgroundColor: AppColors.mergeColor(context),
            )
          : null,
    );
  }

  Widget _buildFileSelectionSection(
      BuildContext context, WidgetRef ref, MergeState state) {
    return Card(
      elevation: 0.1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.upload_file,
                  color: AppColors.primary(context),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Select PDF Files',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!state.hasFiles) ...[
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.border(context),
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _pickPdfFiles(context, ref),
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 40,
                          color: AppColors.primary(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose PDF Files',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select multiple PDF files to merge',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.success(context).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success(context),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${state.selectedFiles.length} files selected',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _pickPdfFiles(context, ref),
                      child: const Text('Add More'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, MergeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Merge Button
        if (!state.hasResult) ...[
          ElevatedButton.icon(
            onPressed: state.canMerge
                ? () => ref.read(mergeNotifierProvider.notifier).mergePdfs()
                : null,
            icon: state.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.merge),
            label: Text(state.isLoading ? 'Merging...' : 'Merge PDFs'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.mergeColor(context),
            ),
          ),
          if (!state.hasEnoughFiles) ...[
            const SizedBox(height: 8),
            Text(
              'Please select at least 2 PDF files to merge',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],

        // Download Button
        if (state.hasResult) ...[
          SaveButton(
            onPressed: state.canSave
                ? () => ref.read(mergeNotifierProvider.notifier).saveResult()
                : null,
            isLoading: state.isSaving,
            savedPath: state.savedPath,
            buttonText: 'Save Merged PDF',
          ),
          const SizedBox(height: 12),

          // Process Another Button
          OutlinedButton.icon(
            onPressed: () => ref.read(mergeNotifierProvider.notifier).reset(),
            icon: const Icon(Icons.refresh),
            label: const Text('Merge More PDFs'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      elevation: 0.1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info(context),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'About PDF Merging',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Combine multiple PDF files into a single document:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
            const SizedBox(height: 12),
            _buildInfoList(context, [
              'Preserve original formatting and quality',
              'Drag and drop to reorder files',
              'Support for password-protected PDFs',
              'Maintains bookmarks and metadata',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoList(BuildContext context, List<String> items) {
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary(context),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Implement a proper file picker
  Future<void> _pickPdfFiles(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final files = result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();

        if (files.isNotEmpty) {
          // Validate file sizes
          final List<File> validFiles = [];
          final List<String> oversizedFiles = [];
          final int maxSizeMB = 50; // 50MB max per file

          for (final file in files) {
            final sizeInMB = file.lengthSync() / (1024 * 1024);
            if (sizeInMB <= maxSizeMB) {
              validFiles.add(file);
            } else {
              oversizedFiles.add(file.path.split('/').last);
            }
          }

          // Add valid files
          if (validFiles.isNotEmpty) {
            ref.read(mergeNotifierProvider.notifier).addFiles(validFiles);
          }

          // Show warning if any files were too large
          if (oversizedFiles.isNotEmpty) {
            _showOversizedFilesWarning(context, oversizedFiles);
          }
        }
      }
    } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to pick files: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showOversizedFilesWarning(
      BuildContext context, List<String> fileNames) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Files Too Large'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'The following files exceed the 50MB size limit and were not added:'),
            const SizedBox(height: 8),
            ...fileNames.map((name) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
