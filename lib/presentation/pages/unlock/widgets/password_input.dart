// lib/presentation/pages/unlock/widgets/password_input.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PasswordInput extends StatefulWidget {
  final String password;
  final Function(String) onPasswordChanged;

  const PasswordInput({
    super.key,
    required this.password,
    required this.onPasswordChanged,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController(text: widget.password);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock_open,
                  color: AppColors.unlockColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Enter Password',
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
                labelText: 'PDF Password',
                hintText: 'Enter the password for this PDF',
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
                helperText:
                    'This is the password that was used to protect the PDF',
              ),
              obscureText: _obscurePassword,
              onChanged: widget.onPasswordChanged,
            ),

            const SizedBox(height: 16),

            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
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
                      'Your password is used only to unlock the PDF and is not stored or transmitted.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.info,
                          ),
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
}
