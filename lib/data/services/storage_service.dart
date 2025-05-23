// lib/data/services/storage_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart' as path;
import '../../core/utils/permission_manager.dart';
import 'fallback_storage_service.dart';

part 'storage_service.g.dart';

@riverpod
StorageService storageService(StorageServiceRef ref) {
  return StorageService();
}

class StorageService {
  // Root directory name for all app files
  final String _rootDirName = 'MegaPDF';

  // Permission manager
  final _permissionManager = PermissionManager();

  // Fallback service
  final _fallbackService = FallbackStorageService();

  // Private storage mode (when public storage is not accessible)
  bool _usePrivateStorage = false;

  // Get the full path to the MegaPDF directory
  Future<String?> getMegaPDFPath() async {
    try {
      final dir = await createMegaPDFDirectory();
      return dir?.path;
    } catch (e) {
      debugPrint('⚠️ Error getting MegaPDF path: $e');
      return null;
    }
  }

  // Check if storage permissions are granted
  Future<bool> checkPermissions() async {
    return await _permissionManager.hasStoragePermission();
  }

  // Request storage permissions
  Future<bool> requestPermissions(BuildContext context) async {
    return await _permissionManager.requestStoragePermission(context);
  }

  // Create MegaPDF folder in the root directory
  Future<Directory?> createMegaPDFDirectory() async {
    try {
      print('Creating MegaPDF directory...');
      final rootDir = await getRootDirectory();

      if (rootDir == null) {
        debugPrint('⚠️ Root directory is null');
        return null;
      }

      final megaPdfDir = Directory(path.join(rootDir.path, _rootDirName));
      print('MegaPDF directory path: ${megaPdfDir.path}');

      if (!await megaPdfDir.exists()) {
        try {
          await megaPdfDir.create(recursive: true);
          debugPrint('✅ Created MegaPDF directory at: ${megaPdfDir.path}');
        } catch (e) {
          debugPrint('⚠️ Failed to create MegaPDF directory: $e');
          _usePrivateStorage = true;
          final privateDir = await getApplicationDocumentsDirectory();
          final privateMegaPdfDir =
              Directory(path.join(privateDir.path, _rootDirName));
          await privateMegaPdfDir.create(recursive: true);
          print(
              'Created MegaPDF directory in private storage: ${privateMegaPdfDir.path}');
          return privateMegaPdfDir;
        }
      } else {
        print('MegaPDF directory already exists at: ${megaPdfDir.path}');
      }

      return megaPdfDir;
    } catch (e) {
      debugPrint('⚠️ Error creating MegaPDF directory: $e');
      // Fall back to private storage
      _usePrivateStorage = true;
      final privateDir = await getApplicationDocumentsDirectory();
      final privateMegaPdfDir =
          Directory(path.join(privateDir.path, _rootDirName));
      await privateMegaPdfDir.create(recursive: true);
      print(
          'Created MegaPDF directory in private storage after error: ${privateMegaPdfDir.path}');
      return privateMegaPdfDir;
    }
  }

  // Helper method to create a safe filename
  String _createSafeFileName(String fileName) {
    // Remove or replace invalid characters
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_{2,}'), '_')
        .trim();
  }

  // Check if a file exists
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Check if we're using private storage
  bool isUsingPrivateStorage() {
    return _usePrivateStorage;
  }

  // Reset storage mode (for testing)
  void resetStorageMode() {
    _usePrivateStorage = false;
  }

  Future<bool> hasStorageAccess() async {
    return await _permissionManager.hasStoragePermission();
  }

  /// Request storage permissions if needed
  Future<bool> requestStorageAccess(BuildContext context) async {
    return await _permissionManager.requestStoragePermission(context);
  }

  /// Modified getRootDirectory method that respects permissions
  Future<Directory?> getRootDirectory() async {
    try {
      // Check permissions first
      final hasPermission = await hasStorageAccess();

      // If we don't have permission, use private storage
      if (!hasPermission) {
        debugPrint('⚠️ No storage permission, using private storage');
        _usePrivateStorage = true;
        final appDir = await getApplicationDocumentsDirectory();
        print('Using private storage directory: ${appDir.path}');
        return appDir;
      }

      // If we're in private storage mode, return app documents directory
      if (_usePrivateStorage) {
        final appDir = await getApplicationDocumentsDirectory();
        print('Using private storage directory: ${appDir.path}');
        return appDir;
      }

      // Try to get the Downloads directory first (Android only)
      if (Platform.isAndroid) {
        // On newer Android versions with scoped storage, try to use the Download directory
        final externalDir = await getExternalStorageDirectory();

        if (externalDir != null) {
          // Try to navigate to Downloads folder
          String dirPath = externalDir.path;

          // Get to the root storage directory
          List<String> paths = dirPath.split("/");
          int storageIndex = paths.indexOf('storage');

          if (storageIndex >= 0 && paths.length > storageIndex + 2) {
            // Typical path to Downloads folder
            final downloadsPath = path.join(
              '/', // First argument
              path.joinAll(paths.sublist(0,
                  storageIndex + 3)), // Join the sublist into a single string
              'Download',
            );

            // Check if we can access the directory
            try {
              final downloadsDir = Directory(downloadsPath);
              if (await downloadsDir.exists()) {
                // Test if we can actually write to this directory
                final testFile =
                    File(path.join(downloadsPath, '.megapdf_test'));
                try {
                  await testFile.writeAsString('test');
                  await testFile.delete();
                  print('Using downloads directory: $downloadsPath');
                  return downloadsDir;
                } catch (e) {
                  debugPrint('⚠️ Cannot write to Downloads directory: $e');
                  // Fall through to next option
                }
              }
            } catch (e) {
              debugPrint('⚠️ Cannot access Downloads directory: $e');
              // Fall through to next option
            }
          }
        }
      }

      // For iOS or if Android Downloads directory wasn't accessible
      Directory? directory;

      if (Platform.isIOS) {
        // On iOS, use the Documents directory
        directory = await getApplicationDocumentsDirectory();
      } else if (Platform.isAndroid) {
        // On Android, try to use app's external storage
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // Test if we can write to this directory
          try {
            final testFile = File(path.join(externalDir.path, '.megapdf_test'));
            await testFile.writeAsString('test');
            await testFile.delete();
            directory = externalDir;
            print('Using external directory: ${externalDir.path}');
          } catch (e) {
            debugPrint('⚠️ Cannot write to external directory: $e');
            // Fall through to fallback
          }
        }
      }

      if (directory != null) {
        return directory;
      }

      // If we got here, we couldn't access any external storage
      debugPrint('⚠️ Falling back to private storage');
      _usePrivateStorage = true;
      final appDir = await getApplicationDocumentsDirectory();
      print('Using private storage as fallback: ${appDir.path}');
      return appDir;
    } catch (e) {
      debugPrint('⚠️ Error accessing storage: $e');
      // Fall back to application documents directory as a last resort
      _usePrivateStorage = true;
      return await getApplicationDocumentsDirectory();
    }
  }

  /// Simplified saveFile method without folder functionality
  Future<String?> saveFile({
    required String sourceFilePath,
    required String fileName,
    bool addTimestamp = true,
    BuildContext? context,
  }) async {
    try {
      // Check if source file exists
      final sourceFile = File(sourceFilePath);
      if (!await sourceFile.exists()) {
        debugPrint('⚠️ Source file does not exist: $sourceFilePath');
        return null;
      }

      // Check if we have storage permission
      final hasPermission = await hasStorageAccess();

      // If context is provided and we don't have permissions, handle the flow
      if (context != null && !hasPermission && !_usePrivateStorage) {
        final action = await _fallbackService.showStorageOptionsDialog(context);

        switch (action) {
          case StorageAction.requestPermission:
            final granted = await requestStorageAccess(context);
            if (!granted) {
              // Fall back to picker
              return _fallbackService.saveFileWithPicker(
                sourceFilePath: sourceFilePath,
                suggestedFileName: fileName,
                context: context,
              );
            }
            break;

          case StorageAction.chooseSaveLocation:
            return _fallbackService.saveFileWithPicker(
              sourceFilePath: sourceFilePath,
              suggestedFileName: fileName,
              context: context,
            );

          case StorageAction.saveInApp:
            _usePrivateStorage = true;
            break;

          case StorageAction.share:
            await _fallbackService.shareFile(
              filePath: sourceFilePath,
              subject: 'Sharing file from MegaPDF',
              text: 'Here is your processed PDF file.',
            );
            // Return the original path since we didn't actually save a new file
            return sourceFilePath;

          case StorageAction.cancel:
            return null;
        }
      } else if (!hasPermission) {
        // No context provided but no permission - force private storage
        _usePrivateStorage = true;
      }

      // Get MegaPDF directory
      final Directory? megaPdfDir = await createMegaPDFDirectory();

      if (megaPdfDir == null) {
        debugPrint('⚠️ MegaPDF directory is null');

        // Fall back to app's private directory
        return await _fallbackService.saveToAppDirectory(
          sourceFilePath: sourceFilePath,
          fileName: fileName,
          subfolder: null,
        );
      }

      // Generate a safe filename
      final safeName = _createSafeFileName(fileName);

      // Add timestamp if needed
      String finalFileName = safeName;
      if (addTimestamp) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final baseName = path.basenameWithoutExtension(safeName);
        final extension = path.extension(safeName);
        finalFileName = '${baseName}_$timestamp$extension';
      }

      // Full path for the destination file
      final savePath = path.join(megaPdfDir.path, finalFileName);

      try {
        // Copy the file
        final newFile = await sourceFile.copy(savePath);
        debugPrint('✅ File saved to: ${newFile.path}');
        return newFile.path;
      } catch (e) {
        debugPrint('⚠️ Error copying file: $e');

        // If we failed to save to external storage, try private storage
        if (!_usePrivateStorage) {
          _usePrivateStorage = true;
          return await _fallbackService.saveToAppDirectory(
            sourceFilePath: sourceFilePath,
            fileName: fileName,
            subfolder: null,
          );
        }

        return null;
      }
    } catch (e) {
      debugPrint('⚠️ Error saving file: $e');

      // Try fallback if we have a context
      if (context != null) {
        return _fallbackService.saveFileWithPicker(
          sourceFilePath: sourceFilePath,
          suggestedFileName: fileName,
          context: context,
        );
      }

      return null;
    }
  }

  /// Get storage information for the user
  Map<String, dynamic> getStorageInfo() {
    return {
      'usingPrivateStorage': _usePrivateStorage,
      'storageMode': getStorageModeDescription(),
      'canSaveToPublicStorage': !_usePrivateStorage,
    };
  }

  /// Show storage info dialog to user
  Future<void> showStorageInfoDialog(BuildContext context) async {
    final storageInfo = getStorageInfo();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              storageInfo['usingPrivateStorage']
                  ? Icons.lock
                  : Icons.folder_shared,
              color: storageInfo['usingPrivateStorage']
                  ? Colors.orange
                  : Colors.green,
            ),
            const SizedBox(width: 12),
            const Text('Storage Information'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Storage Mode:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(storageInfo['storageMode']),
            const SizedBox(height: 16),
            if (storageInfo['usingPrivateStorage']) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Limited Storage Access',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Files are saved within the app. Other apps cannot access them directly.',
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Full Storage Access',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Files are saved to your device storage and can be accessed by other apps.',
                      style: TextStyle(color: Colors.green.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (storageInfo['usingPrivateStorage'])
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final granted = await requestStorageAccess(context);
                if (granted) {
                  resetStorageMode();
                }
              },
              child: const Text('Grant Storage Access'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Get storage mode description
  String getStorageModeDescription() {
    return _usePrivateStorage
        ? 'Using private app storage (limited access)'
        : 'Using public storage (accessible to all apps)';
  }

  // Get list of files in the MegaPDF directory
  Future<List<File>> getFiles() async {
    try {
      final megaPdfDir = await createMegaPDFDirectory();
      if (megaPdfDir == null) {
        return [];
      }

      if (!await megaPdfDir.exists()) {
        return [];
      }

      final files = <File>[];
      await for (final entity in megaPdfDir.list()) {
        if (entity is File) {
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
    } catch (e) {
      print('Error getting files: $e');
      return [];
    }
  }

  // Delete a file
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
}
