// lib/presentation/pages/settings/widgets/app_info_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';
import '../providers/app_info_provider.dart';

class AppInfoWidget extends ConsumerWidget {
  const AppInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.watch(appInfoNotifierProvider);

    if (appInfo.isLoading) {
      return Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.primary(context)),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading app information...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
          ],
        ),
      );
    }

    if (appInfo.hasError) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error(context),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load app info',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error(context),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              appInfo.error ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(appInfoNotifierProvider.notifier).refreshAppInfo();
              },
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        children: [
          // App Icon with gradient background
          Container(
            padding: const EdgeInsets.all(12),
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

          const SizedBox(height: 16),

          // App Name
          Text(
            appInfo.appName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
          ),

          const SizedBox(height: 4),

          // Version with build number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary(context).withOpacity(0.3),
              ),
            ),
            child: Text(
              'Version ${appInfo.fullVersion}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary(context),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),

          const SizedBox(height: 8),

          // Platform info
          Text(
            '${appInfo.platformName} • ${appInfo.installSource}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Copyright
          Text(
            '© 2025 MegaPDF Team',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
          ),

          const SizedBox(height: 16),

          // Quick actions row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(
                context,
                'v${appInfo.version}',
                Icons.code,
                AppColors.info(context),
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                context,
                'Build ${appInfo.buildNumber}',
                Icons.build,
                AppColors.secondary(context),
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                context,
                appInfo.platformName,
                Icons.smartphone,
                AppColors.warning(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}
