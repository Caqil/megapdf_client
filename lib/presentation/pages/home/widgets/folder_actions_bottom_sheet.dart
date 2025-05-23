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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Folder'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Folder Name',
            hintText: 'Enter folder name...',
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
          onFieldSubmitted: (_) => _createFolder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createFolder,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _createFolder() {
    if (_formKey.currentState!.validate()) {
      widget.onCreateFolder(_controller.text.trim());
      Navigator.pop(context);
    }
  }
}
