// lib/presentation/providers/file_operation_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_operation_notifier.g.dart';

/// A simple counter provider to notify about file operations
@riverpod
class FileOperationNotifier extends _$FileOperationNotifier {
  @override
  int build() {
    return 0;
  }

  /// Call this method whenever a file operation is completed and saved
  void notifyFileOperationCompleted() {
    state = state + 1; // Increment to trigger listeners
  }

  /// Notify about a specific operation type
  void notifyOperationCompleted(String operationType) {
    // Here we could add operation-specific logic if needed
    notifyFileOperationCompleted();
  }
}

/// Provider to listen for file operation changes
@riverpod
Stream<int> fileOperationStream(Ref ref) async* {
  yield* Stream.periodic(const Duration(milliseconds: 500), (count) {
    return ref.watch(fileOperationNotifierProvider);
  });
}

/// Provider for tracking the most recent file operation
@riverpod
class LastOperationNotifier extends _$LastOperationNotifier {
  @override
  FileOperationInfo build() {
    return const FileOperationInfo();
  }

  void setLastOperation({
    required String type,
    required String name,
    required DateTime timestamp,
    String? filePath,
  }) {
    state = FileOperationInfo(
      operationType: type,
      operationName: name,
      timestamp: timestamp,
      filePath: filePath,
    );

    // Also notify the general operation notifier
    ref
        .read(fileOperationNotifierProvider.notifier)
        .notifyOperationCompleted(type);
  }

  void clearLastOperation() {
    state = const FileOperationInfo();
  }
}

/// Data class for storing information about the last file operation
class FileOperationInfo {
  final String? operationType;
  final String? operationName;
  final DateTime? timestamp;
  final String? filePath;

  const FileOperationInfo({
    this.operationType,
    this.operationName,
    this.timestamp,
    this.filePath,
  });

  bool get hasOperation => operationType != null;

  String get timeAgo {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final difference = now.difference(timestamp!);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Yesterday';
      if (difference.inDays < 7) return '${difference.inDays} days ago';
      return '${timestamp!.day}/${timestamp!.month}/${timestamp!.year}';
    }

    if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    }

    if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    }

    return 'Just now';
  }
}
