// lib/presentation/pages/watermark/widgets/watermark_type_tabs.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/watermark_result.dart';

class WatermarkTypeTabs extends StatelessWidget {
  final WatermarkType selectedType;
  final Function(WatermarkType) onTypeChanged;

  const WatermarkTypeTabs({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              context,
              WatermarkType.text,
              'Text',
              Icons.text_fields,
            ),
          ),
          Expanded(
            child: _buildTab(
              context,
              WatermarkType.image,
              'Image',
              Icons.image,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, WatermarkType type, String label, IconData icon) {
    final isSelected = selectedType == type;
    
    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.watermarkColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
