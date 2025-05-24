// lib/presentation/pages/settings/widgets/privacy_policy_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';
import 'package:megapdf_client/presentation/pages/settings/widgets/expandable_card_widget.dart';
import 'package:megapdf_client/presentation/pages/settings/widgets/policy_section_widget.dart';

class PrivacyPolicyWidget extends ConsumerStatefulWidget {
  const PrivacyPolicyWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<PrivacyPolicyWidget> createState() =>
      _PrivacyPolicyWidgetState();
}

class _PrivacyPolicyWidgetState extends ConsumerState<PrivacyPolicyWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpandableCardWidget(
      title: 'Privacy Policy',
      icon: Icons.privacy_tip_outlined,
      iconColor: AppColors.primary(context),
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
            title: 'Information We Collect',
            content:
                'MegaPDF collects minimal information necessary to provide our services. This includes information about your device, operating system, and usage patterns within the app. We do not collect personally identifiable information unless explicitly provided by you for support purposes.',
          ),
          const SizedBox(height: 16),
          const PolicySectionWidget(
            title: 'How We Use Your Information',
            content:
                'We use collected information to improve the app, fix bugs, and enhance the user experience. Usage data helps us understand which features are most valuable and how we can make the app better for you.',
          ),
          const SizedBox(height: 16),
          const PolicySectionWidget(
            title: 'File Storage and Security',
            content:
                'MegaPDF processes your PDF files locally on your device whenever possible. Any files you upload or create are stored in your device\'s storage and are not transmitted to our servers except when using specific online features that require server processing. We do not retain your files on our servers longer than necessary to complete the requested operations.',
          ),
          const SizedBox(height: 16),
          const PolicySectionWidget(
            title: 'Third-Party Services',
            content:
                'MegaPDF may use third-party services for crash reporting and analytics. These services collect anonymous usage data to help us improve the app. You can opt out of analytics collection in the app settings.',
          ),
          const SizedBox(height: 16),
          const PolicySectionWidget(
            title: 'Your Rights',
            content:
                'You have the right to access, correct, or delete any personal information we may hold about you. You can contact us at privacy@megapdf.com to exercise these rights.',
          ),
          const SizedBox(height: 16),
          const PolicySectionWidget(
            title: 'Policy Updates',
            content:
                'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy in the app and updating the "Last Updated" date.',
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
