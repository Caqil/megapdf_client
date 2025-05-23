// lib/presentation/providers/file_operation_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_operation_notifier.g.dart';

@riverpod
class FileOperationNotifier extends _$FileOperationNotifier {
  @override
  int build() {
    return 0;
  }

  // Call this method whenever a file operation is completed and saved
  void notifyFileOperationCompleted() {
    state = state + 1; // Increment to trigger listeners
  }
}

// Provider to listen for file operation changes
@riverpod
Stream<int> fileOperationStream(Ref ref) async* {
  yield* Stream.periodic(const Duration(milliseconds: 500), (count) {
    return ref.watch(fileOperationNotifierProvider);
  });
}
