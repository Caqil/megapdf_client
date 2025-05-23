// lib/data/repositories/folder_repository.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart' as path;
import '../database/database_helper.dart';
import '../models/folder_model.dart';
import '../services/storage_service.dart';

part 'folder_repository.g.dart';

@riverpod
FolderRepository folderRepository(Ref ref) {
  final storageService = ref.watch(storageServiceProvider);
  return FolderRepository(storageService);
}

class FolderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final StorageService _storageService;

  FolderRepository(this._storageService);

  /// Create a new folder (both in database and filesystem)
  Future<int> createFolder({
    required String name,
    required String path,
    int? parentId,
  }) async {
    try {
      // 1. First, check if the folder exists in the database
      final existingFolder = await _dbHelper.getFolderByPath(path);
      if (existingFolder != null) {
        print('Folder already exists in database: $path');
        return existingFolder.id!;
      }

      // 2. Create the physical folder in the filesystem
      final Directory? directory = await _createPhysicalFolder(path);
      if (directory == null) {
        throw Exception('Failed to create physical folder at: $path');
      }

      // 3. Insert folder record in the database
      final now = DateTime.now();
      final folder = FolderModel(
        name: name,
        path: path,
        parentId: parentId,
        createdAt: now,
        updatedAt: now,
      );

      final folderId = await _dbHelper.insertFolder(folder);
      print('Created new folder in database with ID: $folderId');
      return folderId;
    } catch (e) {
      print('Error creating folder: $e');
      rethrow;
    }
  }

  /// Create the physical directory in the filesystem
  Future<Directory?> _createPhysicalFolder(String folderPath) async {
    try {
      // For internal app paths, create the directory directly
      if (folderPath.startsWith('/MegaPDF')) {
        // Get the root directory for MegaPDF
        final rootDir = await _storageService.createMegaPDFDirectory();
        if (rootDir == null) {
          throw Exception('Failed to create or access MegaPDF root directory');
        }

        // Extract the subfolder path (everything after /MegaPDF/)
        // Fix: Remove the leading slash to prevent absolute path issues
        String subfolderPath = folderPath.replaceFirst('/MegaPDF/', '');

        // Handle case where folderPath is exactly "/MegaPDF"
        if (folderPath == '/MegaPDF') {
          subfolderPath = '';
        }

        if (subfolderPath.isEmpty) {
          // This is the root MegaPDF folder itself
          return rootDir;
        }

        // Remove any remaining leading slashes
        subfolderPath = subfolderPath.replaceFirst(RegExp(r'^/+'), '');

        // Create the subfolder within MegaPDF
        final fullPath = path.join(rootDir.path, subfolderPath);
        final directory = Directory(fullPath);

        if (!await directory.exists()) {
          await directory.create(recursive: true);
          print('Created physical folder at: $fullPath');
        } else {
          print('Physical folder already exists at: $fullPath');
        }

        return directory;
      } else {
        // For external paths, we need to use the storage service
        // This handles storage permissions appropriately
        final segments =
            folderPath.split('/').where((s) => s.isNotEmpty).toList();
        if (segments.isEmpty) {
          throw Exception('Invalid folder path: $folderPath');
        }

        // Build up the path and create each segment as needed
        String currentPath = '';
        Directory? currentDir;

        for (int i = 0; i < segments.length; i++) {
          final segment = segments[i];
          currentPath =
              currentPath.isEmpty ? '/$segment' : '$currentPath/$segment';

          // Use storage service to create the directory
          if (i == 0) {
            // This is likely the root directory (e.g., /MegaPDF)
            currentDir = await _storageService.createMegaPDFDirectory();
          } else {
            // This is a subdirectory
            // Remove leading slash and join segments for subfolder creation
            final relativePath = segments.sublist(1, i + 1).join('/');
            currentDir = await _storageService.createSubfolder(relativePath);
          }

          if (currentDir == null) {
            throw Exception('Failed to create directory at: $currentPath');
          }
        }

        return currentDir;
      }
    } catch (e) {
      print('Error creating physical folder: $e');
      return null;
    }
  }

  Future<List<FolderModel>> getFolders({int? parentId}) async {
    return await _dbHelper.getFolders(parentId: parentId);
  }

  Future<FolderModel?> getFolderByPath(String path) async {
    return await _dbHelper.getFolderByPath(path);
  }

  Future<FolderModel?> getFolderById(int id) async {
    return await _dbHelper.getFolderById(id);
  }

  Future<List<FolderModel>> getFolderPath(int folderId) async {
    return await _dbHelper.getFolderPath(folderId);
  }

  Future<bool> updateFolder(FolderModel folder) async {
    final result = await _dbHelper.updateFolder(folder);
    return result > 0;
  }

  Future<bool> renameFolder(int id, String newName) async {
    final folder = await _dbHelper.getFolderById(id);
    if (folder == null) return false;

    // Update path for this folder
    final oldPath = folder.path;
    final pathParts = oldPath.split('/');
    pathParts[pathParts.length - 1] = newName;
    final newPath = pathParts.join('/');

    // Rename the physical folder
    final oldDir = Directory(oldPath);
    final newDir = Directory(newPath);

    if (await oldDir.exists()) {
      try {
        // Rename the physical folder
        await oldDir.rename(newPath);
      } catch (e) {
        print('Error renaming physical folder: $e');
        // Try an alternative approach - copy and delete
        await _copyFolderContents(oldDir, newDir);
        await oldDir.delete(recursive: true);
      }
    }

    final updatedFolder = folder.copyWith(
      name: newName,
      path: newPath,
      updatedAt: DateTime.now(),
    );

    final result = await _dbHelper.updateFolder(updatedFolder);
    return result > 0;
  }

  // Helper to copy folder contents when rename fails
  Future<void> _copyFolderContents(Directory source, Directory dest) async {
    await dest.create(recursive: true);

    await for (final entity in source.list(recursive: false)) {
      final newPath = path.join(dest.path, path.basename(entity.path));

      if (entity is File) {
        await entity.copy(newPath);
      } else if (entity is Directory) {
        final newDir = Directory(newPath);
        await _copyFolderContents(entity, newDir);
      }
    }
  }

  Future<bool> deleteFolder(int id) async {
    // First get the folder details
    final folder = await _dbHelper.getFolderById(id);
    if (folder == null) return false;

    // Delete the physical folder
    try {
      final directory = Directory(folder.path);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        print('Deleted physical folder: ${folder.path}');
      }
    } catch (e) {
      print('Error deleting physical folder: $e');
      // Continue with database deletion even if physical deletion fails
    }

    // Delete folder from database
    final result = await _dbHelper.deleteFolder(id);
    return result > 0;
  }

  Future<bool> folderExists(String path) async {
    // Check if folder exists in database
    final dbExists = await _dbHelper.folderExists(path);

    // Also check if physical folder exists
    bool physicalExists = false;
    try {
      final directory = Directory(path);
      physicalExists = await directory.exists();
    } catch (e) {
      print('Error checking if physical folder exists: $e');
    }

    // Return true if folder exists in both database and filesystem
    return dbExists && physicalExists;
  }

  Future<String> generateUniqueFolderPath(String basePath, String name) async {
    String newPath = '$basePath/$name';
    int counter = 1;

    while (await folderExists(newPath)) {
      newPath = '$basePath/$name ($counter)';
      counter++;
    }

    return newPath;
  }

  Future<FolderModel?> getRootFolder() async {
    final folders = await getFolders(parentId: null);
    if (folders.isNotEmpty) {
      return folders.first;
    }

    // If root folder doesn't exist, create it
    final rootId = await createFolder(
      name: 'MegaPDF',
      path: '/MegaPDF',
    );

    return await getFolderById(rootId);
  }
}
