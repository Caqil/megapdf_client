// lib/presentation/widgets/common/file_picker_button.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/file_utils.dart';

class FilePickerButton extends StatelessWidget {
  final Function(File) onFileSelected;
  final List<String>? acceptedExtensions;
  final int? maxSizeInMB;
  final String? buttonText;
  final String? helperText;
  final bool allowMultiple;

  const FilePickerButton({
    super.key,
    required this.onFileSelected,
    this.acceptedExtensions,
    this.maxSizeInMB,
    this.buttonText,
    this.helperText,
    this.allowMultiple = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.border(context),
              style: BorderStyle.solid,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 40,
                    color: AppColors.primary(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    buttonText ?? 'Choose File',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary(context),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (helperText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      helperText!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions:
            acceptedExtensions?.map((e) => e.replaceFirst('.', '')).toList(),
        allowMultiple: allowMultiple,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;
        final file = File(platformFile.path!);

        // Validate file
        final validationError =
            FileUtils.validateFile(file, maxSizeInMB: maxSizeInMB);
        if (validationError != null) {
          throw Exception(validationError);
        }

        onFileSelected(file);
      }
    } catch (e) {
      // Handle error - you might want to show a snackbar or dialog
      debugPrint('File picker error: $e');
    }
  }
}
