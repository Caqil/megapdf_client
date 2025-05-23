// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/file_manager_provider.dart';
import '../../providers/recent_files_provider.dart';
import '../../widgets/common/custom_snackbar.dart';
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
      // Load files and recent operations
      ref.read(fileManagerNotifierProvider.notifier).loadFiles();
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
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndImportFile,
        backgroundColor: AppColors.primary(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _pickAndImportFile() async {
    try {
      // Show file picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          // Import file to app
          final success = await ref
              .read(fileManagerNotifierProvider.notifier)
              .importFile(file.path!);

          if (success) {
            CustomSnackbar.show(
              context: context,
              message: 'File imported successfully',
              type: SnackbarType.success,
              duration: const Duration(seconds: 3),
            );
          }
        }
      }
    } catch (e) {
      CustomSnackbar.show(
        context: context,
        message: 'Failed to import file: $e',
        type: SnackbarType.failure,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
