// lib/presentation/widgets/dialogs/create_folder_dialog.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../common/custom_snackbar.dart';

class CreateFolderDialog extends StatefulWidget {
  final Function(String) onCreateFolder;
  final String? initialName;

  const CreateFolderDialog({
    super.key,
    required this.onCreateFolder,
    this.initialName,
  });

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.create_new_folder,
              color: AppColors.primary(context),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Create Folder'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Folder Name',
                hintText: 'Enter folder name...',
                prefixIcon: const Icon(Icons.folder_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.background(context),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a folder name';
                }
                if (value.trim().length < 2) {
                  return 'Folder name must be at least 2 characters';
                }
                if (value.contains('/') || value.contains('\\')) {
                  return 'Folder name cannot contain / or \\';
                }
                if (value.contains('<') ||
                    value.contains('>') ||
                    value.contains(':') ||
                    value.contains('"') ||
                    value.contains('|') ||
                    value.contains('?') ||
                    value.contains('*')) {
                  return 'Folder name contains invalid characters';
                }
                return null;
              },
              autofocus: true,
              enabled: !_isCreating,
              onFieldSubmitted: (_) => _createFolder(),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),

            // Folder suggestions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary(context).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary(context).withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick suggestions:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary(context),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _SuggestionChip(
                        label: 'Documents',
                        onTap: () => _controller.text = 'Documents',
                      ),
                      _SuggestionChip(
                        label: 'Projects',
                        onTap: () => _controller.text = 'Projects',
                      ),
                      _SuggestionChip(
                        label: 'Archive',
                        onTap: () => _controller.text = 'Archive',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isCreating ? null : _createFolder,
          icon: _isCreating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.create_new_folder, size: 18),
          label: Text(_isCreating ? 'Creating...' : 'Create'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary(context),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createFolder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final folderName = _controller.text.trim();

      // Simulate network delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      widget.onCreateFolder(folderName);

      if (mounted) {
        Navigator.pop(context);
        CustomSnackbar.show(
          context: context,
          message: 'Folder "$folderName" created successfully',
          type: SnackbarType.success,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      setState(() {
        _isCreating = false;
      });

      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Failed to create folder',
          type: SnackbarType.failure,
          duration: const Duration(seconds: 4),
        );
       
      }
    }
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary(context).withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary(context),
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}
