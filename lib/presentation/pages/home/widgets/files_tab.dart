// lib/presentation/pages/home/widgets/files_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';
import 'package:megapdf_client/data/models/file_item.dart';
import 'package:megapdf_client/presentation/providers/file_manager_provider.dart';
import '../../../widgets/common/custom_snackbar.dart';
import 'file_list_item.dart';
import 'file_grid_item.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/error_widget.dart';

class FilesTab extends ConsumerWidget {
  final FileManagerState fileState;
  final String searchQuery;
  final bool isGridView;

  const FilesTab({
    super.key,
    required this.fileState,
    required this.searchQuery,
    required this.isGridView,
  });

  List<FileItem> _getFilteredFiles(List<FileItem> files) {
    if (searchQuery.isEmpty) return files;
    return files
        .where((file) =>
            file.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredFiles = _getFilteredFiles(fileState.fileItems);

    return Column(
      children: [
        if (searchQuery.isNotEmpty || fileState.hasFiles)
          _buildSearchBar(context),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(fileManagerNotifierProvider.notifier).loadFiles();
            },
            child: fileState.isLoading
                ? _buildLoadingState()
                : fileState.error != null
                    ? _buildErrorState(context, ref)
                    : filteredFiles.isEmpty
                        ? _buildEmptyFilesState(context, ref)
                        : isGridView
                            ? _buildFilesGrid(filteredFiles)
                            : _buildFilesList(filteredFiles),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: LoadingWidget(message: 'Loading files...'),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: CustomErrorWidget(
        message: fileState.error!,
        onRetry: () {
          ref.read(fileManagerNotifierProvider.notifier).loadFiles();
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search files...',
          border: InputBorder.none,
          prefixIcon:
              Icon(Icons.search, color: AppColors.textSecondary(context)),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    // This should ideally trigger a callback to clear the search
                  },
                  icon: Icon(Icons.clear,
                      color: AppColors.textSecondary(context)),
                )
              : null,
        ),
        onChanged: (value) {
          // This should ideally trigger a callback to update the search query
        },
      ),
    );
  }

  Widget _buildFilesList(List<FileItem> files) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: files.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final file = files[index];
        return FileListItem(file: file);
      },
    );
  }

  Widget _buildFilesGrid(List<FileItem> files) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return FileGridItem(file: file);
      },
    );
  }

  Widget _buildEmptyFilesState(BuildContext context, WidgetRef ref) {
    if (searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary(context).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No files found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            size: 64,
            color: AppColors.textSecondary(context).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No files yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Import files to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showImportDialog(context, ref);
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Add Files'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    CustomSnackbar.show(
      context: context,
      message: 'Import files coming soon!',
      type: SnackbarType.info,
      duration: const Duration(seconds: 4),
    );
  }
}
