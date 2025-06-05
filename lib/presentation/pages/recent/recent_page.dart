// lib/presentation/pages/recent/recent_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/presentation/pages/recent/recent_file_card.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/recent_file_model.dart';
import '../../providers/recent_files_provider.dart';
import '../../widgets/common/custom_snackbar.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(recentFilesNotifierProvider.notifier)
          .loadRecentFiles(isInitial: true);
      ref.read(recentFilesNotifierProvider.notifier).loadStats();
    });

    // Add scroll listener for infinite scroll (optional)
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(recentFilesNotifierProvider);
      if (state.canLoadMore) {
        ref.read(recentFilesNotifierProvider.notifier).loadMoreFiles();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final state = ref.watch(recentFilesNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
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
      backgroundColor: AppColors.surface(context),
      centerTitle: false,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.view_list,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Files',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
              ),
              if (state.totalCount > 0)
                Text(
                  state.showingAllFiles
                      ? 'Showing all ${state.totalCount} files'
                      : '${state.recentFiles.length} of ${state.totalCount} files',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                ),
            ],
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
              color: _selectedFilter != null || _showFilterChips
                  ? AppColors.primary(context)
                  : AppColors.textSecondary(context),
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
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary(context)),
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
                leading: Icon(Icons.clear_all, color: AppColors.error(context)),
                title: Text('Clear All',
                    style: TextStyle(color: AppColors.error(context))),
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
      controller: _scrollController,
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

          // Load more / View all section
          if (state.hasRecentFiles) ...[
            const SizedBox(height: 24),
            _buildLoadMoreSection(state),
          ],

          // Add bottom padding for scroll
          const SizedBox(height: 100),
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
                    .loadRecentFiles(isInitial: true);
              },
              selectedColor: AppColors.primary(context).withOpacity(0.2),
              checkmarkColor: AppColors.primary(context),
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
                      .loadRecentFiles(
                        operationType: _selectedFilter,
                        isInitial: true,
                      );
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
                color: AppColors.textPrimary(context),
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
                color: AppColors.primary(context),
                icon: Icons.today,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatsCard(
                title: 'This Week',
                count: state.stats['thisWeek']?.toString() ?? '0',
                subtitle: 'files processed',
                color: AppColors.secondary(context),
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
                    color: AppColors.textPrimary(context),
                  ),
            ),
            // Quick toggle between limited and all files
            if (state.totalCount > 10 && !state.showingAllFiles)
              TextButton(
                onPressed: () {
                  ref.read(recentFilesNotifierProvider.notifier).showAllFiles();
                },
                child: Text(state.viewAllButtonText),
              ),
            if (state.showingAllFiles)
              TextButton(
                onPressed: () {
                  ref
                      .read(recentFilesNotifierProvider.notifier)
                      .showLimitedFiles();
                },
                child: Text('Show Less'),
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

  Widget _buildLoadMoreSection(RecentFilesState state) {
    // Don't show load more section if showing all files
    if (state.showingAllFiles) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Load more button
        if (state.canLoadMore) ...[
          Container(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: state.isLoadingMore
                  ? null
                  : () {
                      ref
                          .read(recentFilesNotifierProvider.notifier)
                          .loadMoreFiles();
                    },
              icon: state.isLoadingMore
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary(context)),
                      ),
                    )
                  : Icon(Icons.expand_more),
              label: Text(
                state.isLoadingMore ? 'Loading...' : state.loadMoreButtonText,
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: AppColors.primary(context)),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // View all button (alternative to load more)
        if (state.hasMoreFiles && !state.isLoadingMore) ...[
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(recentFilesNotifierProvider.notifier).showAllFiles();
              },
              icon: Icon(Icons.visibility),
              label: Text(state.viewAllButtonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],

        // No more files indicator
        if (!state.hasMoreFiles && !state.showingAllFiles) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success(context),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'All files loaded',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary(context),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],

        // Loading more indicator
        if (state.isLoadingMore) ...[
          const SizedBox(height: 16),
          Center(
            child: LoadingWidget(message: 'Loading more files...'),
          ),
        ],
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
              color: AppColors.primary(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_outlined,
              size: 64,
              color: AppColors.primary(context).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedFilter != null
                ? 'No ${_getOperationDisplayName(_selectedFilter!).toLowerCase()} files'
                : 'No recent files',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter != null
                ? 'Try a different filter or process some files'
                : 'Files you process will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary(context),
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
                    .loadRecentFiles(isInitial: true);
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
                CustomSnackbar.show(
                  context: context,
                  message: 'All recent files cleared',
                  type: SnackbarType.success,
                  duration: const Duration(seconds: 4),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error(context),
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
                CustomSnackbar.show(
                  context: context,
                  message: 'Old files cleaned up',
                  type: SnackbarType.success,
                  duration: const Duration(seconds: 4),
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
                  color: AppColors.textSecondary(context),
                ),
          ),
        ],
      ),
    );
  }
}
