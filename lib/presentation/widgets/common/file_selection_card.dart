import 'dart:io';
import 'package:flutter/material.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';

class FileActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String selectButtonText;
  final String actionButtonText;
  final IconData selectIcon;
  final IconData actionIcon;
  final Future<void>  onAction;
  final Future<File?> Function() onPickFile;

  const FileActionCard({
    super.key,
    this.title = 'Select PDF File',
    this.subtitle = 'Choose a PDF file to process',
    this.selectButtonText = 'Select PDF File',
    this.actionButtonText = 'Process File',
    this.selectIcon = Icons.upload_file,
    this.actionIcon = Icons.play_arrow,
    required this.onAction,
    required this.onPickFile,
  });

  @override
  State<FileActionCard> createState() => _FileActionCardState();
}

class _FileActionCardState extends State<FileActionCard> {
  File? _selectedFile;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildFileSelectionArea(),
            const SizedBox(height: 16),
            _buildActionButton(),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelectionArea() {
    if (_selectedFile == null) {
      return OutlinedButton.icon(
        onPressed: _pickFile,
        icon: Icon(widget.selectIcon),
        label: Text(widget.selectButtonText),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
      );
    }
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.picture_as_pdf,
            color: Theme.of(context).primaryColor,
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
              _errorMessage = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton.icon(
      onPressed:
          _selectedFile != null && !_isProcessing ? _performAction : null,
      icon: Icon(widget.actionIcon),
      label: Text(widget.actionButtonText),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      setState(() {
        _isProcessing = true;
        _errorMessage = null;
      });
      final file = await widget.onPickFile();
      setState(() {
        _selectedFile = file;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error selecting file: $e';
      });
    }
  }

  Future<void> _performAction() async {
    if (_selectedFile == null) return;
    try {
      setState(() {
        _isProcessing = true;
        _errorMessage = null;
      });
      await widget.onAction;
      setState(() {
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error processing file: $e';
      });
    }
  }
}
