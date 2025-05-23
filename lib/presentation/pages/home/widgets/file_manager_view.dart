// lib/presentation/widgets/home/widgets/file_manager_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/file_item.dart';
import '../../../providers/file_manager_provider.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/dialogs/folder_selection_dialog.dart';

class FileManagerView extends ConsumerWidget {
  final Function(FileItem) onFolderTap;
  final Function(FileItem) onFileTap;
  final Function(FileItem)? onFileLongPress;

  const FileManagerView({
    super.key,
    required this.onFolderTap,
    required this.onFileTap,
    this.onFileLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileManagerState = ref.watch(fileManagerNotifierProvider);
    final fileManagerNotifier = ref.read(fileManagerNotifierProvider.notifier);

    // Show success message
    if (fileManagerState.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(fileManagerState.successMessage!),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        fileManagerNotifier.clearSuccessMessage();
      });
    }

    if (fileManagerState.isLoading) {
      return const Center(
        child: LoadingWidget(message: 'Loading files...'),
      );
    }

    if (fileManagerState.error != null) {
      return Center(
        child: CustomErrorWidget(
          message: fileManagerState.error!,
          onRetry: () {
            if (fileManagerState.currentFolder != null) {
              fileManagerNotifier
                  .loadFolder(fileManagerState.currentFolder!.id!);
            } else {
              fileManagerNotifier.loadRootFolder();
            }
          },
        ),
      );
    }

    if (!fileManagerState.hasFiles) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No files yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a folder or import files to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: fileManagerState.fileItems.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = fileManagerState.fileItems[index];
        return FileItemTile(
          item: item,
          onTap: () {
            if (item.isDirectory) {
              onFolderTap(item);
            } else {
              onFileTap(item);
            }
          },
          onLongPress:
              onFileLongPress != null ? () => onFileLongPress!(item) : null,
          onMove: (item) => _showMoveDialog(context, ref, item),
          onRename: (item) => _showRenameDialog(context, ref, item),
          onDelete: (item) => _showDeleteDialog(context, ref, item),
        );
      },
    );
  }

  void _showMoveDialog(BuildContext context, WidgetRef ref, FileItem item) {
    showDialog(
      context: context,
      builder: (context) => FolderSelectionDialog(
        title: 'Move ${item.isDirectory ? 'Folder' : 'File'}',
        subtitle: 'Select the destination folder for "${item.name}"',
        excludeFolderId: item.isDirectory ? item.folderId : null,
        onFolderSelected: (targetFolder) {
          ref
              .read(fileManagerNotifierProvider.notifier)
              .moveFileToFolder(item, targetFolder);
        },
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, FileItem item) {
    final controller = TextEditingController(text: item.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename ${item.isDirectory ? 'Folder' : 'File'}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (_) =>
              _performRename(context, ref, item, controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                _performRename(context, ref, item, controller.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _performRename(
      BuildContext context, WidgetRef ref, FileItem item, String newName) {
    if (newName.trim().isNotEmpty && newName.trim() != item.name) {
      ref
          .read(fileManagerNotifierProvider.notifier)
          .renameItem(item, newName.trim());
    }
    Navigator.pop(context);
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, FileItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${item.isDirectory ? 'Folder' : 'File'}'),
        content: Text(
          'Are you sure you want to delete "${item.name}"?'
          '${item.isDirectory ? ' This will also remove all contents inside.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(fileManagerNotifierProvider.notifier).deleteItem(item);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class FileItemTile extends StatelessWidget {
  final FileItem item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Function(FileItem) onMove;
  final Function(FileItem) onRename;
  final Function(FileItem) onDelete;

  const FileItemTile({
    super.key,
    required this.item,
    required this.onTap,
    this.onLongPress,
    required this.onMove,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      onTap: onTap,
      onLongPress: onLongPress,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: item.iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          item.icon,
          color: item.iconColor,
          size: 24,
        ),
      ),
      title: Text(
        item.name,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          if (!item.isDirectory) ...[
            Text(
              item.formattedSize,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const Text(' • '),
          ],
          Text(
            item.formattedDate,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleMenuAction(context, value),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'move',
            child: ListTile(
              leading: Icon(Icons.drive_file_move,
                  size: 20, color: AppColors.primary),
              title: const Text('Move'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuItem(
            value: 'rename',
            child: ListTile(
              leading: Icon(Icons.edit, size: 20),
              title: Text('Rename'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete, size: 20, color: AppColors.error),
              title: Text('Delete', style: TextStyle(color: AppColors.error)),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
        child: Icon(
          Icons.more_vert,
          color: AppColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'move':
        onMove(item);
        break;
      case 'rename':
        onRename(item);
        break;
      case 'delete':
        onDelete(item);
        break;
    }
  }
}
