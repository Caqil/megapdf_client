// lib/presentation/providers/file_manager_provider.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/file_item.dart';
import '../../core/errors/api_exception.dart';

part 'file_manager_provider.g.dart';

@riverpod
class FileManagerNotifier extends _$FileManagerNotifier {
  @override
  FileManagerState build() {
    return const FileManagerState();
  }

  Future<void> loadFiles({String? folderPath}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final Directory baseDir;
      if (folderPath != null) {
        baseDir = Directory(folderPath);
      } else {
        baseDir = await _getDefaultDirectory();
      }

      if (!await baseDir.exists()) {
        await baseDir.create(recursive: true);
      }

      final List<FileSystemEntity> entities = baseDir.listSync();
      final List<FileItem> fileItems = [];

      for (final entity in entities) {
        if (entity is Directory) {
          fileItems.add(FileItem.fromDirectory(entity));
        } else if (entity is File) {
          fileItems.add(FileItem.fromFile(entity));
        }
      }

      // Sort: folders first, then files, both alphabetically
      fileItems.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      state = state.copyWith(
        isLoading: false,
        fileItems: fileItems,
        currentPath: baseDir.path,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createFolder(String folderName) async {
    if (folderName.trim().isEmpty) {
      state = state.copyWith(error: 'Folder name cannot be empty');
      return;
    }

    try {
      final currentDir = Directory(state.currentPath);
      final newFolder =
          Directory(path.join(currentDir.path, folderName.trim()));

      if (await newFolder.exists()) {
        state = state.copyWith(error: 'Folder already exists');
        return;
      }

      await newFolder.create();
      await loadFiles(folderPath: state.currentPath);
    } catch (e) {
      state = state.copyWith(error: 'Failed to create folder: $e');
    }
  }

  Future<void> deleteItem(FileItem item) async {
    try {
      if (item.isDirectory) {
        final dir = Directory(item.path);
        await dir.delete(recursive: true);
      } else {
        final file = File(item.path);
        await file.delete();
      }

      await loadFiles(folderPath: state.currentPath);
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
      final oldPath = item.path;
      final parentDir = path.dirname(oldPath);
      final newPath = path.join(parentDir, newName.trim());

      if (item.isDirectory) {
        final dir = Directory(oldPath);
        await dir.rename(newPath);
      } else {
        final file = File(oldPath);
        await file.rename(newPath);
      }

      await loadFiles(folderPath: state.currentPath);
    } catch (e) {
      state = state.copyWith(error: 'Failed to rename item: $e');
    }
  }

  Future<void> moveItem(FileItem item, String destinationPath) async {
    try {
      final newPath = path.join(destinationPath, item.name);

      if (item.isDirectory) {
        final dir = Directory(item.path);
        await dir.rename(newPath);
      } else {
        final file = File(item.path);
        await file.copy(newPath);
        await file.delete();
      }

      await loadFiles(folderPath: state.currentPath);
    } catch (e) {
      state = state.copyWith(error: 'Failed to move item: $e');
    }
  }

  Future<void> navigateToFolder(String folderPath) async {
    await loadFiles(folderPath: folderPath);
  }

  Future<void> navigateUp() async {
    final currentDir = Directory(state.currentPath);
    final parentDir = currentDir.parent;

    // Don't go above the app's base directory
    final baseDir = await _getDefaultDirectory();
    if (parentDir.path.length >= baseDir.path.length) {
      await loadFiles(folderPath: parentDir.path);
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

  Future<Directory> _getDefaultDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return Directory(path.join(appDocDir.path, 'MegaPDF'));
  }
}

class FileManagerState {
  final List<FileItem> fileItems;
  final String currentPath;
  final List<FileItem> selectedItems;
  final bool isLoading;
  final String? error;
  final bool isSelectionMode;

  const FileManagerState({
    this.fileItems = const [],
    this.currentPath = '',
    this.selectedItems = const [],
    this.isLoading = false,
    this.error,
    this.isSelectionMode = false,
  });

  FileManagerState copyWith({
    List<FileItem>? fileItems,
    String? currentPath,
    List<FileItem>? selectedItems,
    bool? isLoading,
    String? error,
    bool? isSelectionMode,
  }) {
    return FileManagerState(
      fileItems: fileItems ?? this.fileItems,
      currentPath: currentPath ?? this.currentPath,
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
