// lib/core/utils/permission_manager.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  /// Check if storage permissions are granted
  Future<bool> hasStoragePermission() async {
    print('🔧 PERMISSION_MANAGER: Checking storage permission...');

    if (Platform.isIOS) {
      // iOS doesn't need explicit storage permission for app documents
      print('🔧 PERMISSION_MANAGER: iOS - returning true');
      return true;
    }

    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        print('🔧 PERMISSION_MANAGER: Android SDK: $sdkInt');

        if (sdkInt >= 30) {
          // Android 11+ (API 30+) - Check MANAGE_EXTERNAL_STORAGE
          final permission = await Permission.manageExternalStorage.status;
          print(
              '🔧 PERMISSION_MANAGER: MANAGE_EXTERNAL_STORAGE status: $permission');
          return permission.isGranted;
        } else {
          // Android 10 and below - Check traditional storage permissions
          final storage = await Permission.storage.status;
          print('🔧 PERMISSION_MANAGER: Storage permission status: $storage');
          return storage.isGranted;
        }
      } catch (e) {
        print('🔧 PERMISSION_MANAGER: Error checking Android permissions: $e');
        return false;
      }
    }

    print('🔧 PERMISSION_MANAGER: Unknown platform, returning true');
    return true;
  }

  /// Request storage permissions with proper UI flow
  Future<bool> requestStoragePermission(BuildContext context) async {
    if (Platform.isIOS) {
      // iOS handles permissions automatically when accessing files
      return true;
    }

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 30) {
        // Android 11+ - Need MANAGE_EXTERNAL_STORAGE
        return await _requestAndroid11Permission(context);
      } else {
        // Android 10 and below - Traditional storage permission
        return await _requestTraditionalStoragePermission(context);
      }
    }

    return true;
  }

  /// Request permission for Android 11+
  Future<bool> _requestAndroid11Permission(BuildContext context) async {
    final permission = Permission.manageExternalStorage;
    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      // Show explanation dialog first
      final shouldRequest = await _showPermissionExplanationDialog(
        context,
        title: 'Storage Access Required',
        message:
            'MegaPDF needs access to your device storage to save and organize your PDF files. '
            'This allows you to:\n\n'
            '• Save processed PDFs to your Downloads folder\n'
            '• Access files from other apps\n'
            '• Organize files in custom folders\n\n'
            'You can manage this permission in your device settings.',
        isAndroid11: true,
      );

      if (!shouldRequest) return false;

      // Request permission
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await _showPermissionDeniedDialog(
        context,
        title: 'Storage Permission Required',
        message:
            'Storage access has been permanently denied. Please enable it in your device settings to save files.',
        isAndroid11: true,
      );
      return false;
    }

    return false;
  }

  /// Request traditional storage permission for Android 10 and below
  Future<bool> _requestTraditionalStoragePermission(
      BuildContext context) async {
    final permission = Permission.storage;
    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      // Show explanation dialog
      final shouldRequest = await _showPermissionExplanationDialog(
        context,
        title: 'Storage Access Required',
        message:
            'MegaPDF needs access to your device storage to save and organize your PDF files. '
            'This allows you to:\n\n'
            '• Save processed PDFs to your device\n'
            '• Access files from other apps\n'
            '• Organize files in folders\n\n'
            'Your privacy is important - we only access files you choose to work with.',
      );

      if (!shouldRequest) return false;

      // Request permission
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await _showPermissionDeniedDialog(
        context,
        title: 'Storage Permission Required',
        message:
            'Storage access has been permanently denied. Please enable it in your device settings.',
      );
      return false;
    }

    return false;
  }

  /// Show permission explanation dialog
  Future<bool> _showPermissionExplanationDialog(
    BuildContext context, {
    required String title,
    required String message,
    bool isAndroid11 = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.folder_shared,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
              if (isAndroid11) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'On Android 11+, you\'ll be taken to system settings to grant this permission.',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Now'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check, size: 18),
            label: Text(isAndroid11 ? 'Open Settings' : 'Grant Permission'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Show permission permanently denied dialog
  Future<void> _showPermissionDeniedDialog(
    BuildContext context, {
    required String title,
    required String message,
    bool isAndroid11 = false,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.block,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'To enable storage access:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Open your device Settings\n'
                    '2. Go to Apps → MegaPDF\n'
                    '3. Tap Permissions\n'
                    '4. Enable Storage permission',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Check if we should show permission rationale
  Future<bool> shouldShowPermissionRationale() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      Permission permission;
      if (sdkInt >= 30) {
        permission = Permission.manageExternalStorage;
      } else {
        permission = Permission.storage;
      }

      return await permission.shouldShowRequestRationale;
    }

    return false;
  }

  /// Get detailed permission status for debugging
  Future<Map<String, dynamic>> getPermissionStatus() async {
    final Map<String, dynamic> status = {
      'platform': Platform.isAndroid ? 'Android' : 'iOS',
      'hasStoragePermission': false,
      'details': {},
    };

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      status['androidVersion'] = sdkInt;
      status['details']['androidVersion'] = sdkInt;

      if (sdkInt >= 30) {
        final manageStorage = await Permission.manageExternalStorage.status;
        status['details']['manageExternalStorage'] = manageStorage.toString();
        status['hasStoragePermission'] = manageStorage.isGranted;
      } else {
        final storage = await Permission.storage.status;
        status['details']['storage'] = storage.toString();
        status['hasStoragePermission'] = storage.isGranted;
      }
    } else {
      // iOS
      status['hasStoragePermission'] = true;
      status['details']['note'] = 'iOS handles storage access automatically';
    }

    return status;
  }
}
