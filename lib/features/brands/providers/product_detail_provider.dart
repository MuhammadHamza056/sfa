import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductDetailState {
  final int selectedColorIndex;
  final int selectedSizeIndex;
  final String selectedCity;

  const ProductDetailState({
    this.selectedColorIndex = 0,
    this.selectedSizeIndex = 0,
    this.selectedCity = 'cityRiyadh',
  });

  ProductDetailState copyWith({
    int? selectedColorIndex,
    int? selectedSizeIndex,
    String? selectedCity,
  }) {
    return ProductDetailState(
      selectedColorIndex: selectedColorIndex ?? this.selectedColorIndex,
      selectedSizeIndex: selectedSizeIndex ?? this.selectedSizeIndex,
      selectedCity: selectedCity ?? this.selectedCity,
    );
  }
}

/// Replaces the old per-screen `ProductDetailBloc`. Keyed by product
/// (see [productDetailKey]) and auto-disposed, so pushing a related
/// product's detail page on top of another gets its own fresh color/size/
/// city selection instead of inheriting whatever was picked on the page
/// below — the same isolation a bloc created in `initState` gave for free.
class ProductDetailNotifier
    extends AutoDisposeFamilyNotifier<ProductDetailState, String> {
  @override
  ProductDetailState build(String arg) => const ProductDetailState();

  void selectColor(int index) {
    state = state.copyWith(selectedColorIndex: index);
  }

  void selectSize(int index) {
    state = state.copyWith(selectedSizeIndex: index);
  }

  void selectCity(String city) {
    state = state.copyWith(selectedCity: city);
  }
}

final productDetailProvider = NotifierProvider.autoDispose
    .family<ProductDetailNotifier, ProductDetailState, String>(
      ProductDetailNotifier.new,
    );

/// Stable per-product key for [productDetailProvider] — combines name and
/// image since neither the mock data nor [ProductDetailArgs] carries a
/// real product id.
String productDetailKey(String productName, String productImage) =>
    '$productName::$productImage';
