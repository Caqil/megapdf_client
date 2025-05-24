// lib/presentation/pages/settings/widgets/file_management_section_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';
import 'package:megapdf_client/presentation/widgets/common/custom_snackbar.dart';
import 'package:megapdf_client/presentation/pages/settings/widgets/section_card_widget.dart';

class FileManagementSectionWidget extends ConsumerWidget {
  const FileManagementSectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCardWidget(
      title: 'File Management',
      icon: Icons.folder_open,
      iconColor: AppColors.secondary(context),
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Icon(
            Icons.storage_rounded,
            color: AppColors.secondary(context),
            size: 28,
          ),
          title: Text(
            'File Manager',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Browse, rename, and delete files saved by MegaPDF',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary(context),
          ),
          onTap: () => context.push('/storage'),
        ),
        const Divider(height: 1, indent: 20, endIndent: 20),
       
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Icon(
            Icons.delete_outline,
            color: AppColors.error(context),
            size: 28,
          ),
          title: Text(
            'Clear All Recent Files',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Remove all recent file history (does not delete actual files)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
          ),
          onTap: () => _showClearHistoryDialog(context),
        ),
      ],
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Recent Files History'),
        content: const Text(
          'This will remove all recent file history but won\'t delete the actual files. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Add logic to clear recent files history
              CustomSnackbar.show(
                context: context,
                message: 'Recent files history cleared successfully',
                type: SnackbarType.success,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error(context),
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear History'),
          ),
        ],
      ),
    );
  }
}
