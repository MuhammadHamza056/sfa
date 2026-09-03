import 'package:flutter_riverpod/flutter_riverpod.dart';

class BrandsState {
  final int selectedGender;

  /// Selected brand category id from `/brands/categories`; empty string
  /// means the "All" chip, which lists brands via the unfiltered `/brands`.
  final String selectedCategoryId;

  const BrandsState({this.selectedGender = 0, this.selectedCategoryId = ''});

  BrandsState copyWith({int? selectedGender, String? selectedCategoryId}) {
    return BrandsState(
      selectedGender: selectedGender ?? this.selectedGender,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
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

  void changeCategory(String categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
  }
}

final brandsProvider = NotifierProvider<BrandsNotifier, BrandsState>(
  BrandsNotifier.new,
);
