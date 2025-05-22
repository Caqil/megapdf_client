// lib/presentation/pages/page_numbers/widgets/position_selector.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PositionSelector extends StatelessWidget {
  final String selectedPosition;
  final Function(String) onPositionChanged;

  const PositionSelector({
    super.key,
    required this.selectedPosition,
    required this.onPositionChanged,
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
                  Icons.place,
                  color: AppColors.pageNumbersColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Page Number Position',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Position Grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  // Top Row
                  Row(
                    children: [
                      Expanded(child: _buildPositionOption('top-left', Icons.north_west)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildPositionOption('top-center', Icons.north)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildPositionOption('top-right', Icons.north_east)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Bottom Row
                  Row(
                    children: [
                      Expanded(child: _buildPositionOption('bottom-left', Icons.south_west)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildPositionOption('bottom-center', Icons.south)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildPositionOption('bottom-right', Icons.south_east)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Selected Position Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.pageNumbersColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.pageNumbersColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getPositionIcon(selectedPosition),
                    color: AppColors.pageNumbersColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getPositionDisplayName(selectedPosition),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.pageNumbersColor,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionOption(String position, IconData icon) {
    final isSelected = selectedPosition == position;
    
    return GestureDetector(
      onTap: () => onPositionChanged(position),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
            ? AppColors.pageNumbersColor.withOpacity(0.15)
            : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected 
              ? AppColors.pageNumbersColor 
              : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.pageNumbersColor : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              _getShortPositionName(position),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.pageNumbersColor : AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPositionIcon(String position) {
    switch (position) {
      case 'top-left':
        return Icons.north_west;
      case 'top-center':
        return Icons.north;
      case 'top-right':
        return Icons.north_east;
      case 'bottom-left':
        return Icons.south_west;
      case 'bottom-center': 
        return Icons.south;
      case 'bottom-right':
        return Icons.south_east;
      default:
        return Icons.place;
    }
  }

  String _getPositionDisplayName(String position) {
    switch (position) {
      case 'top-left':
        return 'Top Left';
      case 'top-center':
        return 'Top Center';
      case 'top-right':
        return 'Top Right';
      case 'bottom-left':
        return 'Bottom Left';
      case 'bottom-center':
        return 'Bottom Center';
      case 'bottom-right':
        return 'Bottom Right';
      default:
        return position;
    }
  }

  String _getShortPositionName(String position) {
    switch (position) {
      case 'top-left':
        return 'Top\nLeft';
      case 'top-center':
        return 'Top\nCenter';
      case 'top-right':
        return 'Top\nRight';
      case 'bottom-left':
        return 'Bottom\nLeft';
      case 'bottom-center':
        return 'Bottom\nCenter';
      case 'bottom-right':
        return 'Bottom\nRight';
      default:
        return position;
    }
  }
}
