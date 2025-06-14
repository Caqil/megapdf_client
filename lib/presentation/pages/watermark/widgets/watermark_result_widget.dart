// lib/presentation/pages/watermark/widgets/watermark_result_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/watermark_result.dart';

class WatermarkResultWidget extends StatelessWidget {
  final WatermarkResult result;

  const WatermarkResultWidget({
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
                        'Watermark Added',
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

            // File Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.watermarkColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.watermarkColor(context).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.branding_watermark,
                    color: AppColors.watermarkColor(context),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Watermark Applied Successfully',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.watermarkColor(context),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (result.fileSize != null) ...[
                    Text(
                      'File Size: ${result.formattedFileSize}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // File Details
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
}
