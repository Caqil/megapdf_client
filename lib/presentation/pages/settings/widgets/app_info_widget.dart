// lib/presentation/pages/settings/widgets/app_info_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';

class AppInfoWidget extends ConsumerWidget {
  const AppInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 40,
            height: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'MegaPDF',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '© 2025 MegaPDF Team',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
          ),
        ],
      ),
    );
  }
}
