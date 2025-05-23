// lib/data/repositories/folder_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database_helper.dart';
import '../models/folder_model.dart';

part 'folder_repository.g.dart';

@riverpod
FolderRepository folderRepository(Ref ref) {
  return FolderRepository();
}

class FolderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> createFolder({
    required String name,
    required String path,
    int? parentId,
  }) async {
    final now = DateTime.now();
    final folder = FolderModel(
      name: name,
      path: path,
      parentId: parentId,
      createdAt: now,
      updatedAt: now,
    );

    return await _dbHelper.insertFolder(folder);
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

    final updatedFolder = folder.copyWith(
      name: newName,
      path: newPath,
      updatedAt: DateTime.now(),
    );

    final result = await _dbHelper.updateFolder(updatedFolder);
    return result > 0;
  }

  Future<bool> deleteFolder(int id) async {
    final result = await _dbHelper.deleteFolder(id);
    return result > 0;
  }

  Future<bool> folderExists(String path) async {
    return await _dbHelper.folderExists(path);
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
    return folders.isNotEmpty ? folders.first : null;
  }
}
