// lib/presentation/pages/compress/compress_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:megapdf_client/data/repositories/pdf_repository_impl.dart';
import 'package:megapdf_client/data/services/storage_service.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/compress_result.dart';
import '../../../data/repositories/pdf_repository.dart';
import '../../../data/services/recent_files_service.dart';
import '../../widgets/storage/storage_info_widget.dart';
import '../../widgets/storage/recently_saved_widget.dart';

class CompressPage extends ConsumerStatefulWidget {
  const CompressPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CompressPage> createState() => _CompressPageState();
}

class _CompressPageState extends ConsumerState<CompressPage> {
  File? _selectedFile;
  bool _isProcessing = false;
  CompressResult? _result;
  String? _errorMessage;
  double _compressionProgress = 0;
  String? _savedFilePath;
  bool _hasStoragePermission = false;

  @override
  void initState() {
    super.initState();
    _checkStoragePermission();
  }

  Future<void> _checkStoragePermission() async {
    final storageService = StorageService();
    final hasPermission = await storageService.checkPermissions();
    setState(() {
      _hasStoragePermission = hasPermission;
    });
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        setState(() {
          _selectedFile = file;
          _result = null;
          _errorMessage = null;
          _savedFilePath = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking file: $e';
      });
    }
  }

  Future<void> _compressPdf() async {
    if (_selectedFile == null) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _compressionProgress = 0;
    });

    try {
      // Request storage permissions if needed
      if (!_hasStoragePermission) {
        final storageService = StorageService();
        final granted = await storageService.requestPermissions(context);
        setState(() {
          _hasStoragePermission = granted;
        });

        if (!granted) {
          setState(() {
            _isProcessing = false;
            _errorMessage = 'Storage permission is required to save files';
          });
          return;
        }
      }

      // Compress the PDF
      final repository = ref.read(pdfRepositoryProvider);
      final result = await repository.compressPdf(_selectedFile!);

      // Save the file to local storage (if operation succeeded)
      if (result.success && result.fileUrl != null) {
        // Create proper subfolder name
        final String subfolder = 'Compressed';

        // Save the file to the "Compressed" subfolder in the MegaPDF directory
        final savedPath = await repository.saveProcessedFile(
          fileUrl: result.fileUrl!,
          filename: result.filename ?? 'compressed.pdf',
          customFileName: 'Compressed_${_selectedFile!.path.split('/').last}',
          subfolder: subfolder,
        );

        // Track operation in recent files
        if (savedPath.isNotEmpty) {
          final recentFilesService = ref.read(recentFilesServiceProvider);
          await recentFilesService.trackCompress(
            originalFile: _selectedFile!,
            resultFileName: result.filename ?? 'compressed.pdf',
            resultFilePath: savedPath,
            compressionRatio: result.compressionRatio,
            originalSizeBytes: result.originalSize,
            compressedSizeBytes: result.compressedSize,
          );

          setState(() {
            _savedFilePath = savedPath;
          });

          // Navigate to success page
          _navigateToSuccessPage(savedPath, result.originalSize ?? 0,
              result.compressedSize ?? 0, result.compressionRatio ?? '0%');
          return;
        }
      }

      setState(() {
        _isProcessing = false;
        _result = result;
        _compressionProgress = 1.0; // Complete
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error compressing PDF: $e';
      });
    }
  }

  void _navigateToSuccessPage(String filePath, int originalSize,
      int compressedSize, String compressionRatio) {
    // Create details string for success page
    // Format: key1:value1|key2:value2|...
    final details = [
      'Original Size:${_formatFileSize(originalSize)}',
      'Compressed Size:${_formatFileSize(compressedSize)}',
      'Space Saved:${_formatFileSize(originalSize - compressedSize)}',
      'Compression Ratio:$compressionRatio',
    ].join('|');

    context.go(
      '/success',
      extra: {
        'filePath': filePath,
        'operationType': 'compress',
        'operationName': 'Compressed',
        'details': details,
      },
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compress PDF'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recently saved file card (if available)
            const RecentlySavedWidget(),

            // Storage info card
            const StorageInfoWidget(
                // This will be populated once implemented
                ),

            const SizedBox(height: 16),

            // File selection card
            _buildFileSelectionCard(),

            if (_selectedFile != null) ...[
              const SizedBox(height: 16),
              _buildProcessingCard(),
            ],

            if (_result != null) ...[
              const SizedBox(height: 16),
              _buildResultCard(),
            ],

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelectionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select PDF to Compress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose a PDF file to reduce its size while maintaining quality',
            ),
            const SizedBox(height: 16),
            if (_selectedFile == null)
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Select PDF File'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              )
            else
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.picture_as_pdf,
                      color: AppColors.primary(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedFile!.path.split('/').last,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${(File(_selectedFile!.path).lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedFile = null;
                        _result = null;
                        _errorMessage = null;
                      });
                    },
                  ),
                ],
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed:
                  _selectedFile != null && !_isProcessing ? _compressPdf : null,
              icon: const Icon(Icons.compress),
              label: const Text('Compress PDF'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: AppColors.primary(context),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Processing',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _isProcessing ? null : _compressionProgress,
              backgroundColor: AppColors.border(context),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isProcessing
                  ? 'Compressing PDF...'
                  : _result != null
                      ? 'Compression complete!'
                      : 'Ready to compress',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    if (_result == null) return const SizedBox.shrink();

    final success = _result!.success;
    final savedToExternal = _savedFilePath != null;

    return Card(
      elevation: 2,
      color: success
          ? AppColors.success(context).withOpacity(0.1)
          : AppColors.error(context).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: success
              ? AppColors.success(context).withOpacity(0.3)
              : AppColors.error(context).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success
                      ? AppColors.success(context)
                      : AppColors.error(context),
                ),
                const SizedBox(width: 8),
                Text(
                  success ? 'Compression Successful' : 'Compression Failed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: success
                            ? AppColors.success(context)
                            : AppColors.error(context),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (success &&
                _result!.originalSize != null &&
                _result!.compressedSize != null) ...[
              _buildResultRow(
                'Original Size',
                _result!.formattedOriginalSize,
              ),
              _buildResultRow(
                'Compressed Size',
                _result!.formattedCompressedSize,
              ),
              _buildResultRow(
                'Compression Ratio',
                '${_result!.compressionRatio}',
              ),
              _buildResultRow(
                'Space Saved',
                _result!.savedSpace,
              ),
              if (savedToExternal) ...[
                const Divider(),
                _buildResultRow(
                  'Saved To',
                  _savedFilePath!.split('/').last,
                  icon: Icons.folder,
                ),
                _buildResultRow(
                  'Storage Location',
                  _getShortenedPath(_savedFilePath!),
                  icon: Icons.save,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Open in viewer
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('View PDF'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Share file
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary(context),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(_result!.message),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      elevation: 2,
      color: AppColors.error(context).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.error(context).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error,
                  color: AppColors.error(context),
                ),
                const SizedBox(width: 8),
                Text(
                  'Error',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error(context),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_errorMessage ?? 'An unknown error occurred'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.textSecondary(context)),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),
        ],
      ),
    );
  }

  String _getShortenedPath(String fullPath) {
    // Find "MegaPDF" in the path and return everything after it
    final parts = fullPath.split('/');
    final megaPdfIndex = parts.indexOf('MegaPDF');

    if (megaPdfIndex >= 0) {
      return '/MegaPDF/${parts.sublist(megaPdfIndex + 1).join('/')}';
    }

    // If MegaPDF not found, return the last 3 directories
    if (parts.length > 3) {
      return '.../${parts.sublist(parts.length - 3).join('/')}';
    }

    return fullPath;
  }
}
