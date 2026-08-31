import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreviousOrdersState {
  final int selectedTab;

  /// Keys of order cards currently expanded, e.g. 'current_1', 'prev_2'.
  final Set<String> expandedCardKeys;

  const PreviousOrdersState({
    this.selectedTab = 0,
    this.expandedCardKeys = const {},
  });

  PreviousOrdersState copyWith({
    int? selectedTab,
    Set<String>? expandedCardKeys,
  }) {
    return PreviousOrdersState(
      selectedTab: selectedTab ?? this.selectedTab,
      expandedCardKeys: expandedCardKeys ?? this.expandedCardKeys,
    );
  }
}

/// Replaces the old per-route `OrdersBloc` (it was re-created fresh every
/// time `/previous-orders` was pushed). `.autoDispose` reproduces that same
/// lifecycle — state resets once nothing is watching the provider anymore.
class PreviousOrdersNotifier extends AutoDisposeNotifier<PreviousOrdersState> {
  @override
  PreviousOrdersState build() => const PreviousOrdersState();

  void changeTab(int index) {
    state = state.copyWith(selectedTab: index);
  }

  void toggleCardExpanded(String cardKey) {
    final updated = Set<String>.from(state.expandedCardKeys);
    if (!updated.remove(cardKey)) {
      updated.add(cardKey);
    }
    state = state.copyWith(expandedCardKeys: updated);
  }
}

final previousOrdersProvider =
    NotifierProvider.autoDispose<PreviousOrdersNotifier, PreviousOrdersState>(
      PreviousOrdersNotifier.new,
    );
