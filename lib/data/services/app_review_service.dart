// lib/core/services/app_review_service.dart
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_review_service.g.dart';

@riverpod
AppReviewService appReviewService(AppReviewServiceRef ref) {
  return AppReviewService();
}

class AppReviewService {
  final InAppReview _inAppReview = InAppReview.instance;

  /// Request an in-app review prompt to be shown to the user
  /// Note: This will not always display as the stores limit how often it can be shown
  Future<void> requestReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      } else {
        // If in-app review isn't available, fall back to store listing
        await openStoreListing();
      }
    } catch (e) {
      debugPrint('Error requesting review: $e');
      // Fall back to store listing if request review fails
      await openStoreListing();
    }
  }

  /// Opens the store listing for the app
  /// This is a fallback for when in-app review isn't available
  Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing(
        appStoreId: '1234567890', // Replace with your iOS App Store ID
        // microsoftStoreId: 'YOUR_MICROSOFT_STORE_ID', // For Windows apps
      );
    } catch (e) {
      debugPrint('Error opening store listing: $e');
    }
  }
}
