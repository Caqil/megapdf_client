// lib/presentation/widgets/bottom_sheets/folder_actions_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FolderActionsBottomSheet extends StatelessWidget {
  final VoidCallback onCreateFolder;
  final VoidCallback onImportFiles;
  final VoidCallback onSettings;
  final VoidCallback? onSortFiles;
  final VoidCallback? onSelectFiles;

  const FolderActionsBottomSheet({
    super.key,
    required this.onCreateFolder,
    required this.onImportFiles,
    required this.onSettings,
    this.onSortFiles,
    this.onSelectFiles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Folder Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action items
          _ActionTile(
            icon: Icons.create_new_folder,
            iconColor: AppColors.primary,
            title: 'Create Folder',
            subtitle: 'Create a new folder to organize files',
            onTap: () {
              Navigator.pop(context);
              onCreateFolder();
            },
          ),

          _ActionTile(
            icon: Icons.upload_file,
            iconColor: AppColors.secondary,
            title: 'Import Files',
            subtitle: 'Import files from your device',
            onTap: () {
              Navigator.pop(context);
              onImportFiles();
            },
          ),

          if (onSortFiles != null)
            _ActionTile(
              icon: Icons.sort,
              iconColor: AppColors.warning,
              title: 'Sort Files',
              subtitle: 'Change file sorting order',
              onTap: () {
                Navigator.pop(context);
                onSortFiles!();
              },
            ),

          if (onSelectFiles != null)
            _ActionTile(
              icon: Icons.checklist,
              iconColor: AppColors.info,
              title: 'Select Files',
              subtitle: 'Select multiple files for batch operations',
              onTap: () {
                Navigator.pop(context);
                onSelectFiles!();
              },
            ),

          const Divider(height: 1),

          _ActionTile(
            icon: Icons.settings,
            iconColor: AppColors.textSecondary,
            title: 'Settings',
            subtitle: 'App preferences and settings',
            onTap: () {
              Navigator.pop(context);
              onSettings();
            },
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
        size: 20,
      ),
    );
  }
}
