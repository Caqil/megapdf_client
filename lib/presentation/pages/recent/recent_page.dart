// lib/presentation/pages/recent/recent_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';

class RecentPage extends ConsumerStatefulWidget {
  const RecentPage({super.key});

  @override
  ConsumerState<RecentPage> createState() => _RecentPageState();
}

class _RecentPageState extends ConsumerState<RecentPage> {
  @override
  Widget build(BuildContext context) {
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
              }
            },
            itemBuilder: (context) => [
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats cards
            Row(
              children: [
                Expanded(
                  child: _StatsCard(
                    title: 'Today',
                    count: '5',
                    subtitle: 'files processed',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatsCard(
                    title: 'This Week',
                    count: '23',
                    subtitle: 'files processed',
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent files list
            _buildRecentFilesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFilesList() {
    // Mock recent files data - replace with actual data from provider
    final recentFiles = [
      _RecentFileItem(
        name: 'document_compressed.pdf',
        operation: 'Compressed',
        time: '2 hours ago',
        originalSize: '5.2 MB',
        finalSize: '2.1 MB',
        icon: Icons.compress,
        color: AppColors.compressColor,
      ),
      _RecentFileItem(
        name: 'presentation_merged.pdf',
        operation: 'Merged',
        time: 'Yesterday',
        originalSize: '3 files',
        finalSize: '8.5 MB',
        icon: Icons.merge,
        color: AppColors.mergeColor,
      ),
      _RecentFileItem(
        name: 'report_protected.pdf',
        operation: 'Protected',
        time: '2 days ago',
        originalSize: '4.1 MB',
        finalSize: '4.1 MB',
        icon: Icons.lock,
        color: AppColors.protectColor,
      ),
      _RecentFileItem(
        name: 'invoice_split.pdf',
        operation: 'Split',
        time: '3 days ago',
        originalSize: '12.3 MB',
        finalSize: '5 parts',
        icon: Icons.call_split,
        color: AppColors.splitColor,
      ),
    ];

    if (recentFiles.isEmpty) {
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
          itemCount: recentFiles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final file = recentFiles[index];
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
            onPressed: () {
              // Implement clear recent files
              Navigator.pop(context);
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
                  selected: true,
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Compress'),
                  selected: false,
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Merge'),
                  selected: false,
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Split'),
                  selected: false,
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Convert'),
                  selected: false,
                  onSelected: (selected) {},
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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

class _RecentFileCard extends StatelessWidget {
  final _RecentFileItem item;

  const _RecentFileCard({required this.item});

  @override
  Widget build(BuildContext context) {
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
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
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
                        color: item.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.operation,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: item.color,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.originalSize} → ${item.finalSize}',
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
                item.time,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.more_vert,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentFileItem {
  final String name;
  final String operation;
  final String time;
  final String originalSize;
  final String finalSize;
  final IconData icon;
  final Color color;

  _RecentFileItem({
    required this.name,
    required this.operation,
    required this.time,
    required this.originalSize,
    required this.finalSize,
    required this.icon,
    required this.color,
  });
}
