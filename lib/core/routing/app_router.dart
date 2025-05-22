import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/pages/home/home_page.dart';
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
      // Home route
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
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
      // GoRoute(
      //   path: '/convert',
      //   name: 'convert',
      //   builder: (context, state) => const ConvertPage(),
      // ),
      // GoRoute(
      //   path: '/protect',
      //   name: 'protect',
      //   builder: (context, state) => const ProtectPage(),
      // ),
      // GoRoute(
      //   path: '/unlock',
      //   name: 'unlock',
      //   builder: (context, state) => const UnlockPage(),
      // ),
      // GoRoute(
      //   path: '/rotate',
      //   name: 'rotate',
      //   builder: (context, state) => const RotatePage(),
      // ),
      // GoRoute(
      //   path: '/page-numbers',
      //   name: 'page-numbers',
      //   builder: (context, state) => const PageNumbersPage(),
      // ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
