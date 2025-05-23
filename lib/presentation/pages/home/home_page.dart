// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/file_item.dart';
import '../../providers/file_manager_provider.dart';
import '../../providers/recent_files_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/dialogs/create_folder_dialog.dart';
import '../pdf_viewer/pdf_viewer_page.dart';
import 'widgets/file_manager_view.dart';
import 'widgets/feature_grid.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  String _searchQuery = '';
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });

    // Load data when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fileManagerNotifierProvider.notifier).loadRootFolder();
      ref.read(recentFilesNotifierProvider.notifier).loadRecentFiles();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileManagerState = ref.watch(fileManagerNotifierProvider);
    final recentFilesState = ref.watch(recentFilesNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Welcome header with stats
          _buildWelcomeHeader(fileManagerState, recentFilesState),

          // Tab bar
          _buildTabBar(),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuickAccessTab(),
                _buildFilesTab(fileManagerState),
                _buildRecentTab(recentFilesState),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MegaPDF',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              Text(
                'Your PDF Workspace',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _showSearchDialog(context),
          icon: const Icon(Icons.search),
          color: AppColors.textSecondary,
          tooltip: 'Search Files',
        ),
        if (_currentTabIndex == 1) // Files tab
          IconButton(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            color: AppColors.textSecondary,
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
        IconButton(
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.account_circle),
          color: AppColors.textSecondary,
          tooltip: 'Profile',
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader(
      FileManagerState fileState, RecentFilesState recentState) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your PDF files with ease',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Files',
                  fileState.fileCount.toString(),
                  Icons.description,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Folders',
                  fileState.folderCount.toString(),
                  Icons.folder,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Recent',
                  recentState.recentFiles.length.toString(),
                  Icons.history,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Quick Tools'),
          Tab(text: 'My Files'),
          Tab(text: 'Recent'),
        ],
      ),
    );
  }

  Widget _buildQuickAccessTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick actions section
          _buildSectionHeader('Quick Actions', Icons.flash_on),
          const SizedBox(height: 16),
          _buildQuickActionsGrid(),

          const SizedBox(height: 24),

          // PDF Tools section
          const FeatureGrid(),

          const SizedBox(height: 24),

          // Tips section
          _buildTipsSection(),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildQuickActionCard(
          'Select File',
          Icons.upload_file,
          AppColors.primary,
          () => _showFilePickerBottomSheet(),
        ),
        _buildQuickActionCard(
          'Create Folder',
          Icons.create_new_folder,
          AppColors.secondary,
          () => _showCreateFolderDialog(context),
        ),
        _buildQuickActionCard(
          'Scan to PDF',
          Icons.document_scanner,
          AppColors.warning,
          () => _showSnackBar('Scan to PDF coming soon!'),
        ),
        _buildQuickActionCard(
          'Import Files',
          Icons.folder_open,
          AppColors.info,
          () => _showSnackBar('Import files coming soon!'),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilesTab(FileManagerState fileState) {
    final filteredFiles = _getFilteredFiles(fileState.fileItems);

    return Column(
      children: [
        // Path breadcrumb and controls
        if (fileState.folderPath.isNotEmpty) _buildBreadcrumb(fileState),

        // Search and filter bar
        if (_searchQuery.isNotEmpty || fileState.hasFiles) _buildSearchBar(),

        // File list/grid
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(fileManagerNotifierProvider.notifier)
                  .loadRootFolder();
            },
            child: filteredFiles.isEmpty
                ? _buildEmptyFilesState(fileState)
                : _isGridView
                    ? _buildFilesGrid(filteredFiles)
                    : _buildFilesList(filteredFiles),
          ),
        ),
      ],
    );
  }

  Widget _buildBreadcrumb(FileManagerState fileState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.surface,
      child: Row(
        children: [
          if (ref.read(fileManagerNotifierProvider.notifier).canGoUp())
            IconButton(
              onPressed: () =>
                  ref.read(fileManagerNotifierProvider.notifier).navigateUp(),
              icon: const Icon(Icons.arrow_back),
              iconSize: 20,
              color: AppColors.primary,
            ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: fileState.folderPath.asMap().entries.map((entry) {
                  final index = entry.key;
                  final folder = entry.value;
                  final isLast = index == fileState.folderPath.length - 1;

                  return Row(
                    children: [
                      GestureDetector(
                        onTap: isLast
                            ? null
                            : () {
                                ref
                                    .read(fileManagerNotifierProvider.notifier)
                                    .navigateToFolder(folder.id!);
                              },
                        child: Text(
                          folder.name,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isLast
                                        ? AppColors.textPrimary
                                        : AppColors.primary,
                                    fontWeight: isLast
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                        ),
                      ),
                      if (!isLast) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search files and folders...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: Icon(Icons.clear, color: AppColors.textSecondary),
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
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
        return _buildFileListItem(file);
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
        return _buildFileGridItem(file);
      },
    );
  }

  Widget _buildFileListItem(FileItem file) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleFileTap(file),
        onLongPress: () => _showFileContextMenu(context, file),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
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
                        if (!file.isDirectory) ...[
                          Text(
                            file.formattedSize,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                          ),
                          const Text(' • '),
                        ],
                        Text(
                          file.formattedDate,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleFileAction(value, file),
                itemBuilder: (context) => [
                  if (file.isPdf) ...[
                    PopupMenuItem(
                      value: 'open',
                      child: ListTile(
                        leading: Icon(Icons.open_in_new,
                            size: 20, color: AppColors.primary),
                        title: const Text('Open'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  PopupMenuItem(
                    value: 'rename',
                    child: ListTile(
                      leading:
                          Icon(Icons.edit, size: 20, color: AppColors.info),
                      title: const Text('Rename'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'move',
                    child: ListTile(
                      leading: Icon(Icons.drive_file_move,
                          size: 20, color: AppColors.warning),
                      title: const Text('Move'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading:
                          Icon(Icons.delete, size: 20, color: AppColors.error),
                      title: Text('Delete',
                          style: TextStyle(color: AppColors.error)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileGridItem(FileItem file) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleFileTap(file),
        onLongPress: () => _showFileContextMenu(context, file),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File icon
              Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: file.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  file.icon,
                  color: file.iconColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 12),
              // File name
              Text(
                file.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // File info
              if (!file.isDirectory)
                Text(
                  file.formattedSize,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              Text(
                file.formattedDate,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyFilesState(FileManagerState fileState) {
    if (fileState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No files found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
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
            Icons.folder_open_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No files yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a folder or import files to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateOptionsBottomSheet(),
            icon: const Icon(Icons.add),
            label: const Text('Add Files'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTab(RecentFilesState recentState) {
    if (recentState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (recentState.recentFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: recentState.recentFiles.take(20).length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final file = recentState.recentFiles[index];
        return _buildRecentFileCard(file);
      },
    );
  }

  Widget _buildRecentFileCard(recentFile) {
    final color = _getOperationColor(recentFile.operationType);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (recentFile.resultFilePath != null) {
            _openPDFFile(
                recentFile.resultFilePath!, recentFile.originalFileName);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
                child: Icon(_getOperationIcon(recentFile.operationType),
                    color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recentFile.originalFileName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
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
                            recentFile.operation,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          recentFile.timeAgo,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (recentFile.resultFilePath != null)
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: AppColors.info, size: 24),
              const SizedBox(width: 12),
              Text(
                'Pro Tips',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('Tap on PDF files to open them in the viewer'),
          _buildTipItem('Long press on files for quick actions'),
          _buildTipItem('Use search to quickly find your files'),
          _buildTipItem('Switch between list and grid view in Files tab'),
          _buildTipItem('Organize files in folders for better management'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.info,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showCreateOptionsBottomSheet(),
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        'Create',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  // Helper methods
  List<FileItem> _getFilteredFiles(List<FileItem> files) {
    if (_searchQuery.isEmpty) return files;

    return files
        .where((file) =>
            file.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _handleFileTap(FileItem file) {
    if (file.isDirectory) {
      if (file.folderId != null) {
        ref
            .read(fileManagerNotifierProvider.notifier)
            .navigateToFolder(file.folderId!);
      }
    } else if (file.isPdf) {
      _openPDFFile(file.path, file.name);
    } else {
      _showFileOptionsBottomSheet(context, file);
    }
  }

  void _handleFileAction(String action, FileItem file) {
    switch (action) {
      case 'open':
        if (file.isPdf) {
          _openPDFFile(file.path, file.name);
        }
        break;
      case 'rename':
        _showRenameDialog(context, file);
        break;
      case 'move':
        _showMoveDialog(context, file);
        break;
      case 'delete':
        _showDeleteDialog(context, file);
        break;
    }
  }

  void _openPDFFile(String filePath, String fileName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(
          filePath: filePath,
          fileName: fileName,
        ),
      ),
    );
  }

  // Action methods
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Files'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter file name...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
            Navigator.pop(context);
            // Switch to files tab to show search results
            _tabController.animateTo(1);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateFolderDialog(
        onCreateFolder: (name) {
          ref.read(fileManagerNotifierProvider.notifier).createFolder(name);
        },
      ),
    );
  }

  void _showFilePickerBottomSheet() {
    _showSnackBar('File picker coming soon!');
  }

  void _showCreateOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create New',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.create_new_folder),
              title: const Text('New Folder'),
              onTap: () {
                Navigator.pop(context);
                _showCreateFolderDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Import File'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Import file coming soon!');
              },
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner),
              title: const Text('Scan Document'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Scan document coming soon!');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFileOptionsBottomSheet(BuildContext context, FileItem file) {
    _showSnackBar('File options coming soon!');
  }

  void _showFileContextMenu(BuildContext context, FileItem file) {
    _showSnackBar('File context menu coming soon!');
  }

  void _showRenameDialog(BuildContext context, FileItem file) {
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
                    .renameItem(file, newName);
              }
              Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showMoveDialog(BuildContext context, FileItem file) {
    _showSnackBar('Move functionality coming soon!');
  }

  void _showDeleteDialog(BuildContext context, FileItem file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${file.isDirectory ? 'Folder' : 'File'}'),
        content: Text(
          'Are you sure you want to delete "${file.name}"?'
          '${file.isDirectory ? ' This will also delete all contents inside.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(fileManagerNotifierProvider.notifier).deleteItem(file);
              Navigator.pop(context);
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

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
