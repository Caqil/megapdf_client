// lib/presentation/widgets/dialogs/folder_selection_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/folder_model.dart';
import '../../../data/repositories/folder_repository.dart';

class FolderSelectionDialog extends ConsumerStatefulWidget {
  final String title;
  final String? subtitle;
  final int? excludeFolderId; // Exclude current folder from selection
  final Function(FolderModel) onFolderSelected;

  const FolderSelectionDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.excludeFolderId,
    required this.onFolderSelected,
  });

  @override
  ConsumerState<FolderSelectionDialog> createState() =>
      _FolderSelectionDialogState();
}

class _FolderSelectionDialogState extends ConsumerState<FolderSelectionDialog> {
  List<FolderModel> _folders = [];
  List<FolderModel> _folderPath = [];
  FolderModel? _currentFolder;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRootFolders();
  }

  Future<void> _loadRootFolders() async {
    setState(() => _isLoading = true);

    try {
      final folderRepo = ref.read(folderRepositoryProvider);
      final rootFolder = await folderRepo.getRootFolder();

      if (rootFolder != null) {
        await _loadFolder(rootFolder.id!);
      }
    } catch (e) {
      print('Error loading folders: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFolder(int folderId) async {
    setState(() => _isLoading = true);

    try {
      final folderRepo = ref.read(folderRepositoryProvider);
      final currentFolder = await folderRepo.getFolderById(folderId);
      final subfolders = await folderRepo.getFolders(parentId: folderId);
      final folderPath = await folderRepo.getFolderPath(folderId);

      setState(() {
        _currentFolder = currentFolder;
        _folders = subfolders
            .where((folder) => folder.id != widget.excludeFolderId)
            .toList();
        _folderPath = folderPath;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading folder: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.folder_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            // Breadcrumb
            if (_folderPath.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    if (_currentFolder?.parentId != null)
                      IconButton(
                        onPressed: () => _loadFolder(_currentFolder!.parentId!),
                        icon: const Icon(Icons.arrow_back, size: 20),
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        _folderPath.map((f) => f.name).join(' / '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Folder List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildFolderList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (_currentFolder != null)
          ElevatedButton.icon(
            onPressed: () {
              widget.onFolderSelected(_currentFolder!);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
            label: const Text('Select This Folder'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildFolderList() {
    if (_folders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No subfolders',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'You can select the current folder or go back',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _folders.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final folder = _folders[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.folder,
              color: AppColors.primary,
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
            'Created ${_formatDate(folder.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Select folder button
              IconButton(
                onPressed: () {
                  widget.onFolderSelected(folder);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle_outline),
                color: AppColors.success,
                tooltip: 'Select this folder',
              ),
              // Navigate into folder button
              IconButton(
                onPressed: () => _loadFolder(folder.id!),
                icon: const Icon(Icons.chevron_right),
                color: AppColors.textSecondary,
                tooltip: 'Open folder',
              ),
            ],
          ),
          onTap: () => _loadFolder(folder.id!),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
