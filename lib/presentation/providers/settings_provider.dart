// lib/presentation/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/database_helper.dart';
import '../../data/services/storage_service.dart';
import 'dart:io';

part 'settings_provider.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _autoDeleteKey = 'auto_delete_days';
  static const String _defaultQualityKey = 'default_quality';
  static const String _fileNamingKey = 'file_naming_pattern';
  static const String _showPreviewKey = 'show_file_preview';
  static const String _autoSaveKey = 'auto_save_results';
  static const String _analyticsKey = 'analytics_enabled';

  @override
  SettingsState build() {
    _loadSettings();
    return const SettingsState();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      final autoDeleteDays = prefs.getInt(_autoDeleteKey) ?? 30;
      final defaultQuality = prefs.getInt(_defaultQualityKey) ?? 90;
      final fileNaming = prefs.getString(_fileNamingKey) ?? 'timestamp';
      final showPreview = prefs.getBool(_showPreviewKey) ?? true;
      final autoSave = prefs.getBool(_autoSaveKey) ?? true;
      final analytics = prefs.getBool(_analyticsKey) ?? true;

      // Load storage info
      final storageInfo = await _getStorageInfo();

      state = state.copyWith(
        isLoading: false,
        themeMode: ThemeMode.values[themeIndex],
        autoDeleteDays: autoDeleteDays,
        defaultQuality: defaultQuality,
        fileNamingPattern: fileNaming,
        showFilePreview: showPreview,
        autoSaveResults: autoSave,
        analyticsEnabled: analytics,
        storageInfo: storageInfo,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load settings: $e',
      );
    }
  }

  Future<StorageInfo> _getStorageInfo() async {
    try {
      final dbHelper = DatabaseHelper();
      final recentFilesCount = await dbHelper.getRecentFilesCount();

      final storageService = StorageService();
      final appDir = await storageService.createMegaPDFDirectory();

      int totalFiles = 0;
      int totalSize = 0;

      if (appDir != null && await appDir.exists()) {
        await for (final entity in appDir.list(recursive: true)) {
          if (entity is File) {
            totalFiles++;
            try {
              totalSize += await entity.length();
            } catch (e) {
              // Skip files that can't be read
            }
          }
        }
      }

      return StorageInfo(
        totalFiles: totalFiles,
        totalSize: totalSize,
        recentFilesCount: recentFilesCount,
        appDirectory: appDir?.path ?? '',
      );
    } catch (e) {
      return StorageInfo(
        totalFiles: 0,
        totalSize: 0,
        recentFilesCount: 0,
        appDirectory: '',
      );
    }
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);

      state = state.copyWith(themeMode: mode);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update theme: $e');
    }
  }

  Future<void> updateAutoDeleteDays(int days) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_autoDeleteKey, days);

      state = state.copyWith(autoDeleteDays: days);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update auto-delete setting: $e');
    }
  }

  Future<void> updateDefaultQuality(int quality) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_defaultQualityKey, quality);

      state = state.copyWith(defaultQuality: quality);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update default quality: $e');
    }
  }

  Future<void> updateFileNamingPattern(String pattern) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fileNamingKey, pattern);

      state = state.copyWith(fileNamingPattern: pattern);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update file naming pattern: $e');
    }
  }

  Future<void> updateShowFilePreview(bool show) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_showPreviewKey, show);

      state = state.copyWith(showFilePreview: show);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update preview setting: $e');
    }
  }

  Future<void> updateAutoSaveResults(bool autoSave) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoSaveKey, autoSave);

      state = state.copyWith(autoSaveResults: autoSave);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update auto-save setting: $e');
    }
  }

  Future<void> updateAnalyticsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_analyticsKey, enabled);

      state = state.copyWith(analyticsEnabled: enabled);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update analytics setting: $e');
    }
  }

  Future<void> clearAppData() async {
    try {
      state = state.copyWith(isLoading: true);

      // Clear recent files database
      final dbHelper = DatabaseHelper();
      await dbHelper.clearAllData();

      // Clear app files
      final storageService = StorageService();
      final appDir = await storageService.createMegaPDFDirectory();

      if (appDir != null && await appDir.exists()) {
        await for (final entity in appDir.list()) {
          try {
            if (entity is File) {
              await entity.delete();
            } else if (entity is Directory) {
              await entity.delete(recursive: true);
            }
          } catch (e) {
            // Continue deleting other files
          }
        }
      }

      // Refresh storage info
      final storageInfo = await _getStorageInfo();

      state = state.copyWith(
        isLoading: false,
        storageInfo: storageInfo,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to clear app data: $e',
      );
    }
  }

  Future<void> clearRecentFiles() async {
    try {
      state = state.copyWith(isLoading: true);

      final dbHelper = DatabaseHelper();
      await dbHelper.clearRecentFiles();

      // Refresh storage info
      final storageInfo = await _getStorageInfo();

      state = state.copyWith(
        isLoading: false,
        storageInfo: storageInfo,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to clear recent files: $e',
      );
    }
  }

  Future<void> refreshStorageInfo() async {
    try {
      final storageInfo = await _getStorageInfo();
      state = state.copyWith(storageInfo: storageInfo);
    } catch (e) {
      state = state.copyWith(error: 'Failed to refresh storage info: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class SettingsState {
  final bool isLoading;
  final String? error;
  final ThemeMode themeMode;
  final int autoDeleteDays;
  final int defaultQuality;
  final String fileNamingPattern;
  final bool showFilePreview;
  final bool autoSaveResults;
  final bool analyticsEnabled;
  final StorageInfo? storageInfo;

  const SettingsState({
    this.isLoading = true,
    this.error,
    this.themeMode = ThemeMode.system,
    this.autoDeleteDays = 30,
    this.defaultQuality = 90,
    this.fileNamingPattern = 'timestamp',
    this.showFilePreview = true,
    this.autoSaveResults = true,
    this.analyticsEnabled = true,
    this.storageInfo,
  });

  SettingsState copyWith({
    bool? isLoading,
    String? error,
    ThemeMode? themeMode,
    int? autoDeleteDays,
    int? defaultQuality,
    String? fileNamingPattern,
    bool? showFilePreview,
    bool? autoSaveResults,
    bool? analyticsEnabled,
    StorageInfo? storageInfo,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      themeMode: themeMode ?? this.themeMode,
      autoDeleteDays: autoDeleteDays ?? this.autoDeleteDays,
      defaultQuality: defaultQuality ?? this.defaultQuality,
      fileNamingPattern: fileNamingPattern ?? this.fileNamingPattern,
      showFilePreview: showFilePreview ?? this.showFilePreview,
      autoSaveResults: autoSaveResults ?? this.autoSaveResults,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      storageInfo: storageInfo ?? this.storageInfo,
    );
  }

  bool get hasError => error != null;

  String get themeModeDisplayName {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  String get fileNamingDisplayName {
    switch (fileNamingPattern) {
      case 'timestamp':
        return 'Add timestamp';
      case 'original':
        return 'Keep original';
      case 'operation':
        return 'Add operation name';
      default:
        return fileNamingPattern;
    }
  }

  String get autoDeleteDisplayName {
    if (autoDeleteDays == 0) {
      return 'Never';
    } else if (autoDeleteDays == 1) {
      return '1 day';
    } else {
      return '$autoDeleteDays days';
    }
  }
}

class StorageInfo {
  final int totalFiles;
  final int totalSize;
  final int recentFilesCount;
  final String appDirectory;

  const StorageInfo({
    required this.totalFiles,
    required this.totalSize,
    required this.recentFilesCount,
    required this.appDirectory,
  });

  String get formattedSize {
    if (totalSize < 1024) {
      return '${totalSize} B';
    } else if (totalSize < 1024 * 1024) {
      return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    } else if (totalSize < 1024 * 1024 * 1024) {
      return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
