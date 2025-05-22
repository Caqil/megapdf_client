// lib/presentation/pages/split/widgets/page_range_input.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PageRangeInput extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;

  const PageRangeInput({
    super.key,
    this.initialValue = '',
    required this.onChanged,
  });

  @override
  State<PageRangeInput> createState() => _PageRangeInputState();
}

class _PageRangeInputState extends State<PageRangeInput> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
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
      return;
    }

    // Basic validation for page ranges format
    final rangePattern = RegExp(r'^(\d+(-\d+)?)(,\s*\d+(-\d+)?)*$');
    if (!rangePattern.hasMatch(text)) {
      setState(() => _errorText = 'Invalid format. Use: 1-3,5,7-9');
      return;
    }

    setState(() => _errorText = null);
    widget.onChanged(text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Page Ranges:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),

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
          color: AppColors.splitColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.splitColor.withOpacity(0.3)),
        ),
        child: Text(
          example,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.splitColor,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}
