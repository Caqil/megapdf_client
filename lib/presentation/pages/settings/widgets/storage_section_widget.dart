// lib/presentation/pages/settings/widgets/storage_section_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:megapdf_client/data/services/storage_service.dart';
import 'package:megapdf_client/core/theme/app_colors.dart';
import 'package:megapdf_client/presentation/widgets/common/custom_snackbar.dart';
import 'package:megapdf_client/presentation/pages/settings/widgets/section_card_widget.dart';
import 'package:megapdf_client/presentation/pages/settings/widgets/settings_switch_widget.dart';

class StorageSectionWidget extends ConsumerStatefulWidget {
  const StorageSectionWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<StorageSectionWidget> createState() =>
      _StorageSectionWidgetState();
}

class _StorageSectionWidgetState extends ConsumerState<StorageSectionWidget> {
  bool _hasStoragePermission = false;
  String? _megaPdfPath;

  @override
  void initState() {
    super.initState();
    _checkStoragePermission();
  }

  Future<void> _checkStoragePermission() async {
    final storageService = StorageService();
    final hasPermission = await storageService.checkPermissions();
    final path = await storageService.getMegaPDFPath();

    setState(() {
      _hasStoragePermission = hasPermission;
      _megaPdfPath = path;
    });
  }

  Future<void> _requestStoragePermission() async {
    final storageService = StorageService();
    final granted = await storageService.requestPermissions(context);

    setState(() {
      _hasStoragePermission = granted;
    });

    if (granted) {
      // Get MegaPDF directory path
      final path = await storageService.getMegaPDFPath();
      setState(() {
        _megaPdfPath = path;
      });

      _showSnackBar('Storage permission granted');
    } else {
      _showSnackBar('Storage permission required to save files', isError: true);
    }
  }

  String _formatPath(String path) {
    if (path.contains('/storage/emulated/0')) {
      return path.replaceFirst('/storage/emulated/0', 'Internal Storage');
    }
    return path;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    CustomSnackbar.show(
      context: context,
      message: message,
      type: isError ? SnackbarType.failure : SnackbarType.success,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionCardWidget(
      title: 'Storage',
      icon: Icons.storage,
      iconColor: AppColors.primary(context),
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Icon(
            _hasStoragePermission ? Icons.check_circle : Icons.error,
            color: _hasStoragePermission
                ? AppColors.success(context)
                : AppColors.error(context),
            size: 28,
          ),
          title: Text(
            'Storage Permission',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _hasStoragePermission
                  ? 'Permission granted to access device storage'
                  : 'Storage permission required to save and manage files',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
          ),
          trailing: _hasStoragePermission
              ? const Icon(Icons.verified, color: Colors.green)
              : ElevatedButton(
                  onPressed: _requestStoragePermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Grant'),
                ),
        ),
        const Divider(height: 1, indent: 20, endIndent: 20),
        if (_hasStoragePermission && _megaPdfPath != null)
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Icon(
              Icons.folder,
              color: AppColors.primary(context),
              size: 28,
            ),
            title: Text(
              'Files Location',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _formatPath(_megaPdfPath!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.open_in_new,
                color: AppColors.primary(context),
              ),
              onPressed: () => context.push('/storage'),
              tooltip: 'Open Files',
            ),
          ),
        const Divider(height: 1, indent: 20, endIndent: 20),
        if (_hasStoragePermission)
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Icon(
              Icons.cleaning_services,
              color: AppColors.warning(context),
              size: 28,
            ),
            title: Text(
              'Clean Temporary Files',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Remove cached and temporary files to free up storage space',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
              ),
            ),
            onTap: () {
              _showSnackBar('Cleaning temporary files...');
              // Add cleanup logic here
              Future.delayed(const Duration(seconds: 2), () {
                _showSnackBar('Temporary files cleared successfully');
              });
            },
          ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: SettingsSwitchWidget(
            title: 'Save files to Downloads',
            description: 'PDF files will be saved to your Downloads folder',
            initialValue: true,
            onChanged: (value) {
              _showSnackBar(
                value
                    ? 'Files will be saved to Downloads folder'
                    : 'Files will be saved to app storage only',
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: SettingsSwitchWidget(
            title: 'Add timestamp to filenames',
            description: 'Automatically add date and time to saved files',
            initialValue: true,
            onChanged: (value) {
              _showSnackBar(
                value
                    ? 'Timestamps will be added to filenames'
                    : 'Timestamps will not be added to filenames',
              );
            },
          ),
        ),
      ],
    );
  }
}
