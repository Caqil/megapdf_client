import 'package:flutter/material.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';
import 'package:megapdf_client/presentation/providers/recent_files_provider.dart';

class RecentTab extends StatelessWidget {
  final RecentFilesState recentState;

  const RecentTab({super.key, required this.recentState});

  @override
  Widget build(BuildContext context) {
    if (recentState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (recentState.recentFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 64,
              color: AppColors.textSecondary(context).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No recent files',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Files you process will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: recentState.recentFiles.take(20).length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final file = recentState.recentFiles[index];
        return _buildRecentFileCard(context, file);
      },
    );
  }

  Widget _buildRecentFileCard(BuildContext context, dynamic recentFile) {
    final color = _getOperationColor(recentFile.operationType, context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (recentFile.resultFilePath != null) {
            Navigator.pushNamed(
              context,
              '/pdfViewer',
              arguments: {
                'filePath': recentFile.resultFilePath,
                'fileName': recentFile.originalFileName,
              },
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getOperationIcon(recentFile.operationType),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recentFile.originalFileName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            recentFile.operation,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          recentFile.timeAgo,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (recentFile.resultFilePath != null)
                Icon(Icons.check_circle,
                    color: AppColors.success(context), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Color _getOperationColor(String operationType, BuildContext context) {
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
