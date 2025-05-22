// lib/presentation/widgets/common/permission_request_widget.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/permission_manager.dart';

class PermissionRequestWidget extends StatefulWidget {
  final Widget child;
  final String? title;
  final String? message;

  const PermissionRequestWidget({
    super.key,
    required this.child,
    this.title,
    this.message,
  });

  @override
  State<PermissionRequestWidget> createState() =>
      _PermissionRequestWidgetState();
}

class _PermissionRequestWidgetState extends State<PermissionRequestWidget> {
  bool _hasPermissions = false;
  bool _isChecking = true;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() => _isChecking = true);

    try {
      final permissionManager = PermissionManager();
      final hasPermissions = await permissionManager.hasDownloadPermissions();

      setState(() {
        _hasPermissions = hasPermissions;
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _hasPermissions = false;
        _isChecking = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    setState(() => _isRequesting = true);

    try {
      final permissionManager = PermissionManager();
      final granted = await permissionManager.requestDownloadPermissions(
        context: context,
        showRationale: true,
      );

      setState(() {
        _hasPermissions = granted;
        _isRequesting = false;
      });
    } catch (e) {
      setState(() {
        _hasPermissions = false;
        _isRequesting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to request permissions: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_hasPermissions) {
      return _buildPermissionRequest();
    }

    return widget.child;
  }

  Widget _buildPermissionRequest() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            widget.title ?? 'Storage Permission Required',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            widget.message ??
                'This app needs storage permission to download and save PDF files to your device. Please grant storage permission to continue.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isRequesting ? null : _requestPermissions,
              icon: _isRequesting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.security),
              label: Text(_isRequesting ? 'Requesting...' : 'Grant Permission'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _checkPermissions,
            icon: const Icon(Icons.refresh),
            label: const Text('Check Again'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
