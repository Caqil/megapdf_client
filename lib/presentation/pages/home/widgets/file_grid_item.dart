// lib/presentation/pages/home/widgets/file_grid_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';
import 'package:megapdf_client/data/models/file_item.dart';
import 'package:megapdf_client/presentation/pages/pdf_viewer/pdf_viewer_page.dart';
import 'package:megapdf_client/presentation/providers/file_manager_provider.dart';
import 'package:megapdf_client/presentation/widgets/dialogs/folder_selection_dialog.dart';

class FileGridItem extends ConsumerWidget {
  final FileItem file;

  const FileGridItem({super.key, required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleFileTap(context, ref),
        onLongPress: () => _showFileContextMenu(context, ref),
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
              // File icon area with more button
              Row(
                children: [
                  Expanded(
                    child: Container(
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
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) =>
                        _handleFileAction(context, ref, value),
                    itemBuilder: (context) => [
                      if (file.isPdf) ...[
                        PopupMenuItem(
                          value: 'open',
                          child: ListTile(
                            leading: Icon(Icons.open_in_new,
                                size: 20, color: AppColors.primary(context)),
                            title: const Text('Open'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                      PopupMenuItem(
                        value: 'move',
                        child: ListTile(
                          leading: Icon(Icons.drive_file_move,
                              size: 20, color: AppColors.warning(context)),
                          title: const Text('Move'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'rename',
                        child: ListTile(
                          leading: Icon(Icons.edit,
                              size: 20, color: AppColors.info(context)),
                          title: const Text('Rename'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete,
                              size: 20, color: AppColors.error(context)),
                          title: Text('Delete',
                              style:
                                  TextStyle(color: AppColors.error(context))),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.background(context),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.more_vert,
                        color: AppColors.textSecondary(context),
                        size: 16,
                      ),
                    ),
                  ),
                ],
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

  void _handleFileAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'open':
        if (file.isPdf) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFViewerPage(
                filePath: file.path,
                fileName: file.name,
              ),
            ),
          );
        }
        break;
      case 'move':
        _showMoveDialog(context, ref);
        break;
      case 'rename':
        _showRenameDialog(context, ref);
        break;
      case 'delete':
        _showDeleteDialog(context, ref);
        break;
    }
  }

  void _showMoveDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => FolderSelectionDialog(
        title: 'Move ${file.isDirectory ? 'Folder' : 'File'}',
        subtitle: 'Select the destination folder for "${file.name}"',
        excludeFolderId: file.isDirectory ? file.folderId : null,
        onFolderSelected: (targetFolder) {
          ref
              .read(fileManagerNotifierProvider.notifier)
              .moveFileToFolder(file, targetFolder);
        },
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: file.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != file.name) {
                ref
                    .read(fileManagerNotifierProvider.notifier)
                    .renameItem(file, newName);
              }
              Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${file.isDirectory ? 'Folder' : 'File'}'),
        content: Text(
          'Are you sure you want to delete "${file.name}"?'
          '${file.isDirectory ? ' This will also delete all contents inside.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(fileManagerNotifierProvider.notifier).deleteItem(file);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error(context)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFileContextMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            if (file.isPdf)
              ListTile(
                leading:
                    Icon(Icons.open_in_new, color: AppColors.primary(context)),
                title: const Text('Open'),
                onTap: () {
                  Navigator.pop(context);
                  _handleFileAction(context, ref, 'open');
                },
              ),
            ListTile(
              leading: Icon(Icons.drive_file_move,
                  color: AppColors.warning(context)),
              title: const Text('Move'),
              onTap: () {
                Navigator.pop(context);
                _handleFileAction(context, ref, 'move');
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: AppColors.info(context)),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _handleFileAction(context, ref, 'rename');
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error(context)),
              title: Text('Delete',
                  style: TextStyle(color: AppColors.error(context))),
              onTap: () {
                Navigator.pop(context);
                _handleFileAction(context, ref, 'delete');
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
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
