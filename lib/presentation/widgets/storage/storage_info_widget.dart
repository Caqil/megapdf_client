// lib/presentation/widgets/storage/storage_info_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/data/services/storage_service.dart';
import 'package:path/path.dart' as path;
import '../../../core/theme/app_colors.dart';
import '../../../presentation/providers/file_path_provider.dart';

class StorageInfoWidget extends ConsumerWidget {
  final VoidCallback? onOpenFolder;

  const StorageInfoWidget({Key? key, this.onOpenFolder}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directoryPathAsync = ref.watch(megaPdfDirectoryPathProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: directoryPathAsync.when(
        data: (directoryPath) => _buildStorageInfo(context, directoryPath),
        loading: () => const Center(
          child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (error, stack) => Text(
          'Error loading storage info: ${error.toString()}',
          style: TextStyle(color: AppColors.error(context)),
        ),
      ),
    );
  }

  Widget _buildStorageInfo(BuildContext context, String? directoryPath) {
    if (directoryPath == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Storage Access',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'MegaPDF needs storage permission to save files.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              // Request permissions
              final storageService = StorageService();
              await storageService.requestPermissions(context);
            },
            child: const Text('Grant Permission'),
          ),
        ],
      );
    }

    // Get directory name for display
    String displayPath = directoryPath;
    if (Platform.isAndroid && directoryPath.contains('/storage/emulated/0')) {
      displayPath =
          directoryPath.replaceFirst('/storage/emulated/0', 'Internal Storage');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.folder_special,
              color: AppColors.primary(context),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Files saved to:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.background(context),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayPath,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.folder_open,
                  color: AppColors.primary(context),
                  size: 20,
                ),
                onPressed: onOpenFolder,
                tooltip: 'Open folder',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStorageStat(
              context,
              'PDF Files',
              _countFilesWithExtension(directoryPath, '.pdf').toString(),
              Icons.picture_as_pdf,
              AppColors.compressColor(context),
            ),
            _buildStorageStat(
              context,
              'All Files',
              _countAllFiles(directoryPath).toString(),
              Icons.insert_drive_file,
              AppColors.secondaryLight(context),
            ),
            _buildStorageStat(
              context,
              'Folders',
              _countFolders(directoryPath).toString(),
              Icons.folder,
              AppColors.warning(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStorageStat(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  // Helper methods to count files - these would be better implemented with a real file cache
  int _countFilesWithExtension(String directoryPath, String extension) {
    try {
      final directory = Directory(directoryPath);
      if (!directory.existsSync()) return 0;

      int count = 0;
      final entities = directory.listSync(recursive: true);

      for (var entity in entities) {
        if (entity is File &&
            path.extension(entity.path).toLowerCase() == extension) {
          count++;
        }
      }

      return count;
    } catch (e) {
      print('Error counting files: $e');
      return 0;
    }
  }

  int _countAllFiles(String directoryPath) {
    try {
      final directory = Directory(directoryPath);
      if (!directory.existsSync()) return 0;

      int count = 0;
      final entities = directory.listSync(recursive: true);

      for (var entity in entities) {
        if (entity is File) {
          count++;
        }
      }

      return count;
    } catch (e) {
      print('Error counting files: $e');
      return 0;
    }
  }

  int _countFolders(String directoryPath) {
    try {
      final directory = Directory(directoryPath);
      if (!directory.existsSync()) return 0;

      int count = 0;
      final entities = directory.listSync(recursive: true);

      for (var entity in entities) {
        if (entity is Directory) {
          count++;
        }
      }

      // Exclude the root directory itself
      return count > 0 ? count - 1 : 0;
    } catch (e) {
      print('Error counting folders: $e');
      return 0;
    }
  }
}
