// lib/core/utils/storage_manager.dart - Updated with robust error handling

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'permission_manager.dart';

part 'storage_manager.g.dart';

@riverpod
StorageManager storageManager(Ref ref) {
  return StorageManager();
}

class StorageManager {
  final PermissionManager _permissionManager = PermissionManager();

  /// Save a processed file to app-specific storage with comprehensive error handling
  Future<String?> saveProcessedFile({
    required String sourceFilePath,
    required String fileName,
    String? customFileName,
    String? subfolder,
  }) async {
    try {
      debugPrint('🔍 STORAGE: =========================');
      debugPrint('🔍 STORAGE: Starting saveProcessedFile');
      debugPrint('🔍 STORAGE: Source path: $sourceFilePath');
      debugPrint('🔍 STORAGE: Target filename: $fileName');
      debugPrint('🔍 STORAGE: Custom filename: $customFileName');
      debugPrint('🔍 STORAGE: Subfolder: $subfolder');

      // Step 1: Validate source file
      final sourceFile = File(sourceFilePath);
      debugPrint('🔍 STORAGE: Checking if source file exists...');

      if (!await sourceFile.exists()) {
        debugPrint(
            '🔍 STORAGE: ERROR - Source file does not exist: $sourceFilePath');

        // List directory contents for debugging
        try {
          final sourceDir = Directory(path.dirname(sourceFilePath));
          if (await sourceDir.exists()) {
            debugPrint('🔍 STORAGE: Source directory exists, contents:');
            await for (final entity in sourceDir.list()) {
              debugPrint('🔍 STORAGE: - ${entity.path}');
            }
          } else {
            debugPrint(
                '🔍 STORAGE: Source directory does not exist: ${sourceDir.path}');
          }
        } catch (e) {
          debugPrint('🔍 STORAGE: Error listing source directory: $e');
        }

        throw Exception('Source file does not exist: $sourceFilePath');
      }

      final sourceFileSize = await sourceFile.length();
      debugPrint('🔍 STORAGE: Source file exists, size: $sourceFileSize bytes');

      // Step 2: Check permissions
      debugPrint('🔍 STORAGE: Checking storage permissions...');
      final hasPermission = await _permissionManager.hasStoragePermission();
      if (!hasPermission) {
        debugPrint('🔍 STORAGE: ERROR - Storage permissions not granted');
        throw Exception('Storage permissions not granted');
      }
      debugPrint('🔍 STORAGE: Storage permissions OK');

      // Step 3: Determine target directory with multiple fallbacks
      Directory? targetDir;
      List<String> attemptedPaths = [];

      // Try multiple storage locations in order of preference
      final storageTries = [
        () async {
          final externalDir = await getExternalStorageDirectory();
          return externalDir != null
              ? Directory(path.join(externalDir.path, 'MegaPDF'))
              : null;
        },
        () async {
          final appDir = await getApplicationDocumentsDirectory();
          return Directory(path.join(appDir.path, 'MegaPDF'));
        },
        () async {
          final tempDir = await getTemporaryDirectory();
          return Directory(path.join(tempDir.path, 'MegaPDF'));
        },
      ];

      for (int i = 0; i < storageTries.length; i++) {
        try {
          debugPrint('🔍 STORAGE: Trying storage location ${i + 1}...');
          final dir = await storageTries[i]();
          if (dir != null) {
            attemptedPaths.add(dir.path);

            // Test if we can create/write to this directory
            if (await _testDirectoryAccess(dir)) {
              targetDir = dir;
              debugPrint('🔍 STORAGE: Using storage location: ${dir.path}');
              break;
            } else {
              debugPrint('🔍 STORAGE: Cannot write to directory: ${dir.path}');
            }
          }
        } catch (e) {
          debugPrint('🔍 STORAGE: Storage location ${i + 1} failed: $e');
        }
      }

      if (targetDir == null) {
        debugPrint('🔍 STORAGE: ERROR - No accessible storage directory found');
        debugPrint('🔍 STORAGE: Attempted paths: $attemptedPaths');
        throw Exception(
            'No accessible storage directory found. Attempted: $attemptedPaths');
      }

      // Step 4: Create subfolder if specified
      if (subfolder != null && subfolder.isNotEmpty) {
        targetDir = Directory(path.join(targetDir.path, subfolder));
        debugPrint('🔍 STORAGE: Using subfolder: ${targetDir.path}');
      }

      // Step 5: Ensure target directory exists
      debugPrint('🔍 STORAGE: Creating target directory...');
      try {
        await targetDir.create(recursive: true);
        debugPrint(
            '🔍 STORAGE: Target directory created/verified: ${targetDir.path}');
      } catch (e) {
        debugPrint('🔍 STORAGE: ERROR - Failed to create target directory: $e');
        throw Exception(
            'Failed to create target directory: ${targetDir.path} - $e');
      }

      // Step 6: Generate final filename
      final finalFileName = customFileName ?? fileName;
      final targetPath = path.join(targetDir.path, finalFileName);
      debugPrint('🔍 STORAGE: Target file path: $targetPath');

      // Step 7: Handle file conflicts
      String actualTargetPath = targetPath;
      if (await File(targetPath).exists()) {
        debugPrint('🔍 STORAGE: Target file exists, generating unique name...');
        actualTargetPath = await _generateUniqueFileName(targetPath);
        debugPrint('🔍 STORAGE: Using unique filename: $actualTargetPath');
      }

      // Step 8: Copy file
      debugPrint('🔍 STORAGE: Copying file...');
      final targetFile = File(actualTargetPath);

      try {
        await sourceFile.copy(actualTargetPath);
        debugPrint('🔍 STORAGE: File copied successfully');
      } catch (e) {
        debugPrint('🔍 STORAGE: ERROR - Copy failed: $e');

        // Try alternative copy method
        debugPrint('🔍 STORAGE: Trying alternative copy method...');
        try {
          final sourceBytes = await sourceFile.readAsBytes();
          await targetFile.writeAsBytes(sourceBytes);
          debugPrint('🔍 STORAGE: Alternative copy succeeded');
        } catch (e2) {
          debugPrint('🔍 STORAGE: ERROR - Alternative copy also failed: $e2');
          throw Exception('Failed to copy file: $e (Alternative method: $e2)');
        }
      }

      // Step 9: Verify copied file
      debugPrint('🔍 STORAGE: Verifying copied file...');
      if (await targetFile.exists()) {
        final targetFileSize = await targetFile.length();
        debugPrint(
            '🔍 STORAGE: Target file exists, size: $targetFileSize bytes');

        if (targetFileSize == sourceFileSize) {
          debugPrint('🔍 STORAGE: File sizes match - copy successful');
          debugPrint('🔍 STORAGE: Final saved path: $actualTargetPath');
          debugPrint('🔍 STORAGE: =========================');
          return actualTargetPath;
        } else {
          debugPrint(
              '🔍 STORAGE: ERROR - File sizes don\'t match (source: $sourceFileSize, target: $targetFileSize)');
          await targetFile.delete(); // Clean up incomplete file
          throw Exception('File copy incomplete - size mismatch');
        }
      } else {
        debugPrint('🔍 STORAGE: ERROR - Target file does not exist after copy');
        throw Exception('Target file does not exist after copy operation');
      }
    } catch (e, stackTrace) {
      debugPrint('🔍 STORAGE: ERROR in saveProcessedFile: $e');
      debugPrint('🔍 STORAGE: Stack trace: $stackTrace');
      return null;
    }
  }

  /// Test if we can write to a directory
  Future<bool> _testDirectoryAccess(Directory dir) async {
    try {
      // Create directory if it doesn't exist
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Test write access by creating a temporary file
      final testFile = File(path.join(
          dir.path, '.test_write_${DateTime.now().millisecondsSinceEpoch}'));
      await testFile.writeAsString('test');

      // Verify the test file exists and clean up
      final exists = await testFile.exists();
      if (exists) {
        await testFile.delete();
      }

      return exists;
    } catch (e) {
      debugPrint('🔍 STORAGE: Directory access test failed: $e');
      return false;
    }
  }

  /// Generate a unique filename if the target already exists
  Future<String> _generateUniqueFileName(String originalPath) async {
    final dir = path.dirname(originalPath);
    final fileName = path.basenameWithoutExtension(originalPath);
    final extension = path.extension(originalPath);

    int counter = 1;
    String newPath;

    do {
      newPath = path.join(dir, '${fileName}_$counter$extension');
      counter++;
    } while (await File(newPath).exists() && counter < 1000);

    return newPath;
  }

  /// Get the MegaPDF storage directory path with fallbacks
  Future<String?> getMegaPDFPath() async {
    try {
      debugPrint('🔍 STORAGE: Getting MegaPDF directory path...');

      // Try external storage first (Android)
      if (Platform.isAndroid) {
        try {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            final megaPdfDir =
                Directory(path.join(externalDir.path, 'MegaPDF'));
            if (await _testDirectoryAccess(megaPdfDir)) {
              debugPrint(
                  '🔍 STORAGE: Using external storage: ${megaPdfDir.path}');
              return megaPdfDir.path;
            }
          }
        } catch (e) {
          debugPrint('🔍 STORAGE: External storage failed: $e');
        }
      }

      // Fallback to app documents directory
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final megaPdfDir = Directory(path.join(appDir.path, 'MegaPDF'));
        if (await _testDirectoryAccess(megaPdfDir)) {
          debugPrint('🔍 STORAGE: Using app documents: ${megaPdfDir.path}');
          return megaPdfDir.path;
        }
      } catch (e) {
        debugPrint('🔍 STORAGE: App documents failed: $e');
      }

      debugPrint('🔍 STORAGE: No accessible directory found');
      return null;
    } catch (e) {
      debugPrint('🔍 STORAGE: Error getting MegaPDF path: $e');
      return null;
    }
  }

  /// Check available storage space
  Future<int> getAvailableSpace() async {
    try {
      final megaPdfPath = await getMegaPDFPath();
      if (megaPdfPath != null) {
        final stat = await FileStat.stat(megaPdfPath);
        return stat.size;
      }
      return 0;
    } catch (e) {
      debugPrint('🔍 STORAGE: Error getting available space: $e');
      return 0;
    }
  }

  /// Clean up temporary files and old processed files
  Future<void> cleanupOldFiles({int daysToKeep = 30}) async {
    try {
      final megaPdfPath = await getMegaPDFPath();
      if (megaPdfPath == null) return;

      final megaPdfDir = Directory(megaPdfPath);
      if (!await megaPdfDir.exists()) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      await for (final entity in megaPdfDir.list(recursive: true)) {
        if (entity is File) {
          try {
            final stat = await entity.stat();
            if (stat.modified.isBefore(cutoffDate)) {
              await entity.delete();
              debugPrint('🔍 STORAGE: Deleted old file: ${entity.path}');
            }
          } catch (e) {
            debugPrint('🔍 STORAGE: Error deleting old file: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('🔍 STORAGE: Error during cleanup: $e');
    }
  }

  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final megaPdfPath = await getMegaPDFPath();
      if (megaPdfPath == null) {
        return {
          'totalFiles': 0,
          'totalSize': 0,
          'path': null,
          'accessible': false,
        };
      }

      final megaPdfDir = Directory(megaPdfPath);
      if (!await megaPdfDir.exists()) {
        return {
          'totalFiles': 0,
          'totalSize': 0,
          'path': megaPdfPath,
          'accessible': false,
        };
      }

      int totalFiles = 0;
      int totalSize = 0;

      await for (final entity in megaPdfDir.list(recursive: true)) {
        if (entity is File) {
          try {
            totalFiles++;
            final size = await entity.length();
            totalSize += size;
          } catch (e) {
            debugPrint('🔍 STORAGE: Error reading file stats: $e');
          }
        }
      }

      return {
        'totalFiles': totalFiles,
        'totalSize': totalSize,
        'path': megaPdfPath,
        'accessible': true,
      };
    } catch (e) {
      debugPrint('🔍 STORAGE: Error getting storage stats: $e');
      return {
        'totalFiles': 0,
        'totalSize': 0,
        'path': null,
        'accessible': false,
        'error': e.toString(),
      };
    }
  }
}
