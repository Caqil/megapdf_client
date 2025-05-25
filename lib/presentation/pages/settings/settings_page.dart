// lib/presentation/pages/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/presentation/pages/settings/widgets/support_section_widget.dart';
import 'package:megapdf_client/presentation/pages/settings/widgets/privacy_policy_widget.dart';
import 'package:megapdf_client/presentation/pages/settings/widgets/terms_of_service_widget.dart';
import 'package:megapdf_client/presentation/pages/settings/widgets/app_info_widget.dart';
import '../../../core/theme/app_colors.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                  'Manage app preferences and storage',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 24),
            SupportSectionWidget(),
            SizedBox(height: 24),
            PrivacyPolicyWidget(),
            SizedBox(height: 24),
            TermsOfServiceWidget(),
            SizedBox(height: 30),
            AppInfoWidget(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
