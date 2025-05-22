// lib/presentation/widgets/common/enhanced_download_button.dart
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import '../../../core/theme/app_colors.dart';

class DownloadButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? downloadedPath;
  final double? progress;
  final String? downloadId;
  final Function(String downloadId)? onDownloadIdReceived;
  final VoidCallback? onCancel;

  const DownloadButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.downloadedPath,
    this.progress,
    this.downloadId,
    this.onDownloadIdReceived,
    this.onCancel,
  });

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  @override
  Widget build(BuildContext context) {
    if (widget.downloadedPath != null) {
      return _buildSuccessState();
    }

    if (widget.isLoading) {
      return _buildLoadingState();
    }

    return _buildInitialState();
  }

  Widget _buildSuccessState() {
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
          onPressed: () => OpenFile.open(widget.downloadedPath!),
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

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress indicator
        if (widget.progress != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Downloading...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                '${(widget.progress! * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: widget.progress,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
        ],

        // Cancel/Loading button
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: null,
                icon: widget.progress != null
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: widget.progress,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                label: Text(
                    widget.progress != null ? 'Downloading...' : 'Starting...'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                ),
              ),
            ),

            // Cancel button if download ID is available
            if (widget.downloadId != null && widget.onCancel != null) ...[
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: widget.onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                child: const Icon(Icons.close),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildInitialState() {
    return ElevatedButton.icon(
      onPressed: widget.onPressed,
      icon: const Icon(Icons.download),
      label: const Text('Download Result'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
