import 'dart:convert';

import 'package:equatable/equatable.dart';

class RecentFileModel extends Equatable {
  final int? id;
  final String originalFileName;
  final String resultFileName;
  final String operation;
  final String operationType;
  final String originalFilePath;
  final String? resultFilePath;
  final String originalSize;
  final String? resultSize;
  final DateTime processedAt;
  final Map<String, dynamic>? metadata;

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
    try {
      print('🔧 MODEL: Attempting to parse RecentFileModel');
      print('🔧 MODEL: Input map keys: ${map.keys.toList()}');
      print('🔧 MODEL: Input map: $map');

      // Safe parsing with defaults and validation
      final id = map['id'] as int?;

      final originalFileName =
          map['original_file_name']?.toString() ?? 'Unknown File';
      final resultFileName =
          map['result_file_name']?.toString() ?? 'Unknown Result';
      final operation = map['operation']?.toString() ?? 'Unknown Operation';
      final operationType = map['operation_type']?.toString() ?? 'unknown';
      final originalFilePath = map['original_file_path']?.toString() ?? '';
      final resultFilePath = map['result_file_path']?.toString();
      final originalSize = map['original_size']?.toString() ?? 'Unknown Size';
      final resultSize = map['result_size']?.toString();

      // Safe DateTime parsing
      DateTime processedAt;
      final processedAtValue = map['processed_at'];
      if (processedAtValue is int) {
        processedAt = DateTime.fromMillisecondsSinceEpoch(processedAtValue);
      } else if (processedAtValue is String) {
        // Try to parse as int string
        final intValue = int.tryParse(processedAtValue);
        if (intValue != null) {
          processedAt = DateTime.fromMillisecondsSinceEpoch(intValue);
        } else {
          // Try to parse as ISO string
          processedAt = DateTime.tryParse(processedAtValue) ?? DateTime.now();
        }
      } else {
        print(
            '🔧 MODEL: Invalid processed_at value: $processedAtValue, using current time');
        processedAt = DateTime.now();
      }

      // Safe metadata parsing
      Map<String, dynamic>? metadata;
      final metadataValue = map['metadata'];
      if (metadataValue != null) {
        if (metadataValue is Map<String, dynamic>) {
          metadata = metadataValue;
        } else if (metadataValue is String && metadataValue.isNotEmpty) {
          try {
            final decoded = jsonDecode(metadataValue);
            if (decoded is Map<String, dynamic>) {
              metadata = decoded;
            }
          } catch (e) {
            print('🔧 MODEL: Failed to parse metadata JSON: $e');
            metadata = null;
          }
        }
      }

      final model = RecentFileModel(
        id: id,
        originalFileName: originalFileName,
        resultFileName: resultFileName,
        operation: operation,
        operationType: operationType,
        originalFilePath: originalFilePath,
        resultFilePath: resultFilePath,
        originalSize: originalSize,
        resultSize: resultSize,
        processedAt: processedAt,
        metadata: metadata,
      );

      print(
          '🔧 MODEL: Successfully created RecentFileModel: ${model.originalFileName}');
      return model;
    } catch (e, stackTrace) {
      print('🔧 MODEL: Error creating RecentFileModel: $e');
      print('🔧 MODEL: Stack trace: $stackTrace');
      print('🔧 MODEL: Input map: $map');

      // Return a safe default model instead of crashing
      return RecentFileModel(
        id: map['id'] as int?,
        originalFileName: 'Error parsing file',
        resultFileName: 'Error',
        operation: 'Error',
        operationType: 'error',
        originalFilePath: '',
        originalSize: '0 B',
        processedAt: DateTime.now(),
        metadata: {'error': e.toString()},
      );
    }
  }

  Map<String, dynamic> toMap() {
    final map = {
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

    print('🔧 MODEL: toMap created: $map');
    return map;
  }

  String get timeAgo {
    try {
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
    } catch (e) {
      print('🔧 MODEL: Error calculating timeAgo: $e');
      return 'Unknown time';
    }
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
