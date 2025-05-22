import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';

import '../../core/errors/api_exception.dart';
import '../../core/constants/api_constants.dart';
import '../../core/config/dio_config.dart';

part 'file_service.g.dart';

@riverpod
FileService fileService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return FileService(dio);
}

class FileService {
  final Dio _dio;

  FileService(this._dio);

  /// Save a processed file to local app storage
  Future<String> saveFileToLocal({
    required String fileUrl,
    required String filename,
    String? customFileName,
    String? subfolder,
  }) async {
    try {
      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();

      // Create MegaPDF directory if it doesn't exist
      final megaPdfDir = Directory(path.join(appDir.path, 'MegaPDF'));
      if (!await megaPdfDir.exists()) {
        await megaPdfDir.create(recursive: true);
      }

      // Create subfolder if specified
      Directory targetDir = megaPdfDir;
      if (subfolder != null) {
        targetDir = Directory(path.join(megaPdfDir.path, subfolder));
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
      }

      // Create unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(filename);
      final baseName =
          customFileName ?? path.basenameWithoutExtension(filename);
      final safeBaseName = _createSafeFileName(baseName);
      final localFileName = '${safeBaseName}_$timestamp$extension';

      final localFilePath = path.join(targetDir.path, localFileName);

      // Download file data
      final response = await _dio.download(
        fileUrl,
        localFilePath,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
        ),
      );

      if (response.statusCode == 200) {
        return localFilePath;
      } else {
        throw ApiException.server('Failed to download file');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException.network('Failed to save file: ${e.message}');
      }
      throw ApiException.unknown('Failed to save file: ${e.toString()}');
    }
  }

  /// Get file size in bytes
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      final stat = await file.stat();
      return stat.size;
    } catch (e) {
      return 0;
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Delete a file
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw ApiException.unknown('Failed to delete file: ${e.toString()}');
    }
  }

  /// Get all saved PDF files from app directory
  Future<List<File>> getSavedFiles({String? subfolder}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final megaPdfDir = Directory(path.join(appDir.path, 'MegaPDF'));

      Directory targetDir = megaPdfDir;
      if (subfolder != null) {
        targetDir = Directory(path.join(megaPdfDir.path, subfolder));
      }

      return await _scanDirectoryForPDFs(targetDir);
    } catch (e) {
      return [];
    }
  }

  Future<List<File>> _scanDirectoryForPDFs(Directory directory) async {
    if (!await directory.exists()) {
      return [];
    }

    final files = <File>[];
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
        files.add(entity);
      }
    }

    // Sort by modification date (newest first)
    files.sort((a, b) {
      final aStat = a.statSync();
      final bStat = b.statSync();
      return bStat.modified.compareTo(aStat.modified);
    });

    return files;
  }

  /// Clean up old saved files (older than specified days)
  Future<void> cleanupOldFiles({int olderThanDays = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));
      final savedFiles = await getSavedFiles();

      for (final file in savedFiles) {
        final stat = file.statSync();
        if (stat.modified.isBefore(cutoffDate)) {
          await file.delete();
        }
      }
    } catch (e) {
      // Silently fail cleanup
      print('Cleanup failed: $e');
    }
  }

  /// Get file metadata
  Future<Map<String, dynamic>> getFileMetadata(File file) async {
    try {
      final stat = await file.stat();
      return {
        'name': path.basename(file.path),
        'size': stat.size,
        'modified': stat.modified.toIso8601String(),
        'extension': path.extension(file.path),
        'path': file.path,
      };
    } catch (e) {
      return {};
    }
  }

  String _createSafeFileName(String fileName) {
    // Remove or replace invalid characters
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_{2,}'), '_')
        .trim();
  }
}
