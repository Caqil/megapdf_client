// lib/presentation/pages/watermark/widgets/watermark_options.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/watermark_result.dart';

class WatermarkOptions extends StatelessWidget {
  final WatermarkPosition position;
  final int rotation;
  final int opacity;
  final int scale;
  final String pages;
  final String? customPages;
  final int? customX;
  final int? customY;
  final Function(WatermarkPosition) onPositionChanged;
  final Function(int) onRotationChanged;
  final Function(int) onOpacityChanged;
  final Function(int) onScaleChanged;
  final Function(String) onPagesChanged;
  final Function(String?) onCustomPagesChanged;
  final Function(int?, int?) onCustomPositionChanged;

  const WatermarkOptions({
    super.key,
    required this.position,
    required this.rotation,
    required this.opacity,
    required this.scale,
    required this.pages,
    this.customPages,
    this.customX,
    this.customY,
    required this.onPositionChanged,
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
                  color: AppColors.watermarkColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Watermark Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Position Selection
            _buildPositionSection(context),
            const SizedBox(height: 20),

            // Rotation Control
            _buildRotationSection(context),
            const SizedBox(height: 20),

            // Opacity Control
            _buildOpacitySection(context),
            const SizedBox(height: 20),

            // Scale Control (for image watermarks)
            _buildScaleSection(context),
            const SizedBox(height: 20),

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

  Widget _buildPositionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Position:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<WatermarkPosition>(
          value: position,
          decoration: const InputDecoration(
            hintText: 'Select position',
            prefixIcon: Icon(Icons.place),
          ),
          items: [
            DropdownMenuItem(
              value: WatermarkPosition.center,
              child: Text('Center'),
            ),
            DropdownMenuItem(
              value: WatermarkPosition.topLeft,
              child: Text('Top Left'),
            ),
            DropdownMenuItem(
              value: WatermarkPosition.topRight,
              child: Text('Top Right'),
            ),
            DropdownMenuItem(
              value: WatermarkPosition.bottomLeft,
              child: Text('Bottom Left'),
            ),
            DropdownMenuItem(
              value: WatermarkPosition.bottomRight,
              child: Text('Bottom Right'),
            ),
            DropdownMenuItem(
              value: WatermarkPosition.tile,
              child: Text('Tile (Repeat)'),
            ),
            DropdownMenuItem(
              value: WatermarkPosition.custom,
              child: Text('Custom Position'),
            ),
          ],
          onChanged: (value) => onPositionChanged(value!),
        ),
      ],
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
            Text(
              '${rotation}°',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.watermarkColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: rotation.toDouble(),
          min: -180,
          max: 180,
          divisions: 36,
          activeColor: AppColors.watermarkColor,
          onChanged: (value) => onRotationChanged(value.round()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '-180°',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            Text(
              '180°',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
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
            Text(
              '${opacity}%',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.watermarkColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: opacity.toDouble(),
          min: 10,
          max: 100,
          divisions: 18,
          activeColor: AppColors.watermarkColor,
          onChanged: (value) => onOpacityChanged(value.round()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transparent',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            Text(
              'Opaque',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
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
            Text(
              '${scale}%',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.watermarkColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: scale.toDouble(),
          min: 10,
          max: 200,
          divisions: 19,
          activeColor: AppColors.watermarkColor,
          onChanged: (value) => onScaleChanged(value.round()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Small',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            Text(
              'Large',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
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
          activeColor: AppColors.watermarkColor,
          contentPadding: EdgeInsets.zero,
        ),

        // Custom Pages Option
        RadioListTile<String>(
          title: const Text('Custom Pages'),
          value: 'custom',
          groupValue: pages,
          onChanged: (value) => onPagesChanged(value!),
          activeColor: AppColors.watermarkColor,
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
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info,
                color: AppColors.info,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Position from top-left corner. (0,0) = top-left, negative values move outside page.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.info,
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
