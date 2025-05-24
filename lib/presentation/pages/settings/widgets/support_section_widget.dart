// lib/presentation/pages/settings/widgets/support_section_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';
import 'package:megapdf_client/presentation/widgets/common/custom_snackbar.dart';
import 'package:megapdf_client/presentation/pages/settings/widgets/section_card_widget.dart';

class SupportSectionWidget extends ConsumerWidget {
  const SupportSectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCardWidget(
      title: 'Support',
      icon: Icons.help_outline,
      iconColor: AppColors.info(context),
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Icon(
            Icons.help_center,
            color: AppColors.info(context),
            size: 28,
          ),
          title: Text(
            'Help & FAQ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Get answers to common questions and learn how to use MegaPDF',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary(context),
          ),
          onTap: () {
            CustomSnackbar.show(
              context: context,
              message: 'Help Center coming soon!',
              type: SnackbarType.info,
            );
          },
        ),
        const Divider(height: 1, indent: 20, endIndent: 20),
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Icon(
            Icons.email_outlined,
            color: AppColors.info(context),
            size: 28,
          ),
          title: Text(
            'Contact Support',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Get help with issues or send feedback to our team',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary(context),
          ),
          onTap: () {
            CustomSnackbar.show(
              context: context,
              message: 'Contact form coming soon!',
              type: SnackbarType.info,
            );
          },
        ),
        const Divider(height: 1, indent: 20, endIndent: 20),
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Icon(
            Icons.star_outline,
            color: AppColors.warning(context),
            size: 28,
          ),
          title: Text(
            'Rate This App',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'If you enjoy using MegaPDF, please consider rating it',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary(context),
          ),
          onTap: () {
            CustomSnackbar.show(
              context: context,
              message: 'Thank you for your support!',
              type: SnackbarType.success,
            );
          },
        ),
      ],
    );
  }
}
