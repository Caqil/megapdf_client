import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/merge_result.dart';

class MergeResultWidget extends StatelessWidget {
  final MergeResult result;

  const MergeResultWidget({
    super.key,
    required this.result,
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
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success(context).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.success(context),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Merge Complete',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success(context),
                            ),
                      ),
                      Text(
                        result.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Merge Stats
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mergeColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.mergeColor(context).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  // File Count and Document Preview
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // File Count
                            Row(
                              children: [
                                Icon(
                                  Icons.merge,
                                  color: AppColors.mergeColor(context),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${result.fileCount ?? 0} Files Merged',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.mergeColor(context),
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Total Page Count
                            if (result.fileCount != null)
                              Row(
                                children: [
                                  Icon(
                                    Icons.file_copy,
                                    color: AppColors.textSecondary(context),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${result.fileCount} Pages',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color:
                                              AppColors.textSecondary(context),
                                        ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Document Preview
                      Container(
                        width: 80,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              color: AppColors.mergeColor(context),
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'PDF',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Size Comparison
                  Row(
                    children: [
                      Expanded(
                        child: _buildSizeInfo(
                          context,
                          'Total Input',
                          result.formattedTotalInputSize,
                          Icons.input,
                          AppColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.textMuted(context),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSizeInfo(
                          context,
                          'Merged File',
                          result.formattedMergedSize,
                          Icons.picture_as_pdf,
                          AppColors.success(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Compression Info
                  if (result.compressionRatio != 0) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: result.compressionRatio > 0
                            ? AppColors.success(context).withOpacity(0.1)
                            : AppColors.info(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            result.compressionRatio > 0
                                ? Icons.trending_down
                                : Icons.info,
                            color: result.compressionRatio > 0
                                ? AppColors.success(context)
                                : AppColors.info(context),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            result.compressionInfo,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: result.compressionRatio > 0
                                      ? AppColors.success(context)
                                      : AppColors.info(context),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // File Info
            if (result.filename != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    color: AppColors.textSecondary(context),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                 
                ],
              ),
            ],

            // Additional Information
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
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
                    Icons.info,
                    color: AppColors.info(context),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your PDF files have been merged successfully. Click "Save Merged PDF" to download the result.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.info(context),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeInfo(
    BuildContext context,
    String label,
    String size,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary(context),
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          size,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Extension methods for MergeResult to add convenience getters
extension MergeResultExtension on MergeResult {
  String get formattedTotalInputSize {
    if (totalInputSize == null) return 'Unknown';
    return '${(totalInputSize! / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String get formattedMergedSize {
    if (mergedSize == null) return 'Unknown';
    return '${(mergedSize! / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String get compressionInfo {
    if (compressionRatio == null || compressionRatio == 0) {
      return 'No size change';
    }

    if (compressionRatio! > 0) {
      return '${compressionRatio?.toStringAsFixed(1)}% Size Reduction';
    } else {
      return '${compressionRatio?.abs().toStringAsFixed(1)}% Size Increase';
    }
  }
}
