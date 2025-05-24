import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/file_extensions.dart';

class FileListWidget extends StatelessWidget {
  final List<File> files;
  final Function(int) onRemoveFile;
  final Function(int, int) onReorderFiles;
  final bool showPreview;

  const FileListWidget({
    super.key,
    required this.files,
    required this.onRemoveFile,
    required this.onReorderFiles,
    this.showPreview = true,
  });

  @override
  Widget build(BuildContext context) {
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
                  Icons.list,
                  color: AppColors.mergeColor(context),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Files to Merge',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  '${files.length} files',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.info(context).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.drag_indicator,
                    color: AppColors.info(context),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Drag to reorder files. Files will be merged in this order.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.info(context),
                          ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Total size indicator
            if (files.isNotEmpty) ...[
              _buildTotalSizeIndicator(context),
              const SizedBox(height: 16),
            ],

            // File List
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: files.length,
              onReorder: onReorderFiles,
              itemBuilder: (context, index) {
                final file = files[index];
                return _buildFileItem(context, file, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSizeIndicator(BuildContext context) {
    // Calculate total size
    int totalBytes = 0;
    for (final file in files) {
      totalBytes += file.lengthSync();
    }

    // Format total size
    final totalSizeMB = (totalBytes / (1024 * 1024)).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.mergeColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: AppColors.mergeColor(context).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.data_usage,
            color: AppColors.mergeColor(context),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Total Size: $totalSizeMB MB',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.mergeColor(context),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(BuildContext context, File file, int index) {
    return Container(
      key: ValueKey(file.path),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mergeColor(context).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: AppColors.mergeColor(context).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Order Number
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.mergeColor(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // File Icon
              Icon(
                Icons.picture_as_pdf,
                color: AppColors.mergeColor(context),
                size: 24,
              ),

              const SizedBox(width: 12),

              // File Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.baseName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Size: ${file.formattedSize}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                    ),
                  ],
                ),
              ),

              // Drag Handle
              Icon(
                Icons.drag_handle,
                color: AppColors.textMuted(context),
              ),

              const SizedBox(width: 8),

              // Remove Button
              IconButton(
                onPressed: () => onRemoveFile(index),
                icon: Icon(
                  Icons.close,
                  color: AppColors.error(context),
                  size: 20,
                ),
                tooltip: 'Remove file',
              ),
            ],
          ),

          // Preview (conditionally shown)
          if (showPreview) ...[
            const SizedBox(height: 8),
            _buildPreview(context, file),
          ],
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context, File file) {
    // For a real implementation, you would use a PDF thumbnail library
    // For this example, we'll just show a placeholder
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf,
            color: Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            'PDF Preview',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}
