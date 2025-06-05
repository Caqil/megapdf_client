// lib/presentation/pages/settings/widgets/files_storage_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/settings_provider.dart';
import 'common/custom_snackbar.dart';
import 'settings_section_widget.dart';

class FilesStorageSection extends ConsumerWidget {
  final SettingsState state;

  const FilesStorageSection({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsSectionWidget(
      title: 'Files & Storage',
      icon: Icons.storage,
      iconColor: AppColors.secondary(context),
      children: [
        // Storage Usage
        if (state.storageInfo != null) ...[
          _buildStorageUsageItem(context, state.storageInfo!),
          const Divider(height: 1, indent: 16, endIndent: 16),
        ],

        // Auto-delete old files
        SettingsItemWidget(
          icon: Icons.auto_delete,
          iconColor: AppColors.warning(context),
          title: 'Auto-delete Old Files',
          subtitle: 'Remove files older than ${state.autoDeleteDisplayName}',
          onTap: () => _showAutoDeleteDialog(context, ref),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Clear Recent Files
        SettingsItemWidget(
          icon: Icons.history,
          iconColor: AppColors.info(context),
          title: 'Clear Recent Files',
          subtitle: 'Remove recent files history',
          onTap: () => _showClearRecentDialog(context, ref),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Clear All App Data
        SettingsItemWidget(
          icon: Icons.delete_forever,
          iconColor: AppColors.error(context),
          title: 'Clear All Data',
          subtitle: 'Remove all files and reset app',
          onTap: () => _showClearAllDataDialog(context, ref),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Export/Backup Files
        SettingsItemWidget(
          icon: Icons.backup,
          iconColor: AppColors.success(context),
          title: 'Backup Files',
          subtitle: 'Export your files to external storage',
          onTap: () => _exportFiles(context),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // App Directory
        if (state.storageInfo != null) ...[
          SettingsItemWidget(
            icon: Icons.folder_open,
            iconColor: AppColors.primary(context),
            title: 'App Directory',
            subtitle: _getShortPath(state.storageInfo!.appDirectory),
            onTap: () =>
                _showDirectoryInfo(context, state.storageInfo!.appDirectory),
            trailing: Icon(
              Icons.info_outline,
              color: AppColors.textSecondary(context),
              size: 20,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStorageUsageItem(BuildContext context, StorageInfo storage) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pie_chart,
                  color: AppColors.secondary(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Storage Usage',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${storage.totalFiles} files • ${storage.formattedSize}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _showDetailedStorage(context, storage),
                child: Text('Details'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Storage breakdown
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStorageBreakdownItem(
                    context,
                    'Files',
                    storage.totalFiles.toString(),
                    Icons.description,
                    AppColors.primary(context),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.border(context),
                ),
                Expanded(
                  child: _buildStorageBreakdownItem(
                    context,
                    'Recent',
                    storage.recentFilesCount.toString(),
                    Icons.history,
                    AppColors.info(context),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.border(context),
                ),
                Expanded(
                  child: _buildStorageBreakdownItem(
                    context,
                    'Size',
                    storage.formattedSize,
                    Icons.storage,
                    AppColors.warning(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageBreakdownItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary(context),
              ),
        ),
      ],
    );
  }

  String _getShortPath(String fullPath) {
    if (fullPath.length <= 30) return fullPath;
    return '...${fullPath.substring(fullPath.length - 27)}';
  }

  void _showAutoDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Auto-delete Old Files'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Automatically delete files older than:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...([0, 7, 14, 30, 60, 90].map((days) {
              final displayText = days == 0 ? 'Never' : '$days days';
              return RadioListTile<int>(
                title: Text(displayText),
                value: days,
                groupValue: state.autoDeleteDays,
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(settingsNotifierProvider.notifier)
                        .updateAutoDeleteDays(value);
                    Navigator.pop(context);
                  }
                },
                activeColor: AppColors.primary(context),
              );
            }).toList()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearRecentDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.warning(context)),
            const SizedBox(width: 8),
            Text('Clear Recent Files'),
          ],
        ),
        content: Text(
          'This will remove all entries from your recent files history. The actual files will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(settingsNotifierProvider.notifier)
                  .clearRecentFiles();

              if (context.mounted) {
                CustomSnackbar.show(
                  context: context,
                  message: 'Recent files history cleared',
                  type: SnackbarType.success,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning(context),
            ),
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.error(context)),
            const SizedBox(width: 8),
            Text('Clear All Data'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text('• All processed files'),
            Text('• Recent files history'),
            Text('• App cache and temporary files'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.error(context).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: AppColors.error(context),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error(context),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(settingsNotifierProvider.notifier).clearAppData();

              if (context.mounted) {
                CustomSnackbar.show(
                  context: context,
                  message: 'All app data cleared',
                  type: SnackbarType.success,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error(context),
            ),
            child: Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showDetailedStorage(BuildContext context, StorageInfo storage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Storage Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                  context, 'Total Files', storage.totalFiles.toString()),
              _buildDetailRow(context, 'Total Size', storage.formattedSize),
              _buildDetailRow(
                  context, 'Recent Files', storage.recentFilesCount.toString()),
              _buildDetailRow(context, 'Storage Path', storage.appDirectory),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDirectoryInfo(BuildContext context, String directory) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('App Directory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MegaPDF stores all processed files in this directory:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: SelectableText(
                directory,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border:
                    Border.all(color: AppColors.info(context).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.info(context),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can access this folder using any file manager app.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.info(context),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportFiles(BuildContext context) {
    CustomSnackbar.show(
      context: context,
      message: 'File export functionality coming soon',
      type: SnackbarType.info,
    );
  }
}
