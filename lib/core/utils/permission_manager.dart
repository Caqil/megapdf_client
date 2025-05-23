// lib/core/utils/enhanced_permission_manager.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:app_settings/app_settings.dart';

class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  // Cache Android version to avoid repeated checks
  int? _androidSdkVersion;
  bool? _hasAllFilesAccess;

  /// Check if the device requires MANAGE_EXTERNAL_STORAGE permission (Android 11+)
  Future<bool> _needsManageExternalStorage() async {
    if (!Platform.isAndroid) return false;

    _androidSdkVersion ??= await _getAndroidVersion();
    return _androidSdkVersion! >= 30; // Android 11+
  }

  /// Get Android SDK version
  Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;

    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    } catch (e) {
      debugPrint('Error getting Android version: $e');
      return 0;
    }
  }

  /// Check if all required storage permissions are granted
  Future<bool> hasStoragePermission() async {
    if (!Platform.isAndroid) return true; // iOS handles permissions differently

    // Check if Android 11+ (API 30+) - requires special handling
    if (await _needsManageExternalStorage()) {
      _hasAllFilesAccess = await Permission.manageExternalStorage.isGranted;
      return _hasAllFilesAccess!;
    }

    // For Android 10 (API 29)
    if (_androidSdkVersion == 29) {
      return await Permission.storage.isGranted;
    }

    // For older Android versions
    return await Permission.storage.isGranted;
  }

  /// Request storage permissions with appropriate handling for different Android versions
  Future<bool> requestStoragePermission(BuildContext context) async {
    if (!Platform.isAndroid) return true; // iOS handles permissions differently

    // Check if Android 11+ (API 30+) - requires special handling
    if (await _needsManageExternalStorage()) {
      final status = await Permission.manageExternalStorage.status;

      if (status.isDenied || status.isPermanentlyDenied) {
        // Show a rationale dialog before requesting permission
        final shouldRequest = await _showPermissionRationaleDialog(
          context,
          'Storage Access Required',
          'MegaPDF needs to access all files on your device to save PDFs to your Downloads folder. This requires special permission on your Android version.',
          'Without this permission, files can only be saved within the app.',
        );

        if (!shouldRequest) return false;

        // Request the permission
        final result = await Permission.manageExternalStorage.request();
        _hasAllFilesAccess = result.isGranted;

        // If denied, show settings dialog
        if (!result.isGranted) {
          _showSettingsDialog(context);
          return false;
        }

        return result.isGranted;
      }

      _hasAllFilesAccess = status.isGranted;
      return status.isGranted;
    }

    // For Android 10 (API 29) and below
    final storageStatus = await Permission.storage.status;

    if (storageStatus.isDenied || storageStatus.isPermanentlyDenied) {
      // Show a rationale dialog before requesting permission
      final shouldRequest = await _showPermissionRationaleDialog(
        context,
        'Storage Permission Required',
        'MegaPDF needs storage permission to save files to your device.',
        'Without this permission, you won\'t be able to access saved files outside the app.',
      );

      if (!shouldRequest) return false;

      // Request the permission
      final result = await Permission.storage.request();

      // If denied, show settings dialog
      if (!result.isGranted &&
          (result.isPermanentlyDenied || storageStatus.isPermanentlyDenied)) {
        _showSettingsDialog(context);
        return false;
      }

      return result.isGranted;
    }

    return storageStatus.isGranted;
  }

  /// Open system settings for the app
  Future<void> openSettings() async {
    await AppSettings.openAppSettings();
  }

  /// Show dialog explaining why the permission is needed
  Future<bool> _showPermissionRationaleDialog(
    BuildContext context,
    String title,
    String message,
    String warningMessage,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(warningMessage,
                          style: const TextStyle(fontSize: 12))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Show dialog to direct user to settings
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Storage permission is required for MegaPDF to work properly.'),
            const SizedBox(height: 12),
            if (Platform.isAndroid && _androidSdkVersion! >= 30)
              const Text(
                'Please enable "Allow access to manage all files" in the next screen.',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            else
              const Text(
                'Please enable storage permission in Settings.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Fallback method using Storage Access Framework if direct storage access fails
  Future<bool> useStorageAccessFramework(BuildContext context) async {
    if (!Platform.isAndroid) return false;

    try {
      // This would use a plugin like file_picker or flutter_document_picker
      // to request access via the Storage Access Framework
      // For now, we'll just show a dialog explaining this

      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Alternative Access Method'),
          content: const Text(
            'MegaPDF can use an alternative method to save files. This will show a folder picker each time you save a file, but allows you to choose exactly where to save.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Use Alternative Method'),
            ),
          ],
        ),
      );

      return result ?? false;
    } catch (e) {
      debugPrint('Error using Storage Access Framework: $e');
      return false;
    }
  }

  /// Get detailed status of permissions for debugging
  Future<Map<String, String>> getPermissionStatus() async {
    final result = <String, String>{};

    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        result['Android SDK'] = androidInfo.version.sdkInt.toString();
        result['Android Release'] = androidInfo.version.release;
        result['Device'] = '${androidInfo.manufacturer} ${androidInfo.model}';

        // Check basic storage permission
        final storageStatus = await Permission.storage.status;
        result['Storage Permission'] = storageStatus.toString();

        // Check advanced permissions for Android 11+
        if (androidInfo.version.sdkInt >= 30) {
          final manageStatus = await Permission.manageExternalStorage.status;
          result['Manage External Storage'] = manageStatus.toString();
        }

        // Check Android 13+ media permissions
        if (androidInfo.version.sdkInt >= 33) {
          final imagesStatus = await Permission.photos.status;
          result['Read Media Images'] = imagesStatus.toString();
        }
      } catch (e) {
        result['Error'] = e.toString();
      }
    } else if (Platform.isIOS) {
      result['Platform'] = 'iOS (permissions handled differently)';
    }

    return result;
  }
}
