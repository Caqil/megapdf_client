// lib/core/services/simple_storage_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'storage_service.g.dart';

@riverpod
StorageService storageService(Ref ref) {
  return StorageService();
}

class StorageService {
  /// Creates a MegaPDF folder in the appropriate location based on platform
  Future<Directory?> createMegaPDFDirectory() async {
    try {
      final baseDir = await _getBaseStorageDirectory();
      if (baseDir == null) return null;

      final megaPdfDir = Directory(path.join(baseDir.path, 'MegaPDF'));
      if (!await megaPdfDir.exists()) {
        await megaPdfDir.create(recursive: true);
      }
      return megaPdfDir;
    } catch (e) {
      debugPrint('Error creating MegaPDF directory: $e');
      return null;
    }
  }

  /// Gets the base directory where MegaPDF folder will be created
  Future<Directory?> _getBaseStorageDirectory() async {
    try {
      debugPrint('🔍 Getting base storage directory');

      if (Platform.isAndroid) {
        debugPrint('🔍 Platform is Android');

        // First try using getExternalStorageDirectory()
        try {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            debugPrint('🔍 External storage directory: ${externalDir.path}');

            // This will be something like: /storage/emulated/0/Android/data/your.package.name/files
            // We want to strip the Android/data/package part to make it more accessible
            final String rootPath = externalDir.path.split('/Android/')[0];
            debugPrint('🔍 Root path: $rootPath');

            // Create a Documents folder in the root directory
            final docsDir = Directory('$rootPath/Documents');
            if (!await docsDir.exists()) {
              await docsDir.create(recursive: true);
              debugPrint('🔍 Created Documents directory: ${docsDir.path}');
            } else {
              debugPrint(
                  '🔍 Documents directory already exists: ${docsDir.path}');
            }

            return docsDir;
          } else {
            debugPrint('🔍 getExternalStorageDirectory() returned null');
          }
        } catch (e) {
          debugPrint('🔍 Error getting external storage directory: $e');
        }

        // If that fails, try to use getApplicationDocumentsDirectory()
        try {
          final appDocDir = await getApplicationDocumentsDirectory();
          debugPrint(
              '🔍 Using application documents directory: ${appDocDir.path}');
          return appDocDir;
        } catch (e) {
          debugPrint('🔍 Error getting application documents directory: $e');
        }

        // If that also fails, try to use getDownloadsDirectory()
        try {
          final downloadsDir = await getDownloadsDirectory();
          if (downloadsDir != null) {
            debugPrint('🔍 Using downloads directory: ${downloadsDir.path}');
            return downloadsDir;
          } else {
            debugPrint('🔍 getDownloadsDirectory() returned null');
          }
        } catch (e) {
          debugPrint('🔍 Error getting downloads directory: $e');
        }
      } else if (Platform.isIOS) {
        debugPrint('🔍 Platform is iOS');

        // On iOS, use the documents directory which can be exposed to Files app
        try {
          final docsDir = await getApplicationDocumentsDirectory();
          debugPrint('🔍 Using iOS documents directory: ${docsDir.path}');
          return docsDir;
        } catch (e) {
          debugPrint('🔍 Error getting iOS documents directory: $e');
        }
      } else {
        debugPrint('🔍 Platform is not Android or iOS');
      }

      // Last resort - try to use temp directory
      try {
        debugPrint('🔍 Attempting to use temporary directory as fallback');
        final tempDir = await getTemporaryDirectory();
        return tempDir;
      } catch (e) {
        debugPrint('🔍 Error getting temporary directory: $e');
      }

      debugPrint('🔍 ERROR: Could not determine a suitable storage directory');
      return null;
    } catch (e) {
      debugPrint('🔍 Error in _getBaseStorageDirectory: $e');
      return null;
    }
  }

  /// Gets the path to the MegaPDF directory
  Future<String?> getMegaPDFPath() async {
    final dir = await createMegaPDFDirectory();
    return dir?.path;
  }

  /// Check if storage permissions are granted
  Future<bool> checkPermissions() async {
    if (Platform.isAndroid) {
      return await Permission.storage.isGranted;
    }
    return true; // iOS doesn't need runtime permission for app documents
  }

  /// Request storage permissions
  Future<bool> requestPermissions(BuildContext context) async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS doesn't need runtime permission for app documents
  }

  /// Save a file to the MegaPDF directory
  Future<String?> saveFile({
    required String sourceFilePath,
    required String fileName,
    String? subfolder,
    bool addTimestamp = false,
  }) async {
    try {
      debugPrint('🔍 Starting saveFile operation');
      debugPrint('🔍 sourceFilePath: $sourceFilePath');
      debugPrint('🔍 fileName: $fileName');
      debugPrint('🔍 subfolder: $subfolder');

      // Verify source file exists
      final sourceFile = File(sourceFilePath);
      if (!await sourceFile.exists()) {
        debugPrint('🔍 ERROR: Source file does not exist: $sourceFilePath');
        return null;
      }

      // Get source file size for verification
      final sourceSize = await sourceFile.length();
      debugPrint('🔍 Source file size: $sourceSize bytes');

      // Create MegaPDF directory
      final megaPdfDir = await createMegaPDFDirectory();
      if (megaPdfDir == null) {
        debugPrint('🔍 ERROR: Failed to create MegaPDF directory');
        return null;
      }

      debugPrint('🔍 MegaPDF directory: ${megaPdfDir.path}');

      // Create subfolder if specified
      Directory targetDir = megaPdfDir;
      if (subfolder != null && subfolder.isNotEmpty) {
        targetDir = Directory(path.join(megaPdfDir.path, subfolder));
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
          debugPrint('🔍 Created subfolder: ${targetDir.path}');
        }
      }

      // Generate a unique filename with timestamp if needed
      final extension = path.extension(fileName);
      final baseName = path.basenameWithoutExtension(fileName);
      final safeBaseName = _createSafeFileName(baseName);
      final timestamp =
          addTimestamp ? '_${DateTime.now().millisecondsSinceEpoch}' : '';
      final targetFileName = '$safeBaseName$timestamp$extension';
      final targetFilePath = path.join(targetDir.path, targetFileName);

      debugPrint('🔍 Target file path: $targetFilePath');

      // Copy the source file to the target path
      final targetFile = await sourceFile.copy(targetFilePath);

      // Verify the file was copied correctly
      if (await targetFile.exists()) {
        final targetSize = await targetFile.length();
        debugPrint(
            '🔍 Target file created successfully. Size: $targetSize bytes');

        if (targetSize != sourceSize) {
          debugPrint(
              '🔍 WARNING: Target file size ($targetSize) does not match source file size ($sourceSize)');
        }
      } else {
        debugPrint('🔍 ERROR: Target file was not created');
        return null;
      }

      return targetFile.path;
    } catch (e) {
      debugPrint('🔍 ERROR saving file: $e');
      return null;
    }
  }

  /// Creates a safe filename by removing/replacing invalid characters
  String _createSafeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_{2,}'), '_')
        .trim();
  }

  /// Get all PDF files from the MegaPDF directory
  Future<List<File>> getPdfFiles({String? subfolder}) async {
    try {
      final megaPdfDir = await createMegaPDFDirectory();
      if (megaPdfDir == null) return [];

      Directory targetDir = megaPdfDir;
      if (subfolder != null && subfolder.isNotEmpty) {
        targetDir = Directory(path.join(megaPdfDir.path, subfolder));
        if (!await targetDir.exists()) return [];
      }

      final List<File> pdfFiles = [];
      await for (final entity in targetDir.list(recursive: false)) {
        if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
          pdfFiles.add(entity);
        }
      }

      // Sort by modification date (newest first)
      pdfFiles.sort((a, b) {
        return b.lastModifiedSync().compareTo(a.lastModifiedSync());
      });

      return pdfFiles;
    } catch (e) {
      debugPrint('Error getting PDF files: $e');
      return [];
    }
  }

  /// Delete a file
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  /// Share a file
  Future<void> shareFile(String filePath,
      {String? subject, String? text}) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: subject,
        text: text,
      );
    } catch (e) {
      debugPrint('Error sharing file: $e');
    }
  }

  /// Open a file for viewing
  Future<bool> openFile(String filePath) async {
    try {
      // This would typically use a plugin like open_file or url_launcher
      // For this example, just return true
      return true;
    } catch (e) {
      debugPrint('Error opening file: $e');
      return false;
    }
  }
}
