// lib/core/utils/storage_manager.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/services/storage_service.dart';

part 'storage_manager.g.dart';

@riverpod
StorageManager storageManager(Ref ref) {
  final storageService = ref.watch(storageServiceProvider);
  return StorageManager(storageService);
}

class StorageManager {
  final StorageService _storageService;

  StorageManager(this._storageService);

  /// Save a processed PDF file to the appropriate subfolder
  Future<String> saveProcessedFile({
    required String sourceFilePath,
    required String fileName,
    String? customFileName,
    String? subfolder,
  }) async {
    try {
      // Make sure permissions are granted
      final hasPermission = await _storageService.checkPermissions();
      if (!hasPermission) {
        debugPrint('Storage permissions not granted');
        return '';
      }

      // Use the custom file name if provided, otherwise use original name
      final finalFileName = customFileName ?? fileName;

      // Save the file to the specified subfolder
      final savedPath = await _storageService.saveFile(
        sourceFilePath: sourceFilePath,
        fileName: finalFileName,
        subfolder: subfolder,
        addTimestamp: true,
      );

      if (savedPath != null) {
        debugPrint('File saved successfully at: $savedPath');
        return savedPath;
      } else {
        debugPrint('Failed to save file');
        return '';
      }
    } catch (e) {
      debugPrint('Error saving processed file: $e');
      return '';
    }
  }

  /// Get all saved PDF files from a specific subfolder
  Future<List<File>> getSavedFiles({String? subfolder}) async {
    return await _storageService.getPdfFiles(subfolder: subfolder);
  }

  /// Get the storage path for MegaPDF
  Future<String?> getMegaPDFPath() async {
    return await _storageService.getMegaPDFPath();
  }

  /// Request storage permissions if needed
  Future<bool> requestPermissions(BuildContext context) async {
    return await _storageService.requestPermissions(context);
  }

  /// Check if storage permissions are granted
  Future<bool> hasPermissions() async {
    return await _storageService.checkPermissions();
  }

  /// Delete a file
  Future<bool> deleteFile(String filePath) async {
    return await _storageService.deleteFile(filePath);
  }

  /// Share a file
  Future<void> shareFile(String filePath,
      {String? subject, String? text}) async {
    await _storageService.shareFile(filePath, subject: subject, text: text);
  }

  /// Check if a file exists
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get formatted file size
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get file size
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      final stat = await file.stat();
      return stat.size;
    } catch (e) {
      return 0;
    }
  }
}
