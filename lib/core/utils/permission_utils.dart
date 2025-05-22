// lib/core/utils/permission_utils.dart
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionUtils {
  /// Request storage permissions
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final storage = await Permission.storage.request();
      final external = await Permission.manageExternalStorage.request();
      return storage.isGranted || external.isGranted;
    } else if (Platform.isIOS) {
      final photos = await Permission.photos.request();
      return photos.isGranted;
    }
    return true; // Other platforms
  }

  /// Request camera permission (for image watermarks)
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Check if all required permissions are granted
  static Future<bool> hasAllRequiredPermissions() async {
    if (Platform.isAndroid) {
      final storage = await Permission.storage.isGranted;
      final external = await Permission.manageExternalStorage.isGranted;
      return storage || external;
    } else if (Platform.isIOS) {
      return await Permission.photos.isGranted;
    }
    return true;
  }

  /// Open app settings for manual permission grant
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
}
