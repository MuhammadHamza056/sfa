import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/reel_models.dart';
import '../data/reels_repository.dart';

final reelsRepositoryProvider = Provider<ReelsRepository>((ref) {
  return ReelsRepository(ApiClient.instance);
});

/// [reelsFeedProvider]'s state: the flattened list of pages fetched so far,
/// plus enough pagination bookkeeping to drive infinite scroll.
class ReelsFeedState {
  final List<Reel> items;
  final int page;
  final int totalPages;
  final bool isLoadingMore;

  const ReelsFeedState({
    this.items = const [],
    this.page = 1,
    this.totalPages = 1,
    this.isLoadingMore = false,
  });

  bool get hasMore => page < totalPages;

  ReelsFeedState copyWith({
    List<Reel>? items,
    int? page,
    int? totalPages,
    bool? isLoadingMore,
  }) {
    return ReelsFeedState(
      items: items ?? this.items,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// M68, with optimistic M69/M70 mutations applied in place so the feed
/// doesn't refetch on every like/save tap, and page-based infinite scroll
/// on top of the guide's `{ items, total, page, limit, totalPages }` shape.
class ReelsFeedNotifier extends AsyncNotifier<ReelsFeedState> {
  ReelsRepository get _repository => ref.read(reelsRepositoryProvider);

  @override
  Future<ReelsFeedState> build() async {
    final result = await _repository.getReels(page: 1);
    return result.when(
      success: (data) => ReelsFeedState(
        items: data.items,
        page: data.page,
        totalPages: data.totalPages,
      ),
      failure: (e) => throw e,
    );
  }

  void _replace(String id, Reel Function(Reel) update) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: [
          for (final reel in current.items)
            if (reel.id == id) update(reel) else reel,
        ],
      ),
    );
  }

  /// M69
  Future<void> toggleLike(String id) async {
    final current = state.valueOrNull?.items.firstWhere((r) => r.id == id);
    if (current == null) return;
    // Optimistic flip.
    _replace(
      id,
      (r) => r.copyWith(
        isLiked: !r.isLiked,
        likesCount: r.likesCount + (r.isLiked ? -1 : 1),
      ),
    );
    final result = await _repository.toggleLike(id);
    result.when(
      success: (data) => _replace(
        id,
        (r) => r.copyWith(isLiked: data.isLiked, likesCount: data.likesCount),
      ),
      failure: (_) => _replace(
        id,
        (r) => r.copyWith(
          isLiked: current.isLiked,
          likesCount: current.likesCount,
        ),
      ),
    );
  }

  /// M70
  Future<void> toggleSave(String id) async {
    final current = state.valueOrNull?.items.firstWhere((r) => r.id == id);
    if (current == null) return;
    _replace(
      id,
      (r) => r.copyWith(
        isSaved: !r.isSaved,
        savesCount: r.savesCount + (r.isSaved ? -1 : 1),
      ),
    );
    final result = await _repository.toggleSave(id);
    result.when(
      // The guide's M70 response doesn't echo `savesCount` back — keep the
      // optimistic value already applied above unless the server did send one.
      success: (data) => _replace(
        id,
        (r) => r.copyWith(
          isSaved: data.isSaved,
          savesCount: data.savesCount ?? r.savesCount,
        ),
      ),
      failure: (_) => _replace(
        id,
        (r) => r.copyWith(
          isSaved: current.isSaved,
          savesCount: current.savesCount,
        ),
      ),
    );
  }

  /// Fetches the next page and appends it to the feed. No-ops while a page
  /// is already in flight, once there's nothing left to fetch, or while
  /// showing the mock placeholder feed.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await _repository.getReels(page: current.page + 1);
    result.when(
      success: (data) => state = AsyncData(
        current.copyWith(
          items: [...current.items, ...data.items],
          page: data.page,
          totalPages: data.totalPages,
          isLoadingMore: false,
        ),
      ),
      failure: (_) => state = AsyncData(current.copyWith(isLoadingMore: false)),
    );
  }
}

final reelsFeedProvider =
    AsyncNotifierProvider<ReelsFeedNotifier, ReelsFeedState>(
      ReelsFeedNotifier.new,
    );
