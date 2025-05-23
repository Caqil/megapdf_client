// lib/presentation/pages/split/widgets/split_results.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/split_result.dart';

class SplitResults extends StatelessWidget {
  final SplitResult result;
  final List<String> savedPaths;
  final Function(String) onOpenPart;
  final VoidCallback onDownloadAll;
  final bool isDownloading;

  const SplitResults({
    super.key,
    required this.result,
    this.savedPaths = const [],
    required this.onOpenPart,
    required this.onDownloadAll,
    this.isDownloading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Get split parts from result
    final parts = result.splitParts ?? [];

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
                        'Split Complete',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success(context),
                            ),
                      ),
                      Text(
                        '${parts.length} file${parts.length != 1 ? 's' : ''} created',
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
                  backgroundColor: AppColors.success(context),
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

            // Special case for single part
            if (parts.length == 1)
              _buildSinglePartItem(context, parts.first, 1,
                  savedPaths.isNotEmpty ? savedPaths.first : null)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: parts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final part = parts[index];
                  final savedPath =
                      index < savedPaths.length ? savedPaths[index] : null;
                  return _buildPartItem(context, part, index + 1, savedPath);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSinglePartItem(
      BuildContext context, SplitPart part, int partNumber, String? savedPath) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success(context).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.splitColor(context).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.picture_as_pdf,
                  color: AppColors.splitColor(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      part.filename ?? 'Split PDF',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Pages: ${part.pageRange ?? 'All'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                    ),
                  ],
                ),
              ),
              if (savedPath != null)
                ElevatedButton.icon(
                  onPressed: () => onOpenPart(savedPath),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.splitColor(context),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your PDF was split successfully. Since it only had one page, the result is identical to the original.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartItem(
      BuildContext context, SplitPart part, int partNumber, String? savedPath) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.splitColor(context).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: AppColors.splitColor(context).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // File Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.splitColor(context).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.picture_as_pdf,
              color: AppColors.splitColor(context),
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
                  'Pages: ${part.pageRange ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                ),
                Text(
                  '${part.pageCount ?? 0} page${part.pageCount != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                ),
              ],
            ),
          ),

          // View Button
          if (savedPath != null)
            ElevatedButton.icon(
              onPressed: () => onOpenPart(savedPath),
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('View'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.splitColor(context),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
        ],
      ),
    );
  }
}
