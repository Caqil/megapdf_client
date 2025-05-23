import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:megapdf_client/presentation/pages/home/widgets/folder_actions_bottom_sheet.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/file_manager_provider.dart';
import '../../providers/recent_files_provider.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/welcome_header.dart';
import 'widgets/home_tab_bar.dart';
import 'widgets/quick_access_tab.dart';
import 'widgets/files_tab.dart';
import 'widgets/recent_tab.dart';

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

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isNotEmpty) _tabController.animateTo(1); // Switch to Files tab
    });
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fileManagerState = ref.watch(fileManagerNotifierProvider);
    final recentFilesState = ref.watch(recentFilesNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: HomeAppBar(
        currentTabIndex: _currentTabIndex,
        isGridView: _isGridView,
        onSearch: _updateSearchQuery,
        onToggleView: _toggleViewMode,
        onProfileTap: () => context.go('/profile'),
      ),
      body: Column(
        children: [
          WelcomeHeader(
            fileState: fileManagerState,
            recentState: recentFilesState,
          ),
          HomeTabBar(controller: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                QuickAccessTab(),
                FilesTab(
                  fileState: fileManagerState,
                  searchQuery: _searchQuery,
                  isGridView: _isGridView,
                ),
                RecentTab(recentState: recentFilesState),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOptionsBottomSheet(),
        backgroundColor: AppColors.primary(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Create',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
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
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.create_new_folder),
              title: const Text('New Folder'),
              onTap: () {
                Navigator.pop(context);
                _showCreateFolderDialog();
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

  void _showCreateFolderDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateFolderDialog(
        onCreateFolder: (name) {
          ref.read(fileManagerNotifierProvider.notifier).createFolder(name);
        },
      ),
    );
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
}
