/// M64 — matches the guide's response example exactly.
class Review {
  final String id;
  final double rating;
  final String comment;
  final List<String> images;
  final String userName;
  final DateTime? createdAt;
  final int helpfulCount;

  const Review({
    required this.id,
    required this.rating,
    required this.comment,
    this.images = const [],
    required this.userName,
    this.createdAt,
    this.helpfulCount = 0,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: json['comment']?.toString() ?? '',
      images: (json['images'] as List? ?? const []).map((v) => v.toString()).toList(),
      userName: json['userName']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      helpfulCount: (json['helpfulCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class ReviewsPage {
  final List<Review> items;
  final int total;
  final int page;
  final int totalPages;

  const ReviewsPage({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory ReviewsPage.fromJson(Map<String, dynamic> json) {
    return ReviewsPage(
      items: (json['items'] as List? ?? const [])
          .map((v) => Review.fromJson(v as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

/// M65 — matches the guide's response example: `{avgRating, totalReviews,
/// breakdown: {"5": 115, ...}}`. Kept lenient (older field-name fallbacks)
/// in case a differently-versioned backend is in front of this.
class ReviewsSummary {
  final double average;
  final int total;
  final Map<int, int> distribution;

  const ReviewsSummary({required this.average, required this.total, required this.distribution});

  factory ReviewsSummary.fromJson(Map<String, dynamic> json) {
    final dist = <int, int>{};
    final rawDist = json['distribution'] ?? json['breakdown'];
    if (rawDist is List) {
      for (final entry in rawDist) {
        if (entry is Map<String, dynamic>) {
          final stars = (entry['stars'] as num?)?.toInt();
          final count = (entry['count'] as num?)?.toInt();
          if (stars != null && count != null) dist[stars] = count;
        }
      }
    } else if (rawDist is Map) {
      rawDist.forEach((key, value) {
        final stars = int.tryParse(key.toString());
        final count = (value as num?)?.toInt();
        if (stars != null && count != null) dist[stars] = count;
      });
    }
    return ReviewsSummary(
      average: (json['average'] as num?)?.toDouble() ??
          (json['avgRating'] as num?)?.toDouble() ??
          0,
      total: (json['totalReviews'] as num?)?.toInt() ??
          (json['total'] as num?)?.toInt() ??
          (json['reviewCount'] as num?)?.toInt() ??
          0,
      distribution: dist,
    );
  }
}
