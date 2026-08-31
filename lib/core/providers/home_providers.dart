import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The selected Women/Men/Kids tab shown under the home screen's hero
/// section. Replaces the old `HomeBloc.selectedCategoryIndex`.
final homeSelectedCategoryIndexProvider = StateProvider<int>((ref) => 0);

/// Vertical scroll offset of the home screen's body, in logical pixels.
/// Drives the fixed top bar's fade-in background so it stays legible once
/// the hero image scrolls away underneath it.
final homeScrollOffsetProvider = StateProvider<double>((ref) => 0);

/// The selected Women/Men/Kids tab for the featured products grid. Shared
/// between the home screen's embedded section and the standalone "view
/// all" screen so the two stay in sync. Replaces the old
/// `HomeBloc.selectedFeaturedTab` — a bloc scoped to the `/home` route was
/// never reachable from `/featured-products`, which is pushed on the root
/// navigator outside that route's provider tree.
final homeSelectedFeaturedTabProvider = StateProvider<int>((ref) => 0);
