// lib/presentation/pages/rotate/rotate_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/rotate_provider.dart';
import '../../widgets/common/app_bar_widget.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/file_picker_button.dart';
import '../../widgets/common/download_button.dart';
import 'widgets/rotation_selector.dart';
import 'widgets/page_selector.dart';
import 'widgets/rotate_result_widget.dart';

class RotatePage extends ConsumerStatefulWidget {
  final String? initialFilePath;
  final String? initialFileName;

  const RotatePage({
    super.key,
    this.initialFilePath,
    this.initialFileName,
  });

  @override
  ConsumerState<RotatePage> createState() => _RotatePageState();
}

class _RotatePageState extends ConsumerState<RotatePage> {
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
          ref.read(rotateNotifierProvider.notifier).selectFile(file);

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
    final state = ref.watch(rotateNotifierProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Rotate PDF',
        subtitle: 'Rotate pages in your PDF document',
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
                const SizedBox(height: 24),
                RotationSelector(
                  selectedAngle: state.angle,
                  onAngleChanged: (angle) => ref
                      .read(rotateNotifierProvider.notifier)
                      .updateAngle(angle),
                ),
                const SizedBox(height: 24),
                PageSelector(
                  pages: state.pages,
                  onPagesChanged: (pages) => ref
                      .read(rotateNotifierProvider.notifier)
                      .updatePages(pages),
                ),
              ],

              if (state.hasResult) ...[
                const SizedBox(height: 24),
                RotateResultWidget(result: state.result!),
              ],

              if (state.hasError) ...[
                const SizedBox(height: 24),
                CustomErrorWidget(
                  message: state.error!,
                  onRetry: state.canRotate
                      ? () =>
                          ref.read(rotateNotifierProvider.notifier).rotatePdf()
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
      BuildContext context, WidgetRef ref, RotateState state) {
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
                ref.read(rotateNotifierProvider.notifier).selectFile(file);
              },
              acceptedExtensions: const ['.pdf'],
              maxSizeInMB: 50,
              buttonText: state.hasFile ? 'Change PDF File' : 'Choose PDF File',
              helperText: 'Select a PDF file up to 50MB to rotate',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfoSection(BuildContext context, RotateState state) {
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
                    'Size: ${(file.lengthSync() / (1024 * 1024)).toStringAsFixed(1)} MB',
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
      BuildContext context, WidgetRef ref, RotateState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Rotate Button
        if (!state.hasResult) ...[
          ElevatedButton.icon(
            onPressed: state.canRotate
                ? () => ref.read(rotateNotifierProvider.notifier).rotatePdf()
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
                : const Icon(Icons.rotate_right),
            label: Text(state.isLoading ? 'Rotating...' : 'Rotate PDF'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.rotateColor(context),
            ),
          ),
        ],

        // Download Button
        if (state.hasResult) ...[
          SaveButton(
            onPressed: state.canSave
                ? () => ref.read(rotateNotifierProvider.notifier).saveResult()
                : null,
            isLoading: state.isSaving,
            savedPath: state.savedPath,
            buttonText: 'Save Rotate PDF',
          ),
          const SizedBox(height: 12),

          // Process Another Button
          OutlinedButton.icon(
            onPressed: () => ref.read(rotateNotifierProvider.notifier).reset(),
            icon: const Icon(Icons.refresh),
            label: const Text('Rotate Another PDF'),
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
                  'About PDF Rotation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Rotate pages in your PDF document:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
            const SizedBox(height: 12),
            _buildInfoList(context, [
              'Rotate pages by 90°, 180°, or 270°',
              'Apply rotation to all pages or specific pages',
              'Maintains document quality and formatting',
              'Perfect for fixing document orientation',
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
