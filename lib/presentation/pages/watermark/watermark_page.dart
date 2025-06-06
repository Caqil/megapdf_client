// lib/presentation/pages/watermark/watermark_page.dart - Updated implementation
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/watermark_result.dart';
import '../../providers/watermark_provider.dart';
import '../../widgets/common/app_bar_widget.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/file_picker_button.dart';
import '../../widgets/common/download_button.dart';
import '../../widgets/watermark_position_selector.dart';
import '../../widgets/watermark_settings.dart';
import 'widgets/watermark_type_tabs.dart';
import 'widgets/text_watermark_form.dart';
import 'widgets/image_watermark_form.dart';
import 'widgets/watermark_result_widget.dart';
// import 'widgets/watermark_debug_widget.dart'; // Uncomment for debugging

class WatermarkPage extends ConsumerStatefulWidget {
  final String? initialFilePath;
  final String? initialFileName;

  const WatermarkPage({
    super.key,
    this.initialFilePath,
    this.initialFileName,
  });

  @override
  ConsumerState<WatermarkPage> createState() => _WatermarkPageState();
}

class _WatermarkPageState extends ConsumerState<WatermarkPage> {
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
          ref.read(watermarkNotifierProvider.notifier).selectFile(file);

          // Show a notification to the user
          CustomSnackbar.show(
            context: context,
            message:
                'Loaded ${widget.initialFileName ?? "file"} for watermarking',
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
    final state = ref.watch(watermarkNotifierProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add Watermark',
        subtitle: 'Add text or image watermark to PDF',
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
                _buildWatermarkTypeSection(context, ref, state),
                const SizedBox(height: 24),
                _buildWatermarkContentSection(context, ref, state),
                const SizedBox(height: 24),
                WatermarkPositionSelector(
                  selectedPosition: state.position,
                  onPositionChanged: (position) => ref
                      .read(watermarkNotifierProvider.notifier)
                      .updatePositionOptions(position: position),
                ),
                const SizedBox(height: 24),
                WatermarkSettings(
                  watermarkType: state.watermarkType,
                  rotation: state.rotation,
                  opacity: state.opacity,
                  scale: state.scale,
                  pages: state.pages,
                  customPages: state.customPages,
                  customX: state.customX,
                  customY: state.customY,
                  position: state.position,
                  onRotationChanged: (rotation) => ref
                      .read(watermarkNotifierProvider.notifier)
                      .updatePositionOptions(rotation: rotation),
                  onOpacityChanged: (opacity) => ref
                      .read(watermarkNotifierProvider.notifier)
                      .updatePositionOptions(opacity: opacity),
                  onScaleChanged: (scale) => ref
                      .read(watermarkNotifierProvider.notifier)
                      .updatePositionOptions(scale: scale),
                  onPagesChanged: (pages) => ref
                      .read(watermarkNotifierProvider.notifier)
                      .updatePageOptions(pages: pages),
                  onCustomPagesChanged: (customPages) => ref
                      .read(watermarkNotifierProvider.notifier)
                      .updatePageOptions(customPages: customPages),
                  onCustomPositionChanged: (x, y) => ref
                      .read(watermarkNotifierProvider.notifier)
                      .updatePositionOptions(customX: x, customY: y),
                ),
              ],

              if (state.hasResult) ...[
                const SizedBox(height: 24),
                WatermarkResultWidget(result: state.result!),
              ],

              if (state.hasError) ...[
                const SizedBox(height: 24),
                CustomErrorWidget(
                  message: state.error!,
                  onRetry: state.canAddWatermark
                      ? () => ref
                          .read(watermarkNotifierProvider.notifier)
                          .addWatermark()
                      : null,
                ),
              ],

              const SizedBox(height: 24),
              _buildActionButtons(context, ref, state),

              // Debug widget (uncomment for testing)
              // const SizedBox(height: 24),
              // WatermarkDebugWidget(
              //   watermarkType: state.watermarkType,
              //   text: state.text,
              //   textColor: state.textColor,
              //   fontSize: state.fontSize,
              //   fontFamily: state.fontFamily,
              //   position: state.position,
              //   rotation: state.rotation,
              //   opacity: state.opacity,
              //   scale: state.scale,
              //   pages: state.pages,
              //   customPages: state.customPages,
              //   customX: state.customX,
              //   customY: state.customY,
              // ),

              const SizedBox(height: 24),
              _buildInfoSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileSelectionSection(
      BuildContext context, WidgetRef ref, WatermarkState state) {
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
                ref.read(watermarkNotifierProvider.notifier).selectFile(file);
              },
              acceptedExtensions: const ['.pdf'],
              maxSizeInMB: 50,
              buttonText: state.hasFile ? 'Change PDF File' : 'Choose PDF File',
              helperText: 'Select a PDF file up to 50MB to add watermark',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfoSection(BuildContext context, WatermarkState state) {
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

  Widget _buildWatermarkTypeSection(
      BuildContext context, WidgetRef ref, WatermarkState state) {
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
                  Icons.branding_watermark,
                  color: AppColors.watermarkColor(context),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Watermark Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            WatermarkTypeTabs(
              selectedType: state.watermarkType,
              onTypeChanged: (type) => ref
                  .read(watermarkNotifierProvider.notifier)
                  .selectWatermarkType(type),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatermarkContentSection(
      BuildContext context, WidgetRef ref, WatermarkState state) {
    if (state.watermarkType == WatermarkType.text) {
      return TextWatermarkForm(
        text: state.text,
        textColor: state.textColor,
        fontSize: state.fontSize,
        fontFamily: state.fontFamily,
        onTextChanged: (text) => ref
            .read(watermarkNotifierProvider.notifier)
            .updateTextOptions(text: text),
        onColorChanged: (color) => ref
            .read(watermarkNotifierProvider.notifier)
            .updateTextOptions(textColor: color),
        onFontSizeChanged: (size) => ref
            .read(watermarkNotifierProvider.notifier)
            .updateTextOptions(fontSize: size),
        onFontFamilyChanged: (family) => ref
            .read(watermarkNotifierProvider.notifier)
            .updateTextOptions(fontFamily: family),
      );
    } else {
      return ImageWatermarkForm(
        selectedImage: state.watermarkImage,
        onImageSelected: (image) => ref
            .read(watermarkNotifierProvider.notifier)
            .selectWatermarkImage(image),
      );
    }
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, WatermarkState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Add Watermark Button
        if (!state.hasResult) ...[
          ElevatedButton.icon(
            onPressed: state.canAddWatermark
                ? () =>
                    ref.read(watermarkNotifierProvider.notifier).addWatermark()
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
                : const Icon(Icons.branding_watermark),
            label:
                Text(state.isLoading ? 'Adding Watermark...' : 'Add Watermark'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.watermarkColor(context),
            ),
          ),
        ],

        // Download Button
        if (state.hasResult) ...[
          SaveButton(
            onPressed: state.canSave
                ? () =>
                    ref.read(watermarkNotifierProvider.notifier).saveResult()
                : null,
            isLoading: state.isSaving,
            savedPath: state.savedPath,
            buttonText: 'Save Watermarked PDF',
          ),
          const SizedBox(height: 12),

          // Process Another Button
          OutlinedButton.icon(
            onPressed: () =>
                ref.read(watermarkNotifierProvider.notifier).reset(),
            icon: const Icon(Icons.refresh),
            label: const Text('Add Watermark to Another PDF'),
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
                  'About Watermarks',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Add watermarks to protect and brand your documents:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
            const SizedBox(height: 12),
            _buildInfoList(context, [
              'Text watermarks for copyright notices',
              'Image watermarks for logos and branding',
              'Customizable position, rotation, and opacity',
              'Apply to specific pages or entire document',
              'Professional results with precise control',
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
