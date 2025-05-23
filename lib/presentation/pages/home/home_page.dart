// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/file_manager_provider.dart';
import '../../providers/recent_files_provider.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../widgets/dialogs/folder_creation_dialog.dart'; // Import the improved dialog
import 'widgets/home_app_bar.dart';
import 'widgets/welcome_header.dart';
import 'widgets/home_tab_bar.dart';
import 'widgets/quick_access_tab.dart';
import 'widgets/files_tab.dart';
import 'widgets/recent_tab.dart';
import 'widgets/folder_actions_bottom_sheet.dart';

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
      // The file manager provider will auto-load the root folder in its build method
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
      builder: (context) => FolderActionsBottomSheet(
        onCreateFolder: _showCreateFolderDialog,
        onImportFiles: () {},
        onSettings: () => context.go('/settings'),
      ),
    );
  }

  void _showCreateFolderDialog() {
    // Use our improved folder creation dialog
    showDialog(
      context: context,
      builder: (context) => CreateFolderDialog(
        onCreateFolder: (name) {
          // Show a loading indicator while the folder is being created
          _showLoadingDialog('Creating folder "$name"...');

          // Create the folder
          ref
              .read(fileManagerNotifierProvider.notifier)
              .createFolder(name)
              .then((_) {
            // Hide the loading indicator
            Navigator.of(context, rootNavigator: true).pop();
          }).catchError((error) {
            // Hide the loading indicator
            Navigator.of(context, rootNavigator: true).pop();
          });
        },
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
