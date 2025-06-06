// lib/presentation/pages/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';
import '../../providers/app_info_provider.dart';
import '../../widgets/about_support_section.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/files_storage_section.dart';
import '../../widgets/general_settings_section.dart';
import '../../widgets/privacy_security_section.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  void initState() {
    super.initState();

    // Listen for settings errors
    ref.listenManual(settingsNotifierProvider, (previous, next) {
      if (next.hasError && mounted) {
        CustomSnackbar.show(
          context: context,
          message: next.error!,
          type: SnackbarType.failure,
        );
        ref.read(settingsNotifierProvider.notifier).clearError();
      }
    });

    // Listen for app info errors
    ref.listenManual(appInfoNotifierProvider, (previous, next) {
      if (next.hasError && mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Failed to load app information',
          type: SnackbarType.failure,
        );
        ref.read(appInfoNotifierProvider.notifier).clearError();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsNotifierProvider);
    final appInfoState = ref.watch(appInfoNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: _buildAppBar(context, appInfoState),
      body: settingsState.isLoading
          ? const Center(child: LoadingWidget(message: 'Loading settings...'))
          : _buildBody(context, settingsState),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppInfoState appInfo) {
    return AppBar(
      backgroundColor: AppColors.surface(context),
      centerTitle: false,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textPrimary(context),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
              ),
              Text(
                'Customize your experience',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Theme mode quick toggle
        IconButton(
          onPressed: () => _quickToggleTheme(),
          icon: Icon(
            _getThemeIcon(ref.read(settingsNotifierProvider).themeMode),
            color: AppColors.textSecondary(context),
          ),
          tooltip: 'Toggle theme',
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'refresh_app_info',
              child: ListTile(
                leading: Icon(Icons.refresh, color: AppColors.info(context)),
                title: Text('Refresh App Info'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'reset_settings',
              child: ListTile(
                leading: Icon(Icons.restore, color: AppColors.warning(context)),
                title: Text('Reset Settings'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'export_settings',
              child: ListTile(
                leading: Icon(Icons.download, color: AppColors.info(context)),
                title: Text('Export Settings'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          icon: Icon(
            Icons.more_vert,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, SettingsState state) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref.read(settingsNotifierProvider.notifier).refreshStorageInfo(),
          ref.read(appInfoNotifierProvider.notifier).refreshAppInfo(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick stats header
            _buildQuickStats(context, state),
            const SizedBox(height: 24),

            // General Settings
            GeneralSettingsSection(state: state),
            const SizedBox(height: 20),

            // Files & Storage
            FilesStorageSection(state: state),
            const SizedBox(height: 20),

            // Privacy & Security
            PrivacySecuritySection(state: state),
            const SizedBox(height: 20),

            // About & Support
            AboutSupportSection(state: state),

            // Bottom padding
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, SettingsState state) {
    if (state.storageInfo == null) {
      return const SizedBox.shrink();
    }

    final storage = state.storageInfo!;
    final appInfo = ref.watch(appInfoNotifierProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary(context),
            AppColors.primary(context).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary(context).withOpacity(0.3),
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
                      'Storage Usage',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${storage.totalFiles} files • ${storage.formattedSize}',
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
                  Icons.storage,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Files',
                  storage.totalFiles.toString(),
                  Icons.description,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Recent',
                  storage.recentFilesCount.toString(),
                  Icons.history,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Version',
                  appInfo.version,
                  Icons.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String label, String value, IconData icon) {
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

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  void _quickToggleTheme() {
    final currentTheme = ref.read(settingsNotifierProvider).themeMode;
    ThemeMode newTheme;

    switch (currentTheme) {
      case ThemeMode.light:
        newTheme = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newTheme = ThemeMode.system;
        break;
      case ThemeMode.system:
        newTheme = ThemeMode.light;
        break;
    }

    ref.read(settingsNotifierProvider.notifier).updateThemeMode(newTheme);

    CustomSnackbar.show(
      context: context,
      message: 'Theme changed to ${_getThemeName(newTheme)}',
      type: SnackbarType.info,
      duration: const Duration(seconds: 2),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh_app_info':
        ref.read(appInfoNotifierProvider.notifier).refreshAppInfo();
        CustomSnackbar.show(
          context: context,
          message: 'App information refreshed',
          type: SnackbarType.success,
        );
        break;
      case 'reset_settings':
        _showResetSettingsDialog();
        break;
      case 'export_settings':
        _exportSettings();
        break;
    }
  }

  void _showResetSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.warning(context)),
            const SizedBox(width: 8),
            Text('Reset Settings'),
          ],
        ),
        content: Text(
          'This will reset all settings to their default values. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning(context),
            ),
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    // TODO: Implement reset settings functionality
    CustomSnackbar.show(
      context: context,
      message: 'Reset settings functionality not implemented yet',
      type: SnackbarType.info,
    );
  }

  void _exportSettings() {
    // TODO: Implement export settings functionality
    CustomSnackbar.show(
      context: context,
      message: 'Export settings functionality not implemented yet',
      type: SnackbarType.info,
    );
  }
}
