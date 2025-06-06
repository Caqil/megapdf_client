// Update lib/presentation/providers/permission_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/permission_manager.dart';

part 'permission_provider.g.dart';

@riverpod
class PermissionNotifier extends _$PermissionNotifier {
  static const String _permissionGrantedKey = 'permission_granted';
  static const String _firstLaunchKey = 'first_launch';

  @override
  PermissionState build() {
    // Initialize with loading state
    return const PermissionState(
      isLoading: true,
      hasPermission: false,
      isFirstLaunch: true,
    );
  }

  /// Initialize permission checking
  Future<void> initializePermissions() async {
    print('🔧 PERMISSION: Starting permission initialization...');
    await _checkPermissionStatus();
  }

  /// Check current permission status and first launch
  Future<void> _checkPermissionStatus() async {
    print('🔧 PERMISSION: Starting permission check...');

    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if this is the first launch
      final isFirstLaunch = !prefs.containsKey(_firstLaunchKey);
      print('🔧 PERMISSION: First launch: $isFirstLaunch');

      // Check current permission status
      final permissionManager = PermissionManager();
      final hasPermission = await permissionManager.hasStoragePermission();
      print('🔧 PERMISSION: Has permission: $hasPermission');

      // Get stored permission state
      final storedPermission = prefs.getBool(_permissionGrantedKey) ?? false;
      print('🔧 PERMISSION: Stored permission: $storedPermission');

      // Get detailed status for debugging
      final debugInfo = await permissionManager.getPermissionStatus();
      print('🔧 PERMISSION: Debug info: $debugInfo');

      final finalPermissionState = hasPermission || storedPermission;
      print('🔧 PERMISSION: Final permission state: $finalPermissionState');

      state = PermissionState(
        isLoading: false,
        hasPermission: finalPermissionState,
        isFirstLaunch: isFirstLaunch,
        debugInfo: debugInfo,
      );

      print('🔧 PERMISSION: State updated: ${state.toString()}');
    } catch (e) {
      print('🔧 PERMISSION: Error checking permission status: $e');
      state = PermissionState(
        isLoading: false,
        hasPermission: false,
        isFirstLaunch: true,
        error: e.toString(),
      );
    }
  }

  /// Set permission granted status
  Future<void> setPermissionGranted(bool granted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_permissionGrantedKey, granted);

      state = state.copyWith(
        hasPermission: granted,
        isLoading: false,
        error: null,
      );

      print('🔧 PERMISSION: Permission status saved: $granted');
    } catch (e) {
      print('🔧 PERMISSION: Error saving permission status: $e');
    }
  }

  /// Mark first launch as complete
  Future<void> markFirstLaunchComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstLaunchKey, true);

      state = state.copyWith(isFirstLaunch: false);
      print('🔧 PERMISSION: First launch marked complete');
    } catch (e) {
      print('🔧 PERMISSION: Error marking first launch complete: $e');
    }
  }

  /// Request permission with proper error handling
  Future<bool> requestPermission(BuildContext context) async {
    print('🔧 PERMISSION: Permission request started');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final permissionManager = PermissionManager();
      final granted = await permissionManager.requestStoragePermission(context);
      
      print('🔧 PERMISSION: Permission request result: $granted');
      
      // Save the result
      await setPermissionGranted(granted);
      
      // Mark first launch as complete if permission granted
      if (granted && state.isFirstLaunch) {
        await markFirstLaunchComplete();
      }
      
      return granted;
    } catch (e) {
      print('🔧 PERMISSION: Error requesting permission: $e');
      state = state.copyWith(
        isLoading: false, 
        error: 'Failed to request permission: $e'
      );
      return false;
    }
  }

  /// Refresh permission status
  Future<void> refreshPermissionStatus() async {
    print('🔧 PERMISSION: Refresh requested');
    state = state.copyWith(isLoading: true, error: null);
    await _checkPermissionStatus();
  }

  /// Check if we should show permission screen
  bool shouldShowPermissionScreen() {
    return (state.isFirstLaunch || !state.hasPermission) && !state.isLoading;
  }

  /// Get detailed permission info for debugging
  Future<Map<String, dynamic>> getPermissionDebugInfo() async {
    final permissionManager = PermissionManager();
    final status = await permissionManager.getPermissionStatus();

    final prefs = await SharedPreferences.getInstance();

    return {
      ...status,
      'storedPermission': prefs.getBool(_permissionGrantedKey),
      'firstLaunch': !prefs.containsKey(_firstLaunchKey),
      'shouldShowRationale': await permissionManager.shouldShowPermissionRationale(),
      'currentState': state.toString(),
    };
  }

  /// Force permission check (useful after returning from settings)
  Future<void> forcePermissionCheck() async {
    print('🔧 PERMISSION: Force permission check');
    final permissionManager = PermissionManager();
    final hasPermission = await permissionManager.hasStoragePermission();
    
    if (hasPermission != state.hasPermission) {
      print('🔧 PERMISSION: Permission status changed: $hasPermission');
      await setPermissionGranted(hasPermission);
      
      if (hasPermission && state.isFirstLaunch) {
        await markFirstLaunchComplete();
      }
    }
  }

  /// Clear error state
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

/// Permission state class
class PermissionState {
  final bool isLoading;
  final bool hasPermission;
  final bool isFirstLaunch;
  final String? error;
  final Map<String, dynamic>? debugInfo;

  const PermissionState({
    required this.isLoading,
    required this.hasPermission,
    required this.isFirstLaunch,
    this.error,
    this.debugInfo,
  });

  PermissionState copyWith({
    bool? isLoading,
    bool? hasPermission,
    bool? isFirstLaunch,
    String? error,
    Map<String, dynamic>? debugInfo,
  }) {
    return PermissionState(
      isLoading: isLoading ?? this.isLoading,
      hasPermission: hasPermission ?? this.hasPermission,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      error: error,
      debugInfo: debugInfo ?? this.debugInfo,
    );
  }

  bool get shouldShowPermissionScreen => 
      !isLoading && (isFirstLaunch || !hasPermission);
  bool get canSaveFiles => hasPermission && !isLoading;
  bool get hasError => error != null;

  @override
  String toString() {
    return 'PermissionState(isLoading: $isLoading, hasPermission: $hasPermission, isFirstLaunch: $isFirstLaunch, error: $error)';
  }
}

/// Helper provider to check if permissions are ready
@riverpod
bool permissionsReady(Ref ref) {
  final permissionState = ref.watch(permissionNotifierProvider);
  return !permissionState.isLoading;
}

/// Helper provider to check if we should show permission screen
@riverpod
bool shouldShowPermissionScreen(Ref ref) {
  final permissionState = ref.watch(permissionNotifierProvider);
  return permissionState.shouldShowPermissionScreen;
}