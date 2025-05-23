// lib/presentation/widgets/storage/recently_saved_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../presentation/providers/file_path_provider.dart';
import '../../pages/pdf_viewer/pdf_viewer_page.dart';

class RecentlySavedWidget extends ConsumerWidget {
  final VoidCallback? onViewAll;

  const RecentlySavedWidget({Key? key, this.onViewAll}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedFileState = ref.watch(fileSaveNotifierProvider);

    // If no recently saved file, return empty container
    if (!savedFileState.hasLastSaved) {
      return const SizedBox.shrink();
    }

    final filePath = savedFileState.lastSavedFilePath!;
    final fileName = filePath.split('/').last;
    final fileType = savedFileState.lastSavedType ?? 'unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success(context).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.success(context),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Recently Saved',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success(context),
                    ),
              ),
              const Spacer(),
              Text(
                savedFileState.timeAgo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _openFile(context, filePath, fileName),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getOperationColor(context, fileType)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getOperationIcon(fileType),
                      color: _getOperationColor(context, fileType),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to open file',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.open_in_new,
                    color: AppColors.primary(context),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                'Share',
                Icons.share,
                AppColors.secondary(context),
                () => _shareFile(context, filePath),
              ),
              _buildActionButton(
                context,
                'Find in Folder',
                Icons.folder_open,
                AppColors.primary(context),
                () => _openFolder(context, filePath),
              ),
              _buildActionButton(
                context,
                'Delete',
                Icons.delete,
                AppColors.error(context),
                () => _confirmDelete(context, ref, filePath),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFile(BuildContext context, String filePath, String fileName) {
    final file = File(filePath);
    if (!file.existsSync()) {
      _showSnackBar(context, 'File not found', isError: true);
      return;
    }

    if (filePath.toLowerCase().endsWith('.pdf')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(
            filePath: filePath,
            fileName: fileName,
          ),
        ),
      );
    } else {
      // For non-PDF files, you might want to use a different approach
      _showSnackBar(context, 'Opening non-PDF files coming soon!');
    }
  }

  void _shareFile(BuildContext context, String filePath) {
    // Implementation of sharing would go here
    _showSnackBar(context, 'Sharing coming soon!');
  }

  void _openFolder(BuildContext context, String filePath) {
    // Implementation of opening folder would go here
    _showSnackBar(context, 'Opening folder coming soon!');
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: const Text(
            'Are you sure you want to delete this file? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFile(context, ref, filePath);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error(context),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteFile(BuildContext context, WidgetRef ref, String filePath) {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync();
        ref.read(fileSaveNotifierProvider.notifier).clearState();
        _showSnackBar(context, 'File deleted successfully');
      } else {
        _showSnackBar(context, 'File not found', isError: true);
      }
    } catch (e) {
      _showSnackBar(context, 'Error deleting file: $e', isError: true);
    }
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error(context) : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getOperationColor(BuildContext context, String operationType) {
    switch (operationType) {
      case 'compress':
        return AppColors.compressColor(context);
      case 'merge':
        return AppColors.mergeColor(context);
      case 'split':
        return AppColors.splitColor(context);
      case 'convert':
        return AppColors.convertColor(context);
      case 'protect':
        return AppColors.protectColor(context);
      case 'unlock':
        return AppColors.unlockColor(context);
      case 'rotate':
        return AppColors.rotateColor(context);
      case 'watermark':
        return AppColors.watermarkColor(context);
      case 'page_numbers':
        return AppColors.pageNumbersColor(context);
      default:
        return AppColors.primary(context);
    }
  }

  IconData _getOperationIcon(String operationType) {
    switch (operationType) {
      case 'compress':
        return Icons.compress;
      case 'merge':
        return Icons.merge;
      case 'split':
        return Icons.call_split;
      case 'convert':
        return Icons.transform;
      case 'protect':
        return Icons.lock;
      case 'unlock':
        return Icons.lock_open;
      case 'rotate':
        return Icons.rotate_right;
      case 'watermark':
        return Icons.branding_watermark;
      case 'page_numbers':
        return Icons.format_list_numbered;
      default:
        return Icons.description;
    }
  }
}
