// lib/data/models/recent_file_model.dart
import 'package:equatable/equatable.dart';

class RecentFileModel extends Equatable {
  final int? id;
  final String originalFileName;
  final String resultFileName;
  final String operation;
  final String operationType; // compress, merge, split, etc.
  final String originalFilePath;
  final String? resultFilePath;
  final String originalSize;
  final String? resultSize;
  final DateTime processedAt;
  final Map<String, dynamic>? metadata; // Additional data as JSON

  const RecentFileModel({
    this.id,
    required this.originalFileName,
    required this.resultFileName,
    required this.operation,
    required this.operationType,
    required this.originalFilePath,
    this.resultFilePath,
    required this.originalSize,
    this.resultSize,
    required this.processedAt,
    this.metadata,
  });

  factory RecentFileModel.fromMap(Map<String, dynamic> map) {
    return RecentFileModel(
      id: map['id'],
      originalFileName: map['original_file_name'],
      resultFileName: map['result_file_name'],
      operation: map['operation'],
      operationType: map['operation_type'],
      originalFilePath: map['original_file_path'],
      resultFilePath: map['result_file_path'],
      originalSize: map['original_size'],
      resultSize: map['result_size'],
      processedAt: DateTime.fromMillisecondsSinceEpoch(map['processed_at']),
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'original_file_name': originalFileName,
      'result_file_name': resultFileName,
      'operation': operation,
      'operation_type': operationType,
      'original_file_path': originalFilePath,
      'result_file_path': resultFilePath,
      'original_size': originalSize,
      'result_size': resultSize,
      'processed_at': processedAt.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(processedAt);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Yesterday';
      if (difference.inDays < 7) return '${difference.inDays} days ago';
      return '${processedAt.day}/${processedAt.month}/${processedAt.year}';
    }

    if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    }

    if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    }

    return 'Just now';
  }

  @override
  List<Object?> get props => [
        id,
        originalFileName,
        resultFileName,
        operation,
        operationType,
        originalFilePath,
        resultFilePath,
        originalSize,
        resultSize,
        processedAt,
        metadata
      ];
}
