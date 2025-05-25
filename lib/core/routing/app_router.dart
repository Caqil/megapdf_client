// lib/core/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/pages/contact/contact_page.dart';
import '../../presentation/pages/faq/faq_page.dart';
import '../../presentation/pages/main/main_navigation_page.dart';
import '../../presentation/pages/onboarding/permission_initialization_page.dart';
import '../../presentation/pages/onboarding/splash_screen.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/scanner/scanner_page.dart';
import '../../presentation/pages/tools/tools_page.dart';
import '../../presentation/pages/recent/recent_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/compress/compress_page.dart';
import '../../presentation/pages/split/split_page.dart';
import '../../presentation/pages/merge/merge_page.dart';
import '../../presentation/pages/watermark/watermark_page.dart';
import '../../presentation/pages/convert/convert_page.dart';
import '../../presentation/pages/protect/protect_page.dart';
import '../../presentation/pages/unlock/unlock_page.dart';
import '../../presentation/pages/rotate/rotate_page.dart';
import '../../presentation/pages/page_numbers/page_numbers_page.dart';
import '../../presentation/pages/storage/storage_browser_page.dart';
import '../../presentation/pages/common/file_operation_success_page.dart';
import '../../presentation/pages/pdf_viewer/pdf_viewer_page.dart';

part 'app_router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Permission initialization
      GoRoute(
        path: '/permissions',
        name: 'permissions',
        builder: (context, state) => const PermissionInitializationPage(),
      ),

      // Main navigation route (with bottom navigation)
      GoRoute(
        path: '/',
        name: 'main',
        builder: (context, state) => const MainNavigationPage(),
      ),

      // Direct access to individual tabs (optional)
      GoRoute(
        path: '/files',
        name: 'files',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/tools',
        name: 'tools',
        builder: (context, state) => const ToolsPage(),
      ),
      GoRoute(
        path: '/recent',
        name: 'recent',
        builder: (context, state) => const RecentPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/scanner',
        name: 'scanner',
        builder: (context, state) => const ScannerPage(),
      ),
      // PDF Operations
      GoRoute(
        path: '/compress',
        name: 'compress',
        builder: (context, state) {
          final filePath = state.uri.queryParameters['filePath'];
          final fileName = state.uri.queryParameters['fileName'];
          return CompressPage(
            initialFilePath: filePath,
            initialFileName: fileName,
          );
        },
      ),
      GoRoute(
        path: '/split',
        name: 'split',
        builder: (context, state) {
          final filePath = state.uri.queryParameters['filePath'];
          final fileName = state.uri.queryParameters['fileName'];
          return SplitPage(
            initialFilePath: filePath,
            initialFileName: fileName,
          );
        },
      ),
      GoRoute(
        path: '/merge',
        name: 'merge',
        builder: (context, state) {
          final filePath = state.uri.queryParameters['filePath'];
          final fileName = state.uri.queryParameters['fileName'];
          return MergePage(
            initialFilePath: filePath,
            initialFileName: fileName,
          );
        },
      ),
      GoRoute(
        path: '/watermark',
        name: 'watermark',
        builder: (context, state) {
          final filePath = state.uri.queryParameters['filePath'];
          final fileName = state.uri.queryParameters['fileName'];
          return WatermarkPage(
            initialFilePath: filePath,
            initialFileName: fileName,
          );
        },
      ),
      GoRoute(
        path: '/convert',
        name: 'convert',
        builder: (context, state) {
          final filePath = state.uri.queryParameters['filePath'];
          final fileName = state.uri.queryParameters['fileName'];
          return ConvertPage(
            initialFilePath: filePath,
            initialFileName: fileName,
          );
        },
      ),
      GoRoute(
        path: '/protect',
        name: 'protect',
        builder: (context, state) {
          final filePath = state.uri.queryParameters['filePath'];
          final fileName = state.uri.queryParameters['fileName'];
          return ProtectPage(
            initialFilePath: filePath,
            initialFileName: fileName,
          );
        },
      ),
      GoRoute(
        path: '/unlock',
        name: 'unlock',
        builder: (context, state) {
          final filePath = state.uri.queryParameters['filePath'];
          final fileName = state.uri.queryParameters['fileName'];
          return UnlockPage(
            initialFilePath: filePath,
            initialFileName: fileName,
          );
        },
      ),
      GoRoute(
        path: '/rotate',
        name: 'rotate',
        builder: (context, state) {
          final filePath = state.uri.queryParameters['filePath'];
          final fileName = state.uri.queryParameters['fileName'];
          return RotatePage(
            initialFilePath: filePath,
            initialFileName: fileName,
          );
        },
      ),
      GoRoute(
        path: '/page-numbers',
        name: 'page-numbers',
        builder: (context, state) {
          final filePath = state.uri.queryParameters['filePath'];
          final fileName = state.uri.queryParameters['fileName'];
          return PageNumbersPage(
            initialFilePath: filePath,
            initialFileName: fileName,
          );
        },
      ),
     
      GoRoute(
        path: '/faq',
        name: 'faq',
        builder: (context, state) => const FaqPage(),
      ),
      GoRoute(
        path: '/contact',
        name: 'contact',
        builder: (context, state) => const ContactPage(),
      ),
      GoRoute(
        path: '/pdfViewer',
        name: 'pdfViewer',
        builder: (context, state) {
          final filePath = state.uri.queryParameters['filePath'] ?? '';
          final title = state.uri.queryParameters['title'];

          return PDFViewerPage(
            filePath: filePath,
            fileName: title,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.red.shade50,
        foregroundColor: Colors.red.shade700,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red.shade700,
                  ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'The page you\'re looking for doesn\'t exist.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              label: const Text('Go Home'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
