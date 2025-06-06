// lib/presentation/providers/app_info_provider.dart
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:io';

part 'app_info_provider.g.dart';

@riverpod
class AppInfoNotifier extends _$AppInfoNotifier {
  @override
  AppInfoState build() {
    _loadAppInfo();
    return const AppInfoState();
  }

  Future<void> _loadAppInfo() async {
    state = state.copyWith(isLoading: true);

    try {
      final packageInfo = await PackageInfo.fromPlatform();

      state = state.copyWith(
        isLoading: false,
        appName: packageInfo.appName,
        packageName: packageInfo.packageName,
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        buildSignature: packageInfo.buildSignature,
        installerStore: packageInfo.installerStore,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load app info: $e',
      );
    }
  }

  Future<void> refreshAppInfo() async {
    await _loadAppInfo();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class AppInfoState {
  final bool isLoading;
  final String? error;
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final String buildSignature;
  final String? installerStore;

  const AppInfoState({
    this.isLoading = true,
    this.error,
    this.appName = 'MegaPDF',
    this.packageName = 'com.megapdf.client',
    this.version = '1.0.0',
    this.buildNumber = '1',
    this.buildSignature = '',
    this.installerStore,
  });

  AppInfoState copyWith({
    bool? isLoading,
    String? error,
    String? appName,
    String? packageName,
    String? version,
    String? buildNumber,
    String? buildSignature,
    String? installerStore,
  }) {
    return AppInfoState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
      buildSignature: buildSignature ?? this.buildSignature,
      installerStore: installerStore ?? this.installerStore,
    );
  }

  bool get hasError => error != null;

  String get fullVersion => '$version+$buildNumber';

  String get platformName {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  String get installSource {
    if (installerStore != null) {
      switch (installerStore) {
        case 'com.android.vending':
          return 'Google Play Store';
        case 'com.amazon.venezia':
          return 'Amazon Appstore';
        case 'com.sec.android.app.samsungapps':
          return 'Samsung Galaxy Store';
        case 'com.huawei.appmarket':
          return 'Huawei AppGallery';
        default:
          return installerStore!;
      }
    }
    return 'Unknown';
  }

  Map<String, dynamic> toDebugMap() {
    return {
      'App Name': appName,
      'Package Name': packageName,
      'Version': version,
      'Build Number': buildNumber,
      'Full Version': fullVersion,
      'Platform': platformName,
      'Install Source': installSource,
      'Build Signature': buildSignature.isNotEmpty ? 'Present' : 'None',
    };
  }
}
