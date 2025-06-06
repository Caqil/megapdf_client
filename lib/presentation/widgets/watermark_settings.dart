// lib/presentation/pages/watermark/widgets/watermark_settings.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/watermark_result.dart';

class WatermarkSettings extends StatelessWidget {
  final WatermarkType watermarkType;
  final int rotation;
  final int opacity;
  final int scale;
  final String pages;
  final String? customPages;
  final int? customX;
  final int? customY;
  final WatermarkPosition position;

  final Function(int) onRotationChanged;
  final Function(int) onOpacityChanged;
  final Function(int) onScaleChanged;
  final Function(String) onPagesChanged;
  final Function(String?) onCustomPagesChanged;
  final Function(int?, int?) onCustomPositionChanged;

  const WatermarkSettings({
    super.key,
    required this.watermarkType,
    required this.rotation,
    required this.opacity,
    required this.scale,
    required this.pages,
    this.customPages,
    this.customX,
    this.customY,
    required this.position,
    required this.onRotationChanged,
    required this.onOpacityChanged,
    required this.onScaleChanged,
    required this.onPagesChanged,
    required this.onCustomPagesChanged,
    required this.onCustomPositionChanged,
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
                  Icons.tune,
                  color: AppColors.watermarkColor(context),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Watermark Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rotation Control
            _buildRotationSection(context),
            const SizedBox(height: 20),

            // Opacity Control
            _buildOpacitySection(context),
            const SizedBox(height: 20),

            // Scale Control (for image watermarks)
            if (watermarkType == WatermarkType.image) ...[
              _buildScaleSection(context),
              const SizedBox(height: 20),
            ],

            // Page Selection
            _buildPageSelectionSection(context),

            // Custom Position (if position is custom)
            if (position == WatermarkPosition.custom) ...[
              const SizedBox(height: 20),
              _buildCustomPositionSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRotationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rotation:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.watermarkColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${rotation}°',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.watermarkColor(context),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.watermarkColor(context),
            thumbColor: AppColors.watermarkColor(context),
            overlayColor: AppColors.watermarkColor(context).withOpacity(0.2),
            inactiveTrackColor: AppColors.border(context),
          ),
          child: Slider(
            value: rotation.toDouble(),
            min: -180,
            max: 180,
            divisions: 36,
            onChanged: (value) => onRotationChanged(value.round()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '-180°',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
            Text(
              '0°',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
            Text(
              '180°',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOpacitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Opacity:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.watermarkColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${opacity}%',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.watermarkColor(context),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.watermarkColor(context),
            thumbColor: AppColors.watermarkColor(context),
            overlayColor: AppColors.watermarkColor(context).withOpacity(0.2),
            inactiveTrackColor: AppColors.border(context),
          ),
          child: Slider(
            value: opacity.toDouble(),
            min: 10,
            max: 100,
            divisions: 18,
            onChanged: (value) => onOpacityChanged(value.round()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transparent',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
            Text(
              'Opaque',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScaleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Scale:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.watermarkColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${scale}%',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.watermarkColor(context),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.watermarkColor(context),
            thumbColor: AppColors.watermarkColor(context),
            overlayColor: AppColors.watermarkColor(context).withOpacity(0.2),
            inactiveTrackColor: AppColors.border(context),
          ),
          child: Slider(
            value: scale.toDouble(),
            min: 10,
            max: 200,
            divisions: 19,
            onChanged: (value) => onScaleChanged(value.round()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Small',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
            Text(
              'Large',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPageSelectionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Apply to Pages:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),

        // All Pages Option
        RadioListTile<String>(
          title: const Text('All Pages'),
          value: 'all',
          groupValue: pages,
          onChanged: (value) => onPagesChanged(value!),
          activeColor: AppColors.watermarkColor(context),
          contentPadding: EdgeInsets.zero,
        ),

        // Custom Pages Option
        RadioListTile<String>(
          title: const Text('Custom Pages'),
          value: 'custom',
          groupValue: pages,
          onChanged: (value) => onPagesChanged(value!),
          activeColor: AppColors.watermarkColor(context),
          contentPadding: EdgeInsets.zero,
        ),

        // Custom Pages Input
        if (pages == 'custom') ...[
          const SizedBox(height: 8),
          TextFormField(
            initialValue: customPages ?? '',
            decoration: const InputDecoration(
              hintText: 'e.g., 1-3,5,7-9',
              prefixIcon: Icon(Icons.pages),
              helperText: 'Enter page numbers or ranges separated by commas',
            ),
            onChanged: onCustomPagesChanged,
          ),
        ],
      ],
    );
  }

  Widget _buildCustomPositionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Position (pixels):',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: customX?.toString() ?? '0',
                decoration: const InputDecoration(
                  labelText: 'X Position',
                  prefixIcon: Icon(Icons.horizontal_rule),
                  suffixText: 'px',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final x = int.tryParse(value);
                  onCustomPositionChanged(x, customY);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                initialValue: customY?.toString() ?? '0',
                decoration: const InputDecoration(
                  labelText: 'Y Position',
                  prefixIcon: Icon(Icons.vertical_align_center),
                  suffixText: 'px',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final y = int.tryParse(value);
                  onCustomPositionChanged(customX, y);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.info(context).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.info(context).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info,
                color: AppColors.info(context),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Position from top-left corner. (0,0) = top-left corner.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.info(context),
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
