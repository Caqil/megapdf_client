// lib/presentation/pages/settings/widgets/terms_of_service_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';
import 'package:megapdf_client/presentation/pages/settings/widgets/expandable_card_widget.dart';
import 'package:megapdf_client/presentation/pages/settings/widgets/policy_section_widget.dart';

class TermsOfServiceWidget extends ConsumerStatefulWidget {
  const TermsOfServiceWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<TermsOfServiceWidget> createState() =>
      _TermsOfServiceWidgetState();
}

class _TermsOfServiceWidgetState extends ConsumerState<TermsOfServiceWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpandableCardWidget(
      title: 'Terms of Service',
      icon: Icons.description_outlined,
      iconColor: AppColors.secondary(context),
      isExpanded: _isExpanded,
      onToggle: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PolicySectionWidget(
            title: 'Acceptance of Terms',
            content:
                'By downloading, installing, or using MegaPDF, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app.',
          ),
          const SizedBox(height: 16),
          const PolicySectionWidget(
            title: 'License to Use',
            content:
                'MegaPDF grants you a limited, non-exclusive, non-transferable license to use the app for your personal or business purposes on devices you own or control.',
          ),
          const SizedBox(height: 16),
          const PolicySectionWidget(
            title: 'Restrictions',
            content:
                'You may not: (a) copy, modify, or create derivative works of the app; (b) reverse engineer, decompile, or disassemble the app; (c) remove or alter any proprietary notices; (d) use the app for any illegal purpose; (e) transfer, sublicense, or provide access to the app to unauthorized third parties.',
          ),
          const SizedBox(height: 16),
          const PolicySectionWidget(
            title: 'Intellectual Property',
            content:
                'All intellectual property rights in the app and its content remain with MegaPDF and its licensors. You acknowledge that you have no rights in or to the app other than the right to use it in accordance with these terms.',
          ),
          const SizedBox(height: 16),
          const PolicySectionWidget(
            title: 'Liability Limitation',
            content:
                'To the maximum extent permitted by law, MegaPDF shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including loss of profits, data, or goodwill, arising out of or in connection with your use of the app.',
          ),
          const SizedBox(height: 16),
          const PolicySectionWidget(
            title: 'Changes to Terms',
            content:
                'We reserve the right to modify these terms at any time. We will notify you of any changes by posting the new terms in the app. Your continued use of the app after such modifications constitutes your acceptance of the revised terms.',
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Last Updated: May 15, 2024',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary(context),
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
