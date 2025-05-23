// lib/presentation/pages/pdf_viewer/pdf_viewer_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

class PDFViewerPage extends ConsumerStatefulWidget {
  final String filePath;
  final String? fileName;

  const PDFViewerPage({
    super.key,
    required this.filePath,
    this.fileName,
  });

  @override
  ConsumerState<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends ConsumerState<PDFViewerPage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  PdfViewerController? _pdfViewerController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _showToolbar = true;
  int _currentPageNumber = 1;
  int _totalPages = 1;
  double _zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _checkFileExists();
  }

  Future<void> _checkFileExists() async {
    try {
      final file = File(widget.filePath);
      if (!await file.exists()) {
        setState(() {
          _hasError = true;
          _errorMessage = 'PDF file not found at: ${widget.filePath}';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error loading PDF: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _showToolbar ? _buildBottomToolbar() : null,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
        color: AppColors.textPrimary,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.fileName ?? 'PDF Viewer',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (!_isLoading && !_hasError)
            Text(
              'Page $_currentPageNumber of $_totalPages',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _shareFile,
          icon: const Icon(Icons.share),
          color: AppColors.textSecondary,
        ),
        IconButton(
          onPressed: _printDocument,
          icon: const Icon(Icons.print),
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading PDF...'),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Unable to load PDF',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: AppColors.error)),
            const SizedBox(height: 8),
            Text(_errorMessage ?? 'An unknown error occurred'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SfPdfViewer.file(
          File(widget.filePath),
          key: _pdfViewerKey,
          controller: _pdfViewerController,
          onDocumentLoaded: (details) {
            setState(() {
              _totalPages = details.document.pages.count;
            });
          },
          onPageChanged: (details) {
            setState(() {
              _currentPageNumber = details.newPageNumber;
            });
          },
          onZoomLevelChanged: (details) {
            setState(() {
              _zoomLevel = details.newZoomLevel;
            });
          },
          enableDoubleTapZooming: true,
          enableTextSelection: true,
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () => _pdfViewerController?.jumpToPage(1),
            icon: const Icon(Icons.first_page),
            tooltip: 'First Page',
          ),
          IconButton(
            onPressed: () => _pdfViewerController?.previousPage(),
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous Page',
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('$_currentPageNumber / $_totalPages'),
          ),
          IconButton(
            onPressed: () => _pdfViewerController?.nextPage(),
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next Page',
          ),
          IconButton(
            onPressed: () => _pdfViewerController?.jumpToPage(_totalPages),
            icon: const Icon(Icons.last_page),
            tooltip: 'Last Page',
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => _pdfViewerController?.zoomLevel =
                (_zoomLevel / 1.25).clamp(0.5, 3.0),
            icon: const Icon(Icons.zoom_out),
            tooltip: 'Zoom Out',
          ),
          Text('${(_zoomLevel * 100).round()}%'),
          IconButton(
            onPressed: () => _pdfViewerController?.zoomLevel =
                (_zoomLevel * 1.25).clamp(0.5, 3.0),
            icon: const Icon(Icons.zoom_in),
            tooltip: 'Zoom In',
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    if (_hasError || _isLoading) return const SizedBox.shrink();

    return FloatingActionButton(
      onPressed: _printDocument,
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.print, color: Colors.white),
    );
  }

  Future<void> _shareFile() async {
    try {
      await Share.shareXFiles([XFile(widget.filePath)]);
    } catch (e) {
      _showSnackBar('Failed to share file: $e', isError: true);
    }
  }

  Future<void> _printDocument() async {
    try {
      final file = File(widget.filePath);
      final bytes = await file.readAsBytes();

      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: widget.fileName ?? 'document.pdf',
      );
    } catch (e) {
      _showSnackBar('Failed to print document: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _pdfViewerController?.dispose();
    super.dispose();
  }
}
