// lib/presentation/pages/watermark/widgets/watermark_position_selector.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/watermark_result.dart';

class WatermarkPositionSelector extends StatelessWidget {
  final WatermarkPosition selectedPosition;
  final Function(WatermarkPosition) onPositionChanged;

  const WatermarkPositionSelector({
    super.key,
    required this.selectedPosition,
    required this.onPositionChanged,
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
                  Icons.place,
                  color: AppColors.watermarkColor(context),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Watermark Position',
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
                color: AppColors.surfaceVariant(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Column(
                children: [
                  // Top Row
                  Row(
                    children: [
                      Expanded(
                          child: _buildPositionOption(WatermarkPosition.topLeft,
                              Icons.north_west, context)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _buildPositionOption(WatermarkPosition.center,
                              Icons.center_focus_strong, context)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _buildPositionOption(
                              WatermarkPosition.topRight,
                              Icons.north_east,
                              context)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Middle Row
                  Row(
                    children: [
                      Expanded(
                          child: _buildPositionOption(
                              WatermarkPosition.bottomLeft,
                              Icons.south_west,
                              context)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _buildPositionOption(
                              WatermarkPosition.tile, Icons.apps, context)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _buildPositionOption(
                              WatermarkPosition.bottomRight,
                              Icons.south_east,
                              context)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Custom Position Row
                  Row(
                    children: [
                      Expanded(child: Container()), // Spacer
                      Expanded(
                          child: _buildPositionOption(WatermarkPosition.custom,
                              Icons.my_location, context)),
                      Expanded(child: Container()), // Spacer
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
                color: AppColors.watermarkColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.watermarkColor(context).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getPositionIcon(selectedPosition),
                    color: AppColors.watermarkColor(context),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getPositionDisplayName(selectedPosition),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.watermarkColor(context),
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

  Widget _buildPositionOption(
      WatermarkPosition position, IconData icon, BuildContext context) {
    final isSelected = selectedPosition == position;

    return GestureDetector(
      onTap: () => onPositionChanged(position),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.watermarkColor(context).withOpacity(0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? AppColors.watermarkColor(context)
                : AppColors.border(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.watermarkColor(context)
                  : AppColors.textMuted(context),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              _getShortPositionName(position),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppColors.watermarkColor(context)
                    : AppColors.textMuted(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPositionIcon(WatermarkPosition position) {
    switch (position) {
      case WatermarkPosition.topLeft:
        return Icons.north_west;
      case WatermarkPosition.center:
        return Icons.center_focus_strong;
      case WatermarkPosition.topRight:
        return Icons.north_east;
      case WatermarkPosition.bottomLeft:
        return Icons.south_west;
      case WatermarkPosition.bottomRight:
        return Icons.south_east;
      case WatermarkPosition.tile:
        return Icons.apps;
      case WatermarkPosition.custom:
        return Icons.my_location;
      default:
        return Icons.place;
    }
  }

  String _getPositionDisplayName(WatermarkPosition position) {
    switch (position) {
      case WatermarkPosition.topLeft:
        return 'Top Left';
      case WatermarkPosition.center:
        return 'Center';
      case WatermarkPosition.topRight:
        return 'Top Right';
      case WatermarkPosition.bottomLeft:
        return 'Bottom Left';
      case WatermarkPosition.bottomRight:
        return 'Bottom Right';
      case WatermarkPosition.tile:
        return 'Tile (Repeat)';
      case WatermarkPosition.custom:
        return 'Custom Position';
      default:
        return position.toString();
    }
  }

  String _getShortPositionName(WatermarkPosition position) {
    switch (position) {
      case WatermarkPosition.topLeft:
        return 'Top\nLeft';
      case WatermarkPosition.center:
        return 'Center';
      case WatermarkPosition.topRight:
        return 'Top\nRight';
      case WatermarkPosition.bottomLeft:
        return 'Bottom\nLeft';
      case WatermarkPosition.bottomRight:
        return 'Bottom\nRight';
      case WatermarkPosition.tile:
        return 'Tile';
      case WatermarkPosition.custom:
        return 'Custom';
      default:
        return position.toString();
    }
  }
}
