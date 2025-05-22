// lib/core/utils/enhanced_permission_manager.dart
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  /// Request all necessary permissions for file downloading
  Future<bool> requestDownloadPermissions({
    required BuildContext context,
    bool showRationale = true,
  }) async {
    if (!Platform.isAndroid) return true; // iOS handles this differently

    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final androidVersion = androidInfo.version.sdkInt;

      print('Android SDK Version: $androidVersion');

      // For Android 11+ (API 30+)
      if (androidVersion >= 30) {
        return await _requestAndroid11Permissions(context, showRationale);
      }
      // For Android 10 (API 29)
      else if (androidVersion >= 29) {
        return await _requestAndroid10Permissions(context, showRationale);
      }
      // For older Android versions
      else {
        return await _requestLegacyPermissions(context, showRationale);
      }
    } catch (e) {
      print('Error checking Android version: $e');
      // Fallback to requesting all permissions
      return await _requestAllPermissions(context, showRationale);
    }
  }

  /// Android 11+ (API 30+) permission handling
  Future<bool> _requestAndroid11Permissions(
      BuildContext context, bool showRationale) async {
    // Check MANAGE_EXTERNAL_STORAGE permission
    var manageStorageStatus = await Permission.manageExternalStorage.status;

    if (manageStorageStatus.isDenied) {
      if (showRationale && context.mounted) {
        await _showPermissionRationale(
          context,
          'Storage Access Required',
          'This app needs access to device storage to download and save PDF files. Please grant "All files access" permission in the next screen.',
        );
      }

      manageStorageStatus = await Permission.manageExternalStorage.request();
    }

    // If MANAGE_EXTERNAL_STORAGE is denied, try basic storage permissions
    if (manageStorageStatus.isDenied ||
        manageStorageStatus.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermissionDeniedDialog(context, 'manage_external_storage');
      }
      return false;
    }

    // Also request notification permission for Android 13+
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      await Permission.notification.request();
    }

    return manageStorageStatus.isGranted;
  }

  /// Android 10 (API 29) permission handling
  Future<bool> _requestAndroid10Permissions(
      BuildContext context, bool showRationale) async {
    final permissions = [
      Permission.storage,
    ];

    if (showRationale && context.mounted) {
      await _showPermissionRationale(
        context,
        'Storage Permission Required',
        'This app needs storage permission to download and save PDF files to your device.',
      );
    }

    final Map<Permission, PermissionStatus> statuses =
        await permissions.request();

    final storageGranted = statuses[Permission.storage]?.isGranted ?? false;

    if (!storageGranted && context.mounted) {
      await _showPermissionDeniedDialog(context, 'storage');
    }

    return storageGranted;
  }

  /// Legacy Android (API < 29) permission handling
  Future<bool> _requestLegacyPermissions(
      BuildContext context, bool showRationale) async {
    final permissions = [
      Permission.storage,
    ];

    if (showRationale && context.mounted) {
      await _showPermissionRationale(
        context,
        'Storage Permission Required',
        'This app needs storage permission to download and save PDF files to your device.',
      );
    }

    final Map<Permission, PermissionStatus> statuses =
        await permissions.request();

    final storageGranted = statuses[Permission.storage]?.isGranted ?? false;

    if (!storageGranted && context.mounted) {
      await _showPermissionDeniedDialog(context, 'storage');
    }

    return storageGranted;
  }

  /// Fallback method to request all permissions
  Future<bool> _requestAllPermissions(
      BuildContext context, bool showRationale) async {
    final permissions = [
      Permission.storage,
      Permission.manageExternalStorage,
    ];

    if (showRationale && context.mounted) {
      await _showPermissionRationale(
        context,
        'Permissions Required',
        'This app needs storage permissions to download and save PDF files. Please grant all requested permissions.',
      );
    }

    final Map<Permission, PermissionStatus> statuses =
        await permissions.request();

    // Check if any storage permission is granted
    final storageGranted = statuses[Permission.storage]?.isGranted ?? false;
    final manageStorageGranted =
        statuses[Permission.manageExternalStorage]?.isGranted ?? false;

    final hasStoragePermission = storageGranted || manageStorageGranted;

    if (!hasStoragePermission && context.mounted) {
      await _showPermissionDeniedDialog(context, 'storage');
    }

    return hasStoragePermission;
  }

  /// Check if download permissions are currently granted
  Future<bool> hasDownloadPermissions() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final androidVersion = androidInfo.version.sdkInt;

      if (androidVersion >= 30) {
        // Android 11+: Check MANAGE_EXTERNAL_STORAGE
        final manageStorage = await Permission.manageExternalStorage.status;
        return manageStorage.isGranted;
      } else {
        // Android 10 and below: Check regular storage permission
        final storage = await Permission.storage.status;
        return storage.isGranted;
      }
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }

  /// Show permission rationale dialog
  Future<void> _showPermissionRationale(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.security, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Show permission denied dialog with options
  Future<void> _showPermissionDeniedDialog(
    BuildContext context,
    String permissionType,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Permission Required'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Storage permission is required to download files.'),
              const SizedBox(height: 12),
              Text(
                'To enable downloads:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              if (permissionType == 'manage_external_storage') ...[
                const Text('1. Tap "Open Settings"'),
                const Text('2. Find this app in the list'),
                const Text('3. Enable "All files access"'),
              ] else ...[
                const Text('1. Tap "Open Settings"'),
                const Text('2. Find "Permissions"'),
                const Text('3. Enable "Storage" permission'),
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  /// Get permission status details for debugging
  Future<Map<String, String>> getPermissionStatusDetails() async {
    final Map<String, String> details = {};

    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        details['Android Version'] = androidInfo.version.sdkInt.toString();
        details['Device Model'] = androidInfo.model;

        final storage = await Permission.storage.status;
        details['Storage Permission'] = storage.toString();

        final manageStorage = await Permission.manageExternalStorage.status;
        details['Manage External Storage'] = manageStorage.toString();

        final notification = await Permission.notification.status;
        details['Notification Permission'] = notification.toString();
      } catch (e) {
        details['Error'] = e.toString();
      }
    } else {
      details['Platform'] = 'iOS (permissions handled automatically)';
    }

    return details;
  }
}
