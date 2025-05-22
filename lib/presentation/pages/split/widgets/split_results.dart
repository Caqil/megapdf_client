// lib/presentation/pages/split/widgets/split_results.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/split_result.dart';

class SplitResults extends StatelessWidget {
  final List<SplitPart> parts;
  final Function(SplitPart) onDownloadPart;
  final VoidCallback onDownloadAll;
  final bool isDownloading;

  const SplitResults({
    super.key,
    required this.parts,
    required this.onDownloadPart,
    required this.onDownloadAll,
    this.isDownloading = false,
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
                        'Split Complete',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                      ),
                      Text(
                        '${parts.length} files created',
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

            // Download All Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isDownloading ? null : onDownloadAll,
                icon: isDownloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.download),
                label: Text(
                    isDownloading ? 'Downloading...' : 'Download All Files'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.success,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Individual Files
            Text(
              'Individual Files:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: parts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final part = parts[index];
                return _buildPartItem(context, part, index + 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartItem(BuildContext context, SplitPart part, int partNumber) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.splitColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.splitColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // File Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.splitColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.picture_as_pdf,
              color: AppColors.splitColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Part $partNumber',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pages: ${part.pageRange}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                Text(
                  '${part.pageCount} page${part.pageCount != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),

          // Download Button
          IconButton(
            onPressed: isDownloading ? null : () => onDownloadPart(part),
            icon: Icon(
              Icons.download,
              color: isDownloading ? AppColors.textMuted : AppColors.splitColor,
            ),
            tooltip: 'Download this part',
          ),
        ],
      ),
    );
  }
}
