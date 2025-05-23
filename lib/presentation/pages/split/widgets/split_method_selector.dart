// lib/presentation/pages/split/widgets/split_method_selector.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/split_options.dart';

class SplitMethodSelector extends StatelessWidget {
  final SplitMethod selectedMethod;
  final Function(SplitMethod) onMethodChanged;

  const SplitMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Split Method:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Column(
          children: SplitMethod.values.map((method) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildMethodOption(context, method),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMethodOption(BuildContext context, SplitMethod method) {
    final isSelected = selectedMethod == method;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? AppColors.splitColor(context)
              : AppColors.border(context),
          width: isSelected ? 2 : 1,
        ),
        color:
            isSelected ? AppColors.splitColor(context).withOpacity(0.1) : null,
      ),
      child: RadioListTile<SplitMethod>(
        value: method,
        groupValue: selectedMethod,
        onChanged: (value) => onMethodChanged(value!),
        title: Text(
          method.displayName,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.splitColor(context) : null,
              ),
        ),
        subtitle: Text(
          method.description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary(context),
              ),
        ),
        activeColor: AppColors.splitColor(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}
