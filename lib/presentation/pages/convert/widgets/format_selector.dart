// lib/presentation/pages/convert/widgets/format_selector.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FormatSelector extends StatelessWidget {
  final String inputFormat;
  final String outputFormat;
  final Function(String) onInputFormatChanged;
  final Function(String) onOutputFormatChanged;

  const FormatSelector({
    super.key,
    required this.inputFormat,
    required this.outputFormat,
    required this.onInputFormatChanged,
    required this.onOutputFormatChanged,
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
                  Icons.transform,
                  color: AppColors.convertColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Conversion Formats',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Format Selection
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _buildFormatDropdown(
                        context,
                        inputFormat,
                        _getInputFormats(),
                        onInputFormatChanged,
                        'Input Format',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.arrow_forward,
                  color: AppColors.convertColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _buildFormatDropdown(
                        context,
                        outputFormat,
                        _getOutputFormats(inputFormat),
                        onOutputFormatChanged,
                        'Output Format',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Conversion Preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.convertColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.convertColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.transform,
                    color: AppColors.convertColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${inputFormat.toUpperCase()} → ${outputFormat.toUpperCase()}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.convertColor,
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

  Widget _buildFormatDropdown(
    BuildContext context,
    String currentValue,
    List<String> options,
    Function(String) onChanged,
    String hint,
  ) {
    return DropdownButtonFormField<String>(
      value: options.contains(currentValue) ? currentValue : options.first,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(Icons.file_present),
      ),
      items: options.map((format) {
        return DropdownMenuItem(
          value: format,
          child: Text(_getFormatName(format)),
        );
      }).toList(),
      onChanged: (value) => onChanged(value!),
    );
  }

  List<String> _getInputFormats() {
    return ['pdf', 'docx', 'xlsx', 'pptx', 'txt', 'html', 'jpg', 'png'];
  }

  List<String> _getOutputFormats(String inputFormat) {
    // Filter output formats based on input format
    switch (inputFormat) {
      case 'pdf':
        return ['docx', 'xlsx', 'pptx', 'txt', 'html', 'jpg', 'png'];
      case 'docx':
      case 'xlsx':
      case 'pptx':
      case 'txt':
      case 'html':
        return ['pdf'];
      case 'jpg':
      case 'png':
        return ['pdf', 'docx'];
      default:
        return ['pdf', 'docx', 'xlsx', 'pptx', 'txt', 'html', 'jpg', 'png'];
    }
  }

  String _getFormatName(String format) {
    switch (format) {
      case 'pdf':
        return 'PDF';
      case 'docx':
        return 'Word Document';
      case 'xlsx':
        return 'Excel Spreadsheet';
      case 'pptx':
        return 'PowerPoint';
      case 'txt':
        return 'Text File';
      case 'html':
        return 'HTML';
      case 'jpg':
        return 'JPEG Image';
      case 'png':
        return 'PNG Image';
      default:
        return format.toUpperCase();
    }
  }
}
