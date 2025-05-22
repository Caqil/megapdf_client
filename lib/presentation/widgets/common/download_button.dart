// lib/presentation/widgets/common/download_button.dart
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import '../../../core/theme/app_colors.dart';

class DownloadButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? downloadedPath;

  const DownloadButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.downloadedPath,
  });

  @override
  Widget build(BuildContext context) {
    if (downloadedPath != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Success Message
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
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Download Complete!',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'File saved to Downloads folder',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Open File Button
          ElevatedButton.icon(
            onPressed: () => OpenFile.open(downloadedPath!),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open File'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.success,
            ),
          ),
        ],
      );
    }

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.download),
      label: Text(isLoading ? 'Downloading...' : 'Download Result'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
