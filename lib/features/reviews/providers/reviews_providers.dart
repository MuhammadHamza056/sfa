import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/review_models.dart';
import '../data/reviews_repository.dart';

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return ReviewsRepository(ApiClient.instance);
});

/// M64 — keyed by product id.
final productReviewsProvider = FutureProvider.family<ReviewsPage, String>((ref, productId) async {
  final result = await ref.read(reviewsRepositoryProvider).getReviews(productId);
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M65 — keyed by product id.
final reviewsSummaryProvider =
    FutureProvider.family<ReviewsSummary, String>((ref, productId) async {
  final result = await ref.read(reviewsRepositoryProvider).getReviewsSummary(productId);
  return result.when(success: (data) => data, failure: (e) => throw e);
});
