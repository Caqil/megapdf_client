// lib/presentation/providers/file_path_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/data/services/storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'file_path_provider.g.dart';

/// Provides the path to the MegaPDF directory
@riverpod
Future<String?> megaPdfDirectoryPath(Ref ref) async {
  final storageService = ref.watch(storageServiceProvider);
  return await storageService.getMegaPDFPath();
}

/// Provides a state notifier to track file save operations
@riverpod
class FileSaveNotifier extends _$FileSaveNotifier {
  @override
  FileSaveState build() {
    return const FileSaveState();
  }
  
  /// Notifies that a file was saved
  void fileSaved(String path, String type) {
    state = FileSaveState(
      lastSavedFilePath: path,
      lastSavedType: type,
      lastSavedTime: DateTime.now(),
    );
  }
  
  /// Clear the last saved file state
  void clearState() {
    state = const FileSaveState();
  }
}

/// State class for tracking file save operations
class FileSaveState {
  final String? lastSavedFilePath;
  final String? lastSavedType;
  final DateTime? lastSavedTime;
  
  const FileSaveState({
    this.lastSavedFilePath,
    this.lastSavedType,
    this.lastSavedTime,
  });
  
  bool get hasLastSaved => lastSavedFilePath != null;
  
  String get timeAgo {
    if (lastSavedTime == null) return '';
    
    final difference = DateTime.now().difference(lastSavedTime!);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
  }
}