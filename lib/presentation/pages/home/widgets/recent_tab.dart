import 'package:flutter/material.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';
import 'package:megapdf_client/data/models/recent_file_model.dart';
import 'package:megapdf_client/presentation/pages/recent/recent_file_card.dart';
import 'package:megapdf_client/presentation/providers/recent_files_provider.dart';
import 'package:megapdf_client/presentation/widgets/bottom_sheets/file_operations_bottom_sheet.dart';

class RecentTab extends StatelessWidget {
  final RecentFilesState recentState;

  const RecentTab({super.key, required this.recentState});

  @override
  Widget build(BuildContext context) {
    if (recentState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (recentState.recentFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 64,
              color: AppColors.textSecondary(context).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No recent files',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Files you process will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: recentState.recentFiles.take(20).length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final file = recentState.recentFiles[index];
        return RecentFileCard(
          item: file,
          onTap: () => _showFileOperations(file, context),
        );
      },
    );
  }

  void _showFileOperations(RecentFileModel file, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FileOperationsBottomSheet(file: file),
    );
  }
}
