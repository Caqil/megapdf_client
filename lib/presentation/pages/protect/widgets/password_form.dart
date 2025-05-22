// lib/presentation/pages/protect/widgets/password_form.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PasswordForm extends StatefulWidget {
  final String password;
  final Function(String) onPasswordChanged;

  const PasswordForm({
    super.key,
    required this.password,
    required this.onPasswordChanged,
  });

  @override
  State<PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  late TextEditingController _passwordController;
  late TextEditingController _confirmController;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _confirmPassword = '';

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController(text: widget.password);
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
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
                  Icons.lock,
                  color: AppColors.protectColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Password Protection',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Password Input
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter a strong password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                errorText: _getPasswordError(),
              ),
              obscureText: _obscurePassword,
              onChanged: (value) {
                widget.onPasswordChanged(value);
                setState(() {});
              },
            ),

            const SizedBox(height: 16),

            // Confirm Password Input
            TextFormField(
              controller: _confirmController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },
                ),
                errorText: _getConfirmPasswordError(),
              ),
              obscureText: _obscureConfirm,
              onChanged: (value) {
                setState(() {
                  _confirmPassword = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Password Strength Indicator
            _buildPasswordStrengthIndicator(),

            const SizedBox(height: 16),

            // Password Tips
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        color: AppColors.info,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Password Tips:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.info,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Use at least 8 characters\n• Include uppercase and lowercase letters\n• Add numbers and special characters\n• Avoid common words or personal information',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
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

  String? _getPasswordError() {
    if (widget.password.isEmpty) return null;
    if (widget.password.length < 4) {
      return 'Password must be at least 4 characters';
    }
    return null;
  }

  String? _getConfirmPasswordError() {
    if (_confirmPassword.isEmpty) return null;
    if (_confirmPassword != widget.password) {
      return 'Passwords do not match';
    }
    return null;
  }

  Widget _buildPasswordStrengthIndicator() {
    final strength = _calculatePasswordStrength(widget.password);
    final strengthText = _getStrengthText(strength);
    final strengthColor = _getStrengthColor(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Password Strength: ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            Text(
              strengthText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: strengthColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: strength / 4,
          backgroundColor: AppColors.border,
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
        ),
      ],
    );
  }

  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength;
  }

  String _getStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Weak';
    }
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.info;
      case 4:
        return AppColors.success;
      default:
        return AppColors.error;
    }
  }
}
