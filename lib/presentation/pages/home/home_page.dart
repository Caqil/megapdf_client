// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/file_manager_provider.dart';
import '../../providers/recent_files_provider.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/welcome_header.dart';
import 'widgets/quick_access_tab.dart';

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
        onProfileTap: () => context.go('/settings'),
      ),
      body: Column(
        children: [
          WelcomeHeader(
            fileState: fileManagerState,
            recentState: recentFilesState,
          ),
          Expanded(
            child: QuickAccessTab(),
          ),
        ],
      ),
    );
  }
}
