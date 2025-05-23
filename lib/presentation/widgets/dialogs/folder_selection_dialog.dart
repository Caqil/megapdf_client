// lib/presentation/widgets/dialogs/folder_selection_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/folder_model.dart';
import '../../../data/repositories/folder_repository.dart';
import '../../providers/file_manager_provider.dart';

class FolderSelectionDialog extends ConsumerStatefulWidget {
  final String title;
  final String subtitle;
  final int? excludeFolderId;
  final Function(FolderModel) onFolderSelected;

  const FolderSelectionDialog({
    super.key,
    required this.title,
    required this.subtitle,
    this.excludeFolderId,
    required this.onFolderSelected,
  });

  @override
  ConsumerState<FolderSelectionDialog> createState() =>
      _FolderSelectionDialogState();
}

class _FolderSelectionDialogState extends ConsumerState<FolderSelectionDialog> {
  FolderModel? _currentFolder;
  List<FolderModel> _subfolders = [];
  List<FolderModel> _folderPath = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRootFolder();
  }

  Future<void> _loadRootFolder() async {
    try {
      final folderRepo = ref.read(folderRepositoryProvider);
      final rootFolder = await folderRepo.getRootFolder();

      if (rootFolder != null) {
        await _loadFolder(rootFolder);
      } else {
        setState(() {
          _error = 'Root folder not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load folders: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFolder(FolderModel folder) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final folderRepo = ref.read(folderRepositoryProvider);

      // Get subfolders, excluding the folder being moved (if any)
      final allSubfolders = await folderRepo.getFolders(parentId: folder.id);
      final filteredSubfolders = allSubfolders
          .where((subfolder) => subfolder.id != widget.excludeFolderId)
          .toList();

      // Get folder path for breadcrumb
      final folderPath = await folderRepo.getFolderPath(folder.id!);

      setState(() {
        _currentFolder = folder;
        _subfolders = filteredSubfolders;
        _folderPath = folderPath;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load folder: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToFolder(FolderModel folder) async {
    await _loadFolder(folder);
  }

  Future<void> _navigateUp() async {
    if (_currentFolder?.parentId != null) {
      final folderRepo = ref.read(folderRepositoryProvider);
      final parentFolder =
          await folderRepo.getFolderById(_currentFolder!.parentId!);
      if (parentFolder != null) {
        await _loadFolder(parentFolder);
      }
    }
  }

  void _selectCurrentFolder() {
    if (_currentFolder != null) {
      widget.onFolderSelected(_currentFolder!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            // Breadcrumb navigation
            if (_folderPath.isNotEmpty) _buildBreadcrumb(),

            const SizedBox(height: 8),

            // Current folder selection button
            if (_currentFolder != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                child: ElevatedButton.icon(
                  onPressed: _selectCurrentFolder,
                  icon: const Icon(Icons.check),
                  label: Text('Select "${_currentFolder!.name}"'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

            const Divider(),

            // Folder list
            Expanded(
              child: _buildFolderList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildBreadcrumb() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          if (_currentFolder?.parentId != null)
            IconButton(
              onPressed: _navigateUp,
              icon: const Icon(Icons.arrow_back),
              iconSize: 20,
              color: AppColors.primary(context),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _folderPath.asMap().entries.map((entry) {
                  final index = entry.key;
                  final folder = entry.value;
                  final isLast = index == _folderPath.length - 1;

                  return Row(
                    children: [
                      GestureDetector(
                        onTap: isLast ? null : () => _navigateToFolder(folder),
                        child: Text(
                          folder.name,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isLast
                                        ? AppColors.textPrimary(context)
                                        : AppColors.primary(context),
                                    fontWeight: isLast
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                        ),
                      ),
                      if (!isLast) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppColors.textSecondary(context),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error(context),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error(context),
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRootFolder,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_subfolders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 48,
              color: AppColors.textSecondary(context).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No subfolders',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _subfolders.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final folder = _subfolders[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.folder,
              color: Colors.blue,
              size: 20,
            ),
          ),
          title: Text(
            folder.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          subtitle: Text(
            '${folder.createdAt.day}/${folder.createdAt.month}/${folder.createdAt.year}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
          ),
          trailing: const Icon(Icons.chevron_right, size: 20),
          onTap: () => _navigateToFolder(folder),
        );
      },
    );
  }
}
