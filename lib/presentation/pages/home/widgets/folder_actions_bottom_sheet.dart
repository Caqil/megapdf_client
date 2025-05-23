// lib/presentation/pages/home/widgets/folder_actions_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FolderActionsBottomSheet extends StatelessWidget {
  final VoidCallback onCreateFolder;
  final VoidCallback onImportFiles;
  final VoidCallback onSettings;

  const FolderActionsBottomSheet({
    super.key,
    required this.onCreateFolder,
    required this.onImportFiles,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Container(
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
            title: const Text('Create Folder'),
            subtitle: const Text('Create a new folder'),
            onTap: () {
              Navigator.pop(context);
              onCreateFolder();
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.upload_file,
                color: AppColors.secondary(context),
                size: 20,
              ),
            ),
            title: const Text('Import Files'),
            subtitle: const Text('Import files from device'),
            onTap: () {
              Navigator.pop(context);
              onImportFiles();
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.textSecondary(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.settings,
                color: AppColors.textSecondary(context),
                size: 20,
              ),
            ),
            title: const Text('Settings'),
            subtitle: const Text('App preferences'),
            onTap: () {
              Navigator.pop(context);
              onSettings();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// lib/presentation/pages/home/widgets/create_folder_dialog.dart
class CreateFolderDialog extends StatefulWidget {
  final Function(String) onCreateFolder;

  const CreateFolderDialog({
    super.key,
    required this.onCreateFolder,
  });

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isCreating = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.create_new_folder,
            color: AppColors.primary(context),
          ),
          const SizedBox(width: 12),
          const Text('Create Folder'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Folder Name',
                hintText: 'Enter folder name...',
                prefixIcon: const Icon(Icons.folder),
                errorText: _errorText,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a folder name';
                }
                if (value.contains('/') || value.contains('\\')) {
                  return 'Folder name cannot contain / or \\';
                }
                return null;
              },
              autofocus: true,
              enabled: !_isCreating,
              onFieldSubmitted: (_) => _createFolder(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.info(context).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.info(context),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Folder names cannot contain special characters like / \\ : * ? " < > |',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.info(context),
                          ),
                    ),
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
        ElevatedButton(
          onPressed: _isCreating ? null : _createFolder,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary(context),
          ),
          child: _isCreating
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary),
                  ),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  void _createFolder() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCreating = true;
        _errorText = null;
      });

      try {
        // Close the dialog and invoke the callback
        Navigator.pop(context);
        widget.onCreateFolder(_controller.text.trim());
      } catch (e) {
        // If there's an error and the dialog is still visible
        if (mounted) {
          setState(() {
            _isCreating = false;
            _errorText = 'Error creating folder: $e';
          });
        }
      }
    }
  }
}
