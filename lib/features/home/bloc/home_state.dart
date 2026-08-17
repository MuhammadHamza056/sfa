import 'package:flutter/foundation.dart';

@immutable
class HomeState {
  final int selectedCategoryIndex;
  final int selectedFeaturedTab;

  const HomeState({
    this.selectedCategoryIndex = 0,
    this.selectedFeaturedTab = 0,
  });

  HomeState copyWith({
    int? selectedCategoryIndex,
    int? selectedFeaturedTab,
  }) {
    return HomeState(
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      selectedFeaturedTab: selectedFeaturedTab ?? this.selectedFeaturedTab,
    );
  }
}
