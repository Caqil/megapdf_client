// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../providers/file_manager_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'widgets/file_manager_view.dart';
import 'widgets/folder_actions_bottom_sheet.dart';

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
      ref.read(fileManagerNotifierProvider.notifier).loadFiles();
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
          if (fileManagerState.currentPath.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.surface,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => fileManagerNotifier.navigateUp(),
                    icon: const Icon(Icons.arrow_back),
                    iconSize: 20,
                  ),
                  Expanded(
                    child: Text(
                      _getDisplayPath(fileManagerState.currentPath),
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
                        'My Files',
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
                fileManagerNotifier.navigateToFolder(folder.path);
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

  String _getDisplayPath(String fullPath) {
    final pathParts = fullPath.split('/');
    if (pathParts.length <= 2) return 'My Files';
    return '.../${pathParts.skip(pathParts.length - 2).join('/')}';
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
            // Implement search functionality
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
          // Implement file import
          Navigator.pop(context);
        },
        onSettings: () {
          Navigator.pop(context);
          // Navigate to settings
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
                leading: const Icon(Icons.compress),
                title: const Text('Compress PDF'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/compress');
                },
              ),
              ListTile(
                leading: const Icon(Icons.call_split),
                title: const Text('Split PDF'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/split');
                },
              ),
              ListTile(
                leading: const Icon(Icons.transform),
                title: const Text('Convert PDF'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/convert');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
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
            ListTile(
              leading: const Icon(Icons.drive_file_move),
              title: const Text('Move'),
              onTap: () {
                Navigator.pop(context);
                // Implement move functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                // Implement copy functionality
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
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.name}"?'),
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
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
