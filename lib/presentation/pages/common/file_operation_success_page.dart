// lib/presentation/pages/common/file_operation_success_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as path;

import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../pdf_viewer/pdf_viewer_page.dart';
import '../storage/storage_browser_page.dart';

class FileOperationSuccessPage extends ConsumerWidget {
  final String filePath;
  final String operationType;
  final String operationName;
  final Map<String, dynamic>? details;

  const FileOperationSuccessPage({
    Key? key,
    required this.filePath,
    required this.operationType,
    required this.operationName,
    this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = File(filePath);
    final fileName = path.basename(filePath);
    final directory = path.dirname(filePath);
    final fileExists = file.existsSync();

    // Calculate file size if file exists
    int fileSize = 0;
    if (fileExists) {
      try {
        fileSize = file.lengthSync();
      } catch (e) {
        print('Error getting file size: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$operationName Complete'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Success animation
            Container(
              height: 200,
              alignment: Alignment.center,
              child: Lottie.asset(
                'assets/animations/success.json',
                repeat: false,
                height: 180,
              ),
            ),

            const SizedBox(height: 24),

            // Success message
            Text(
              'File Successfully Processed!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success(context),
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'Your file has been $operationName and saved to your device.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 36),

            // File info card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getOperationColor(context).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getOperationIcon(),
                            color: _getOperationColor(context),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (fileExists)
                                Text(
                                  _formatFileSize(fileSize),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary(context),
                                      ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // File details
                    _buildInfoRow(
                      context,
                      'Operation',
                      operationName,
                      Icons.check_circle,
                      AppColors.success(context),
                    ),

                    if (fileExists)
                      _buildInfoRow(
                        context,
                        'Location',
                        _formatDirectory(directory),
                        Icons.folder,
                        AppColors.warning(context),
                      ),

                    // Additional details
                    if (details != null) ...[
                      const Divider(),
                      ...details!.entries.map((entry) {
                        return _buildInfoRow(
                          context,
                          entry.key,
                          entry.value.toString(),
                          null,
                          null,
                        );
                      }).toList(),
                    ],

                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openFile(context),
                            icon: const Icon(Icons.visibility),
                            label: const Text('View'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _shareFile(context),
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Next action buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _viewInStorage(context),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('View in Storage'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.surface(context),
                    foregroundColor: AppColors.primary(context),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _processAnotherFile(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Process Another File'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.primary(context),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home),
                  label: const Text('Go to Home'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData? icon,
    Color? iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: iconColor ?? AppColors.textSecondary(context),
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFile(BuildContext context) {
    final file = File(filePath);
    if (!file.existsSync()) {
      CustomSnackbar.show(
        context: context,
        message: 'File not found.',
        type: SnackbarType.failure,
        duration: const Duration(seconds: 4),
      );

      return;
    }

    final extension = path.extension(filePath).toLowerCase();

    if (extension == '.pdf') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(
            filePath: filePath,
            fileName: path.basename(filePath),
          ),
        ),
      );
    } else {
      OpenFile.open(filePath);
    }
  }

  void _shareFile(BuildContext context) {
    final file = File(filePath);
    if (!file.existsSync()) {
      CustomSnackbar.show(
        context: context,
        message: 'File not found.',
        type: SnackbarType.failure,
        duration: const Duration(seconds: 4),
      );
     
      return;
    }

    Share.shareXFiles([XFile(filePath)]);
  }

  void _viewInStorage(BuildContext context) {
    final directory = path.dirname(filePath);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StorageBrowserPage(initialPath: directory),
      ),
    );
  }

  void _processAnotherFile(BuildContext context) {
    // Navigate to the appropriate tool page based on operation type
    switch (operationType) {
      case 'compress':
        context.go('/compress');
        break;
      case 'split':
        context.go('/split');
        break;
      case 'merge':
        context.go('/merge');
        break;
      case 'watermark':
        context.go('/watermark');
        break;
      case 'convert':
        context.go('/convert');
        break;
      case 'protect':
        context.go('/protect');
        break;
      case 'unlock':
        context.go('/unlock');
        break;
      case 'rotate':
        context.go('/rotate');
        break;
      case 'page_numbers':
        context.go('/page-numbers');
        break;
      default:
        context.go('/tools');
        break;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDirectory(String directory) {
    if (directory.contains('/storage/emulated/0')) {
      return directory.replaceFirst('/storage/emulated/0', 'Internal Storage');
    }
    return directory;
  }

  Color _getOperationColor(BuildContext context) {
    switch (operationType) {
      case 'compress':
        return AppColors.compressColor(context);
      case 'merge':
        return AppColors.mergeColor(context);
      case 'split':
        return AppColors.splitColor(context);
      case 'convert':
        return AppColors.convertColor(context);
      case 'protect':
        return AppColors.protectColor(context);
      case 'unlock':
        return AppColors.unlockColor(context);
      case 'rotate':
        return AppColors.rotateColor(context);
      case 'watermark':
        return AppColors.watermarkColor(context);
      case 'page_numbers':
        return AppColors.pageNumbersColor(context);
      default:
        return AppColors.primary(context);
    }
  }

  IconData _getOperationIcon() {
    switch (operationType) {
      case 'compress':
        return Icons.compress;
      case 'merge':
        return Icons.merge;
      case 'split':
        return Icons.call_split;
      case 'convert':
        return Icons.transform;
      case 'protect':
        return Icons.lock;
      case 'unlock':
        return Icons.lock_open;
      case 'rotate':
        return Icons.rotate_right;
      case 'watermark':
        return Icons.branding_watermark;
      case 'page_numbers':
        return Icons.format_list_numbered;
      default:
        return Icons.description;
    }
  }
}
