import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/split_options.dart';
import '../../providers/split_provider.dart';
import '../../widgets/common/app_bar_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/file_picker_button.dart';
import 'widgets/split_method_selector.dart';
import 'widgets/page_range_input.dart';
import 'widgets/split_results.dart';

class SplitPage extends ConsumerWidget {
  const SplitPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(splitNotifierProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Split PDF',
        subtitle: 'Extract pages or split into multiple files',
        onBack: () => context.go('/'),
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
                _buildSplitOptionsSection(context, ref, state),
              ],

              // Job Status Section (for async jobs)
              if (state.isAsyncJob && state.jobStatus != null) ...[
                const SizedBox(height: 24),
                _buildJobStatusSection(context, state),
              ],

              if (state.hasError) ...[
                const SizedBox(height: 24),
                CustomErrorWidget(
                  message: state.error!,
                  onRetry: state.canSplit
                      ? () => ref
                          .read(splitNotifierProvider.notifier)
                          .splitPdf(state.selectedFile!, state.splitOptions!)
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
      BuildContext context, WidgetRef ref, SplitState state) {
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
                ref.read(splitNotifierProvider.notifier).selectFile(file);
              },
              acceptedExtensions: const ['.pdf'],
              maxSizeInMB: 50,
              buttonText: state.hasFile ? 'Change PDF File' : 'Choose PDF File',
              helperText: 'Select a PDF file up to 50MB to split',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfoSection(BuildContext context, SplitState state) {
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

  Widget _buildSplitOptionsSection(
      BuildContext context, WidgetRef ref, SplitState state) {
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
                  Icons.settings,
                  color: AppColors.splitColor(context),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Split Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Split Method Selector
            SplitMethodSelector(
              selectedMethod:
                  state.splitOptions?.splitMethod ?? SplitMethod.range,
              onMethodChanged: (method) {
                final options = SplitOptions(splitMethod: method);
                ref
                    .read(splitNotifierProvider.notifier)
                    .updateSplitOptions(options);
              },
            ),

            const SizedBox(height: 16),

            // Additional options based on selected method
            if (state.splitOptions?.splitMethod == SplitMethod.range) ...[
              PageRangeInput(
                initialValue: state.splitOptions?.pageRanges ?? '',
                onChanged: (ranges) {
                  final options = SplitOptions.byRange(ranges);
                  ref
                      .read(splitNotifierProvider.notifier)
                      .updateSplitOptions(options);
                },
              ),
            ] else if (state.splitOptions?.splitMethod ==
                SplitMethod.every) ...[
              _buildEveryNInput(context, ref, state),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEveryNInput(
      BuildContext context, WidgetRef ref, SplitState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Split every N pages:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue:
                    state.splitOptions?.everyNPages?.toString() ?? '1',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter number of pages',
                  prefixIcon: Icon(Icons.pages),
                ),
                onChanged: (value) {
                  final n = int.tryParse(value) ?? 1;
                  final options = SplitOptions.everyNPages(n);
                  ref
                      .read(splitNotifierProvider.notifier)
                      .updateSplitOptions(options);
                },
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'pages',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJobStatusSection(BuildContext context, SplitState state) {
    final jobStatus = state.jobStatus!;

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
                  jobStatus.isCompleted
                      ? Icons.check_circle
                      : jobStatus.isError
                          ? Icons.error
                          : Icons.hourglass_empty,
                  color: jobStatus.isCompleted
                      ? AppColors.success(context)
                      : jobStatus.isError
                          ? AppColors.error(context)
                          : AppColors.warning(context),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    jobStatus.statusMessage,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            if (!jobStatus.isCompleted && !jobStatus.isError) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: jobStatus.progressPercentage,
                backgroundColor: AppColors.border(context),
                valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.splitColor(context)),
              ),
              const SizedBox(height: 8),
              Text(
                'Progress: ${jobStatus.progress}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, SplitState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Split Button
        if (!state.hasResult) ...[
          ElevatedButton.icon(
            onPressed: state.canSplit
                ? () => ref
                    .read(splitNotifierProvider.notifier)
                    .splitPdf(state.selectedFile!, state.splitOptions!)
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
                : const Icon(Icons.call_split),
            label: Text(state.isLoading ? 'Splitting...' : 'Split PDF'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.splitColor(context),
            ),
          ),
        ],

        // Process Another Button
        if (state.hasResult) ...[
          OutlinedButton.icon(
            onPressed: () => ref.read(splitNotifierProvider.notifier).reset(),
            icon: const Icon(Icons.refresh),
            label: const Text('Split Another PDF'),
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
                  'About PDF Splitting',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Split PDFs into smaller files using different methods:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
            const SizedBox(height: 12),
            _buildSplitMethodInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitMethodInfo(BuildContext context) {
    return Column(
      children: [
        _buildMethodInfo(
          context,
          'Custom Ranges',
          'Split by specific page ranges (e.g., 1-3, 5, 7-9)',
          Icons.view_array,
        ),
        _buildMethodInfo(
          context,
          'Extract All Pages',
          'Create a separate file for each page',
          Icons.layers,
        ),
        _buildMethodInfo(
          context,
          'Every N Pages',
          'Split into chunks of N pages each',
          Icons.view_module,
        ),
      ],
    );
  }

  Widget _buildMethodInfo(
      BuildContext context, String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.splitColor(context),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
