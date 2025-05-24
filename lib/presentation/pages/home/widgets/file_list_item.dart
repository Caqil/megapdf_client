import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';
import 'package:megapdf_client/data/models/file_item.dart';
import 'package:megapdf_client/presentation/pages/pdf_viewer/pdf_viewer_page.dart';
import 'package:megapdf_client/presentation/providers/file_manager_provider.dart';

import '../../../widgets/common/custom_snackbar.dart';

class FileListItem extends ConsumerWidget {
  final FileItem file;

  const FileListItem({super.key, required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleFileTap(context),
        onLongPress: () => _showFileContextMenu(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: file.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  file.icon,
                  color: file.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          file.formattedSize,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                        ),
                        const Text(' • '),
                        Text(
                          file.formattedDate,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleFileAction(context, ref, value),
                itemBuilder: (context) => [
                  if (file.isPdf) ...[
                    PopupMenuItem(
                      value: 'open',
                      child: ListTile(
                        leading: Icon(Icons.open_in_new,
                            size: 20, color: AppColors.primary(context)),
                        title: const Text('Open'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  if (file.isPdf) ...[
                    PopupMenuItem(
                      value: 'tools',
                      child: ListTile(
                        leading: Icon(Icons.build,
                            size: 20, color: AppColors.primary(context)),
                        title: const Text('Use with Tool'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  PopupMenuItem(
                    value: 'rename',
                    child: ListTile(
                      leading: Icon(Icons.edit,
                          size: 20, color: AppColors.info(context)),
                      title: const Text('Rename'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'share',
                    child: ListTile(
                      leading: Icon(Icons.share,
                          size: 20, color: AppColors.secondary(context)),
                      title: const Text('Share'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete,
                          size: 20, color: AppColors.error(context)),
                      title: Text('Delete',
                          style: TextStyle(color: AppColors.error(context))),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary(context),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileTap(BuildContext context) {
    if (file.isPdf) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(
            filePath: file.path,
            fileName: file.name,
          ),
        ),
      );
    } else {
      _showSnackBar(context, 'File options coming soon!');
    }
  }

  void _handleFileAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'open':
        if (file.isPdf) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFViewerPage(
                filePath: file.path,
                fileName: file.name,
              ),
            ),
          );
        }
        break;
      case 'tools':
        _showToolsMenu(context);
        break;
      case 'rename':
        _showRenameDialog(context, ref);
        break;
      case 'share':
        _showSnackBar(context, 'Share functionality coming soon!');
        break;
      case 'delete':
        _showDeleteDialog(context, ref);
        break;
    }
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: file.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != file.name) {
                ref
                    .read(fileManagerNotifierProvider.notifier)
                    .renameFile(file, newName);
              }
              Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text(
          'Are you sure you want to delete "${file.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(fileManagerNotifierProvider.notifier)
                  .deleteFile(file, context: context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error(context)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Show the file context menu with added tools section
  void _showFileContextMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.background(context),
              borderRadius: const BorderRadius.only(
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

                // File info header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: file.iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          file.icon,
                          size: 28,
                          color: file.iconColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary(context),
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${file.formattedSize} • ${file.formattedDate}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick actions
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildQuickActionButton(
                                  context: context,
                                  icon: Icons.open_in_new,
                                  label: 'Open',
                                  color: AppColors.primary(context),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _handleFileTap(context);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildQuickActionButton(
                                  context: context,
                                  icon: Icons.share,
                                  label: 'Share',
                                  color: AppColors.secondary(context),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showSnackBar(context,
                                        'Share functionality coming soon!');
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // File operations section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'File Operations',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary(context),
                                ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        ListTile(
                          leading:
                              Icon(Icons.edit, color: AppColors.info(context)),
                          title: const Text('Rename'),
                          subtitle: const Text('Change file name'),
                          onTap: () {
                            Navigator.pop(context);
                            _showRenameDialog(context, ref);
                          },
                        ),

                        ListTile(
                          leading: Icon(Icons.delete,
                              color: AppColors.error(context)),
                          title: const Text('Delete'),
                          subtitle: const Text('Remove file from device'),
                          onTap: () {
                            Navigator.pop(context);
                            _showDeleteDialog(context, ref);
                          },
                        ),

                        // PDF Tools section (if it's a PDF file)
                        if (file.isPdf) ...[
                          const SizedBox(height: 16),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'PDF Tools',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary(context),
                                  ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Grid of tool options
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 4,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 0.9,
                              children: [
                                _buildToolButton(
                                  context: context,
                                  icon: Icons.compress,
                                  label: 'Compress',
                                  color: AppColors.compressColor(context),
                                  route: '/compress',
                                ),
                                _buildToolButton(
                                  context: context,
                                  icon: Icons.call_split,
                                  label: 'Split',
                                  color: AppColors.splitColor(context),
                                  route: '/split',
                                ),
                                _buildToolButton(
                                  context: context,
                                  icon: Icons.merge,
                                  label: 'Merge',
                                  color: AppColors.mergeColor(context),
                                  route: '/merge',
                                ),
                                _buildToolButton(
                                  context: context,
                                  icon: Icons.branding_watermark,
                                  label: 'Watermark',
                                  color: AppColors.watermarkColor(context),
                                  route: '/watermark',
                                ),
                                _buildToolButton(
                                  context: context,
                                  icon: Icons.transform,
                                  label: 'Convert',
                                  color: AppColors.convertColor(context),
                                  route: '/convert',
                                ),
                                _buildToolButton(
                                  context: context,
                                  icon: Icons.lock,
                                  label: 'Protect',
                                  color: AppColors.protectColor(context),
                                  route: '/protect',
                                ),
                                _buildToolButton(
                                  context: context,
                                  icon: Icons.rotate_right,
                                  label: 'Rotate',
                                  color: AppColors.rotateColor(context),
                                  route: '/rotate',
                                ),
                                _buildToolButton(
                                  context: context,
                                  icon: Icons.format_list_numbered,
                                  label: 'Page Numbers',
                                  color: AppColors.pageNumbersColor(context),
                                  route: '/page-numbers',
                                ),
                              ],
                            ),
                          ),
                        ],

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
      ),
    );
  }

  // Show the tools menu
  void _showToolsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.build,
                      color: AppColors.primary(context), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Use with Tool',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary(context),
                        ),
                  ),
                ],
              ),
            ),

            // Grid of tool options
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.9,
              children: [
                _buildToolButton(
                  context: context,
                  icon: Icons.compress,
                  label: 'Compress',
                  color: AppColors.compressColor(context),
                  route: '/compress',
                ),
                _buildToolButton(
                  context: context,
                  icon: Icons.call_split,
                  label: 'Split',
                  color: AppColors.splitColor(context),
                  route: '/split',
                ),
                _buildToolButton(
                  context: context,
                  icon: Icons.merge,
                  label: 'Merge',
                  color: AppColors.mergeColor(context),
                  route: '/merge',
                ),
                _buildToolButton(
                  context: context,
                  icon: Icons.branding_watermark,
                  label: 'Watermark',
                  color: AppColors.watermarkColor(context),
                  route: '/watermark',
                ),
                _buildToolButton(
                  context: context,
                  icon: Icons.transform,
                  label: 'Convert',
                  color: AppColors.convertColor(context),
                  route: '/convert',
                ),
                _buildToolButton(
                  context: context,
                  icon: Icons.lock,
                  label: 'Protect',
                  color: AppColors.protectColor(context),
                  route: '/protect',
                ),
                _buildToolButton(
                  context: context,
                  icon: Icons.rotate_right,
                  label: 'Rotate',
                  color: AppColors.rotateColor(context),
                  route: '/rotate',
                ),
                _buildToolButton(
                  context: context,
                  icon: Icons.format_list_numbered,
                  label: 'Page Numbers',
                  color: AppColors.pageNumbersColor(context),
                  route: '/page-numbers',
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  // Helper to build a tool button
  Widget _buildToolButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _navigateToToolWithFile(context, route);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build a quick action button
  Widget _buildQuickActionButton({
    required BuildContext context,
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

  // Navigate to a tool page with the file
  void _navigateToToolWithFile(BuildContext context, String route) {
    // Use the file path as a parameter
    final fileParam = Uri.encodeComponent(file.path);
    final nameParam = Uri.encodeComponent(file.name);

    // Navigate using GoRouter
    context.push('$route?filePath=$fileParam&fileName=$nameParam');
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    CustomSnackbar.show(
      context: context,
      message: message,
      type: isError ? SnackbarType.failure : SnackbarType.info,
      duration: const Duration(seconds: 3),
    );
  }
}
