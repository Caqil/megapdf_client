// lib/presentation/widgets/common/save_button.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? savedPath;
  final String buttonText;

  const SaveButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.savedPath,
    this.buttonText = 'Save Result',
  });

  @override
  Widget build(BuildContext context) {
    if (savedPath != null) {
      return _buildSuccessState(context);
    }

    if (isLoading) {
      return _buildLoadingState();
    }

    return _buildInitialState();
  }

  Widget _buildSuccessState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'File Saved Successfully!',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'File saved to app storage',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ElevatedButton.icon(
      onPressed: null,
      icon: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
      label: const Text('Saving...'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Widget _buildInitialState() {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.save),
      label: Text(buttonText),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
