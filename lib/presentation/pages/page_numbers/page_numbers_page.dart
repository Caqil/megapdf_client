// lib/presentation/pages/page_numbers/page_numbers_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/page_numbers_provider.dart';
import '../../widgets/common/app_bar_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/file_picker_button.dart';
import '../../widgets/common/download_button.dart';
import 'widgets/numbering_options.dart';
import 'widgets/position_selector.dart';
import 'widgets/page_numbers_result_widget.dart';

class PageNumbersPage extends ConsumerWidget {
  const PageNumbersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pageNumbersNotifierProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add Page Numbers',
        subtitle: 'Add page numbers to your PDF document',
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
                PositionSelector(
                  selectedPosition: state.position,
                  onPositionChanged: (position) => ref
                      .read(pageNumbersNotifierProvider.notifier)
                      .updatePosition(position),
                ),
                const SizedBox(height: 24),
                NumberingOptions(
                  format: state.format,
                  fontFamily: state.fontFamily,
                  fontSize: state.fontSize,
                  color: state.color,
                  startNumber: state.startNumber,
                  prefix: state.prefix,
                  suffix: state.suffix,
                  marginX: state.marginX,
                  marginY: state.marginY,
                  selectedPages: state.selectedPages,
                  skipFirstPage: state.skipFirstPage,
                  onFormatChanged: (format) => ref
                      .read(pageNumbersNotifierProvider.notifier)
                      .updateFormat(format),
                  onFontOptionsChanged: (fontFamily, fontSize, color) => ref
                      .read(pageNumbersNotifierProvider.notifier)
                      .updateFontOptions(
                        fontFamily: fontFamily,
                        fontSize: fontSize,
                        color: color,
                      ),
                  onNumberingChanged: (startNumber, prefix, suffix) => ref
                      .read(pageNumbersNotifierProvider.notifier)
                      .updateNumberingOptions(
                        startNumber: startNumber,
                        prefix: prefix,
                        suffix: suffix,
                      ),
                  onMarginsChanged: (marginX, marginY) => ref
                      .read(pageNumbersNotifierProvider.notifier)
                      .updateMargins(marginX: marginX, marginY: marginY),
                  onPageSelectionChanged: (selectedPages, skipFirstPage) => ref
                      .read(pageNumbersNotifierProvider.notifier)
                      .updatePageSelection(
                        selectedPages: selectedPages,
                        skipFirstPage: skipFirstPage,
                      ),
                ),
              ],

              if (state.hasResult) ...[
                const SizedBox(height: 24),
                PageNumbersResultWidget(result: state.result!),
              ],

              if (state.hasError) ...[
                const SizedBox(height: 24),
                CustomErrorWidget(
                  message: state.error!,
                  onRetry: state.canAddPageNumbers
                      ? () => ref
                          .read(pageNumbersNotifierProvider.notifier)
                          .addPageNumbers()
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
      BuildContext context, WidgetRef ref, PageNumbersState state) {
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
                ref.read(pageNumbersNotifierProvider.notifier).selectFile(file);
              },
              acceptedExtensions: const ['.pdf'],
              maxSizeInMB: 50,
              buttonText: state.hasFile ? 'Change PDF File' : 'Choose PDF File',
              helperText: 'Select a PDF file up to 50MB to add page numbers',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfoSection(BuildContext context, PageNumbersState state) {
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
                  const SizedBox(height: 8),
                  // Preview of how page numbers will look
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          AppColors.pageNumbersColor(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.format_list_numbered,
                          color: AppColors.pageNumbersColor(context),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Preview: ${state.previewText}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.pageNumbersColor(context),
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
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
      BuildContext context, WidgetRef ref, PageNumbersState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Add Page Numbers Button
        if (!state.hasResult) ...[
          ElevatedButton.icon(
            onPressed: state.canAddPageNumbers
                ? () => ref
                    .read(pageNumbersNotifierProvider.notifier)
                    .addPageNumbers()
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
                : const Icon(Icons.format_list_numbered),
            label: Text(
                state.isLoading ? 'Adding Numbers...' : 'Add Page Numbers'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.pageNumbersColor(context),
            ),
          ),
        ],

        // Download Button
        if (state.hasResult) ...[
          SaveButton(
            onPressed: state.canSave
                ? () =>
                    ref.read(pageNumbersNotifierProvider.notifier).saveResult()
                : null,
            isLoading: state.isSaving,
            savedPath: state.savedPath,
            buttonText: 'Save Unlocked PDF',
          ),
          const SizedBox(height: 12),

          // Process Another Button
          OutlinedButton.icon(
            onPressed: () =>
                ref.read(pageNumbersNotifierProvider.notifier).reset(),
            icon: const Icon(Icons.refresh),
            label: const Text('Add Numbers to Another PDF'),
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
                  'About Page Numbers',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Add professional page numbers to your PDF documents:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
            const SizedBox(height: 12),
            _buildInfoList(context, [
              'Multiple numbering formats (1,2,3 or i,ii,iii or a,b,c)',
              'Customizable position and styling',
              'Add prefix and suffix text',
              'Skip first page option for title pages',
              'Apply to specific pages or entire document',
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
