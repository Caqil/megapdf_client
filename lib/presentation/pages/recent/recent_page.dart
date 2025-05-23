// lib/presentation/pages/recent/recent_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/recent_file_model.dart';
import '../../providers/recent_files_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/bottom_sheets/file_operations_bottom_sheet.dart';

class RecentPage extends ConsumerStatefulWidget {
  const RecentPage({super.key});

  @override
  ConsumerState<RecentPage> createState() => _RecentPageState();
}

class _RecentPageState extends ConsumerState<RecentPage>
    with AutomaticKeepAliveClientMixin {
  String? _selectedFilter;
  bool _showFilterChips = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recentFilesNotifierProvider.notifier).loadRecentFiles();
      ref.read(recentFilesNotifierProvider.notifier).loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final state = ref.watch(recentFilesNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(state),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(recentFilesNotifierProvider.notifier)
              .refreshRecentFiles();
        },
        child: _buildBody(state),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(RecentFilesState state) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Files',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          if (state.recentFiles.isNotEmpty)
            Text(
              '${state.recentFiles.length} files processed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
        ],
      ),
      actions: [
        // Filter button
        if (state.operationTypes.isNotEmpty)
          IconButton(
            onPressed: () {
              setState(() {
                _showFilterChips = !_showFilterChips;
              });
            },
            icon: Icon(
              _showFilterChips ? Icons.filter_list_off : Icons.filter_list,
              color: _selectedFilter != null ? AppColors.primary : null,
            ),
            tooltip: 'Filter',
          ),

        // Refresh button
        IconButton(
          onPressed: state.isLoading
              ? null
              : () {
                  ref
                      .read(recentFilesNotifierProvider.notifier)
                      .refreshRecentFiles();
                },
          icon: state.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),

        // More options
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'clear_all',
              child: ListTile(
                leading: Icon(Icons.clear_all, color: AppColors.error),
                title:
                    Text('Clear All', style: TextStyle(color: AppColors.error)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'delete_old',
              child: ListTile(
                leading: Icon(Icons.auto_delete),
                title: Text('Delete Old Files'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          icon: Icon(Icons.more_vert),
        ),
      ],
    );
  }

  Widget _buildBody(RecentFilesState state) {
    if (state.isLoading && state.recentFiles.isEmpty) {
      return const Center(
        child: LoadingWidget(message: 'Loading recent files...'),
      );
    }

    if (state.hasError) {
      return Center(
        child: CustomErrorWidget(
          message: state.error!,
          onRetry: () {
            ref.read(recentFilesNotifierProvider.notifier).refreshRecentFiles();
          },
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter chips
          if (_showFilterChips && state.operationTypes.isNotEmpty) ...[
            _buildFilterChips(state),
            const SizedBox(height: 16),
          ],

          // Stats cards
          if (state.stats.isNotEmpty) ...[
            _buildStatsSection(state),
            const SizedBox(height: 24),
          ],

          // Recent files list
          _buildRecentFilesList(state),
        ],
      ),
    );
  }

  Widget _buildFilterChips(RecentFilesState state) {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // All filter chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('All'),
              selected: _selectedFilter == null,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = null;
                });
                ref
                    .read(recentFilesNotifierProvider.notifier)
                    .loadRecentFiles();
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            ),
          ),

          // Operation type filter chips
          ...state.operationTypes.map((operationType) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_getOperationDisplayName(operationType)),
                selected: _selectedFilter == operationType,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected ? operationType : null;
                  });
                  ref
                      .read(recentFilesNotifierProvider.notifier)
                      .loadRecentFiles(operationType: _selectedFilter);
                },
                selectedColor:
                    _getOperationColor(operationType).withOpacity(0.2),
                checkmarkColor: _getOperationColor(operationType),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatsSection(RecentFilesState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Summary',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatsCard(
                title: 'Today',
                count: state.stats['today']?.toString() ?? '0',
                subtitle: 'files processed',
                color: AppColors.primary,
                icon: Icons.today,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatsCard(
                title: 'This Week',
                count: state.stats['thisWeek']?.toString() ?? '0',
                subtitle: 'files processed',
                color: AppColors.secondary,
                icon: Icons.calendar_month,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentFilesList(RecentFilesState state) {
    if (state.recentFiles.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedFilter != null
                  ? '${_getOperationDisplayName(_selectedFilter!)} Files'
                  : 'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            if (state.recentFiles.length > 10)
              TextButton(
                onPressed: () {
                  // TODO: Navigate to expanded view
                },
                child: Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.recentFiles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final file = state.recentFiles[index];
            return RecentFileCard(
              item: file,
              onTap: () => _showFileOperations(file),
            );
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_outlined,
              size: 64,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedFilter != null
                ? 'No ${_getOperationDisplayName(_selectedFilter!).toLowerCase()} files'
                : 'No recent files',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter != null
                ? 'Try a different filter or process some files'
                : 'Files you process will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_selectedFilter != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedFilter = null;
                });
                ref
                    .read(recentFilesNotifierProvider.notifier)
                    .loadRecentFiles();
              },
              child: Text('Show All Files'),
            ),
        ],
      ),
    );
  }

  void _showFileOperations(RecentFileModel file) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FileOperationsBottomSheet(file: file),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear_all':
        _showClearAllDialog();
        break;
      case 'delete_old':
        _showDeleteOldDialog();
        break;
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Recent Files'),
        content: Text(
          'This will remove all recent file records. The actual files will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(recentFilesNotifierProvider.notifier)
                  .clearAllRecentFiles();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('All recent files cleared'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showDeleteOldDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Old Files'),
        content: Text(
          'This will remove recent file records older than 30 days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(recentFilesNotifierProvider.notifier)
                  .deleteOldRecentFiles(keepDays: 30);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Old files cleaned up'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: Text('Delete'),
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
}

// Stats Card Widget
class _StatsCard extends StatelessWidget {
  final String title;
  final String count;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _StatsCard({
    required this.title,
    required this.count,
    required this.subtitle,
    required this.color,
    required this.icon,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Icon(
                icon,
                color: color,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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

// Recent File Card Widget
class RecentFileCard extends StatelessWidget {
  final RecentFileModel item;
  final VoidCallback onTap;

  const RecentFileCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getOperationColor(item.operationType);
    final icon = _getOperationIcon(item.operationType);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Operation icon
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

              // File info
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
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _getSizeInfo(),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.timeAgo,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        const Spacer(),
                        if (item.resultFilePath != null) ...[
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Saved',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // More button
              Icon(
                Icons.more_vert,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSizeInfo() {
    if (item.resultSize != null && item.resultSize != item.originalSize) {
      return '${item.originalSize} → ${item.resultSize}';
    }
    return item.originalSize;
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
