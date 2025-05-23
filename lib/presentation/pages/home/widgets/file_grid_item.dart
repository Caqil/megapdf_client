import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';
import 'package:megapdf_client/data/models/file_item.dart';
import 'package:megapdf_client/presentation/pages/pdf_viewer/pdf_viewer_page.dart';
import 'package:megapdf_client/presentation/providers/file_manager_provider.dart';

class FileGridItem extends ConsumerWidget {
  final FileItem file;

  const FileGridItem({super.key, required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleFileTap(context, ref),
        onLongPress: () =>
            _showSnackBar(context, 'File context menu coming soon!'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: file.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  file.icon,
                  color: file.iconColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                file.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (!file.isDirectory)
                Text(
                  file.formattedSize,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                ),
              Text(
                file.formattedDate,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileTap(BuildContext context, WidgetRef ref) {
    if (file.isDirectory) {
      if (file.folderId != null) {
        ref
            .read(fileManagerNotifierProvider.notifier)
            .navigateToFolder(file.folderId!);
      }
    } else if (file.isPdf) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(
            filePath: file.path,
            fileName: file.name,
          ),
        ),
      );
    } else {
      _showSnackBar(context, 'File options coming soon!');
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
}
