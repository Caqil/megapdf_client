// lib/presentation/pages/settings/widgets/privacy_security_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../pages/settings/widgets/privacy_policy_widget.dart';
import '../pages/settings/widgets/terms_of_service_widget.dart';
import '../providers/settings_provider.dart';
import 'settings_section_widget.dart';

class PrivacySecuritySection extends ConsumerWidget {
  final SettingsState state;

  const PrivacySecuritySection({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsSectionWidget(
      title: 'Privacy & Security',
      icon: Icons.security,
      iconColor: AppColors.success(context),
      children: [
        // Analytics Setting
        SettingsItemWidget(
          icon: Icons.analytics,
          iconColor: AppColors.info(context),
          title: 'Analytics',
          subtitle: 'Help improve the app by sharing usage data',
          trailing: Switch(
            value: state.analyticsEnabled,
            onChanged: (value) {
              ref
                  .read(settingsNotifierProvider.notifier)
                  .updateAnalyticsEnabled(value);
            },
            activeColor: AppColors.primary(context),
          ),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Data Collection Info
        SettingsItemWidget(
          icon: Icons.info_outline,
          iconColor: AppColors.primary(context),
          title: 'What Data We Collect',
          subtitle: 'Learn about data collection and usage',
          onTap: () => _showDataCollectionInfo(context),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Privacy Policy
        SettingsItemWidget(
          icon: Icons.privacy_tip,
          iconColor: AppColors.secondary(context),
          title: 'Privacy Policy',
          subtitle: 'Our commitment to your privacy',
          onTap: () => _showPrivacyPolicy(context),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Terms of Service
        SettingsItemWidget(
          icon: Icons.description,
          iconColor: AppColors.warning(context),
          title: 'Terms of Service',
          subtitle: 'Terms and conditions of use',
          onTap: () => _showTermsOfService(context),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Security Features
        SettingsItemWidget(
          icon: Icons.shield,
          iconColor: AppColors.success(context),
          title: 'Security Features',
          subtitle: 'Local processing, encrypted storage',
          onTap: () => _showSecurityInfo(context),
          trailing: Icon(
            Icons.verified_user,
            color: AppColors.success(context),
            size: 20,
          ),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Data Export/Download
        SettingsItemWidget(
          icon: Icons.download,
          iconColor: AppColors.info(context),
          title: 'Download My Data',
          subtitle: 'Export your data and settings',
          onTap: () => _exportUserData(context),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Delete Account/Data
        SettingsItemWidget(
          icon: Icons.delete_forever,
          iconColor: AppColors.error(context),
          title: 'Delete All Data',
          subtitle: 'Permanently remove all personal data',
          onTap: () => _showDeleteDataDialog(context, ref),
        ),
      ],
    );
  }

  void _showDataCollectionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: AppColors.info(context)),
            const SizedBox(width: 8),
            Text('Data Collection'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MegaPDF collects minimal data to improve your experience:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              _buildDataItem(
                context,
                'Usage Analytics',
                'Anonymous data about app usage, feature popularity, and performance metrics',
                Icons.analytics,
                AppColors.info(context),
                collected: true,
              ),
              _buildDataItem(
                context,
                'Crash Reports',
                'Technical information when the app crashes to help us fix issues',
                Icons.bug_report,
                AppColors.warning(context),
                collected: true,
              ),
              _buildDataItem(
                context,
                'File Content',
                'Your PDF files and documents are processed locally and never sent to our servers',
                Icons.description,
                AppColors.success(context),
                collected: false,
              ),
              _buildDataItem(
                context,
                'Personal Information',
                'We do not collect names, emails, or other personal identifiers',
                Icons.person,
                AppColors.success(context),
                collected: false,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.success(context).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user,
                      color: AppColors.success(context),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All processing happens on your device. Your files never leave your phone.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.success(context),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem(BuildContext context, String title, String description,
      IconData icon, Color color,
      {required bool collected}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: collected
                            ? AppColors.warning(context)
                            : AppColors.success(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        collected ? 'Collected' : 'Not Collected',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
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

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: AppColors.border(context))),
                ),
                child: Row(
                  children: [
                    Icon(Icons.privacy_tip, color: AppColors.primary(context)),
                    const SizedBox(width: 8),
                    Text(
                      'Privacy Policy',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: PrivacyPolicyWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: AppColors.border(context))),
                ),
                child: Row(
                  children: [
                    Icon(Icons.description,
                        color: AppColors.secondary(context)),
                    const SizedBox(width: 8),
                    Text(
                      'Terms of Service',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: TermsOfServiceWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSecurityInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.shield, color: AppColors.success(context)),
            const SizedBox(width: 8),
            Text('Security Features'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSecurityFeature(
                context,
                'Local Processing',
                'All PDF operations happen on your device',
                Icons.phone_android,
                AppColors.success(context),
              ),
              _buildSecurityFeature(
                context,
                'No Cloud Upload',
                'Your files never leave your device',
                Icons.cloud_off,
                AppColors.success(context),
              ),
              _buildSecurityFeature(
                context,
                'Secure Storage',
                'Files are stored in app-specific directories',
                Icons.lock,
                AppColors.success(context),
              ),
              _buildSecurityFeature(
                context,
                'No Network Required',
                'Most features work completely offline',
                Icons.wifi_off,
                AppColors.success(context),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFeature(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
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

  void _exportUserData(BuildContext context) {
    // TODO: Implement data export functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Data'),
        content: Text(
          'Data export functionality will be available in a future update. '
          'Currently, your files are stored locally and can be accessed through the file manager.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.error(context)),
            const SizedBox(width: 8),
            Text('Delete All Data'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete all your data including:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Text('• All processed PDF files'),
            Text('• Recent files history'),
            Text('• App settings and preferences'),
            Text('• Cache and temporary files'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.error(context).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: AppColors.error(context),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error(context),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // This would call the same method as clear all data
              await ref.read(settingsNotifierProvider.notifier).clearAppData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error(context),
            ),
            child: Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
