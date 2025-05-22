import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/merge_provider.dart';
import '../../widgets/common/app_bar_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/download_button.dart';
import 'widgets/file_list_widget.dart';
import 'widgets/merge_result.dart';

class MergePage extends ConsumerWidget {
  const MergePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mergeNotifierProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Merge PDFs',
        subtitle: 'Combine multiple PDF files into one',
        onBack: () => context.go('/'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
              onPressed: () => _showFilePickerDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add Files'),
              backgroundColor: AppColors.mergeColor,
            )
          : null,
    );
  }

  Widget _buildFileSelectionSection(
      BuildContext context, WidgetRef ref, MergeState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.upload_file,
                  color: AppColors.primary,
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
                    color: AppColors.border,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showFilePickerDialog(context, ref),
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 40,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose PDF Files',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select multiple PDF files to merge',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
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
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
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
                      onPressed: () => _showFilePickerDialog(context, ref),
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
              backgroundColor: AppColors.mergeColor,
            ),
          ),
          if (!state.hasEnoughFiles) ...[
            const SizedBox(height: 8),
            Text(
              'Please select at least 2 PDF files to merge',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],

        // Download Button
        if (state.hasResult) ...[
          DownloadButton(
            onPressed: state.canDownload
                ? () =>
                    ref.read(mergeNotifierProvider.notifier).downloadResult()
                : null,
            isLoading: state.isDownloading,
            downloadedPath: state.downloadedPath,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
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
                    color: AppColors.textSecondary,
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
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showFilePickerDialog(BuildContext context, WidgetRef ref) {
    // This would show a file picker dialog
    // For now, just trigger the file picker
    // In a real implementation, you'd use file_picker package
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select PDF Files'),
        content: const Text(
            'This would open a file picker to select multiple PDF files.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Here you would trigger the actual file picker
              // and call ref.read(mergeNotifierProvider.notifier).addFiles(files);
            },
            child: const Text('Select Files'),
          ),
        ],
      ),
    );
  }
}
