import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/pages/main/main_navigation_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/tools/tools_page.dart';
import '../../presentation/pages/recent/recent_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/compress/compress_page.dart';
import '../../presentation/pages/split/split_page.dart';
import '../../presentation/pages/merge/merge_page.dart';
import '../../presentation/pages/watermark/watermark_page.dart';
import '../../presentation/pages/convert/convert_page.dart';
import '../../presentation/pages/protect/protect_page.dart';
import '../../presentation/pages/unlock/unlock_page.dart';
import '../../presentation/pages/rotate/rotate_page.dart';
import '../../presentation/pages/page_numbers/page_numbers_page.dart';

part 'app_router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
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
        builder: (context, state) => const ProfilePage(),
      ),

      // PDF Operations
      GoRoute(
        path: '/compress',
        name: 'compress',
        builder: (context, state) => const CompressPage(),
      ),
      GoRoute(
        path: '/split',
        name: 'split',
        builder: (context, state) => const SplitPage(),
      ),
      GoRoute(
        path: '/merge',
        name: 'merge',
        builder: (context, state) => const MergePage(),
      ),
      GoRoute(
        path: '/watermark',
        name: 'watermark',
        builder: (context, state) => const WatermarkPage(),
      ),
      GoRoute(
        path: '/convert',
        name: 'convert',
        builder: (context, state) => const ConvertPage(),
      ),
      GoRoute(
        path: '/protect',
        name: 'protect',
        builder: (context, state) => const ProtectPage(),
      ),
      GoRoute(
        path: '/unlock',
        name: 'unlock',
        builder: (context, state) => const UnlockPage(),
      ),
      GoRoute(
        path: '/rotate',
        name: 'rotate',
        builder: (context, state) => const RotatePage(),
      ),
      GoRoute(
        path: '/page-numbers',
        name: 'page-numbers',
        builder: (context, state) => const PageNumbersPage(),
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
