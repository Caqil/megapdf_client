// lib/presentation/pages/rotate/widgets/page_selector.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PageSelector extends StatefulWidget {
  final String pages;
  final Function(String) onPagesChanged;

  const PageSelector({
    super.key,
    required this.pages,
    required this.onPagesChanged,
  });

  @override
  State<PageSelector> createState() => _PageSelectorState();
}

class _PageSelectorState extends State<PageSelector> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.pages == 'all' ? '' : widget.pages,
    );
    _controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateInput() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorText = null);
      widget.onPagesChanged('all');
      return;
    }

    // Basic validation for page ranges format
    final rangePattern = RegExp(r'^(\d+(-\d+)?)(,\s*\d+(-\d+)?)*$');
    if (!rangePattern.hasMatch(text)) {
      setState(() => _errorText = 'Invalid format. Use: 1-3,5,7-9');
      return;
    }

    setState(() => _errorText = null);
    widget.onPagesChanged(text);
  }

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
                  Icons.pages,
                  color: AppColors.rotateColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Pages',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // All Pages Option
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Radio<String>(
                    value: 'all',
                    groupValue: widget.pages,
                    onChanged: (value) {
                      _controller.clear();
                      widget.onPagesChanged(value!);
                    },
                    activeColor: AppColors.rotateColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Pages',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          'Rotate all pages in the document',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Specific Pages Option
            Row(
              children: [
                Radio<String>(
                  value: 'specific',
                  groupValue: widget.pages == 'all' ? 'all' : 'specific',
                  onChanged: (value) {
                    if (value == 'specific') {
                      // Don't change the value, just focus on text field
                    }
                  },
                  activeColor: AppColors.rotateColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Specific Pages',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        'Rotate only specified pages',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Page Range Input
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'e.g., 1-3,5,7-9',
                prefixIcon: const Icon(Icons.format_list_numbered),
                errorText: _errorText,
                helperText: 'Enter page numbers or ranges separated by commas',
                helperMaxLines: 2,
              ),
              keyboardType: TextInputType.text,
              onTap: () {
                // When user taps on input, switch to specific pages mode
                if (widget.pages == 'all') {
                  widget.onPagesChanged('');
                }
              },
            ),

            const SizedBox(height: 12),

            // Quick Examples
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickExample('1-3'),
                _buildQuickExample('1,3,5'),
                _buildQuickExample('1-5,10-15'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickExample(String example) {
    return GestureDetector(
      onTap: () {
        _controller.text = example;
        _validateInput();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.rotateColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.rotateColor.withOpacity(0.3)),
        ),
        child: Text(
          example,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.rotateColor,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}
