import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';
import 'package:megapdf_client/presentation/pages/home/widgets/folder_actions_bottom_sheet.dart';
import 'package:megapdf_client/presentation/pages/home/widgets/tips_section.dart';
import 'package:megapdf_client/presentation/providers/file_manager_provider.dart';
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
                title: 'Create Folder',
                icon: Icons.create_new_folder,
                color: AppColors.secondary(context),
                onTap: () => _showCreateFolderDialog(context, ref),
              ),
              QuickActionCard(
                title: 'Scan to PDF',
                icon: Icons.document_scanner,
                color: AppColors.warning(context),
                onTap: () => _showSnackBar(context, 'Scan to PDF coming soon!'),
              ),
              QuickActionCard(
                title: 'Import Files',
                icon: Icons.folder_open,
                color: AppColors.info(context),
                onTap: () =>
                    _showSnackBar(context, 'Import files coming soon!'),
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

  void _showCreateFolderDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => CreateFolderDialog(
        onCreateFolder: (name) {
          ref.read(fileManagerNotifierProvider.notifier).createFolder(name);
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error(context) : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
