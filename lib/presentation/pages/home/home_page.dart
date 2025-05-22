// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:megapdf_client/presentation/pages/home/widgets/folder_actions_bottom_sheet.dart'
    show FolderActionsBottomSheet;

import '../../../core/theme/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../providers/file_manager_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/dialogs/create_folder_dialog.dart';
import 'widgets/file_manager_view.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load files when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fileManagerNotifierProvider.notifier).loadRootFolder();
    });
  }

  @override
  Widget build(BuildContext context) {
    final fileManagerState = ref.watch(fileManagerNotifierProvider);
    final fileManagerNotifier = ref.read(fileManagerNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomHomeAppBar(
        onSearchTap: () => _showSearchDialog(context),
        onMenuTap: () => _showMenuBottomSheet(context),
      ),
      body: Column(
        children: [
          // Path breadcrumb
          if (fileManagerState.folderPath.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.surface,
              child: Row(
                children: [
                  if (fileManagerNotifier.canGoUp())
                    IconButton(
                      onPressed: () => fileManagerNotifier.navigateUp(),
                      icon: const Icon(Icons.arrow_back),
                      iconSize: 20,
                    ),
                  Expanded(
                    child: Text(
                      fileManagerNotifier.getCurrentPath(),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Storage info
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileManagerState.currentFolder?.name ?? 'My Files',
                        style: context.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${fileManagerState.folderCount} folders, ${fileManagerState.fileCount} files',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showCreateFolderDialog(context),
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: Text(
                    'New',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // File list
          Expanded(
            child: FileManagerView(
              onFolderTap: (folder) {
                if (folder.folderId != null) {
                  fileManagerNotifier.navigateToFolder(folder.folderId!);
                }
              },
              onFileTap: (file) {
                _showFileOptionsBottomSheet(context, file);
              },
              onFileLongPress: (file) {
                // Enter selection mode or show context menu
                _showFileContextMenu(context, file);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Files'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter file name...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            // TODO: Implement search functionality
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showMenuBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => FolderActionsBottomSheet(
        onCreateFolder: () => _showCreateFolderDialog(context),
        onImportFiles: () {
          // TODO: Implement file import
          Navigator.pop(context);
          context.showSnackBar('File import feature coming soon!');
        },
        onSettings: () {
          Navigator.pop(context);
          context.go('/profile');
        },
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateFolderDialog(
        onCreateFolder: (name) {
          ref.read(fileManagerNotifierProvider.notifier).createFolder(name);
        },
      ),
    );
  }

  void _showFileOptionsBottomSheet(BuildContext context, file) {
    if (file.isPdf) {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                file.name,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // PDF Tools
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  _buildToolOption(
                    context,
                    Icons.compress,
                    'Compress',
                    AppColors.compressColor,
                    () {
                      Navigator.pop(context);
                      context.go('/compress');
                    },
                  ),
                  _buildToolOption(
                    context,
                    Icons.call_split,
                    'Split',
                    AppColors.splitColor,
                    () {
                      Navigator.pop(context);
                      context.go('/split');
                    },
                  ),
                  _buildToolOption(
                    context,
                    Icons.transform,
                    'Convert',
                    AppColors.convertColor,
                    () {
                      Navigator.pop(context);
                      context.go('/convert');
                    },
                  ),
                  _buildToolOption(
                    context,
                    Icons.branding_watermark,
                    'Watermark',
                    AppColors.watermarkColor,
                    () {
                      Navigator.pop(context);
                      context.go('/watermark');
                    },
                  ),
                  _buildToolOption(
                    context,
                    Icons.lock,
                    'Protect',
                    AppColors.protectColor,
                    () {
                      Navigator.pop(context);
                      context.go('/protect');
                    },
                  ),
                  _buildToolOption(
                    context,
                    Icons.rotate_right,
                    'Rotate',
                    AppColors.rotateColor,
                    () {
                      Navigator.pop(context);
                      context.go('/rotate');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Delete option
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                title: Text(
                  'Delete',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, file);
                },
              ),

              // Bottom padding for safe area
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      );
    } else {
      // For non-PDF files, show basic options
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                file.name,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Rename'),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog(context, file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                textColor: AppColors.error,
                iconColor: AppColors.error,
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, file);
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildToolOption(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showFileContextMenu(BuildContext context, file) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, file);
              },
            ),
            if (file.isDirectory) ...[
              ListTile(
                leading: const Icon(Icons.create_new_folder),
                title: const Text('New Folder'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to this folder first, then create
                  if (file.folderId != null) {
                    ref
                        .read(fileManagerNotifierProvider.notifier)
                        .navigateToFolder(file.folderId!);
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _showCreateFolderDialog(context);
                    });
                  }
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete'),
              textColor: AppColors.error,
              iconColor: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, file);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, file) {
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

  void _confirmDelete(BuildContext context, file) {
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
              context.showSnackBar(
                '${file.isDirectory ? 'Folder' : 'File'} deleted successfully',
              );
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
