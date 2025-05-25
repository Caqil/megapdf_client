// lib/presentation/providers/scanner_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/services/recent_files_service.dart';
import 'file_operation_notifier.dart';
import 'file_manager_provider.dart';

part 'scanner_provider.g.dart';

@riverpod
class ScannerNotifier extends _$ScannerNotifier {
  @override
  ScannerState build() {
    return const ScannerState();
  }

  void resetState() {
    state = const ScannerState();
  }

  Future<void> startScanning(BuildContext context, {int maxPages = 1}) async {
    try {
      state = state.copyWith(isScanning: true, error: null);

      // Use the correct method to scan documents
      final scannedDocuments =
          await FlutterDocScanner().getScanDocuments(page: maxPages);

      if (scannedDocuments != null) {
        // Store the scanned document info
        state = state.copyWith(
          isScanning: false,
          scannedDocuments: scannedDocuments,
          // For Android, scannedDocuments is a PDF path
          // For iOS, scannedDocuments is a list of PNG paths
          isPdf: Platform.isAndroid,
        );
      } else {
        // User cancelled scanning
        state = state.copyWith(
          isScanning: false,
        );
      }
    } on PlatformException catch (e) {
      state = state.copyWith(
        isScanning: false,
        error: 'Error during scanning: ${e.message}',
      );
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        error: 'Error during scanning: ${e.toString()}',
      );
    }
  }

  Future<void> convertToPDF(BuildContext context) async {
    if (!state.hasScannedDocuments) {
      state = state.copyWith(
        error: 'No scanned document available',
      );
      return;
    }

    try {
      state = state.copyWith(isConverting: true, error: null);

      // For Android, the document is already a PDF - just copy it
      if (state.isPdf) {
        final sourceFile = File(state.scannedDocuments as String);

        // Add to app's storage
        final fileManagerNotifier =
            ref.read(fileManagerNotifierProvider.notifier);
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final savedPath = await fileManagerNotifier.addFile(
          sourceFile,
          customName: 'Scanned_Document_$timestamp',
        );

        if (savedPath != null) {
          // Track the scan operation in recent files
          final recentFilesService = ref.read(recentFilesServiceProvider);
          await recentFilesService.trackScan(
            resultFilePath: savedPath,
            resultFileName: path.basename(savedPath),
            originalSize: sourceFile.lengthSync(),
          );

          // Notify file operation completed
          ref
              .read(fileOperationNotifierProvider.notifier)
              .notifyOperationCompleted('scan');

          // Update state with saved PDF path
          state = state.copyWith(
            isConverting: false,
            savedPdfPath: savedPath,
          );

          // Close the scanner page after successful conversion
          if (context.mounted) {
            Navigator.of(context).pop();

            // Optional: Show a success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF saved successfully'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          state = state.copyWith(
            isConverting: false,
            error: 'Failed to save PDF file',
          );
        }
        return;
      }

      // For iOS, we need to convert images to PDF
      // Create a PDF document
      final pdf = pw.Document();

      // Add each image to a PDF page
      if (state.scannedDocuments is List) {
        final List<String> imagePaths = state.scannedDocuments.cast<String>();

        for (final imagePath in imagePaths) {
          final imageFile = File(imagePath);
          final imageBytes = await imageFile.readAsBytes();
          final image = pw.MemoryImage(imageBytes);

          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (pw.Context context) {
                return pw.Center(
                  child: pw.Image(image, fit: pw.BoxFit.contain),
                );
              },
            ),
          );
        }
      }

      // Save the PDF to a temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final pdfPath = path.join(tempDir.path, 'scan_$timestamp.pdf');
      final File pdfFile = File(pdfPath);
      await pdfFile.writeAsBytes(await pdf.save());

      // Add to app's storage
      final fileManagerNotifier =
          ref.read(fileManagerNotifierProvider.notifier);
      final savedPath = await fileManagerNotifier.addFile(
        pdfFile,
        customName: 'Scanned_Document_$timestamp',
      );

      if (savedPath != null) {
        // Track the scan operation in recent files
        final recentFilesService = ref.read(recentFilesServiceProvider);
        await recentFilesService.trackScan(
          resultFilePath: savedPath,
          resultFileName: path.basename(savedPath),
          originalSize: pdfFile.lengthSync(),
        );

        // Notify file operation completed
        ref
            .read(fileOperationNotifierProvider.notifier)
            .notifyOperationCompleted('scan');

        // Update state with saved PDF path
        state = state.copyWith(
          isConverting: false,
          savedPdfPath: savedPath,
        );

        // Close the scanner page after successful conversion
        if (context.mounted) {
          Navigator.of(context).pop();

          // Optional: Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF saved successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        state = state.copyWith(
          isConverting: false,
          error: 'Failed to save PDF file',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isConverting: false,
        error: 'Error converting to PDF: ${e.toString()}',
      );
    }
  }

  Future<void> saveAsImage(BuildContext context) async {
    if (!state.hasScannedDocuments) {
      state = state.copyWith(
        error: 'No scanned document available',
      );
      return;
    }

    try {
      state = state.copyWith(isSaving: true, error: null);

      // For Android (PDF), convert first page to image
      if (state.isPdf) {
        // This would require a PDF to image conversion which is complex
        // For simplicity, we'll just save as PDF in this case
        await convertToPDF(context);
        return;
      }

      // For iOS, save the first image (or the one user selected)
      if (state.scannedDocuments is List && state.scannedDocuments.isNotEmpty) {
        final imagePath = state.scannedDocuments[0] as String;
        final sourceFile = File(imagePath);

        // Add to app's storage
        final fileManagerNotifier =
            ref.read(fileManagerNotifierProvider.notifier);
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final savedPath = await fileManagerNotifier.addFile(
          sourceFile,
          customName: 'Scanned_Image_$timestamp',
        );

        if (savedPath != null) {
          // Track the scan operation in recent files
          final recentFilesService = ref.read(recentFilesServiceProvider);
          await recentFilesService.trackScan(
            resultFilePath: savedPath,
            resultFileName: path.basename(savedPath),
            originalSize: sourceFile.lengthSync(),
            isImage: true,
          );

          // Notify file operation completed
          ref
              .read(fileOperationNotifierProvider.notifier)
              .notifyOperationCompleted('scan');

          // Update state with saved image path
          state = state.copyWith(
            isSaving: false,
            savedImagePath: savedPath,
          );
          if (context.mounted) {
            Navigator.of(context).pop();

            // Optional: Show a success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image saved successfully'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          state = state.copyWith(
            isSaving: false,
            error: 'Failed to save image file',
          );
        }
      } else {
        state = state.copyWith(
          isSaving: false,
          error: 'No images available to save',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Error saving image: ${e.toString()}',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class ScannerState {
  final bool isScanning;
  final bool isConverting;
  final bool isSaving;
  final dynamic
      scannedDocuments; // PDF path for Android, List of PNG paths for iOS
  final bool isPdf; // True if Android (direct PDF), False if iOS (PNGs)
  final String? savedPdfPath;
  final String? savedImagePath;
  final String? error;

  const ScannerState({
    this.isScanning = false,
    this.isConverting = false,
    this.isSaving = false,
    this.scannedDocuments,
    this.isPdf = false,
    this.savedPdfPath,
    this.savedImagePath,
    this.error,
  });

  ScannerState copyWith({
    bool? isScanning,
    bool? isConverting,
    bool? isSaving,
    dynamic scannedDocuments,
    bool? isPdf,
    String? savedPdfPath,
    String? savedImagePath,
    String? error,
  }) {
    return ScannerState(
      isScanning: isScanning ?? this.isScanning,
      isConverting: isConverting ?? this.isConverting,
      isSaving: isSaving ?? this.isSaving,
      scannedDocuments: scannedDocuments ?? this.scannedDocuments,
      isPdf: isPdf ?? this.isPdf,
      savedPdfPath: savedPdfPath ?? this.savedPdfPath,
      savedImagePath: savedImagePath ?? this.savedImagePath,
      error: error,
    );
  }

  bool get hasScannedDocuments => scannedDocuments != null;
  bool get hasError => error != null;
  bool get isProcessing => isScanning || isConverting || isSaving;
  bool get hasSavedFile => savedPdfPath != null || savedImagePath != null;

  // Helper to get document path (first document if multiple)
  String? get documentPath {
    if (scannedDocuments == null) return null;

    // Android: scannedDocuments is a PDF path string
    if (isPdf) return scannedDocuments as String;

    // iOS: scannedDocuments is a list of PNG paths
    if (scannedDocuments is List && scannedDocuments.isNotEmpty) {
      return scannedDocuments[0] as String;
    }

    return null;
  }
}
