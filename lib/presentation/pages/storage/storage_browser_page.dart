// lib/presentation/pages/storage/storage_browser_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/data/services/storage_service.dart';
import 'package:path/path.dart' as path;
import '../../../core/theme/app_colors.dart';
import '../pdf_viewer/pdf_viewer_page.dart';

class StorageBrowserPage extends ConsumerStatefulWidget {
  final String? initialPath;

  const StorageBrowserPage({Key? key, this.initialPath}) : super(key: key);

  @override
  ConsumerState<StorageBrowserPage> createState() => _StorageBrowserPageState();
}

class _StorageBrowserPageState extends ConsumerState<StorageBrowserPage> {
  String? _currentPath;
  List<FileSystemEntity> _items = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _initializeBrowser();
  }

  Future<void> _initializeBrowser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Check storage permission
    final storageService = StorageService();
    final hasPermission = await storageService.checkPermissions();

    if (!hasPermission) {
      setState(() {
        _isLoading = false;
        _hasPermission = false;
        _errorMessage = 'Storage permission required to browse files';
      });
      return;
    }

    setState(() {
      _hasPermission = true;
    });

    try {
      // Start with initial path or get MegaPDF directory
      String? startPath;

      if (widget.initialPath != null) {
        startPath = widget.initialPath;
      } else {
        // Get MegaPDF directory
        final megaPdfDir = await storageService.createMegaPDFDirectory();
        startPath = megaPdfDir?.path;
      }

      if (startPath != null) {
        await _loadDirectory(startPath);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to access storage directory';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error accessing files: $e';
      });
    }
  }

  Future<void> _loadDirectory(String dirPath) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final directory = Directory(dirPath);
      if (await directory.exists()) {
        final items = await directory.list().toList();

        // Sort items: directories first, then files alphabetically
        items.sort((a, b) {
          final aIsDir = a is Directory;
          final bIsDir = b is Directory;

          if (aIsDir && !bIsDir) return -1;
          if (!aIsDir && bIsDir) return 1;

          return path.basename(a.path).compareTo(path.basename(b.path));
        });

        setState(() {
          _currentPath = dirPath;
          _items = items;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Directory does not exist';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading directory: $e';
      });
    }
  }

  bool _canNavigateUp() {
    if (_currentPath == null) return false;

    // Check if we're already at the root
    final rootDir = path.dirname(_currentPath!);
    return path.basename(_currentPath!) != 'MegaPDF' ||
        !rootDir.endsWith('Download');
  }

  Future<void> _navigateUp() async {
    if (_currentPath != null && _canNavigateUp()) {
      final parentDir = path.dirname(_currentPath!);
      await _loadDirectory(parentDir);
    }
  }

  Future<void> _refresh() async {
    if (_currentPath != null) {
      await _loadDirectory(_currentPath!);
    } else {
      await _initializeBrowser();
    }
  }

  Future<void> _requestPermission() async {
    final storageService = StorageService();
    final granted = await storageService.requestPermissions(context);

    if (granted) {
      setState(() {
        _hasPermission = true;
      });
      await _initializeBrowser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Browser'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: _hasPermission ? _buildContent() : _buildPermissionRequest(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.error(context),
                  ),
            ),
            const SizedBox(height: 8),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Path display and up button
        if (_currentPath != null) _buildPathBar(),

        // File list
        Expanded(
          child: _items.isEmpty ? _buildEmptyDirectory() : _buildFileList(),
        ),
      ],
    );
  }

  Widget _buildPathBar() {
    final displayPath = _getDisplayPath(_currentPath!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(
          bottom: BorderSide(color: AppColors.border(context)),
        ),
      ),
      child: Row(
        children: [
          if (_canNavigateUp())
            IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: _navigateUp,
              tooltip: 'Up to parent directory',
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              padding: EdgeInsets.zero,
              iconSize: 20,
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayPath,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          final isDirectory = item is Directory;
          final fileName = path.basename(item.path);

          // Skip hidden files
          if (fileName.startsWith('.')) {
            return const SizedBox.shrink();
          }

          return ListTile(
            leading: Icon(
              isDirectory ? Icons.folder : _getFileIcon(fileName),
              color: isDirectory
                  ? AppColors.warning(context)
                  : _getFileColor(fileName, context),
            ),
            title: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: isDirectory
                ? const Text('Folder')
                : FutureBuilder<FileStat>(
                    future: File(item.path).stat(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text('Loading...');
                      }

                      final stat = snapshot.data!;
                      return Text(
                        '${_formatFileSize(stat.size)} • ${_formatDate(stat.modified)}',
                      );
                    },
                  ),
            onTap: () => _handleItemTap(item),
          );
        },
      ),
    );
  }

  Widget _buildEmptyDirectory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 48,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Empty Folder',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This folder has no files or subfolders',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_off,
            size: 64,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(height: 24),
          Text(
            'Storage Permission Required',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'This app needs permission to access your device storage to browse and manage files.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _requestPermission,
            icon: const Icon(Icons.folder_open),
            label: const Text('Grant Permission'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleItemTap(FileSystemEntity item) {
    if (item is Directory) {
      _loadDirectory(item.path);
    } else if (item is File) {
      _openFile(item);
    }
  }

  void _openFile(File file) {
    final extension = path.extension(file.path).toLowerCase();

    if (extension == '.pdf') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(
            filePath: file.path,
            fileName: path.basename(file.path),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot open ${extension.toUpperCase()} files'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getDisplayPath(String fullPath) {
    if (Platform.isAndroid && fullPath.contains('/storage/emulated/0')) {
      return fullPath.replaceFirst('/storage/emulated/0', 'Internal Storage');
    }
    return fullPath;
  }

  IconData _getFileIcon(String fileName) {
    final extension = path.extension(fileName).toLowerCase();

    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return Icons.image;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.xls':
      case '.xlsx':
        return Icons.table_chart;
      case '.ppt':
      case '.pptx':
        return Icons.slideshow;
      case '.txt':
        return Icons.text_snippet;
      case '.zip':
      case '.rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String fileName, BuildContext context) {
    final extension = path.extension(fileName).toLowerCase();

    switch (extension) {
      case '.pdf':
        return AppColors.error(context);
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return AppColors.secondary(context);
      case '.doc':
      case '.docx':
        return AppColors.primary(context);
      case '.xls':
      case '.xlsx':
        return AppColors.success(context);
      case '.ppt':
      case '.pptx':
        return AppColors.warning(context);
      default:
        return AppColors.textSecondary(context);
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
