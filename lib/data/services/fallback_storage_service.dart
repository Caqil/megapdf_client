// lib/core/services/fallback_storage_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Fallback storage service for when direct storage access is not available
/// This uses the Storage Access Framework (document picker) on Android
class FallbackStorageService {
  static final FallbackStorageService _instance =
      FallbackStorageService._internal();
  factory FallbackStorageService() => _instance;
  FallbackStorageService._internal();

  /// Save a file using document picker to let user choose location
  Future<String?> saveFileWithPicker({
    required String sourceFilePath,
    required String suggestedFileName,
    BuildContext? context,
  }) async {
    try {
      // First, ensure the source file exists
      final sourceFile = File(sourceFilePath);
      if (!await sourceFile.exists()) {
        debugPrint('Source file does not exist: $sourceFilePath');
        return null;
      }

      // Use FilePicker to let the user choose a save location
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save PDF File',
        fileName: suggestedFileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (outputPath == null) {
        // User cancelled the picker
        return null;
      }

      // Ensure the output path has the correct extension
      if (!outputPath.toLowerCase().endsWith('.pdf')) {
        outputPath += '.pdf';
      }

      // Copy the file to the selected location
      final destinationFile = await sourceFile.copy(outputPath);
      return destinationFile.path;
    } catch (e) {
      debugPrint('Error saving file with picker: $e');
      return null;
    }
  }

  /// Share a file instead of saving it directly
  Future<void> shareFile({
    required String filePath,
    String? subject,
    String? text,
  }) async {
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

  /// Save file to app's private directory (when public storage is not accessible)
  Future<String?> saveToAppDirectory({
    required String sourceFilePath,
    required String fileName,
    String? subfolder,
  }) async {
    try {
      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();

      // Create subfolder if needed
      Directory targetDir = appDir;
      if (subfolder != null) {
        targetDir = Directory(path.join(appDir.path, subfolder));
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
      }

      // Generate a unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(fileName);
      final basename = path.basenameWithoutExtension(fileName);
      final safeFileName = '${basename}_$timestamp$extension';

      // Full path for the destination file
      final destinationPath = path.join(targetDir.path, safeFileName);

      // Copy the file
      final sourceFile = File(sourceFilePath);
      final destinationFile = await sourceFile.copy(destinationPath);

      return destinationFile.path;
    } catch (e) {
      debugPrint('Error saving to app directory: $e');
      return null;
    }
  }

  /// Get the app's private directory path for displaying to the user
  Future<String?> getAppDirectoryPath() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      return appDir.path;
    } catch (e) {
      debugPrint('Error getting app directory path: $e');
      return null;
    }
  }

  /// Show a dialog explaining storage limitations and offering alternatives
  Future<StorageAction> showStorageOptionsDialog(BuildContext context) async {
    final result = await showDialog<StorageAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Storage Access'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MegaPDF doesn\'t have permission to save files directly to your storage. '
              'You have these options:',
            ),
            const SizedBox(height: 16),
            _buildOptionTile(
              context,
              'Request Permission',
              'Grant storage permission to save files directly',
              Icons.folder_shared,
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildOptionTile(
              context,
              'Choose Location',
              'Pick where to save each file (one at a time)',
              Icons.save,
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildOptionTile(
              context,
              'Save in App',
              'Save within the app (limited accessibility)',
              Icons.app_shortcut,
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildOptionTile(
              context,
              'Share',
              'Share file to another app instead of saving',
              Icons.share,
              Colors.purple,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, StorageAction.cancel),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    return result ?? StorageAction.cancel;
  }

  Widget _buildOptionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(
          context,
          _getActionFromTitle(title),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  StorageAction _getActionFromTitle(String title) {
    switch (title) {
      case 'Request Permission':
        return StorageAction.requestPermission;
      case 'Choose Location':
        return StorageAction.chooseSaveLocation;
      case 'Save in App':
        return StorageAction.saveInApp;
      case 'Share':
        return StorageAction.share;
      default:
        return StorageAction.cancel;
    }
  }
}

/// Possible actions for handling storage limitations
enum StorageAction {
  requestPermission,
  chooseSaveLocation,
  saveInApp,
  share,
  cancel,
}
