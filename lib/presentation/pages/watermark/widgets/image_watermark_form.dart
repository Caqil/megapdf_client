// lib/presentation/pages/watermark/widgets/image_watermark_form.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/common/file_picker_button.dart';

class ImageWatermarkForm extends StatelessWidget {
  final File? selectedImage;
  final Function(File) onImageSelected;

  const ImageWatermarkForm({
    super.key,
    this.selectedImage,
    required this.onImageSelected,
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
                  Icons.image,
                  color: AppColors.watermarkColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Image Watermark',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (selectedImage == null) ...[
              FilePickerButton(
                onFileSelected: onImageSelected,
                acceptedExtensions: const ['.jpg', '.jpeg', '.png', '.gif'],
                maxSizeInMB: 10,
                buttonText: 'Choose Image',
                helperText: 'Select an image file up to 10MB (JPG, PNG, GIF)',
              ),
            ] else ...[
              // Selected Image Preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    // Image preview
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      selectedImage!.path.split('/').last,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Size: ${(selectedImage!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),

                    const SizedBox(height: 12),

                    TextButton.icon(
                      onPressed: () {
                        // Show file picker again to change image
                      },
                      icon: const Icon(Icons.change_circle),
                      label: const Text('Change Image'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
