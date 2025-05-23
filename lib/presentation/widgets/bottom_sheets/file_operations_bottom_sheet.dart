// lib/presentation/widgets/bottom_sheets/file_operations_bottom_sheet.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/recent_file_model.dart';
import '../../../data/models/folder_model.dart';
import '../../providers/file_manager_provider.dart';
import '../dialogs/folder_selection_dialog.dart';

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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // File info header
          _buildFileHeader(),

          // Quick actions
          _buildQuickActions(),

          // File operations
          _buildFileOperations(),

          // PDF tools
          if (_isPdf) _buildPdfTools(),

          // Bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildFileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // File icon and basic info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getOperationColor(widget.file.operationType)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getFileIcon(),
                  size: 32,
                  color: _getOperationColor(widget.file.operationType),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.file.originalFileName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
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

          const SizedBox(height: 16),

          // File details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
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
                      AppColors.success),
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
                color: AppColors.textSecondary,
              ),
        ),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: iconColor ?? AppColors.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.open_in_new,
              label: 'Open',
              color: AppColors.primary,
              onTap: _openFile,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.share,
              label: 'Share',
              color: AppColors.secondary,
              onTap: _shareFile,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.drive_file_move,
              label: 'Move',
              color: AppColors.warning,
              onTap: _moveToFolder,
            ),
          ),
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
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
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'File Operations',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildOperationTile(
          icon: Icons.info_outline,
          title: 'File Information',
          subtitle: 'View detailed file properties',
          color: AppColors.info,
          onTap: _showFileInfo,
        ),
        _buildOperationTile(
          icon: Icons.folder_open,
          title: 'Show in Folder',
          subtitle: 'Open file location',
          color: AppColors.primary,
          onTap: _showInFolder,
          enabled: widget.file.resultFilePath != null,
        ),
        _buildOperationTile(
          icon: Icons.copy,
          title: 'Duplicate',
          subtitle: 'Make a copy of this file',
          color: AppColors.secondary,
          onTap: _duplicateFile,
          enabled: widget.file.resultFilePath != null,
        ),
        _buildOperationTile(
          icon: Icons.delete_outline,
          title: 'Delete',
          subtitle: 'Remove file from device',
          color: AppColors.error,
          onTap: _deleteFile,
          enabled: widget.file.resultFilePath != null,
        ),
      ],
    );
  }

  Widget _buildPdfTools() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'PDF Tools',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // PDF operations grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
            children: [
              _buildPdfToolButton(
                icon: Icons.compress,
                label: 'Compress',
                color: AppColors.compressColor,
                route: '/compress',
              ),
              _buildPdfToolButton(
                icon: Icons.call_split,
                label: 'Split',
                color: AppColors.splitColor,
                route: '/split',
              ),
              _buildPdfToolButton(
                icon: Icons.branding_watermark,
                label: 'Watermark',
                color: AppColors.watermarkColor,
                route: '/watermark',
              ),
              _buildPdfToolButton(
                icon: Icons.transform,
                label: 'Convert',
                color: AppColors.convertColor,
                route: '/convert',
              ),
              _buildPdfToolButton(
                icon: Icons.lock,
                label: 'Protect',
                color: AppColors.protectColor,
                route: '/protect',
              ),
              _buildPdfToolButton(
                icon: Icons.rotate_right,
                label: 'Rotate',
                color: AppColors.rotateColor,
                route: '/rotate',
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (enabled ? color : AppColors.textSecondary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: enabled ? color : AppColors.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
      trailing: enabled
          ? Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
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
                Navigator.pop(context);
                context.go(route);
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: (enabled ? color : AppColors.textSecondary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  (enabled ? color : AppColors.textSecondary).withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: enabled ? color : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: enabled ? color : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Action methods
  Future<void> _openFile() async {
    if (widget.file.resultFilePath == null) {
      _showSnackBar('File not available on device', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await OpenFile.open(widget.file.resultFilePath!);
      if (result.type != ResultType.done) {
        _showSnackBar('Could not open file: ${result.message}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error opening file: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
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
      _showSnackBar('Error sharing file: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _moveToFolder() async {
    if (widget.file.resultFilePath == null) {
      _showSnackBar('File not available on device', isError: true);
      return;
    }

    Navigator.pop(context); // Close current bottom sheet

    showDialog(
      context: context,
      builder: (context) => FolderSelectionDialog(
        title: 'Move File',
        subtitle:
            'Select the destination folder for "${widget.file.originalFileName}"',
        onFolderSelected: (folder) async {
          try {
            await ref
                .read(fileManagerNotifierProvider.notifier)
                .addFileToCurrentFolder(widget.file.resultFilePath!);
            _showSnackBar('File moved successfully');
          } catch (e) {
            _showSnackBar('Failed to move file: $e', isError: true);
          }
        },
      ),
    );
  }

  void _showFileInfo() {
    showDialog(
      context: context,
      builder: (context) => _FileInfoDialog(file: widget.file),
    );
  }

  void _showInFolder() {
    // TODO: Implement show in folder functionality
    _showSnackBar('Show in folder - Coming soon!');
  }

  void _duplicateFile() {
    // TODO: Implement file duplication
    _showSnackBar('Duplicate file - Coming soon!');
  }

  void _deleteFile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text(
            'Are you sure you want to delete "${widget.file.originalFileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              Navigator.pop(context); // Close bottom sheet

              if (widget.file.resultFilePath != null) {
                try {
                  final file = File(widget.file.resultFilePath!);
                  if (await file.exists()) {
                    await file.delete();
                    _showSnackBar('File deleted successfully');
                  }
                } catch (e) {
                  _showSnackBar('Failed to delete file: $e', isError: true);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
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
        return AppColors.compressColor;
      case 'merge':
        return AppColors.mergeColor;
      case 'split':
        return AppColors.splitColor;
      case 'convert':
        return AppColors.convertColor;
      case 'protect':
        return AppColors.protectColor;
      case 'unlock':
        return AppColors.unlockColor;
      case 'rotate':
        return AppColors.rotateColor;
      case 'watermark':
        return AppColors.watermarkColor;
      case 'page_numbers':
        return AppColors.pageNumbersColor;
      default:
        return AppColors.primary;
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : null,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// File info dialog
class _FileInfoDialog extends StatelessWidget {
  final RecentFileModel file;

  const _FileInfoDialog({required this.file});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('File Information'),
      content: Column(
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
