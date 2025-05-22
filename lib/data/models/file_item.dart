import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p; // Import the path package with an alias

import '../../core/utils/file_utils.dart';

class FileItem extends Equatable {
  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final DateTime lastModified;
  final String? extension;
  final int? folderId; // Add this to link to database folder

  const FileItem({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    required this.lastModified,
    this.extension,
    this.folderId,
  });

  factory FileItem.fromFile(File file) {
    final stat = file.statSync();
    return FileItem(
      name: p.basename(file.path), // Use p.basename from the path package
      path: file.path,
      isDirectory: false,
      size: stat.size,
      lastModified: stat.modified,
      extension: p.extension(file.path).toLowerCase(), // Use p.extension
    );
  }

  factory FileItem.fromDirectory(Directory directory) {
    final stat = directory.statSync();
    return FileItem(
      name: p.basename(directory.path), // Use p.basename
      path: directory.path,
      isDirectory: true,
      size: 0,
      lastModified: stat.modified,
    );
  }

  // Convenience getters
  String get formattedSize {
    if (isDirectory) return '';
    return FileUtils.formatFileSize(size);
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(lastModified);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${lastModified.day}/${lastModified.month}/${lastModified.year}';
    }
  }

  bool get isPdf => extension == '.pdf';
  bool get isImage => FileUtils.isImage(path);
  bool get isDocument => FileUtils.isDocument(path);

  IconData get icon {
    if (isDirectory) return Icons.folder;

    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.xls':
      case '.xlsx':
        return Icons.table_chart;
      case '.ppt':
      case '.pptx':
        return Icons.slideshow;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.bmp':
        return Icons.image;
      case '.zip':
      case '.rar':
      case '.7z':
        return Icons.archive;
      case '.txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color get iconColor {
    if (isDirectory) return Colors.blue;

    switch (extension) {
      case '.pdf':
        return Colors.red;
      case '.doc':
      case '.docx':
        return Colors.blue;
      case '.xls':
      case '.xlsx':
        return Colors.green;
      case '.ppt':
      case '.pptx':
        return Colors.orange;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.bmp':
        return Colors.purple;
      case '.zip':
      case '.rar':
      case '.7z':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  @override
  List<Object?> get props => [path, name, isDirectory, size, lastModified];
}
