// lib/presentation/pages/profile/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:megapdf_client/data/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_snackbar.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _hasStoragePermission = false;
  String? _megaPdfPath;

  @override
  void initState() {
    super.initState();
    _checkStoragePermission();
  }

  Future<void> _checkStoragePermission() async {
    final storageService = StorageService();
    final hasPermission = await storageService.checkPermissions();
    final path = await storageService.getMegaPDFPath();

    setState(() {
      _hasStoragePermission = hasPermission;
      _megaPdfPath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile section
            _buildUserProfileCard(),

            const SizedBox(height: 24),

            // Storage section
            _buildStorageSection(),

            const SizedBox(height: 24),

            // Settings section
            _buildSettingsSection(),

            const SizedBox(height: 24),

            // Support section
            _buildSupportSection(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary(context).withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 40,
                color: AppColors.primary(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guest User',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: AppColors.warning(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Free Plan',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {
                // Sign in functionality
                _showSnackBar('Sign in coming soon!');
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary(context).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.storage,
                  color: AppColors.primary(context),
                ),
                const SizedBox(width: 8),
                Text(
                  'Storage',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary(context),
                      ),
                ),
              ],
            ),
          ),

          // Permission status
          ListTile(
            leading: Icon(
              _hasStoragePermission ? Icons.check_circle : Icons.error,
              color: _hasStoragePermission
                  ? AppColors.success(context)
                  : AppColors.error(context),
            ),
            title: Text(
              'Storage Permission',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: Text(
              _hasStoragePermission
                  ? 'Permission granted'
                  : 'Storage permission required',
            ),
            trailing: _hasStoragePermission
                ? null
                : TextButton(
                    onPressed: _requestStoragePermission,
                    child: const Text('Grant'),
                  ),
          ),

          // Storage path
          if (_hasStoragePermission && _megaPdfPath != null)
            ListTile(
              leading: Icon(
                Icons.folder,
                color: AppColors.warning(context),
              ),
              title: Text(
                'Files Location',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              subtitle: Text(
                _formatPath(_megaPdfPath!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () => context.push('/storage'),
                tooltip: 'Open Files',
              ),
            ),

          // Storage management
          ListTile(
            leading: Icon(
              Icons.folder_open,
              color: AppColors.secondary(context),
            ),
            title: Text(
              'Storage Management',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: const Text('Manage your files and storage space'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/storage'),
          ),

          // Storage options
          if (_hasStoragePermission)
            ListTile(
              leading: Icon(
                Icons.cleaning_services,
                color: AppColors.info(context),
              ),
              title: Text(
                'Clean Storage',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              subtitle: const Text('Remove temporary files'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Clean storage functionality
                _showSnackBar('Cleaning storage...');
              },
            ),

          const Divider(height: 1),

          // Storage settings
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSwitchTile(
                  'Save files to Downloads',
                  'Files will be saved to your Downloads folder',
                  true,
                  (value) {
                    // Toggle save location
                    _showSnackBar(
                      value
                          ? 'Files will be saved to Downloads'
                          : 'Files will be saved to app storage',
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildSwitchTile(
                  'Add timestamp to filenames',
                  'Add date and time to saved files',
                  true,
                  (value) {
                    // Toggle timestamp setting
                    _showSnackBar(
                      value
                          ? 'Timestamps will be added to filenames'
                          : 'Timestamps will not be added',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary(context).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.settings,
                  color: AppColors.secondary(context),
                ),
                const SizedBox(width: 8),
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary(context),
                      ),
                ),
              ],
            ),
          ),

          // Theme setting
          _buildSwitchTile(
            'Dark Mode',
            'Switch between light and dark theme',
            false,
            (value) {
              // Toggle theme
              _showSnackBar(
                value ? 'Dark mode enabled' : 'Light mode enabled',
              );
            },
          ),

          // Notifications setting
          _buildSwitchTile(
            'Notifications',
            'Receive notifications when files are processed',
            true,
            (value) {
              // Toggle notifications
              _showSnackBar(
                value ? 'Notifications enabled' : 'Notifications disabled',
              );
            },
          ),

          // Analytics setting
          _buildSwitchTile(
            'Analytics',
            'Send anonymous usage data to help improve the app',
            true,
            (value) {
              // Toggle analytics
              _showSnackBar(
                value ? 'Analytics enabled' : 'Analytics disabled',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info(context).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.help,
                  color: AppColors.info(context),
                ),
                const SizedBox(width: 8),
                Text(
                  'Support',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.info(context),
                      ),
                ),
              ],
            ),
          ),

          // Help and support
          ListTile(
            leading: Icon(
              Icons.help_center,
              color: AppColors.info(context),
            ),
            title: const Text('Help Center'),
            subtitle: const Text('Get help with using the app'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Open help center
              _showSnackBar('Help Center coming soon!');
            },
          ),

          // Privacy policy
          ListTile(
            leading: Icon(
              Icons.privacy_tip,
              color: AppColors.info(context),
            ),
            title: const Text('Privacy Policy'),
            subtitle: const Text('Learn how we protect your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Open privacy policy
              _showSnackBar('Privacy Policy coming soon!');
            },
          ),

          // Terms of service
          ListTile(
            leading: Icon(
              Icons.description,
              color: AppColors.info(context),
            ),
            title: const Text('Terms of Service'),
            subtitle: const Text('Read our terms and conditions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Open terms of service
              _showSnackBar('Terms of Service coming soon!');
            },
          ),

          // App version
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'MegaPDF v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool initialValue,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(subtitle),
      value: initialValue,
      onChanged: onChanged,
      activeColor: AppColors.primary(context),
    );
  }

  Future<void> _requestStoragePermission() async {
    final storageService = StorageService();
    final granted = await storageService.requestPermissions(context);

    setState(() {
      _hasStoragePermission = granted;
    });

    if (granted) {
      // Get MegaPDF directory path
      final path = await storageService.getMegaPDFPath();
      setState(() {
        _megaPdfPath = path;
      });

      _showSnackBar('Storage permission granted');
    } else {
      _showSnackBar('Storage permission required to save files', isError: true);
    }
  }

  String _formatPath(String path) {
    if (path.contains('/storage/emulated/0')) {
      return path.replaceFirst('/storage/emulated/0', 'Internal Storage');
    }
    return path;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    CustomSnackbar.show(
      context: context,
      message: message,
      type: isError ? SnackbarType.failure : SnackbarType.success,
      duration: const Duration(seconds: 4),
    );
  }
}
