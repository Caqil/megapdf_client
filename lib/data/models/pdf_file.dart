// lib/data/models/pdf_file.dart
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as path;

class PdfFile extends Equatable {
  final File file;
  final String name;
  final int sizeInBytes;
  final DateTime lastModified;

  const PdfFile({
    required this.file,
    required this.name,
    required this.sizeInBytes,
    required this.lastModified,
  });

  factory PdfFile.fromFile(File file) {
    final stat = file.statSync();
    return PdfFile(
      file: file,
      name: path.basename(file.path),
      sizeInBytes: stat.size,
      lastModified: stat.modified,
    );
  }

  // Convenience getters
  String get extension => path.extension(name).toLowerCase();
  bool get isPdf => extension == '.pdf';

  String get formattedSize {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024)
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(lastModified);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${lastModified.day}/${lastModified.month}/${lastModified.year}';
    }
  }

  @override
  List<Object?> get props => [file.path, name, sizeInBytes, lastModified];
}
