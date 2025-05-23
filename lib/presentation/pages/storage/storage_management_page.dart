// lib/presentation/pages/storage/storage_management_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:megapdf_client/data/services/storage_service.dart';
import 'package:path/path.dart' as path;

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/file_utils.dart';
import '../../widgets/storage/storage_info_widget.dart';
import 'storage_browser_page.dart';

class StorageManagementPage extends ConsumerStatefulWidget {
  const StorageManagementPage({Key? key}) : super(key: key);

  @override
  ConsumerState<StorageManagementPage> createState() =>
      _StorageManagementPageState();
}

class _StorageManagementPageState extends ConsumerState<StorageManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StorageService _storageService = StorageService();

  // Storage statistics
  int _totalFiles = 0;
  int _totalFolders = 0;
  int _totalSize = 0;
  bool _isLoading = true;
  String? _megaPdfPath;

  // Files by type
  Map<String, List<FileSystemEntity>> _filesByType = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadStorageInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStorageInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get MegaPDF directory
      final megaPdfDir = await _storageService.createMegaPDFDirectory();

      if (megaPdfDir != null) {
        _megaPdfPath = megaPdfDir.path;

        // Categorize files by type
        _filesByType = {
          'pdf': [],
          'document': [],
          'image': [],
          'other': [],
        };

        // Scan directory recursively
        await _scanDirectory(megaPdfDir);

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading storage info: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _scanDirectory(Directory directory) async {
    try {
      final entities = await directory.list(recursive: true).toList();

      int files = 0;
      int folders = 0;
      int totalSize = 0;

      for (var entity in entities) {
        if (entity is File) {
          files++;
          try {
            final stat = await entity.stat();
            totalSize += stat.size;

            // Categorize file by type
            final extension = path.extension(entity.path).toLowerCase();
            if (extension == '.pdf') {
              _filesByType['pdf']!.add(entity);
            } else if (['.doc', '.docx', '.txt', '.rtf'].contains(extension)) {
              _filesByType['document']!.add(entity);
            } else if (['.jpg', '.jpeg', '.png', '.gif'].contains(extension)) {
              _filesByType['image']!.add(entity);
            } else {
              _filesByType['other']!.add(entity);
            }
          } catch (e) {
            print('Error getting file stats: $e');
          }
        } else if (entity is Directory) {
          folders++;
        }
      }

      // Sort files by modified date (newest first)
      for (var type in _filesByType.keys) {
        _filesByType[type]!.sort((a, b) {
          final aFile = a as File;
          final bFile = b as File;
          try {
            final aStat = aFile.statSync();
            final bStat = bFile.statSync();
            return bStat.modified.compareTo(aStat.modified);
          } catch (e) {
            return 0;
          }
        });
      }

      setState(() {
        _totalFiles = files;
        _totalFolders = folders;
        _totalSize = totalSize;
      });
    } catch (e) {
      print('Error scanning directory: $e');
    }
  }

  void _openFileBrowser([String? initialPath]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StorageBrowserPage(
          initialPath: initialPath ?? _megaPdfPath,
        ),
      ),
    );
  }

  Future<void> _deleteFile(File file) async {
    final fileName = path.basename(file.path);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error(context),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await file.delete();
        _showSnackBar('File deleted successfully');

        // Refresh storage info
        _loadStorageInfo();
      } catch (e) {
        _showSnackBar('Error deleting file: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error(context) : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'PDFs'),
            Tab(text: 'Documents'),
            Tab(text: 'Images'),
            Tab(text: 'Other'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildFileListTab('pdf'),
                _buildFileListTab('document'),
                _buildFileListTab('image'),
                _buildFileListTab('other'),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openFileBrowser(),
        tooltip: 'Browse All Files',
        child: const Icon(Icons.folder_open),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Storage info widget
          StorageInfoWidget(
            onOpenFolder: () => _openFileBrowser(),
          ),

          const SizedBox(height: 24),

          // Storage statistics
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
                  Text(
                    'Storage Statistics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        context,
                        'Total Size',
                        FileUtils.formatFileSize(_totalSize),
                        Icons.data_usage,
                        AppColors.primary(context),
                      ),
                      _buildStatCard(
                        context,
                        'Files',
                        _totalFiles.toString(),
                        Icons.insert_drive_file,
                        AppColors.secondary(context),
                      ),
                      _buildStatCard(
                        context,
                        'Folders',
                        _totalFolders.toString(),
                        Icons.folder,
                        AppColors.warning(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // File Type Distribution
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
                  Text(
                    'File Distribution',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildFileTypeBar(
                    'PDFs',
                    _filesByType['pdf']!.length,
                    _totalFiles,
                    AppColors.error(context),
                  ),
                  const SizedBox(height: 8),
                  _buildFileTypeBar(
                    'Documents',
                    _filesByType['document']!.length,
                    _totalFiles,
                    AppColors.primary(context),
                  ),
                  const SizedBox(height: 8),
                  _buildFileTypeBar(
                    'Images',
                    _filesByType['image']!.length,
                    _totalFiles,
                    AppColors.secondary(context),
                  ),
                  const SizedBox(height: 8),
                  _buildFileTypeBar(
                    'Other',
                    _filesByType['other']!.length,
                    _totalFiles,
                    AppColors.textSecondary(context),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Recent files
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Files',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      TextButton(
                        onPressed: () => _openFileBrowser(),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildRecentFiles(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Storage management options
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
                  Text(
                    'Storage Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.folder_open,
                        color: AppColors.primary(context),
                      ),
                    ),
                    title: const Text('Browse All Files'),
                    subtitle: const Text('View all files in storage'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openFileBrowser(),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warning(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.cleaning_services,
                        color: AppColors.warning(context),
                      ),
                    ),
                    title: const Text('Clean Temporary Files'),
                    subtitle: const Text('Remove cached and temporary files'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Implementation for cleaning temporary files
                      _showSnackBar('Cleaning temporary files...');
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFileListTab(String fileType) {
    final files = _filesByType[fileType] ?? [];

    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: AppColors.textSecondary(context),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${fileType.capitalize()} Files',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Files you save will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index] as File;
        final fileName = path.basename(file.path);

        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getFileTypeColor(file.path, context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getFileTypeIcon(file.path),
                color: _getFileTypeColor(file.path, context),
              ),
            ),
            title: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: FutureBuilder<FileStat>(
              future: file.stat(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text('Loading...');
                }

                final stat = snapshot.data!;
                return Text(
                  '${FileUtils.formatFileSize(stat.size)} • ${_formatDate(stat.modified)}',
                );
              },
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'open':
                    // Open file in viewer
                    break;
                  case 'share':
                    // Share file
                    break;
                  case 'delete':
                    _deleteFile(file);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'open',
                  child: ListTile(
                    leading: Icon(Icons.open_in_new),
                    title: Text('Open'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Share'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: AppColors.error(context),
                    ),
                    title: Text(
                      'Delete',
                      style: TextStyle(color: AppColors.error(context)),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            onTap: () {
              // Open file in viewer
            },
          ),
        );
      },
    );
  }

  Widget _buildRecentFiles() {
    // Get most recent files (first 5) across all types
    final allFiles = <File>[];

    for (var fileList in _filesByType.values) {
      for (var entity in fileList) {
        if (entity is File) {
          allFiles.add(entity);
        }
      }
    }

    // Sort by modification date (newest first)
    allFiles.sort((a, b) {
      try {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return bStat.modified.compareTo(aStat.modified);
      } catch (e) {
        return 0;
      }
    });

    final recentFiles = allFiles.take(5).toList();

    if (recentFiles.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: Text(
          'No recent files',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary(context),
              ),
        ),
      );
    }

    return Column(
      children: recentFiles.map((file) {
        final fileName = path.basename(file.path);

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getFileTypeColor(file.path, context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileTypeIcon(file.path),
              color: _getFileTypeColor(file.path, context),
              size: 20,
            ),
          ),
          title: Text(
            fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: FutureBuilder<FileStat>(
            future: file.stat(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text('Loading...');
              }

              final stat = snapshot.data!;
              return Text(
                '${FileUtils.formatFileSize(stat.size)} • ${_formatDate(stat.modified)}',
                style: Theme.of(context).textTheme.bodySmall,
              );
            },
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.open_in_new,
              size: 20,
              color: AppColors.primary(context),
            ),
            onPressed: () {
              // Open file in viewer
            },
          ),
          onTap: () {
            // Open file in viewer
          },
        );
      }).toList(),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildFileTypeBar(
    String label,
    int count,
    int total,
    Color color,
  ) {
    // Avoid division by zero
    final percentage = total > 0 ? count / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('$count files'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: AppColors.border(context),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  IconData _getFileTypeIcon(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
      case '.txt':
      case '.rtf':
        return Icons.description;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileTypeColor(String filePath, BuildContext context) {
    final extension = path.extension(filePath).toLowerCase();

    switch (extension) {
      case '.pdf':
        return AppColors.error(context);
      case '.doc':
      case '.docx':
      case '.txt':
      case '.rtf':
        return AppColors.primary(context);
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return AppColors.secondary(context);
      default:
        return AppColors.textSecondary(context);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
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

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
  }
}
