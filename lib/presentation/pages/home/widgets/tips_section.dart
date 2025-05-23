import 'package:flutter/material.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';

class TipsSection extends StatelessWidget {
  const TipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info(context).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates,
                  color: AppColors.info(context), size: 24),
              const SizedBox(width: 12),
              Text(
                'Pro Tips',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.info(context),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem(context, 'Tap on PDF files to open them in the viewer'),
          _buildTipItem(context, 'Long press on files for quick actions'),
          _buildTipItem(context, 'Use search to quickly find your files'),
          _buildTipItem(
              context, 'Switch between list and grid view in Files tab'),
          _buildTipItem(
              context, 'Organize files in folders for better management'),
        ],
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.info(context),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
