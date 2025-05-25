// lib/presentation/pages/home/widgets/quick_access_tab.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import 'package:megapdf_client/core/theme/app_colors.dart';
import 'package:megapdf_client/core/utils/file_utils.dart';
import 'package:megapdf_client/data/repositories/recent_files_repository.dart';
import 'package:megapdf_client/presentation/pages/home/widgets/tips_section.dart';
import 'package:megapdf_client/presentation/providers/file_operation_notifier.dart';
import 'package:megapdf_client/presentation/providers/file_path_provider.dart';
import '../../../../data/services/recent_files_service.dart';
import '../../../providers/file_manager_provider.dart';
import '../../../widgets/common/custom_snackbar.dart';
import 'quick_action_card.dart';
import 'section_header.dart';
import 'feature_grid.dart';

class QuickAccessTab extends ConsumerWidget {
  const QuickAccessTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> _pickAndImportFile() async {
      try {
        // Show file picker
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        );

        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          if (file.path != null) {
            // Create a File object from the path
            final sourceFile = File(file.path!);
            final originalName = file.name;
            final originalSize = sourceFile.lengthSync();

            // Use addFile instead of importFile to get the destination path
            final savedPath = await ref
                .read(fileManagerNotifierProvider.notifier)
                .addFile(sourceFile);

            if (savedPath != null) {
              // Track in recent files
              final recentFilesService = ref.read(recentFilesServiceProvider);
              // Since there's no trackImport method, we'll use the repository directly
              final recentFilesRepository =
                  ref.read(recentFilesRepositoryProvider);
              await recentFilesRepository.addRecentFile(
                originalFileName: originalName,
                resultFileName: path.basename(savedPath),
                operation: 'Import File',
                operationType: 'import',
                originalFilePath: sourceFile.path,
                resultFilePath: savedPath,
                originalSize: FileUtils.formatFileSize(originalSize),
                resultSize: FileUtils.formatFileSize(
                    originalSize), // Same size for import
                metadata: {
                  'imported_at': DateTime.now().toIso8601String(),
                  'is_public_storage': true,
                },
              );

              // Notify file operation completed
              ref
                  .read(fileOperationNotifierProvider.notifier)
                  .notifyOperationCompleted('import');

              // Set as last operation
              ref.read(lastOperationNotifierProvider.notifier).setLastOperation(
                    type: 'import',
                    name: 'Imported File',
                    timestamp: DateTime.now(),
                    filePath: savedPath,
                  );

              // Notify file save system
              ref
                  .read(fileSaveNotifierProvider.notifier)
                  .fileSaved(savedPath, 'import');

              CustomSnackbar.show(
                context: context,
                message: 'File imported successfully',
                type: SnackbarType.success,
                duration: const Duration(seconds: 3),
              );
            }
          }
        }
      } catch (e) {
        CustomSnackbar.show(
          context: context,
          message: 'Failed to import file: $e',
          type: SnackbarType.failure,
          duration: const Duration(seconds: 3),
        );
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Quick Actions', icon: Icons.flash_on),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              QuickActionCard(
                title: 'Import File',
                icon: Icons.upload_file,
                color: AppColors.primary(context),
                onTap: () => _pickAndImportFile(),
              ),
              QuickActionCard(
                title: 'Scan to PDF',
                icon: Icons.document_scanner,
                color: AppColors.warning(context),
                onTap: () => context.push('/scanner'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const FeatureGrid(),
          const SizedBox(height: 24),
          const TipsSection(),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    CustomSnackbar.show(
      context: context,
      message: message,
      type: isError ? SnackbarType.failure : SnackbarType.success,
      duration: const Duration(seconds: 4),
    );
  }
}
