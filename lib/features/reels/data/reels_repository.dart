import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import 'reel_models.dart';

/// M68-M72 from the guide.
class ReelsRepository {
  ReelsRepository(this._client);

  final ApiClient _client;

  /// M68: Social commerce reels video feed. Paginated — `{ items, total,
  /// page, limit, totalPages }`.
  Future<ApiResult<ReelsPage>> getReels({int page = 1, int limit = 10}) {
    return _client.get<ReelsPage>(
      ApiEndpoints.reels,
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (data) => ReelsPage.fromJson(data as Map<String, dynamic>? ?? const {}),
    );
  }

  /// M69: Like/unlike fashion reel
  Future<ApiResult<({bool isLiked, int likesCount})>> toggleLike(String id) {
    return _client.post<({bool isLiked, int likesCount})>(
      ApiEndpoints.reelLike(id),
      fromJson: (data) {
        final map = data as Map<String, dynamic>;
        return (
          isLiked: map['isLiked'] as bool? ?? false,
          likesCount: (map['likesCount'] as num?)?.toInt() ?? 0,
        );
      },
    );
  }

  /// M70: Bookmark/unsave fashion reel. The guide's response is just
  /// `{isSaved}` — no `savesCount` — so that's nullable here; the caller
  /// keeps its own optimistic count when the server doesn't echo one back.
  Future<ApiResult<({bool isSaved, int? savesCount})>> toggleSave(String id) {
    return _client.post<({bool isSaved, int? savesCount})>(
      ApiEndpoints.reelSave(id),
      fromJson: (data) {
        final map = data as Map<String, dynamic>;
        return (
          isSaved: map['isSaved'] as bool? ?? false,
          savesCount: (map['savesCount'] as num?)?.toInt(),
        );
      },
    );
  }

  /// M71: Resolve reel share deep link. Matches the guide's response
  /// exactly: `{shareUrl}`.
  Future<ApiResult<String>> getShareLink(String id) {
    return _client.get<String>(
      ApiEndpoints.reelShare(id),
      fromJson: (data) =>
          (data as Map<String, dynamic>)['shareUrl']?.toString() ?? '',
    );
  }
}
