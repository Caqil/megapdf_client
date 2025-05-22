// lib/presentation/pages/page_numbers/widgets/numbering_options.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class NumberingOptions extends StatelessWidget {
  final String format;
  final String fontFamily;
  final int fontSize;
  final String color;
  final int startNumber;
  final String prefix;
  final String suffix;
  final int marginX;
  final int marginY;
  final String selectedPages;
  final bool skipFirstPage;

  final Function(String) onFormatChanged;
  final Function(String?, int?, String?) onFontOptionsChanged;
  final Function(int?, String?, String?) onNumberingChanged;
  final Function(int?, int?) onMarginsChanged;
  final Function(String?, bool?) onPageSelectionChanged;

  const NumberingOptions({
    super.key,
    required this.format,
    required this.fontFamily,
    required this.fontSize,
    required this.color,
    required this.startNumber,
    required this.prefix,
    required this.suffix,
    required this.marginX,
    required this.marginY,
    required this.selectedPages,
    required this.skipFirstPage,
    required this.onFormatChanged,
    required this.onFontOptionsChanged,
    required this.onNumberingChanged,
    required this.onMarginsChanged,
    required this.onPageSelectionChanged,
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
                  Icons.format_list_numbered,
                  color: AppColors.pageNumbersColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Numbering Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Format Selection
            Text(
              'Number Format:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: format,
              decoration: const InputDecoration(
                hintText: 'Select format',
                prefixIcon: Icon(Icons.format_list_numbered),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'numeric', child: Text('Numbers (1, 2, 3...)')),
                DropdownMenuItem(
                    value: 'roman', child: Text('Roman (I, II, III...)')),
                DropdownMenuItem(
                    value: 'alphabetic', child: Text('Letters (A, B, C...)')),
              ],
              onChanged: (value) => onFormatChanged(value!),
            ),

            const SizedBox(height: 16),

            // Font Options
            Text(
              'Font Options:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: fontFamily,
                    decoration: const InputDecoration(
                      labelText: 'Font',
                      prefixIcon: Icon(Icons.font_download),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'Helvetica', child: Text('Helvetica')),
                      DropdownMenuItem(value: 'Times', child: Text('Times')),
                      DropdownMenuItem(
                          value: 'Courier', child: Text('Courier')),
                    ],
                    onChanged: (value) =>
                        onFontOptionsChanged(value, null, null),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: fontSize.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Size',
                      prefixIcon: Icon(Icons.format_size),
                      suffixText: 'pt',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final size = int.tryParse(value);
                      if (size != null) {
                        onFontOptionsChanged(null, size, null);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Color Selection
            Text(
              'Color:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            _buildColorPicker(),

            const SizedBox(height: 16),

            // Start Number and Prefix/Suffix
            Text(
              'Numbering Format:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: startNumber.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Start Number',
                      prefixIcon: Icon(Icons.start),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final number = int.tryParse(value);
                      if (number != null) {
                        onNumberingChanged(number, null, null);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: prefix,
                    decoration: const InputDecoration(
                      labelText: 'Prefix',
                      hintText: 'Page ',
                    ),
                    onChanged: (value) => onNumberingChanged(null, value, null),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: suffix,
                    decoration: const InputDecoration(
                      labelText: 'Suffix',
                      hintText: ' of X',
                    ),
                    onChanged: (value) => onNumberingChanged(null, null, value),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Margins
            Text(
              'Margins:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Horizontal: ${marginX}pt'),
                      Slider(
                        value: marginX.toDouble(),
                        min: 10,
                        max: 100,
                        divisions: 18,
                        activeColor: AppColors.pageNumbersColor,
                        onChanged: (value) =>
                            onMarginsChanged(value.round(), null),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vertical: ${marginY}pt'),
                      Slider(
                        value: marginY.toDouble(),
                        min: 10,
                        max: 100,
                        divisions: 18,
                        activeColor: AppColors.pageNumbersColor,
                        onChanged: (value) =>
                            onMarginsChanged(null, value.round()),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Page Selection
            Text(
              'Page Selection:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: selectedPages,
              decoration: const InputDecoration(
                labelText: 'Specific Pages (optional)',
                hintText: 'e.g., 2-10 or 2,4,6-8',
                prefixIcon: Icon(Icons.pages),
                helperText: 'Leave empty to number all pages',
              ),
              onChanged: (value) => onPageSelectionChanged(value, null),
            ),

            const SizedBox(height: 12),

            // Skip First Page Option
            CheckboxListTile(
              title: const Text('Skip First Page'),
              subtitle: const Text(
                  'Don\'t add numbers to the first page (title page)'),
              value: skipFirstPage,
              onChanged: (value) => onPageSelectionChanged(null, value),
              activeColor: AppColors.pageNumbersColor,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    final colors = [
      '#000000', // Black
      '#333333', // Dark Gray
      '#666666', // Gray
      '#0000FF', // Blue
      '#FF0000', // Red
      '#008000', // Green
    ];

    return Wrap(
      spacing: 8,
      children: colors.map((colorHex) {
        final isSelected = color == colorHex;
        return GestureDetector(
          onTap: () => onFontOptionsChanged(null, null, colorHex),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(
                  int.parse(colorHex.substring(1), radix: 16) + 0xFF000000),
              border: Border.all(
                color:
                    isSelected ? AppColors.pageNumbersColor : AppColors.border,
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
}
