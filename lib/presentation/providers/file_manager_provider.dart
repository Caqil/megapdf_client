// lib/presentation/providers/file_manager_provider.dart
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/file_item.dart';
import '../../data/models/folder_model.dart';
import '../../data/repositories/folder_repository.dart';
import '../../core/errors/api_exception.dart';

part 'file_manager_provider.g.dart';

@riverpod
class FileManagerNotifier extends _$FileManagerNotifier {
  @override
  FileManagerState build() {
    return const FileManagerState();
  }

  Future<void> loadRootFolder() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final folderRepo = ref.read(folderRepositoryProvider);
      final rootFolder = await folderRepo.getRootFolder();

      if (rootFolder != null) {
        await loadFolder(rootFolder.id!);
      } else {
        // Create root folder if it doesn't exist
        final rootId = await folderRepo.createFolder(
          name: 'MegaPDF',
          path: '/MegaPDF',
        );
        await loadFolder(rootId);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadFolder(int folderId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final folderRepo = ref.read(folderRepositoryProvider);
      final currentFolder = await folderRepo.getFolderById(folderId);

      if (currentFolder == null) {
        throw Exception('Folder not found');
      }

      // Get subfolders
      final subfolders = await folderRepo.getFolders(parentId: folderId);

      // Get physical files in this folder (if any)
      final physicalFiles = await _getPhysicalFiles(currentFolder.path);

      // Combine folders and files
      final List<FileItem> fileItems = [];

      // Add folders first
      for (final folder in subfolders) {
        fileItems.add(FileItem(
          name: folder.name,
          path: folder.path,
          isDirectory: true,
          size: 0,
          lastModified: folder.updatedAt,
          folderId: folder.id,
        ));
      }

      // Add physical files
      fileItems.addAll(physicalFiles);

      // Get folder path for breadcrumb
      final folderPath = await folderRepo.getFolderPath(folderId);

      state = state.copyWith(
        isLoading: false,
        fileItems: fileItems,
        currentFolder: currentFolder,
        folderPath: folderPath,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<List<FileItem>> _getPhysicalFiles(String folderPath) async {
    try {
      // This would be used if you want to also show actual files from device storage
      // For now, we'll just return empty list since we're managing virtual folders
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> createFolder(String folderName) async {
    if (folderName.trim().isEmpty) {
      state = state.copyWith(error: 'Folder name cannot be empty');
      return;
    }

    final currentFolder = state.currentFolder;
    if (currentFolder == null) {
      state = state.copyWith(error: 'No current folder selected');
      return;
    }

    try {
      final folderRepo = ref.read(folderRepositoryProvider);

      // Generate unique folder path
      final newPath = await folderRepo.generateUniqueFolderPath(
        currentFolder.path,
        folderName.trim(),
      );

      final pathParts = newPath.split('/');
      final uniqueName = pathParts.last;

      await folderRepo.createFolder(
        name: uniqueName,
        path: newPath,
        parentId: currentFolder.id,
      );

      // Reload current folder
      await loadFolder(currentFolder.id!);
    } catch (e) {
      state = state.copyWith(error: 'Failed to create folder: $e');
    }
  }

  Future<void> deleteItem(FileItem item) async {
    try {
      if (item.isDirectory && item.folderId != null) {
        final folderRepo = ref.read(folderRepositoryProvider);
        await folderRepo.deleteFolder(item.folderId!);
      } else {
        // Delete physical file if it exists
        final file = File(item.path);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Reload current folder
      if (state.currentFolder != null) {
        await loadFolder(state.currentFolder!.id!);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete item: $e');
    }
  }

  Future<void> renameItem(FileItem item, String newName) async {
    if (newName.trim().isEmpty) {
      state = state.copyWith(error: 'Name cannot be empty');
      return;
    }

    try {
      if (item.isDirectory && item.folderId != null) {
        final folderRepo = ref.read(folderRepositoryProvider);
        await folderRepo.renameFolder(item.folderId!, newName.trim());
      } else {
        // Rename physical file
        final oldFile = File(item.path);
        if (await oldFile.exists()) {
          final directory = path.dirname(item.path);
          final extension = path.extension(item.path);
          final newPath = path.join(directory, '$newName$extension');
          await oldFile.rename(newPath);
        }
      }

      // Reload current folder
      if (state.currentFolder != null) {
        await loadFolder(state.currentFolder!.id!);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to rename item: $e');
    }
  }

  Future<void> navigateToFolder(int folderId) async {
    await loadFolder(folderId);
  }

  Future<void> navigateUp() async {
    final currentFolder = state.currentFolder;
    if (currentFolder?.parentId != null) {
      await loadFolder(currentFolder!.parentId!);
    }
  }

  void setSelectedItems(List<FileItem> items) {
    state = state.copyWith(selectedItems: items);
  }

  void clearSelection() {
    state = state.copyWith(selectedItems: []);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  String getCurrentPath() {
    return state.folderPath.map((f) => f.name).join(' / ');
  }

  bool canGoUp() {
    return state.currentFolder?.parentId != null;
  }
}

class FileManagerState {
  final List<FileItem> fileItems;
  final FolderModel? currentFolder;
  final List<FolderModel> folderPath;
  final List<FileItem> selectedItems;
  final bool isLoading;
  final String? error;
  final bool isSelectionMode;

  const FileManagerState({
    this.fileItems = const [],
    this.currentFolder,
    this.folderPath = const [],
    this.selectedItems = const [],
    this.isLoading = false,
    this.error,
    this.isSelectionMode = false,
  });

  FileManagerState copyWith({
    List<FileItem>? fileItems,
    FolderModel? currentFolder,
    List<FolderModel>? folderPath,
    List<FileItem>? selectedItems,
    bool? isLoading,
    String? error,
    bool? isSelectionMode,
  }) {
    return FileManagerState(
      fileItems: fileItems ?? this.fileItems,
      currentFolder: currentFolder ?? this.currentFolder,
      folderPath: folderPath ?? this.folderPath,
      selectedItems: selectedItems ?? this.selectedItems,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  bool get hasFiles => fileItems.isNotEmpty;
  bool get hasSelection => selectedItems.isNotEmpty;
  int get fileCount => fileItems.where((item) => !item.isDirectory).length;
  int get folderCount => fileItems.where((item) => item.isDirectory).length;
}
