// lib/presentation/pages/onboarding/splash_screen.dart
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/permission_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) async {
      final status =
          await AppTrackingTransparency.requestTrackingAuthorization();
    });
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    _animationController.forward();

    // Initialize the permission check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePermissions();
    });
  }

  Future<void> _initializePermissions() async {
    // Ensure the permission provider is initialized
    await ref
        .read(permissionNotifierProvider.notifier)
        .refreshPermissionStatus();
  }

  void _navigateBasedOnPermissionState(PermissionState state) {
    if (_hasNavigated || !mounted) return;

    print(
        '🔧 SPLASH: Permission state - loading: ${state.isLoading}, firstLaunch: ${state.isFirstLaunch}, hasPermission: ${state.hasPermission}');

    if (state.isLoading) {
      print('🔧 SPLASH: Still loading, waiting...');
      return; // Still loading, wait
    }

    _hasNavigated = true;

    if (state.isFirstLaunch && !state.hasPermission) {
      print(
          '🔧 SPLASH: First launch without permission, going to /permissions');
      context.go('/permissions');
    } else {
      print('🔧 SPLASH: Going to main app');
      ref.read(permissionNotifierProvider.notifier).markFirstLaunchComplete();
      context.go('/');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the permission state
    final permissionState = ref.watch(permissionNotifierProvider);

    // Handle navigation when state changes
    ref.listen<PermissionState>(permissionNotifierProvider, (previous, next) {
      print('🔧 SPLASH: Permission state changed - ${next.toString()}');

      // Add a small delay to ensure animation has had time to show
      Future.delayed(const Duration(milliseconds: 1500), () {
        _navigateBasedOnPermissionState(next);
      });
    });

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background(context),
              AppColors.primary(context).withOpacity(0.05),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary(context),
                              AppColors.primary(context).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(17),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primary(context).withOpacity(0.4),
                              blurRadius: 25,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // App name with fade animation
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'MegaPDF',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary(context),
                                letterSpacing: 1.2,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your PDF Toolkit',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textSecondary(context),
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 60),

              // Loading indicator and status
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          permissionState.isLoading
                              ? 'Checking permissions...'
                              : 'Initializing...',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
