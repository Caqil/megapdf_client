// lib/presentation/widgets/about_support_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/services/app_review_service.dart';
import '../providers/settings_provider.dart';
import '../providers/app_info_provider.dart';
import 'common/custom_snackbar.dart';
import 'settings_section_widget.dart';

class AboutSupportSection extends ConsumerWidget {
  final SettingsState state;

  const AboutSupportSection({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.watch(appInfoNotifierProvider);

    return SettingsSectionWidget(
      title: 'About & Support',
      icon: Icons.help_center,
      iconColor: AppColors.info(context),
      children: [
        // App Info Header
        _buildAppInfoHeader(context, appInfo),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Help & FAQ
        SettingsItemWidget(
          icon: Icons.help,
          iconColor: AppColors.info(context),
          title: 'Help & FAQ',
          subtitle: 'Get answers to common questions',
          onTap: () => context.push('/faq'),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Contact Support
        SettingsItemWidget(
          icon: Icons.support_agent,
          iconColor: AppColors.secondary(context),
          title: 'Contact Support',
          subtitle: 'Get help with issues or send feedback',
          onTap: () => context.push('/contact'),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Rate App
        SettingsItemWidget(
          icon: Icons.star,
          iconColor: AppColors.warning(context),
          title: 'Rate This App',
          subtitle: 'Help us improve by leaving a review',
          onTap: () => _rateApp(context, ref),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Share App
        SettingsItemWidget(
          icon: Icons.share,
          iconColor: AppColors.success(context),
          title: 'Share App',
          subtitle: 'Tell your friends about MegaPDF',
          onTap: () => _shareApp(context),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // What's New
        SettingsItemWidget(
          icon: Icons.new_releases,
          iconColor: AppColors.primary(context),
          title: 'What\'s New',
          subtitle: 'See the latest features and updates',
          onTap: () => _showWhatsNew(context, appInfo),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Version Info
        SettingsItemWidget(
          icon: Icons.info,
          iconColor: AppColors.textSecondary(context),
          title: 'Version Information',
          subtitle: 'App version, build info, and system details',
          onTap: () => _showVersionInfo(context, appInfo),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Licenses
        SettingsItemWidget(
          icon: Icons.library_books,
          iconColor: AppColors.textSecondary(context),
          title: 'Open Source Licenses',
          subtitle: 'Third-party libraries and their licenses',
          onTap: () => _showLicenses(context, appInfo),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Website
        SettingsItemWidget(
          icon: Icons.language,
          iconColor: AppColors.primary(context),
          title: 'Official Website',
          subtitle: 'Visit megapdf.com for more information',
          onTap: () => _openWebsite(context),
          trailing: Icon(
            Icons.open_in_new,
            color: AppColors.textSecondary(context),
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildAppInfoHeader(BuildContext context, AppInfoState appInfo) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary(context).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.picture_as_pdf,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appInfo.appName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All-in-One PDF Converter & Editor',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.primary(context).withOpacity(0.3)),
                  ),
                  child: Text(
                    'Version ${appInfo.fullVersion}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary(context),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
          if (appInfo.isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primary(context)),
              ),
            ),
        ],
      ),
    );
  }

  void _rateApp(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(appReviewServiceProvider).requestReview();
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Could not open app review. Please try again later.',
          type: SnackbarType.failure,
        );
      }
    }
  }

  void _shareApp(BuildContext context) {
    // TODO: Implement share functionality
    CustomSnackbar.show(
      context: context,
      message: 'Share functionality coming soon',
      type: SnackbarType.info,
    );
  }

  void _showWhatsNew(BuildContext context, AppInfoState appInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.new_releases, color: AppColors.primary(context)),
            const SizedBox(width: 8),
            Text('What\'s New'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Version ${appInfo.fullVersion}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                context,
                'Complete PDF Toolkit',
                'Compress, merge, split, convert, and protect PDFs',
                Icons.build_circle,
                AppColors.primary(context),
              ),
              _buildFeatureItem(
                context,
                'Enhanced User Interface',
                'Beautiful, intuitive design with improved navigation',
                Icons.design_services,
                AppColors.secondary(context),
              ),
              _buildFeatureItem(
                context,
                'Advanced Settings',
                'Comprehensive settings for customizing your experience',
                Icons.settings,
                AppColors.info(context),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.primary(context).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.celebration,
                      color: AppColors.primary(context),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Thank you for using MegaPDF! More features coming soon.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary(context),
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

  Widget _buildFeatureItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
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

  void _showVersionInfo(BuildContext context, AppInfoState appInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Version Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow(context, 'App Name', appInfo.appName),
              _buildInfoRow(context, 'Package', appInfo.packageName),
              _buildInfoRow(context, 'Version', appInfo.version),
              _buildInfoRow(context, 'Build Number', appInfo.buildNumber),
              _buildInfoRow(context, 'Platform', appInfo.platformName),
              _buildInfoRow(context, 'Install Source', appInfo.installSource),
              const SizedBox(height: 16),
              Text(
                'Device Information',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(context, 'Screen Size',
                  '${MediaQuery.of(context).size.width.round()} x ${MediaQuery.of(context).size.height.round()}'),
              _buildInfoRow(context, 'Pixel Ratio',
                  MediaQuery.of(context).devicePixelRatio.toStringAsFixed(2)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _copyVersionInfo(context, appInfo),
                  icon: Icon(Icons.copy, size: 16),
                  label: Text('Copy Info'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                  ),
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

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(color: AppColors.textSecondary(context)),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _copyVersionInfo(BuildContext context, AppInfoState appInfo) {
    final info = '''
${appInfo.appName} Version Information
App Name: ${appInfo.appName}
Package: ${appInfo.packageName}
Version: ${appInfo.version}
Build Number: ${appInfo.buildNumber}
Full Version: ${appInfo.fullVersion}
Platform: ${appInfo.platformName}
Install Source: ${appInfo.installSource}
Screen Size: ${MediaQuery.of(context).size.width.round()} x ${MediaQuery.of(context).size.height.round()}
Pixel Ratio: ${MediaQuery.of(context).devicePixelRatio.toStringAsFixed(2)}
''';

    Clipboard.setData(ClipboardData(text: info));
    Navigator.pop(context);

    CustomSnackbar.show(
      context: context,
      message: 'Version information copied to clipboard',
      type: SnackbarType.success,
    );
  }

  void _showLicenses(BuildContext context, AppInfoState appInfo) {
    showLicensePage(
      context: context,
      applicationName: appInfo.appName,
      applicationVersion: appInfo.fullVersion,
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient(context),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.picture_as_pdf,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }

  void _openWebsite(BuildContext context) {
    CustomSnackbar.show(
      context: context,
      message: 'Website functionality coming soon',
      type: SnackbarType.info,
    );
  }
}
