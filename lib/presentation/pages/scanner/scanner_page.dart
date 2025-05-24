import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/scanner_provider.dart';
import '../../widgets/common/custom_snackbar.dart';
import 'widgets/save_options_bottom_sheet.dart';
import 'widgets/scan_result_view.dart';

class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startScanning() async {
    await ref
        .read(scannerNotifierProvider.notifier)
        .startScanning(context, maxPages: 3);

    final scannerState = ref.read(scannerNotifierProvider);
    if (scannerState.hasScannedDocuments) {
      _animationController.forward();
      // Show save options if scanning was successful
      if (mounted) {
        _showSaveOptionsBottomSheet();
      }
    }
  }

  void _showSaveOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SaveOptionsBottomSheet(
        onSaveAsImage: () {
          Navigator.pop(context);
          _saveAsImage();
        },
        onSaveToPdf: () {
          Navigator.pop(context);
          _convertToPdf();
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _saveAsImage() async {
    final loadingKey = GlobalKey<State>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        key: loadingKey,
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(
                strokeWidth: 8,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primary(context)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Saving Image...",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please wait while we process your document",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    await ref.read(scannerNotifierProvider.notifier).saveAsImage(context);

    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop(); // Close loading dialog
    }

    final scannerState = ref.read(scannerNotifierProvider);
    if (scannerState.savedImagePath != null) {
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Image saved successfully!',
          type: SnackbarType.success,
          duration: const Duration(seconds: 3),
        );
      }
    } else if (scannerState.error != null) {
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: scannerState.error!,
          type: SnackbarType.failure,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _convertToPdf() async {
    final loadingKey = GlobalKey<State>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        key: loadingKey,
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              width: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary(context)),
                    ),
                  ),
                  Icon(
                    Icons.picture_as_pdf,
                    size: 40,
                    color: AppColors.primary(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Converting to PDF...",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please wait while we create your PDF document",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    await ref.read(scannerNotifierProvider.notifier).convertToPDF(context);

    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop(); // Close loading dialog
    }

    final scannerState = ref.read(scannerNotifierProvider);
    if (scannerState.savedPdfPath != null) {
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'PDF saved successfully!',
          type: SnackbarType.success,
          duration: const Duration(seconds: 3),
        );
      }
    } else if (scannerState.error != null) {
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: scannerState.error!,
          type: SnackbarType.failure,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerNotifierProvider);

    return WillPopScope(
      onWillPop: () async {
        if (scannerState.isProcessing) {
          // Prevent back navigation during processing
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: _buildAppBar(scannerState),
        body: _buildBody(scannerState),
        floatingActionButton: _buildFloatingActionButton(scannerState),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ScannerState scannerState) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.surface(context),
      title: Text(
        'Document Scanner',
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: scannerState.isProcessing
              ? AppColors.textSecondary(context).withOpacity(0.5)
              : AppColors.textPrimary(context),
        ),
        onPressed: scannerState.isProcessing ? null : () => context.pop(),
      ),
      actions: [
        if (scannerState.hasScannedDocuments && !scannerState.isProcessing)
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: AppColors.primary(context),
            ),
            onPressed: _startScanning,
            tooltip: 'Scan Again',
          ),
        if (scannerState.hasScannedDocuments && !scannerState.isProcessing)
          IconButton(
            icon: Icon(
              Icons.save_alt,
              color: AppColors.primary(context),
            ),
            onPressed: _showSaveOptionsBottomSheet,
            tooltip: 'Save Options',
          ),
      ],
    );
  }

  Widget _buildBody(ScannerState scannerState) {
    if (scannerState.isScanning) {
      return _buildScanningState();
    }

    if (scannerState.hasError) {
      return _buildErrorState(scannerState);
    }

    if (scannerState.hasScannedDocuments) {
      return ScanResultView(
        documentPath: scannerState.documentPath!,
        isPdf: scannerState.isPdf,
        onScanAgain: _startScanning,
        onSaveOptions: _showSaveOptionsBottomSheet,
      );
    }

    // Empty state or scanning cancelled
    return _buildEmptyState();
  }

  Widget _buildScanningState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface(context),
            AppColors.primary(context).withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary(context).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 8,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary(context),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Scanner is initializing...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Please hold your camera steady and point it at the document',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ScannerState scannerState) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface(context),
            Colors.red.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error(context),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Scanning Failed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.error(context),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                scannerState.error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _startScanning,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface(context),
            AppColors.primary(context).withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace this with Lottie animation if available
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.document_scanner_outlined,
                size: 80,
                color: AppColors.primary(context),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Ready to Scan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Capture documents, receipts, or notes and convert them to PDF',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: _startScanning,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Start Scanning'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
                shadowColor: AppColors.primary(context).withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton(ScannerState scannerState) {
    if (scannerState.hasScannedDocuments && !scannerState.isProcessing) {
      return FloatingActionButton.extended(
        onPressed: _showSaveOptionsBottomSheet,
        icon: const Icon(Icons.save),
        label: const Text('Save Document'),
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        elevation: 4,
      );
    }

    return null;
  }
}
