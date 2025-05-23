import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';
import 'package:megapdf_client/data/models/file_item.dart';
import 'package:megapdf_client/presentation/pages/pdf_viewer/pdf_viewer_page.dart';
import 'package:megapdf_client/presentation/providers/file_manager_provider.dart';

import '../../../widgets/common/custom_snackbar.dart';

class FileListItem extends ConsumerWidget {
  final FileItem file;

  const FileListItem({super.key, required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleFileTap(context, ref),
        onLongPress: () => _showFileContextMenu(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: file.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  file.icon,
                  color: file.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (!file.isDirectory) ...[
                          Text(
                            file.formattedSize,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary(context),
                                    ),
                          ),
                          const Text(' • '),
                        ],
                        Text(
                          file.formattedDate,
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
              PopupMenuButton<String>(
                onSelected: (value) => _handleFileAction(context, ref, value),
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
                    value: 'rename',
                    child: ListTile(
                      leading: Icon(Icons.edit,
                          size: 20, color: AppColors.info(context)),
                      title: const Text('Rename'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
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
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete,
                          size: 20, color: AppColors.error(context)),
                      title: Text('Delete',
                          style: TextStyle(color: AppColors.error(context))),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary(context),
                  size: 20,
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
      case 'rename':
        _showRenameDialog(context, ref);
        break;
      case 'move':
        _showSnackBar(context, 'Move functionality coming soon!');
        break;
      case 'delete':
        _showDeleteDialog(context, ref);
        break;
    }
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

  void _showFileContextMenu(BuildContext context) {
    _showSnackBar(context, 'File context menu coming soon!');
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    CustomSnackbar.show(
      context: context,
      message: message,
      type: isError ? SnackbarType.failure : SnackbarType.info,
      duration: const Duration(seconds: 4),
    );
  }
}
