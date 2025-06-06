// Create lib/presentation/widgets/common/permission_request_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/permission_provider.dart';

class PermissionRequestWidget extends ConsumerStatefulWidget {
  final VoidCallback? onPermissionGranted;

  const PermissionRequestWidget({
    super.key,
    this.onPermissionGranted,
  });

  @override
  ConsumerState<PermissionRequestWidget> createState() =>
      _PermissionRequestWidgetState();
}

class _PermissionRequestWidgetState
    extends ConsumerState<PermissionRequestWidget> with WidgetsBindingObserver {
  bool _isRequestingPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize permissions when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(permissionNotifierProvider.notifier).initializePermissions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Check permissions when user returns from settings
    if (state == AppLifecycleState.resumed && !_isRequestingPermission) {
      ref.read(permissionNotifierProvider.notifier).forcePermissionCheck();
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionState = ref.watch(permissionNotifierProvider);

    // Listen for permission changes
    ref.listen<PermissionState>(permissionNotifierProvider, (previous, next) {
      if (previous?.hasPermission != next.hasPermission && next.hasPermission) {
        widget.onPermissionGranted?.call();
      }
    });

    if (permissionState.isLoading) {
      return _buildLoadingScreen();
    }

    if (permissionState.hasPermission) {
      return _buildSuccessScreen();
    }

    return _buildPermissionRequestScreen(permissionState);
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.primary(context)),
            ),
            const SizedBox(height: 24),
            Text(
              'Checking permissions...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success(context).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 80,
                color: AppColors.success(context),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Permission Granted!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success(context),
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'You can now save and access your PDF files.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRequestScreen(PermissionState permissionState) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon and Title
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient(context),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary(context).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.storage,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Storage Permission Required',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'MegaPDF needs storage permission to save your processed PDF files to your device.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary(context),
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Features list
              _buildFeaturesList(),

              const SizedBox(height: 32),

              // Error message
              if (permissionState.hasError) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error(context).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: AppColors.error(context),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          permissionState.error!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.error(context),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Grant Permission Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      _isRequestingPermission ? null : _requestPermission,
                  icon: _isRequestingPermission
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                      : const Icon(Icons.security),
                  label: Text(
                    _isRequestingPermission
                        ? 'Requesting Permission...'
                        : 'Grant Storage Permission',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Debug info (only in debug mode)
              if (permissionState.debugInfo != null) ...[
                TextButton(
                  onPressed: () => _showDebugInfo(permissionState.debugInfo!),
                  child: Text(
                    'Debug Info',
                    style: TextStyle(color: AppColors.textSecondary(context)),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Continue without permission (not recommended)
              TextButton(
                onPressed: () => _showContinueWithoutPermissionDialog(),
                child: Text(
                  'Continue without permission (files won\'t be saved)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary(context),
                        decoration: TextDecoration.underline,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {
        'icon': Icons.save,
        'title': 'Save PDF Files',
        'description': 'Keep your processed files accessible',
      },
      {
        'icon': Icons.folder,
        'title': 'Organize Files',
        'description': 'Create folders and manage your documents',
      },
      {
        'icon': Icons.security,
        'title': 'Secure Storage',
        'description': 'Files are stored safely on your device',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: AppColors.primary(context),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['title'] as String,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        feature['description'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isRequestingPermission = true;
    });

    try {
      final granted = await ref
          .read(permissionNotifierProvider.notifier)
          .requestPermission(context);

      if (granted) {
        // Permission granted, the listener will handle the UI update
        print('🔧 PERMISSION: Permission granted successfully');
      } else {
        print('🔧 PERMISSION: Permission denied');
      }
    } catch (e) {
      print('🔧 PERMISSION: Error during permission request: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingPermission = false;
        });
      }
    }
  }

  void _showDebugInfo(Map<String, dynamic> debugInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Debug Info'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: debugInfo.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        '${entry.key}:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(entry.value.toString()),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showContinueWithoutPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.warning(context)),
            const SizedBox(width: 8),
            Text('Continue Without Permission?'),
          ],
        ),
        content: Text(
          'Without storage permission, MegaPDF cannot save your processed files. '
          'You will need to manually share or export files each time.\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Mark first launch as complete without permission
              ref
                  .read(permissionNotifierProvider.notifier)
                  .markFirstLaunchComplete();
              widget.onPermissionGranted?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning(context),
            ),
            child: Text('Continue Anyway'),
          ),
        ],
      ),
    );
  }
}
