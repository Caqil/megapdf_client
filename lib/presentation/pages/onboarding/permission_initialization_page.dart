// lib/presentation/pages/onboarding/permission_initialization_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/permission_manager.dart';
import '../../providers/permission_provider.dart';
import '../../widgets/common/custom_snackbar.dart';

class PermissionInitializationPage extends ConsumerStatefulWidget {
  const PermissionInitializationPage({super.key});

  @override
  ConsumerState<PermissionInitializationPage> createState() =>
      _PermissionInitializationPageState();
}

class _PermissionInitializationPageState
    extends ConsumerState<PermissionInitializationPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isRequestingPermission = false;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();

    // Check permission status on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialPermissionStatus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkInitialPermissionStatus() async {
    final hasPermission = await PermissionManager().hasStoragePermission();
    if (hasPermission) {
      setState(() {
        _permissionGranted = true;
      });

      // Update permission provider
      ref.read(permissionNotifierProvider.notifier).setPermissionGranted(true);

      // Navigate to main app after a short delay
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        context.go('/');
      }
    }
  }

  Future<void> _requestPermission() async {
    if (_isRequestingPermission) return;

    setState(() {
      _isRequestingPermission = true;
    });

    try {
      final granted =
          await PermissionManager().requestStoragePermission(context);

      setState(() {
        _permissionGranted = granted;
        _isRequestingPermission = false;
      });

      // Update permission provider
      ref
          .read(permissionNotifierProvider.notifier)
          .setPermissionGranted(granted);

      if (granted) {
        CustomSnackbar.show(
          context: context,
          message:
              'Storage permission granted! You can now save files to your device.',
          type: SnackbarType.success,
          duration: const Duration(seconds: 3),
        );

        // Navigate to main app
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          context.go('/');
        }
      } else {
        CustomSnackbar.show(
          context: context,
          message:
              'Permission denied. You can still use the app with limited functionality.',
          type: SnackbarType.info,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      setState(() {
        _isRequestingPermission = false;
      });

      CustomSnackbar.show(
        context: context,
        message: 'Error requesting permission: $e',
        type: SnackbarType.failure,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _continueWithoutPermission() {
    ref.read(permissionNotifierProvider.notifier).setPermissionGranted(false);
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Expanded(
                flex: 2,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App icon/logo
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary(context),
                                AppColors.primary(context).withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary(context).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Welcome to MegaPDF',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary(context),
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your powerful PDF toolkit',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Permission request section
              Expanded(
                flex: 3,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_permissionGranted) ...[
                        // Permission granted state
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.success(context).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  AppColors.success(context).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 60,
                                color: AppColors.success(context),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'All Set!',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success(context),
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You can now save and organize your PDF files.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary(context),
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Permission request state
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface(context),
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: AppColors.border(context)),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.folder_shared,
                                size: 60,
                                color: AppColors.primary(context),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Storage Access',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary(context),
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'MegaPDF needs access to your device storage to save and organize your PDF files.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary(context),
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),

                              // Features list
                              _buildFeatureItem(
                                context,
                                Icons.download,
                                'Save processed PDFs to your device',
                              ),
                              const SizedBox(height: 12),
                              _buildFeatureItem(
                                context,
                                Icons.folder_open,
                                'Access files from other apps',
                              ),
                              const SizedBox(height: 12),
                              _buildFeatureItem(
                                context,
                                Icons.folder,
                                'Organize files in custom folders',
                              ),

                              if (Platform.isAndroid) ...[
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.info(context)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: AppColors.info(context),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Your privacy matters. We only access files you choose to work with.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.info(context),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Action buttons
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!_permissionGranted) ...[
                      // Grant permission button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isRequestingPermission
                              ? null
                              : _requestPermission,
                          icon: _isRequestingPermission
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.check_circle, size: 24),
                          label: Text(
                            _isRequestingPermission
                                ? 'Requesting...'
                                : 'Grant Storage Access',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary(context),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Continue without permission button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: TextButton.icon(
                          onPressed: _isRequestingPermission
                              ? null
                              : _continueWithoutPermission,
                          icon: Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color: AppColors.textSecondary(context),
                          ),
                          label: Text(
                            'Continue with Limited Access',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary(context).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary(context),
                ),
          ),
        ),
      ],
    );
  }
}
