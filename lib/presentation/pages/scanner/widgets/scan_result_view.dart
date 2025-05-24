// lib/presentation/pages/scanner/widgets/scan_result_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ScanResultView extends StatelessWidget {
  final dynamic documentPath; // String for Android (PDF), String for iOS (PNG)
  final bool isPdf;
  final VoidCallback onScanAgain;
  final VoidCallback onSaveOptions;

  const ScanResultView({
    super.key,
    required this.documentPath,
    required this.isPdf,
    required this.onScanAgain,
    required this.onSaveOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: isPdf
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            size: 64,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'PDF Document Scanned',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Document saved as PDF',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    )
                  : Image.file(
                      File(documentPath),
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: onScanAgain,
                icon: const Icon(Icons.refresh),
                label: const Text('Scan Again'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: onSaveOptions,
                icon: const Icon(Icons.save),
                label: const Text('Save Options'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
