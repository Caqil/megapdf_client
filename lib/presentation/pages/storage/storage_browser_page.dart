
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:megapdf_client/core/theme/app_colors.dart';
import 'package:megapdf_client/data/models/file_item.dart';
import 'package:megapdf_client/presentation/providers/file_manager_provider.dart';
import 'package:megapdf_client/presentation/providers/file_path_provider.dart';
import 'package:megapdf_client/presentation/widgets/common/custom_snackbar.dart';

class StorageBrowserPage extends ConsumerStatefulWidget {
  const StorageBrowserPage({Key? key}) : super(key: key);

  @override
  ConsumerState<StorageBrowserPage> createState() => _StorageBrowserPageState();
}

class _StorageBrowserPageState extends ConsumerState<StorageBrowserPage> {
  final TextEditingController _renameController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Initial file load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fileManagerNotifierProvider.notifier).loadFiles();
    });
  }

  @override
  void dispose() {
    _renameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileManagerState = ref.watch(fileManagerNotifierProvider);
    final directoryPath = ref.watch(megaPdfDirectoryPathProvider).valueOrNull;

    return Scaffold(
      appBar: _buildAppBar(context, fileManagerState),
      body: Stack(
        children: [
          Column(
            children: [
              _buildStorageInfoCard(context, directoryPath),
              Expanded(
                child: _buildFileList(context, fileManagerState),
              ),
            ],
          ),
          if (fileManagerState.isLoading)
            const LoadingOverlay(message: 'Processing files...'),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  AppBar _buildAppBar(BuildContext context, FileManagerState state) {
    return AppBar(
      backgroundColor: AppColors.surface(context),
      elevation: 0,
      title: Text(
        'Storage Manager',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: AppColors.textPrimary(context),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (state.isSelectionMode) ...[
          IconButton(
            icon: const Icon(Icons.select_all),
            color: AppColors.primary(context),
            onPressed: () =>
                ref.read(fileManagerNotifierProvider.notifier).selectAll(),
            tooltip: 'Select All',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: AppColors.error(context),
            onPressed: () => _confirmDeleteSelected(context),
            tooltip: 'Delete Selected',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            color: AppColors.textPrimary(context),
            onPressed: () =>
                ref.read(fileManagerNotifierProvider.notifier).clearSelection(),
            tooltip: 'Cancel Selection',
          ),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.refresh),
            color: AppColors.primary(context),
            onPressed: () {
              _refreshKey.currentState?.show();
              ref.read(fileManagerNotifierProvider.notifier).refreshFiles();
            },
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: AppColors.textPrimary(context),
            ),
            onSelected: (value) {
              if (value == 'select_mode') {
                // Toggle selection mode
                if (!state.isSelectionMode && state.fileItems.isNotEmpty) {
                  ref.read(fileManagerNotifierProvider.notifier).selectAll();
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'select_mode',
                child: Row(
                  children: [
                    Icon(Icons.select_all, size: 20),
                    SizedBox(width: 8),
                    Text('Select All'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStorageInfoCard(BuildContext context, String? directoryPath) {
    return Card(
      margin: const EdgeInsets.all(12),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.folder_open,
                    color: AppColors.primary(context),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MegaPDF Files',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary(context),
                                ),
                      ),
                      if (directoryPath != null)
                        Text(
                          _formatPath(directoryPath),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileList(BuildContext context, FileManagerState state) {
    if (state.isLoading && state.fileItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.fileItems.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.folder_open,
          title: 'No Files Found',
          subtitle: 'Files you process with MegaPDF will appear here',
          actionLabel: 'Refresh',
          onAction: () =>
              ref.read(fileManagerNotifierProvider.notifier).refreshFiles(),
        ),
      );
    }

    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: () async {
        await ref.read(fileManagerNotifierProvider.notifier).refreshFiles();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: state.fileItems.length,
        itemBuilder: (context, index) {
          final file = state.fileItems[index];
          return _buildFileCard(context, file, state, index);
        },
      ),
    );
  }

  Widget _buildFileCard(
      BuildContext context, FileItem file, FileManagerState state, int index) {
    final isSelected = state.selectedItems.contains(file);

    // Group files by date
    final DateTime fileDate = file.lastModified;
    final String dateGroup = _getDateGroup(fileDate);

    // Show date header for the first file of each date group
    final bool showHeader = index == 0 ||
        _getDateGroup(state.fileItems[index - 1].lastModified) != dateGroup;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 16, bottom: 8),
            child: Text(
              dateGroup,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? BorderSide(color: AppColors.primary(context), width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (state.isSelectionMode) {
                ref
                    .read(fileManagerNotifierProvider.notifier)
                    .toggleFileSelection(file);
              } else {
                _openFile(context, file);
              }
            },
            onLongPress: () {
              if (!state.isSelectionMode) {
                ref
                    .read(fileManagerNotifierProvider.notifier)
                    .toggleFileSelection(file);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // File type icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          _getFileIconColor(file.extension!).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: _getFileIcon(file.extension!),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // File info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          file.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary(context),
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              FileUtils.formatFileSize(file.size),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.textSecondary(context),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(file.lastModified),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Selection indicator or actions
                  if (state.isSelectionMode)
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        ref
                            .read(fileManagerNotifierProvider.notifier)
                            .toggleFileSelection(file);
                      },
                      activeColor: AppColors.primary(context),
                    )
                  else
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: AppColors.textSecondary(context),
                      ),
                      onSelected: (value) =>
                          _handleFileAction(context, value, file),
                      itemBuilder: (context) => [
                        const PopupMenuItem<String>(
                          value: 'open',
                          child: Row(
                            children: [
                              Icon(Icons.open_in_new, size: 20),
                              SizedBox(width: 8),
                              Text('Open'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'rename',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Rename'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        // Import file functionality
        // You would typically show a file picker here
      },
      label: const Text('Import File'),
      icon: const Icon(Icons.add),
      backgroundColor: AppColors.primary(context),
    );
  }

  void _handleFileAction(BuildContext context, String action, FileItem file) {
    switch (action) {
      case 'open':
        _openFile(context, file);
        break;
      case 'rename':
        _showRenameDialog(context, file);
        break;
      case 'delete':
        _confirmDeleteFile(context, file);
        break;
    }
  }

  void _openFile(BuildContext context, FileItem file) {
    // Implement file opening logic here
    // This would typically use a PDF viewer or system intent
    CustomSnackbar.show(
      context: context,
      message: 'Opening ${file.name}...',
      type: SnackbarType.info,
    );
  }

  void _showRenameDialog(BuildContext context, FileItem file) {
    final fileName = path.basenameWithoutExtension(file.name);
    _renameController.text = fileName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename File'),
        content: TextField(
          controller: _renameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'New Name',
            hintText: 'Enter new file name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = _renameController.text.trim();
              Navigator.pop(context);

              if (newName.isNotEmpty && newName != fileName) {
                ref.read(fileManagerNotifierProvider.notifier).renameFile(
                      file,
                      newName,
                      context: context,
                    );
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFile(BuildContext context, FileItem file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(fileManagerNotifierProvider.notifier).deleteFile(
                    file,
                    context: context,
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSelected(BuildContext context) {
    final state = ref.read(fileManagerNotifierProvider);
    if (state.selectedItems.isEmpty) return;

    ref.read(fileManagerNotifierProvider.notifier).deleteSelectedFiles(context);
  }

  String _formatPath(String path) {
    if (path.contains('/storage/emulated/0')) {
      return path.replaceFirst('/storage/emulated/0', 'Internal Storage');
    }
    return path;
  }

  String _getDateGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final fileDate = DateTime(date.year, date.month, date.day);

    if (fileDate == today) {
      return 'Today';
    } else if (fileDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(fileDate).inDays < 7) {
      return DateFormat('EEEE').format(date); // Day name
    } else {
      return DateFormat('MMMM d, yyyy').format(date); // Month day, year
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  Widget _getFileIcon(String extension) {
    IconData iconData;

    switch (extension.toLowerCase()) {
      case '.pdf':
        iconData = Icons.picture_as_pdf;
        break;
      case '.jpg':
      case '.jpeg':
      case '.png':
        iconData = Icons.image;
        break;
      case '.doc':
      case '.docx':
        iconData = Icons.description;
        break;
      case '.xls':
      case '.xlsx':
        iconData = Icons.table_chart;
        break;
      case '.ppt':
      case '.pptx':
        iconData = Icons.slideshow;
        break;
      default:
        iconData = Icons.insert_drive_file;
    }

    return Icon(
      iconData,
      color: _getFileIconColor(extension),
      size: 28,
    );
  }

  Color _getFileIconColor(String extension) {
    switch (extension.toLowerCase()) {
      case '.pdf':
        return Colors.red;
      case '.jpg':
      case '.jpeg':
      case '.png':
        return Colors.blue;
      case '.doc':
      case '.docx':
        return Colors.indigo;
      case '.xls':
      case '.xlsx':
        return Colors.green;
      case '.ppt':
      case '.pptx':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

// Add this utility class if it doesn't exist yet
class FileUtils {
  static String formatFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      final kb = sizeInBytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    } else if (sizeInBytes < 1024 * 1024 * 1024) {
      final mb = sizeInBytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    } else {
      final gb = sizeInBytes / (1024 * 1024 * 1024);
      return '${gb.toStringAsFixed(1)} GB';
    }
  }
}

// Add this widget if it doesn't exist yet
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary(context).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.primary(context),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Add this widget if it doesn't exist yet
class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
