import 'package:flutter_riverpod/flutter_riverpod.dart';

class BrandsState {
  final int selectedGender;
  final int selectedCategory;

  const BrandsState({this.selectedGender = 0, this.selectedCategory = 0});

  BrandsState copyWith({int? selectedGender, int? selectedCategory}) {
    return BrandsState(
      selectedGender: selectedGender ?? this.selectedGender,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

/// Replaces the old `BrandsBloc`. The Brands tab stays alive in the bottom
/// nav's `IndexedStack`, so a plain (non-autoDispose) notifier mirrors the
/// bloc's original lifetime — created once and kept for as long as the tab
/// exists.
class BrandsNotifier extends Notifier<BrandsState> {
  @override
  BrandsState build() => const BrandsState();

  void changeGender(int genderIndex) {
    state = state.copyWith(selectedGender: genderIndex);
  }

  void changeCategory(int categoryIndex) {
    state = state.copyWith(selectedCategory: categoryIndex);
  }
}

final brandsProvider = NotifierProvider<BrandsNotifier, BrandsState>(
  BrandsNotifier.new,
);
