// Recent File Card Widget
import 'package:flutter/material.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';
import 'package:megapdf_client/data/models/recent_file_model.dart';

class RecentFileCard extends StatelessWidget {
  final RecentFileModel item;
  final VoidCallback onTap;

  const RecentFileCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getOperationColor(item.operationType, context);
    final icon = _getOperationIcon(item.operationType);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow(context),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Operation icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // File info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.originalFileName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(context),
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
                            item.operation,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _getSizeInfo(),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary(context),
                                    ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.textSecondary(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.timeAgo,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                        ),
                        const Spacer(),
                        if (item.resultFilePath != null) ...[
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.success(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Saved',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.success(context),
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // More button
              Icon(
                Icons.more_vert,
                color: AppColors.textSecondary(context),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSizeInfo() {
    if (item.resultSize != null && item.resultSize != item.originalSize) {
      return '${item.originalSize} → ${item.resultSize}';
    }
    return item.originalSize;
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
