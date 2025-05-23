// lib/presentation/providers/permission_provider.dart
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

  /// Check current permission status and first launch
  Future<void> _checkPermissionStatus() async {
    print('🔧 PERMISSION: Starting permission check...');

    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if this is the first launch
      final isFirstLaunch = !prefs.containsKey(_firstLaunchKey);
      print('🔧 PERMISSION: First launch: $isFirstLaunch');

      // Check current permission status
      final hasPermission = await PermissionManager().hasStoragePermission();
      print('🔧 PERMISSION: Has permission: $hasPermission');

      // Get stored permission state
      final storedPermission = prefs.getBool(_permissionGrantedKey) ?? false;
      print('🔧 PERMISSION: Stored permission: $storedPermission');

      final finalPermissionState = hasPermission || storedPermission;
      print('🔧 PERMISSION: Final permission state: $finalPermissionState');

      state = PermissionState(
        isLoading: false,
        hasPermission: finalPermissionState,
        isFirstLaunch: isFirstLaunch,
      );

      print('🔧 PERMISSION: State updated: ${state.toString()}');
    } catch (e) {
      print('🔧 PERMISSION: Error checking permission status: $e');
      state = const PermissionState(
        isLoading: false,
        hasPermission: false,
        isFirstLaunch: true,
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
      );
    } catch (e) {
      print('Error saving permission status: $e');
    }
  }

  /// Mark first launch as complete
  Future<void> markFirstLaunchComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstLaunchKey, true);

      state = state.copyWith(isFirstLaunch: false);
    } catch (e) {
      print('Error marking first launch complete: $e');
    }
  }

  /// Request permission
  Future<bool> requestPermission(context) async {
    state = state.copyWith(isLoading: true);

    try {
      final granted =
          await PermissionManager().requestStoragePermission(context);
      await setPermissionGranted(granted);
      return granted;
    } catch (e) {
      print('Error requesting permission: $e');
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  /// Refresh permission status
  Future<void> refreshPermissionStatus() async {
    print('🔧 PERMISSION: Refresh requested');
    state = state.copyWith(isLoading: true);
    await _checkPermissionStatus();
  }

  /// Check if we should show permission screen
  bool shouldShowPermissionScreen() {
    return state.isFirstLaunch || !state.hasPermission;
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
      'shouldShowRationale':
          await permissionManager.shouldShowPermissionRationale(),
    };
  }
}

/// Permission state class
class PermissionState {
  final bool isLoading;
  final bool hasPermission;
  final bool isFirstLaunch;

  const PermissionState({
    required this.isLoading,
    required this.hasPermission,
    required this.isFirstLaunch,
  });

  PermissionState copyWith({
    bool? isLoading,
    bool? hasPermission,
    bool? isFirstLaunch,
  }) {
    return PermissionState(
      isLoading: isLoading ?? this.isLoading,
      hasPermission: hasPermission ?? this.hasPermission,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }

  bool get shouldShowPermissionScreen => isFirstLaunch && !hasPermission;
  bool get canSaveFiles => hasPermission;

  @override
  String toString() {
    return 'PermissionState(isLoading: $isLoading, hasPermission: $hasPermission, isFirstLaunch: $isFirstLaunch)';
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
  return !permissionState.isLoading &&
      permissionState.isFirstLaunch &&
      !permissionState.hasPermission;
}
