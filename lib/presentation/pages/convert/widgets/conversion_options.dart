// lib/presentation/pages/convert/widgets/conversion_options.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ConversionOptions extends StatelessWidget {
  final bool enableOcr;
  final int quality;
  final String password;
  final Function(bool) onOcrChanged;
  final Function(int) onQualityChanged;
  final Function(String) onPasswordChanged;

  const ConversionOptions({
    super.key,
    required this.enableOcr,
    required this.quality,
    required this.password,
    required this.onOcrChanged,
    required this.onQualityChanged,
    required this.onPasswordChanged,
  });

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
                  Icons.settings,
                  color: AppColors.convertColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Conversion Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // OCR Option
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.text_fields,
                        color: AppColors.convertColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enable OCR',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              'Extract text from images and scanned documents',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: enableOcr,
                        onChanged: onOcrChanged,
                        activeColor: AppColors.convertColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quality Setting
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quality: ${quality}%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: quality.toDouble(),
                  min: 10,
                  max: 100,
                  divisions: 9,
                  activeColor: AppColors.convertColor,
                  onChanged: (value) => onQualityChanged(value.round()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Low',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    Text(
                      'High',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Password Input
            TextFormField(
              initialValue: password,
              decoration: const InputDecoration(
                labelText: 'Password (if file is protected)',
                hintText: 'Enter password for protected files',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              onChanged: onPasswordChanged,
            ),
          ],
        ),
      ),
    );
  }
}
