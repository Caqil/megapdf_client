import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/compress_result.dart';

class CompressionResult extends StatelessWidget {
  final CompressResult result;

  const CompressionResult({
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
                        'Compression Complete',
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

            // Compression Stats
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.compressColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.compressColor(context).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  // Compression Ratio
                  if (result.compressionRatio != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.trending_down,
                          color: AppColors.compressColor(context),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${result.compressionRatio} Size Reduction',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.compressColor(context),
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Size Comparison
                  Row(
                    children: [
                      Expanded(
                        child: _buildSizeInfo(
                          context,
                          'Original Size',
                          result.formattedOriginalSize,
                          Icons.file_present,
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
                          'Compressed Size',
                          result.formattedCompressedSize,
                          Icons.photo_size_select_small_sharp,
                          AppColors.success(context),
                        ),
                      ),
                    ],
                  ),

                  if (result.originalSize != null &&
                      result.compressedSize != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.save_alt,
                            color: AppColors.success(context),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Space Saved: ${result.savedSpace}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success(context),
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
