import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import 'review_models.dart';

/// M64-M67 from the guide.
class ReviewsRepository {
  ReviewsRepository(this._client);

  final ApiClient _client;

  /// M64: Product customer reviews list
  Future<ApiResult<ReviewsPage>> getReviews(
    String productId, {
    int page = 1,
    int limit = 10,
  }) {
    return _client.get<ReviewsPage>(
      ApiEndpoints.productReviews(productId),
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (data) {
        if (data is Map<String, dynamic> && data.containsKey('items')) {
          return ReviewsPage.fromJson(data);
        }
        final items = data is List
            ? data.map((v) => Review.fromJson(v as Map<String, dynamic>)).toList()
            : <Review>[];
        return ReviewsPage(items: items, total: items.length, page: 1, totalPages: 1);
      },
    );
  }

  /// M65: 5-star rating breakdown & average
  Future<ApiResult<ReviewsSummary>> getReviewsSummary(String productId) {
    return _client.get<ReviewsSummary>(
      ApiEndpoints.productReviewsSummary(productId),
      fromJson: (data) => ReviewsSummary.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M66: Submit verified purchase review. The guide's response is just
  /// `{success, message}` — no review object back — so this resolves to
  /// void rather than parsing a (nonexistent) `Review` from the body.
  Future<ApiResult<void>> submitReview(
    String productId, {
    required int rating,
    required String comment,
    List<String> images = const [],
  }) {
    return _client.post<void>(
      ApiEndpoints.productReviews(productId),
      data: {'rating': rating, 'comment': comment, 'images': images},
      fromJson: (_) {},
    );
  }

  /// M67: Mark review helpful — toggles, matching the guide's response
  /// `{helpful, helpfulCount}`.
  Future<ApiResult<({bool helpful, int helpfulCount})>> markHelpful(String reviewId) {
    return _client.post<({bool helpful, int helpfulCount})>(
      ApiEndpoints.reviewHelpful(reviewId),
      fromJson: (data) {
        final map = data as Map<String, dynamic>;
        return (
          helpful: map['helpful'] as bool? ?? false,
          helpfulCount: (map['helpfulCount'] as num?)?.toInt() ?? 0,
        );
      },
    );
  }
}
