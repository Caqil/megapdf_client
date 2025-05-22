// lib/presentation/pages/merge/widgets/file_list_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/file_extensions.dart';

class FileListWidget extends StatelessWidget {
  final List<File> files;
  final Function(int) onRemoveFile;
  final Function(int, int) onReorderFiles;

  const FileListWidget({
    super.key,
    required this.files,
    required this.onRemoveFile,
    required this.onReorderFiles,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.list,
                  color: AppColors.mergeColor,
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
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.drag_indicator,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Drag to reorder files. Files will be merged in this order.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
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

  Widget _buildFileItem(BuildContext context, File file, int index) {
    return Container(
      key: ValueKey(file.path),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mergeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.mergeColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Order Number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.mergeColor,
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
            color: AppColors.mergeColor,
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
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Drag Handle
          Icon(
            Icons.drag_handle,
            color: AppColors.textMuted,
          ),
          
          const SizedBox(width: 8),
          
          // Remove Button
          IconButton(
            onPressed: () => onRemoveFile(index),
            icon: Icon(
              Icons.close,
              color: AppColors.error,
              size: 20,
            ),
            tooltip: 'Remove file',
          ),
        ],
      ),
    );
  }
}
