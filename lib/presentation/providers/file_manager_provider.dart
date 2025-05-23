// lib/presentation/providers/file_manager_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/file_item.dart';
import '../../data/services/storage_service.dart';

part 'file_manager_provider.g.dart';

@riverpod
class FileManagerNotifier extends _$FileManagerNotifier {
  @override
  FileManagerState build() {
    // Load files when provider is first created
    loadFiles();
    return const FileManagerState();
  }

  Future<void> loadFiles() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get all files from the MegaPDF directory
      final fileList = await _getAllFiles();

      state = state.copyWith(
        isLoading: false,
        fileItems: fileList,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<List<FileItem>> _getAllFiles() async {
    try {
      // Get the MegaPDF directory
      final storageService = StorageService();
      final Directory? megaPdfDir =
          await storageService.createMegaPDFDirectory();

      if (megaPdfDir == null) {
        throw Exception('Could not access storage directory');
      }

      // Create if it doesn't exist
      if (!await megaPdfDir.exists()) {
        await megaPdfDir.create(recursive: true);
      }

      final List<FileItem> fileItems = [];

      // Scan for PDF files
      await for (final entity in megaPdfDir.list(recursive: false)) {
        if (entity is File) {
          final stat = entity.statSync();
          fileItems.add(FileItem(
            name: path.basename(entity.path),
            path: entity.path,
            isDirectory: false,
            size: stat.size,
            lastModified: stat.modified,
            extension: path.extension(entity.path).toLowerCase(),
          ));
        }
      }

      // Sort files by date (newest first)
      fileItems.sort((a, b) => b.lastModified.compareTo(a.lastModified));

      return fileItems;
    } catch (e) {
      print('Error getting files: $e');
      return [];
    }
  }

  // Refresh files
  Future<void> refreshFiles() async {
    await loadFiles();
  }

  // Delete file
  Future<void> deleteFile(FileItem file, {BuildContext? context}) async {
    if (context != null) {
      // Show confirmation dialog
      final shouldDelete =
          await _showDeleteConfirmationDialog(context, file.name);
      if (!shouldDelete) return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      // Delete physical file
      final fileToDelete = File(file.path);
      if (await fileToDelete.exists()) {
        await fileToDelete.delete();
      }

      // Reload files
      await loadFiles();

      state = state.copyWith(
        isLoading: false,
        successMessage: 'File "${file.name}" deleted successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete file: $e',
      );
    }
  }

  // Show delete confirmation dialog
  Future<bool> _showDeleteConfirmationDialog(
      BuildContext context, String fileName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete File'),
            content: Text('Are you sure you want to delete "$fileName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Rename file
  Future<void> renameFile(FileItem file, String newName,
      {BuildContext? context}) async {
    try {
      if (newName.trim().isEmpty) {
        state = state.copyWith(error: 'File name cannot be empty');
        return;
      }

      state = state.copyWith(isLoading: true, error: null);

      final directory = path.dirname(file.path);
      final extension = path.extension(file.path);
      final newPath = path.join(directory, '$newName$extension');

      // Check if a file with the new name already exists
      if (await File(newPath).exists()) {
        state = state.copyWith(
          isLoading: false,
          error: 'A file with this name already exists',
        );
        return;
      }

      // Rename the file
      final oldFile = File(file.path);
      await oldFile.rename(newPath);

      // Reload files
      await loadFiles();

      state = state.copyWith(
        isLoading: false,
        successMessage: 'File renamed successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to rename file: $e',
      );
    }
  }

  // Import a file to the app
  Future<bool> importFile(String sourcePath, {String? customName}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        state = state.copyWith(
          isLoading: false,
          error: 'Source file does not exist',
        );
        return false;
      }

      // Get the MegaPDF directory
      final storageService = StorageService();
      final Directory? megaPdfDir =
          await storageService.createMegaPDFDirectory();

      if (megaPdfDir == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Could not access storage directory',
        );
        return false;
      }

      // Generate file name
      final originalName = path.basename(sourcePath);
      final extension = path.extension(originalName);
      final baseName =
          customName ?? path.basenameWithoutExtension(originalName);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final destFileName = '${baseName}_$timestamp$extension';

      // Create destination path
      final destPath = path.join(megaPdfDir.path, destFileName);

      // Copy the file
      await sourceFile.copy(destPath);

      // Reload files
      await loadFiles();

      state = state.copyWith(
        isLoading: false,
        successMessage: 'File imported successfully',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to import file: $e',
      );
      return false;
    }
  }

  // Add a file directly to the app's storage
  Future<String?> addFile(File file, {String? customName}) async {
    try {
      // Get the MegaPDF directory
      final storageService = StorageService();
      final Directory? megaPdfDir =
          await storageService.createMegaPDFDirectory();

      if (megaPdfDir == null) {
        return null;
      }

      // Generate file name
      final originalName = path.basename(file.path);
      final extension = path.extension(originalName);
      final baseName =
          customName ?? path.basenameWithoutExtension(originalName);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final destFileName = '${baseName}_$timestamp$extension';

      // Create destination path
      final destPath = path.join(megaPdfDir.path, destFileName);

      // Copy the file
      final newFile = await file.copy(destPath);

      // Reload files (don't await to avoid blocking)
      loadFiles();

      return newFile.path;
    } catch (e) {
      print('Error adding file: $e');
      return null;
    }
  }

  // Selection methods
  void toggleFileSelection(FileItem file) {
    final currentSelection = [...state.selectedItems];

    if (currentSelection.contains(file)) {
      currentSelection.remove(file);
    } else {
      currentSelection.add(file);
    }

    state = state.copyWith(
      selectedItems: currentSelection,
      isSelectionMode: currentSelection.isNotEmpty,
    );
  }

  void clearSelection() {
    state = state.copyWith(
      selectedItems: [],
      isSelectionMode: false,
    );
  }

  void selectAll() {
    state = state.copyWith(
      selectedItems: [...state.fileItems],
      isSelectionMode: state.fileItems.isNotEmpty,
    );
  }

  // Delete multiple files
  Future<void> deleteSelectedFiles(BuildContext context) async {
    if (state.selectedItems.isEmpty) return;

    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Files'),
            content: Text(
              'Are you sure you want to delete ${state.selectedItems.length} selected files?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      int deletedCount = 0;

      // Delete each file
      for (final file in state.selectedItems) {
        final fileToDelete = File(file.path);
        if (await fileToDelete.exists()) {
          await fileToDelete.delete();
          deletedCount++;
        }
      }

      // Clear selection and reload files
      clearSelection();
      await loadFiles();

      state = state.copyWith(
        isLoading: false,
        successMessage: '$deletedCount files deleted successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete files: $e',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }

  // Check if a file with the given name exists
  Future<bool> fileExists(String fileName) async {
    try {
      final storageService = StorageService();
      final Directory? megaPdfDir =
          await storageService.createMegaPDFDirectory();

      if (megaPdfDir == null) {
        return false;
      }

      final filePath = path.join(megaPdfDir.path, fileName);
      return await File(filePath).exists();
    } catch (e) {
      print('Error checking if file exists: $e');
      return false;
    }
  }
}

class FileManagerState {
  final List<FileItem> fileItems;
  final List<FileItem> selectedItems;
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final bool isSelectionMode;

  const FileManagerState({
    this.fileItems = const [],
    this.selectedItems = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.isSelectionMode = false,
  });

  FileManagerState copyWith({
    List<FileItem>? fileItems,
    List<FileItem>? selectedItems,
    bool? isLoading,
    String? error,
    String? successMessage,
    bool? isSelectionMode,
  }) {
    return FileManagerState(
      fileItems: fileItems ?? this.fileItems,
      selectedItems: selectedItems ?? this.selectedItems,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  bool get hasFiles => fileItems.isNotEmpty;
  bool get hasSelection => selectedItems.isNotEmpty;
  int get fileCount => fileItems.length;
}
