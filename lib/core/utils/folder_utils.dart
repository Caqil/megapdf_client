// lib/core/utils/folder_utils.dart
import 'dart:io';

class FolderUtils {
  // Invalid characters for folder names on different platforms
  static const _windowsInvalidChars = r'<>:"/\|?*';
  static const _unixInvalidChars = r'/\0';
  static const _iosInvalidChars = r':/\0';

  /// Validates a folder name for the current platform
  static String? validateFolderName(String name) {
    if (name.trim().isEmpty) {
      return 'Folder name cannot be empty';
    }

    final trimmed = name.trim();

    // Check length
    if (trimmed.length > 255) {
      return 'Folder name is too long (max 255 characters)';
    }

    // Check for platform-specific invalid characters
    String invalidChars;
    if (Platform.isWindows) {
      invalidChars = _windowsInvalidChars;
    } else if (Platform.isIOS) {
      invalidChars = _iosInvalidChars;
    } else {
      invalidChars = _unixInvalidChars;
    }

    for (int i = 0; i < invalidChars.length; i++) {
      if (trimmed.contains(invalidChars[i])) {
        return 'Folder name contains invalid character: "${invalidChars[i]}"';
      }
    }

    // Check for reserved names (Windows)
    if (Platform.isWindows) {
      final reservedNames = [
        'CON',
        'PRN',
        'AUX',
        'NUL',
        'COM1',
        'COM2',
        'COM3',
        'COM4',
        'COM5',
        'COM6',
        'COM7',
        'COM8',
        'COM9',
        'LPT1',
        'LPT2',
        'LPT3',
        'LPT4',
        'LPT5',
        'LPT6',
        'LPT7',
        'LPT8',
        'LPT9'
      ];

      if (reservedNames.contains(trimmed.toUpperCase())) {
        return 'Folder name is reserved by the system';
      }
    }

    // Check for names that start or end with spaces or dots
    if (trimmed.startsWith(' ') || trimmed.endsWith(' ')) {
      return 'Folder name cannot start or end with spaces';
    }

    if (trimmed.startsWith('.') || trimmed.endsWith('.')) {
      return 'Folder name cannot start or end with dots';
    }

    return null; // Valid
  }

  /// Sanitizes a folder name to make it valid for the current platform
  static String sanitizeFolderName(String name) {
    String sanitized = name.trim();

    // Replace invalid characters with underscores
    String invalidChars;
    if (Platform.isWindows) {
      invalidChars = _windowsInvalidChars;
    } else if (Platform.isIOS) {
      invalidChars = _iosInvalidChars;
    } else {
      invalidChars = _unixInvalidChars;
    }

    for (int i = 0; i < invalidChars.length; i++) {
      sanitized = sanitized.replaceAll(invalidChars[i], '_');
    }

    // Replace multiple consecutive underscores with single underscore
    sanitized = sanitized.replaceAll(RegExp(r'_{2,}'), '_');

    // Remove leading/trailing underscores and dots
    sanitized = sanitized.replaceAll(RegExp(r'^[_\.]|[_\.]$'), '');

    // Ensure it's not empty after sanitization
    if (sanitized.isEmpty) {
      sanitized = 'New_Folder';
    }

    // Truncate if too long
    if (sanitized.length > 255) {
      sanitized = sanitized.substring(0, 255);
    }

    return sanitized;
  }

  /// Generates a unique folder name by appending a number if needed
  static String generateUniqueName(
      String baseName, List<String> existingNames) {
    String candidateName = baseName;
    int counter = 1;

    while (existingNames.contains(candidateName)) {
      candidateName = '$baseName ($counter)';
      counter++;
    }

    return candidateName;
  }

  /// Converts a logical folder path to display-friendly format
  static String formatPathForDisplay(String logicalPath) {
    if (logicalPath.startsWith('/MegaPDF/')) {
      return logicalPath.substring('/MegaPDF/'.length);
    } else if (logicalPath == '/MegaPDF') {
      return 'Home';
    }
    return logicalPath;
  }

  /// Gets the parent path from a logical path
  static String? getParentPath(String logicalPath) {
    if (logicalPath == '/MegaPDF') {
      return null; // Root has no parent
    }

    final parts = logicalPath.split('/');
    if (parts.length <= 2) {
      return '/MegaPDF'; // Direct child of root
    }

    parts.removeLast();
    return parts.join('/');
  }

  /// Checks if a path is a descendant of another path
  static bool isDescendantPath(String descendantPath, String ancestorPath) {
    if (descendantPath == ancestorPath) {
      return true;
    }

    return descendantPath.startsWith('$ancestorPath/');
  }

  /// Creates a safe file name from a folder name
  static String createSafeFileName(String folderName) {
    return sanitizeFolderName(folderName).replaceAll(' ', '_').toLowerCase();
  }
}
