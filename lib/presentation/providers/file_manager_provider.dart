// lib/presentation/providers/file_manager_provider.dart
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/file_item.dart';
import '../../data/models/folder_model.dart';
import '../../data/repositories/folder_repository.dart';
import '../../data/database/database_helper.dart';
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
      final dbHelper = DatabaseHelper();

      final currentFolder = await folderRepo.getFolderById(folderId);

      if (currentFolder == null) {
        throw Exception('Folder not found');
      }

      // Get subfolders
      final subfolders = await folderRepo.getFolders(parentId: folderId);

      // Get files linked to this folder
      final linkedFiles = await dbHelper.getFilesInFolder(folderId);

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

      // Add linked files
      for (final fileLink in linkedFiles) {
        final file = File(fileLink.filePath);
        if (await file.exists()) {
          final stat = file.statSync();
          fileItems.add(FileItem(
            name: fileLink.fileName,
            path: fileLink.filePath,
            isDirectory: false,
            size: stat.size,
            lastModified: stat.modified,
            extension: path.extension(fileLink.filePath).toLowerCase(),
          ));
        }
      }

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

  Future<void> moveFileToFolder(FileItem file, FolderModel targetFolder) async {
    try {
      final dbHelper = DatabaseHelper();

      if (file.isDirectory) {
        // Moving folder - update parent_id
        final folderRepo = ref.read(folderRepositoryProvider);
        final folderToMove = await folderRepo.getFolderById(file.folderId!);

        if (folderToMove != null) {
          final updatedFolder = folderToMove.copyWith(
            parentId: targetFolder.id,
            updatedAt: DateTime.now(),
          );

          // Actually update the folder in database
          final updateResult = await folderRepo.updateFolder(updatedFolder);
          if (!updateResult) {
            throw Exception('Failed to update folder in database');
          }
        }
      } else {
        // Moving file - update the file-folder link
        final existingLink = await dbHelper.getFileLocation(file.path);

        if (existingLink != null) {
          // Update existing link to new folder
          final updateResult = await dbHelper.moveFileToFolder(
            filePath: file.path,
            newFolderId: targetFolder.id!,
          );

          if (updateResult == 0) {
            throw Exception('Failed to update file location in database');
          }
        } else {
          // Create new link
          await dbHelper.addFileToFolder(
            filePath: file.path,
            fileName: file.name,
            folderId: targetFolder.id!,
          );
        }
      }

      // Reload current folder to reflect changes
      if (state.currentFolder != null) {
        await loadFolder(state.currentFolder!.id!);
      }

      state = state.copyWith(
        successMessage:
            '${file.isDirectory ? 'Folder' : 'File'} moved to "${targetFolder.name}" successfully',
      );
    } catch (e) {
      state = state.copyWith(
          error: 'Failed to move ${file.isDirectory ? 'folder' : 'file'}: $e');
    }
  }

  Future<void> deleteItem(FileItem item) async {
    try {
      final dbHelper = DatabaseHelper();

      if (item.isDirectory && item.folderId != null) {
        final folderRepo = ref.read(folderRepositoryProvider);

        // Remove all files from folder first
        await dbHelper.removeFilesFromFolder(item.folderId!);

        // Delete the folder
        final deleteResult = await folderRepo.deleteFolder(item.folderId!);
        if (!deleteResult) {
          throw Exception('Failed to delete folder from database');
        }
      } else {
        // Remove file link from folder
        await dbHelper.removeFileFromFolder(item.path);

        // Delete physical file if it exists
        try {
          final file = File(item.path);
          if (await file.exists()) {
            await file.delete();
            print('Physical file deleted: ${item.path}');
          }
        } catch (e) {
          print('Warning: Could not delete physical file: $e');
          // Continue even if physical file deletion fails
        }
      }

      // Reload current folder
      if (state.currentFolder != null) {
        await loadFolder(state.currentFolder!.id!);
      }

      state = state.copyWith(
        successMessage:
            '${item.isDirectory ? 'Folder' : 'File'} "${item.name}" deleted successfully',
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete item: $e');
    }
  }

  Future<void> addFileToCurrentFolder(String filePath) async {
    final currentFolder = state.currentFolder;
    if (currentFolder == null) {
      state = state.copyWith(error: 'No current folder selected');
      return;
    }

    try {
      final dbHelper = DatabaseHelper();
      final file = File(filePath);

      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      await dbHelper.addFileToFolder(
        filePath: filePath,
        fileName: path.basename(filePath),
        folderId: currentFolder.id!,
      );

      // Reload current folder
      await loadFolder(currentFolder.id!);

      state = state.copyWith(
        successMessage: 'File added to folder successfully',
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to add file to folder: $e');
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
        // For files, we need to update the file link
        final dbHelper = DatabaseHelper();
        final fileLink = await dbHelper.getFileLocation(item.path);

        if (fileLink != null) {
          // Remove old link and add new one with updated name
          await dbHelper.removeFileFromFolder(item.path);

          // If renaming involves changing the actual file, handle that here
          final oldFile = File(item.path);
          if (await oldFile.exists()) {
            final directory = path.dirname(item.path);
            final extension = path.extension(item.path);
            final newPath = path.join(directory, '$newName$extension');
            final newFile = await oldFile.rename(newPath);

            // Add new link with new path and name
            await dbHelper.addFileToFolder(
              filePath: newFile.path,
              fileName: path.basename(newFile.path),
              folderId: fileLink.folderId,
            );
          }
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

  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
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
  final String? successMessage;
  final bool isSelectionMode;

  const FileManagerState({
    this.fileItems = const [],
    this.currentFolder,
    this.folderPath = const [],
    this.selectedItems = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.isSelectionMode = false,
  });

  FileManagerState copyWith({
    List<FileItem>? fileItems,
    FolderModel? currentFolder,
    List<FolderModel>? folderPath,
    List<FileItem>? selectedItems,
    bool? isLoading,
    String? error,
    String? successMessage,
    bool? isSelectionMode,
  }) {
    return FileManagerState(
      fileItems: fileItems ?? this.fileItems,
      currentFolder: currentFolder ?? this.currentFolder,
      folderPath: folderPath ?? this.folderPath,
      selectedItems: selectedItems ?? this.selectedItems,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  bool get hasFiles => fileItems.isNotEmpty;
  bool get hasSelection => selectedItems.isNotEmpty;
  int get fileCount => fileItems.where((item) => !item.isDirectory).length;
  int get folderCount => fileItems.where((item) => item.isDirectory).length;
}
