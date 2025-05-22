
// lib/presentation/pages/protect/widgets/permission_settings.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PermissionSettings extends StatelessWidget {
  final String permission;
  final bool allowPrinting;
  final bool allowCopying;
  final bool allowEditing;
  final Function(String) onPermissionChanged;
  final Function(bool) onPrintingChanged;
  final Function(bool) onCopyingChanged;
  final Function(bool) onEditingChanged;

  const PermissionSettings({
    super.key,
    required this.permission,
    required this.allowPrinting,
    required this.allowCopying,
    required this.allowEditing,
    required this.onPermissionChanged,
    required this.onPrintingChanged,
    required this.onCopyingChanged,
    required this.onEditingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: AppColors.protectColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Permission Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Permission Level
            Text(
              'Permission Level:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: permission,
              decoration: const InputDecoration(
                hintText: 'Select permission level',
                prefixIcon: Icon(Icons.admin_panel_settings),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'no_restrictions',
                  child: Text('No Restrictions'),
                ),
                DropdownMenuItem(
                  value: 'restricted',
                  child: Text('Restricted'),
                ),
                DropdownMenuItem(
                  value: 'highly_restricted',
                  child: Text('Highly Restricted'),
                ),
              ],
              onChanged: (value) => onPermissionChanged(value!),
            ),

            const SizedBox(height: 20),

            // Individual Permissions
            Text(
              'Specific Permissions:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),

            _buildPermissionTile(
              context,
              'Allow Printing',
              'Users can print this document',
              Icons.print,
              allowPrinting,
              onPrintingChanged,
            ),

            _buildPermissionTile(
              context,
              'Allow Copying',
              'Users can copy text and images',
              Icons.copy,
              allowCopying,
              onCopyingChanged,
            ),

            _buildPermissionTile(
              context,
              'Allow Editing',
              'Users can modify the document',
              Icons.edit,
              allowEditing,
              onEditingChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionTile(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: value ? AppColors.protectColor : AppColors.textMuted,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.protectColor,
          ),
        ],
      ),
    );
  }
}
