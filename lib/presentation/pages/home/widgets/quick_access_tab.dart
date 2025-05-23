// lib/presentation/pages/home/widgets/quick_access_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';
import 'package:megapdf_client/presentation/pages/home/widgets/tips_section.dart';
import '../../../widgets/common/custom_snackbar.dart';
import 'quick_action_card.dart';
import 'section_header.dart';
import 'feature_grid.dart';

class QuickAccessTab extends ConsumerWidget {
  const QuickAccessTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Quick Actions', icon: Icons.flash_on),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              QuickActionCard(
                title: 'Select File',
                icon: Icons.upload_file,
                color: AppColors.primary(context),
                onTap: () => _showSnackBar(context, 'File picker coming soon!'),
              ),
              QuickActionCard(
                title: 'Scan to PDF',
                icon: Icons.document_scanner,
                color: AppColors.warning(context),
                onTap: () => _showSnackBar(context, 'Scan to PDF coming soon!'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const FeatureGrid(),
          const SizedBox(height: 24),
          const TipsSection(),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    CustomSnackbar.show(
      context: context,
      message: message,
      type: isError ? SnackbarType.failure : SnackbarType.success,
      duration: const Duration(seconds: 4),
    );
  }
}
