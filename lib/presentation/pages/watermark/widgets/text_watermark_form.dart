// lib/presentation/pages/watermark/widgets/text_watermark_form.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TextWatermarkForm extends StatelessWidget {
  final String text;
  final String textColor;
  final int fontSize;
  final String fontFamily;
  final Function(String) onTextChanged;
  final Function(String) onColorChanged;
  final Function(int) onFontSizeChanged;
  final Function(String) onFontFamilyChanged;

  const TextWatermarkForm({
    super.key,
    required this.text,
    required this.textColor,
    required this.fontSize,
    required this.fontFamily,
    required this.onTextChanged,
    required this.onColorChanged,
    required this.onFontSizeChanged,
    required this.onFontFamilyChanged,
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
                  Icons.text_fields,
                  color: AppColors.watermarkColor(context),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Text Watermark',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Text Input
            TextFormField(
              initialValue: text,
              decoration: const InputDecoration(
                labelText: 'Watermark Text',
                hintText: 'Enter watermark text',
                prefixIcon: Icon(Icons.title),
              ),
              maxLength: 100,
              onChanged: onTextChanged,
            ),

            const SizedBox(height: 16),

            // Text Color
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Text Color:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                _buildColorPicker(context),
              ],
            ),

            const SizedBox(height: 16),

            // Font Size
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Font Size: ${fontSize}pt',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Slider(
                    value: fontSize.toDouble(),
                    min: 8,
                    max: 120,
                    divisions: 28,
                    activeColor: AppColors.watermarkColor(context),
                    onChanged: (value) => onFontSizeChanged(value.round()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Font Family
            DropdownButtonFormField<String>(
              value: fontFamily,
              decoration: const InputDecoration(
                labelText: 'Font Family',
                prefixIcon: Icon(Icons.font_download),
              ),
              items: const [
                DropdownMenuItem(value: 'Helvetica', child: Text('Helvetica')),
                DropdownMenuItem(value: 'Times', child: Text('Times')),
                DropdownMenuItem(value: 'Courier', child: Text('Courier')),
              ],
              onChanged: (value) => onFontFamilyChanged(value!),
            ),

            const SizedBox(height: 16),

            // Preview
            _buildPreview(context),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(BuildContext context) {
    final colors = [
      '#FF0000',
      '#00FF00',
      '#0000FF',
      '#000000',
      '#FFFFFF',
      '#FFFF00',
      '#FF00FF',
      '#00FFFF',
    ];

    return Wrap(
      spacing: 8,
      children: colors.map((color) {
        final isSelected = textColor == color;
        return GestureDetector(
          onTap: () => onColorChanged(color),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  Color(int.parse(color.substring(1), radix: 16) + 0xFF000000),
              border: Border.all(
                color: isSelected
                    ? AppColors.watermarkColor(context)
                    : AppColors.border(context),
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              text.isNotEmpty ? text : 'WATERMARK',
              style: TextStyle(
                fontSize: (fontSize / 2).clamp(12, 24).toDouble(),
                fontWeight: FontWeight.bold,
                color: Color(
                    int.parse(textColor.substring(1), radix: 16) + 0xFF000000),
                fontFamily: fontFamily.toLowerCase(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
