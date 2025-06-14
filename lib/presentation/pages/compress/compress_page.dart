import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/compress_provider.dart';
import '../../widgets/common/app_bar_widget.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/file_picker_button.dart';
import '../../widgets/common/download_button.dart';
import 'widgets/compression_result.dart';

class CompressPage extends ConsumerStatefulWidget {
  final String? initialFilePath;
  final String? initialFileName;

  const CompressPage({
    super.key,
    this.initialFilePath,
    this.initialFileName,
  });

  @override
  ConsumerState<CompressPage> createState() => _CompressPageState();
}

class _CompressPageState extends ConsumerState<CompressPage> {
  @override
  void initState() {
    super.initState();

    // Check for parameters in route and load file if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialFileIfAvailable();
    });
  }

  void _loadInitialFileIfAvailable() {
    if (widget.initialFilePath != null && widget.initialFilePath!.isNotEmpty) {
      try {
        final file = File(widget.initialFilePath!);
        if (file.existsSync()) {
          // Select the file in the provider
          ref.read(compressNotifierProvider.notifier).selectFile(file);

          // Show a notification to the user
          CustomSnackbar.show(
            context: context,
            message:
                'Loaded ${widget.initialFileName ?? "file"} for protection',
            type: SnackbarType.success,
          );
        } else {
          CustomSnackbar.show(
            context: context,
            message: 'Could not find the selected file',
            type: SnackbarType.failure,
          );
        }
      } catch (e) {
        CustomSnackbar.show(
          context: context,
          message: 'Error loading file: $e',
          type: SnackbarType.failure,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(compressNotifierProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Compress PDF',
        subtitle: 'Reduce file size while maintaining quality',
        onBack: () => context.pop('/'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // File Selection Section
              _buildFileSelectionSection(context, ref, state),

              if (state.hasFile) ...[
                const SizedBox(height: 24),
                _buildFileInfoSection(context, state),
              ],

              if (state.hasResult) ...[
                const SizedBox(height: 24),
                CompressionResult(result: state.result!),
              ],

              if (state.hasError) ...[
                const SizedBox(height: 24),
                CustomErrorWidget(
                  message: state.error!,
                  onRetry: state.canCompress
                      ? () => ref
                          .read(compressNotifierProvider.notifier)
                          .compressPdf(state.selectedFile!)
                      : null,
                ),
              ],

              const SizedBox(height: 24),
              _buildActionButtons(context, ref, state),

              const SizedBox(height: 24),
              _buildInfoSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileSelectionSection(
      BuildContext context, WidgetRef ref, CompressState state) {
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
                  Icons.upload_file,
                  color: AppColors.primary(context),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Select PDF File',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilePickerButton(
              onFileSelected: (file) {
                ref.read(compressNotifierProvider.notifier).selectFile(file);
              },
              acceptedExtensions: const ['.pdf'],
              maxSizeInMB: 50,
              buttonText: state.hasFile ? 'Change PDF File' : 'Choose PDF File',
              helperText: 'Select a PDF file up to 50MB to compress',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfoSection(BuildContext context, CompressState state) {
    final file = state.selectedFile!;

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
                  Icons.insert_drive_file,
                  color: AppColors.success(context),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Selected File',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.success(context).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.path.split('/').last,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Size: ${file.lengthSync().toString()} bytes',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary(context),
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

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, CompressState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Compress Button
        if (!state.hasResult) ...[
          ElevatedButton.icon(
            onPressed: state.canCompress
                ? () => ref
                    .read(compressNotifierProvider.notifier)
                    .compressPdf(state.selectedFile!)
                : null,
            icon: state.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.compress),
            label: Text(state.isLoading ? 'Compressing...' : 'Compress PDF'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.compressColor(context),
            ),
          ),
        ],

        if (state.hasResult) ...[
          SaveButton(
            onPressed: state.canSave
                ? () => ref.read(compressNotifierProvider.notifier).saveResult()
                : null,
            isLoading: state.isSaving,
            savedPath: state.savedPath,
            buttonText: 'Save Compressed PDF',
          ),
          const SizedBox(height: 12),

          // Process Another Button
          OutlinedButton.icon(
            onPressed: () =>
                ref.read(compressNotifierProvider.notifier).reset(),
            icon: const Icon(Icons.refresh),
            label: const Text('Compress Another PDF'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
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
                  Icons.info_outline,
                  color: AppColors.info(context),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'About PDF Compression',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'PDF compression reduces file size by optimizing images, fonts, and structure while maintaining document quality. This is useful for:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
            const SizedBox(height: 12),
            _buildInfoList(context, [
              'Faster file sharing and uploads',
              'Reduced storage requirements',
              'Improved email attachment compatibility',
              'Better web page loading performance',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoList(BuildContext context, List<String> items) {
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary(context),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
