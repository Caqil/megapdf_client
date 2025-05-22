// lib/presentation/pages/rotate/widgets/rotation_selector.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RotationSelector extends StatelessWidget {
  final int selectedAngle;
  final Function(int) onAngleChanged;

  const RotationSelector({
    super.key,
    required this.selectedAngle,
    required this.onAngleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.rotate_right,
                  color: AppColors.rotateColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Rotation Angle',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rotation Options
            Row(
              children: [
                Expanded(
                  child: _buildRotationOption(
                      context, 90, Icons.rotate_90_degrees_ccw),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRotationOption(context, 180, Icons.flip),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRotationOption(
                      context, 270, Icons.rotate_90_degrees_cw),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Selected Rotation Preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.rotateColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.rotateColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    _getRotationIcon(selectedAngle),
                    color: AppColors.rotateColor,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getRotationDescription(selectedAngle),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.rotateColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRotationOption(BuildContext context, int angle, IconData icon) {
    final isSelected = selectedAngle == angle;

    return GestureDetector(
      onTap: () => onAngleChanged(angle),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.rotateColor.withOpacity(0.15)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.rotateColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  isSelected ? AppColors.rotateColor : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              '${angle}°',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.rotateColor
                        : AppColors.textSecondary,
                  ),
            ),
            Text(
              _getShortDescription(angle),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRotationIcon(int angle) {
    switch (angle) {
      case 90:
        return Icons.rotate_90_degrees_ccw;
      case 180:
        return Icons.flip;
      case 270:
        return Icons.rotate_90_degrees_cw;
      default:
        return Icons.rotate_right;
    }
  }

  String _getRotationDescription(int angle) {
    switch (angle) {
      case 90:
        return '90° Clockwise';
      case 180:
        return '180° Flip';
      case 270:
        return '270° Clockwise';
      default:
        return '${angle}° Rotation';
    }
  }

  String _getShortDescription(int angle) {
    switch (angle) {
      case 90:
        return 'Clockwise';
      case 180:
        return 'Flip';
      case 270:
        return 'Counter-clockwise';
      default:
        return 'Rotate';
    }
  }
}
