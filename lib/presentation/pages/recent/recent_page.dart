// lib/presentation/pages/recent/recent_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/data/models/recent_file_model.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/recent_files_provider.dart';

class RecentPage extends ConsumerStatefulWidget {
  const RecentPage({super.key});

  @override
  ConsumerState<RecentPage> createState() => _RecentPageState();
}

class _RecentPageState extends ConsumerState<RecentPage> {
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    // Load recent files when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recentFilesNotifierProvider.notifier).loadRecentFiles();
      ref.read(recentFilesNotifierProvider.notifier).loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recentFilesNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Recent Files',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  _showClearRecentDialog();
                  break;
                case 'filter':
                  _showFilterOptions();
                  break;
                case 'refresh':
                  ref
                      .read(recentFilesNotifierProvider.notifier)
                      .loadRecentFiles();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh, size: 20),
                  title: Text('Refresh'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'filter',
                child: ListTile(
                  leading: Icon(Icons.filter_list, size: 20),
                  title: Text('Filter'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.clear_all, size: 20),
                  title: Text('Clear All'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats cards
                  if (state.stats.isNotEmpty) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _StatsCard(
                            title: 'Today',
                            count: state.stats['today']?.toString() ?? '0',
                            subtitle: 'files processed',
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatsCard(
                            title: 'This Week',
                            count: state.stats['thisWeek']?.toString() ?? '0',
                            subtitle: 'files processed',
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Filter chips
                  if (state.operationTypes.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _selectedFilter == null,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedFilter = null);
                              ref
                                  .read(recentFilesNotifierProvider.notifier)
                                  .loadRecentFiles();
                            }
                          },
                        ),
                        ...state.operationTypes.map((type) {
                          return FilterChip(
                            label: Text(_getOperationDisplayName(type)),
                            selected: _selectedFilter == type,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = selected ? type : null;
                              });
                              ref
                                  .read(recentFilesNotifierProvider.notifier)
                                  .loadRecentFiles(
                                      operationType: selected ? type : null);
                            },
                          );
                        }).toList(),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Recent files list
                  _buildRecentFilesList(state),
                ],
              ),
            ),
    );
  }

  Widget _buildRecentFilesList(RecentFilesState state) {
    if (state.recentFiles.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.recentFiles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final file = state.recentFiles[index];
            return _RecentFileCard(item: file);
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Icon(
            Icons.history_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No recent files',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Files you process will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  void _showClearRecentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Recent Files'),
        content: const Text(
            'Are you sure you want to clear all recent files? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(recentFilesNotifierProvider.notifier)
                  .clearAllRecentFiles();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recent files cleared')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Operation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedFilter == null,
                  onSelected: (selected) {
                    setState(() => _selectedFilter = null);
                    ref
                        .read(recentFilesNotifierProvider.notifier)
                        .loadRecentFiles();
                    Navigator.pop(context);
                  },
                ),
                ...ref
                    .read(recentFilesNotifierProvider)
                    .operationTypes
                    .map((type) {
                  return FilterChip(
                    label: Text(_getOperationDisplayName(type)),
                    selected: _selectedFilter == type,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? type : null;
                      });
                      ref
                          .read(recentFilesNotifierProvider.notifier)
                          .loadRecentFiles(
                              operationType: selected ? type : null);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getOperationDisplayName(String operationType) {
    switch (operationType) {
      case 'compress':
        return 'Compress';
      case 'merge':
        return 'Merge';
      case 'split':
        return 'Split';
      case 'convert':
        return 'Convert';
      case 'protect':
        return 'Protect';
      case 'unlock':
        return 'Unlock';
      case 'rotate':
        return 'Rotate';
      case 'watermark':
        return 'Watermark';
      case 'page_numbers':
        return 'Page Numbers';
      default:
        return operationType.toUpperCase();
    }
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

  IconData _getOperationIcon(String operationType) {
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

class _StatsCard extends StatelessWidget {
  final String title;
  final String count;
  final String subtitle;
  final Color color;

  const _StatsCard({
    required this.title,
    required this.count,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _RecentFileCard extends ConsumerWidget {
  final RecentFileModel item;

  const _RecentFileCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _getOperationColor(item.operationType);
    final icon = _getOperationIcon(item.operationType);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.originalFileName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.operation,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.originalSize}${item.resultSize != null ? ' → ${item.resultSize}' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.timeAgo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    // TODO: Implement delete single item
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, size: 16),
                      title: Text('Remove'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  IconData _getOperationIcon(String operationType) {
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
