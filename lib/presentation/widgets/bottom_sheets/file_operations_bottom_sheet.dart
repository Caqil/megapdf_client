// lib/presentation/widgets/bottom_sheets/file_operations_bottom_sheet.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/data/database/database_helper.dart';
import 'package:megapdf_client/presentation/providers/recent_files_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/recent_file_model.dart';
import '../common/custom_snackbar.dart';

class FileOperationsBottomSheet extends ConsumerStatefulWidget {
  final RecentFileModel file;

  const FileOperationsBottomSheet({
    super.key,
    required this.file,
  });

  @override
  ConsumerState<FileOperationsBottomSheet> createState() =>
      _FileOperationsBottomSheetState();
}

class _FileOperationsBottomSheetState
    extends ConsumerState<FileOperationsBottomSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background(context),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      // File info header
                      _buildFileHeader(),

                      // Quick actions
                      _buildQuickActions(),

                      // File operations
                      _buildFileOperations(),

                      // PDF tools
                      if (_isPdf) _buildPdfTools(),

                      // Bottom padding for safe area
                      SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // File icon and basic info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getOperationColor(widget.file.operationType)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getFileIcon(),
                  size: 28,
                  color: _getOperationColor(widget.file.operationType),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.file.originalFileName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(context),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getOperationColor(widget.file.operationType)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.file.operation,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  _getOperationColor(widget.file.operationType),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // File details
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Column(
              children: [
                _buildDetailRow('Size', _getFileSize()),
                const SizedBox(height: 8),
                _buildDetailRow('Modified', widget.file.timeAgo),
                const SizedBox(height: 8),
                _buildDetailRow('Operation', widget.file.operation),
                if (widget.file.resultFilePath != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('Status', 'Downloaded', Icons.check_circle,
                      AppColors.success(context)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      [IconData? icon, Color? iconColor]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary(context),
              ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
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
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary(context),
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.open_in_new,
              label: 'Open',
              color: AppColors.primary(context),
              onTap: _openFile,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.share,
              label: 'Share',
              color: AppColors.secondary(context),
              onTap: _shareFile,
            ),
          ),
          const SizedBox(width: 8),
         
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileOperations() {
    return Column(
      children: [
        const SizedBox(height: 7),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'File Operations',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
          ),
        ),
        const SizedBox(height: 8),
        _buildOperationTile(
          icon: Icons.info_outline,
          title: 'File Information',
          subtitle: 'View detailed file properties',
          color: AppColors.info(context),
          onTap: _showFileInfo,
        ),
        _buildOperationTile(
          icon: Icons.folder_open,
          title: 'Show in Folder',
          subtitle: 'Open file location',
          color: AppColors.primary(context),
          onTap: _showInFolder,
          enabled: widget.file.resultFilePath != null,
        ),
        _buildOperationTile(
          icon: Icons.copy,
          title: 'Duplicate',
          subtitle: 'Make a copy of this file',
          color: AppColors.secondary(context),
          onTap: _duplicateFile,
          enabled: widget.file.resultFilePath != null,
        ),
        _buildOperationTile(
          icon: Icons.delete_outline,
          title: 'Delete',
          subtitle: 'Remove file from device',
          color: AppColors.error(context),
          onTap: _deleteFile,
          enabled: widget.file.resultFilePath != null,
        ),
      ],
    );
  }

  Widget _buildPdfTools() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'PDF Tools',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.9,
            children: [
              _buildPdfToolButton(
                icon: Icons.compress,
                label: 'Compress',
                color: AppColors.compressColor(context),
                route: '/compress',
              ),
              _buildPdfToolButton(
                icon: Icons.call_split,
                label: 'Split',
                color: AppColors.splitColor(context),
                route: '/split',
              ),
              _buildPdfToolButton(
                icon: Icons.branding_watermark,
                label: 'Watermark',
                color: AppColors.watermarkColor(context),
                route: '/watermark',
              ),
              _buildPdfToolButton(
                icon: Icons.transform,
                label: 'Convert',
                color: AppColors.convertColor(context),
                route: '/convert',
              ),
              _buildPdfToolButton(
                icon: Icons.lock,
                label: 'Protect',
                color: AppColors.protectColor(context),
                route: '/protect',
              ),
              _buildPdfToolButton(
                icon: Icons.rotate_right,
                label: 'Rotate',
                color: AppColors.rotateColor(context),
                route: '/rotate',
              ),
              _buildPdfToolButton(
                icon: Icons.format_list_numbered,
                label: 'Numbers',
                color: AppColors.pageNumbersColor(context),
                route: '/page-numbers',
              ),
              _buildPdfToolButton(
                icon: Icons.merge,
                label: 'Merge',
                color: AppColors.mergeColor(context),
                route: '/merge',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOperationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return ListTile(
      enabled: enabled && !_isLoading,
      onTap: enabled ? onTap : null,
      leading: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: (enabled ? color : AppColors.textSecondary(context))
              .withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: enabled ? color : AppColors.textSecondary(context),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: enabled
                  ? AppColors.textPrimary(context)
                  : AppColors.textSecondary(context),
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary(context),
            ),
      ),
      trailing: enabled
          ? Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary(context),
              size: 20,
            )
          : null,
    );
  }

  Widget _buildPdfToolButton({
    required IconData icon,
    required String label,
    required Color color,
    required String route,
  }) {
    final enabled = widget.file.resultFilePath != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled
            ? () {
                if (mounted) {
                  Navigator.pop(context);
                  context.go(route);
                }
              }
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: (enabled ? color : AppColors.textSecondary(context))
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (enabled ? color : AppColors.textSecondary(context))
                  .withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: enabled ? color : AppColors.textSecondary(context),
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: enabled ? color : AppColors.textSecondary(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Action methods with proper mounted checks
  Future<void> _openFile() async {
    if (widget.file.resultFilePath == null) {
      _showSnackBar('File not available on device', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await OpenFile.open(widget.file.resultFilePath!);
      if (mounted) {
        if (result.type != ResultType.done) {
          _showSnackBar('Could not open file: ${result.message}',
              isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error opening file: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _shareFile() async {
    if (widget.file.resultFilePath == null) {
      _showSnackBar('File not available for sharing', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Share.shareXFiles([XFile(widget.file.resultFilePath!)],
          text: 'Sharing ${widget.file.originalFileName}');
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error sharing file: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showFileInfo() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => _FileInfoDialog(file: widget.file),
      );
    }
  }

  void _showInFolder() {
    _showSnackBar('Show in folder - Coming soon!');
  }

  void _duplicateFile() {
    _showSnackBar('Duplicate file - Coming soon!');
  }

  void _deleteFile() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: AppColors.error(dialogContext),
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text('Delete File'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${widget.file.originalFileName}"?',
              style: Theme.of(dialogContext).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error(dialogContext).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.error(dialogContext).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.error(dialogContext),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. The file will be permanently removed from your device.',
                      style:
                          Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                                color: AppColors.error(dialogContext),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => _performDelete(dialogContext),
            icon: const Icon(Icons.delete_forever, size: 18),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error(dialogContext),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(BuildContext dialogContext) async {
    // Close the confirmation dialog
    Navigator.pop(dialogContext);

    // Close the bottom sheet if still mounted
    if (mounted) {
      Navigator.pop(context);
    }

    // Show loading dialog with proper context management
    BuildContext? loadingContext;
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          loadingContext = context;
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Deleting file...'),
              ],
            ),
          );
        },
      );
    }

    try {
      bool fileDeleted = false;
      bool databaseUpdated = false;

      if (widget.file.resultFilePath != null) {
        final file = File(widget.file.resultFilePath!);
        if (await file.exists()) {
          await file.delete();
          fileDeleted = true;
          print('Physical file deleted: ${widget.file.resultFilePath}');
        }
      }

      try {
        final dbHelper = DatabaseHelper();

        await dbHelper.database.then((db) async {
          await db.delete(
            'recent_files',
            where: 'id = ?',
            whereArgs: [widget.file.id],
          );
        });

        databaseUpdated = true;
        print('Database records removed');
      } catch (e) {
        print('Warning: Could not update database: $e');
      }

      // Close loading dialog if still mounted
      if (loadingContext != null && mounted) {
        Navigator.pop(loadingContext!);
      }

      if (mounted) {
        ref.read(recentFilesNotifierProvider.notifier).refreshRecentFiles();

        _showSnackBar(
          fileDeleted
              ? 'File deleted successfully'
              : 'File record removed (file was already deleted)',
        );
      }
    } catch (e) {
      // Close loading dialog if still mounted
      if (loadingContext != null && mounted) {
        Navigator.pop(loadingContext!);
      }

      if (mounted) {
        _showSnackBar('Failed to delete file: $e', isError: true);
      }
      print('Error during file deletion: $e');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    CustomSnackbar.show(
      context: context,
      message: message,
      type: isError ? SnackbarType.failure : SnackbarType.info,
      duration: const Duration(seconds: 4),
    );
  }

  // Helper methods
  bool get _isPdf =>
      widget.file.originalFileName.toLowerCase().endsWith('.pdf');

  String _getFileSize() {
    if (widget.file.resultSize != null) {
      return widget.file.resultSize!;
    }
    return widget.file.originalSize;
  }

  IconData _getFileIcon() {
    if (_isPdf) return Icons.picture_as_pdf;
    return Icons.insert_drive_file;
  }

  Color _getOperationColor(String operationType) {
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
}

// File info dialog with mounted checks
class _FileInfoDialog extends StatelessWidget {
  final RecentFileModel file;

  const _FileInfoDialog({required this.file});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('File Information'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Name', file.originalFileName),
            _buildInfoRow('Operation', file.operation),
            _buildInfoRow('Type', file.operationType.toUpperCase()),
            _buildInfoRow('Original Size', file.originalSize),
            if (file.resultSize != null)
              _buildInfoRow('Result Size', file.resultSize!),
            _buildInfoRow('Processed', file.timeAgo),
            if (file.resultFilePath != null)
              _buildInfoRow('Location', file.resultFilePath!),
            if (file.metadata != null) ...[
              const SizedBox(height: 8),
              Text(
                'Metadata:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ...file.metadata!.entries.map(
                  (entry) => _buildInfoRow(entry.key, entry.value.toString())),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
