// lib/presentation/pages/merge/widgets/merge_result.dart
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
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.success,
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
                              color: AppColors.success,
                            ),
                      ),
                      Text(
                        result.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
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
                color: AppColors.mergeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.mergeColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  // File Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.merge,
                        color: AppColors.mergeColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${result.fileCount ?? 0} Files Merged',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.mergeColor,
                                ),
                      ),
                    ],
                  ),
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
                          AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSizeInfo(
                          context,
                          'Merged File',
                          result.formattedMergedSize,
                          Icons.picture_as_pdf,
                          AppColors.success,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Compression Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: result.compressionRatio > 0
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.info.withOpacity(0.1),
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
                              ? AppColors.success
                              : AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          result.compressionInfo,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: result.compressionRatio > 0
                                        ? AppColors.success
                                        : AppColors.info,
                                  ),
                        ),
                      ],
                    ),
                  ),
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
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'File: ${result.filename}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ],
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
                color: AppColors.textSecondary,
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
