import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_detail_event.dart';
import 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc() : super(const ProductDetailState()) {
    on<SelectColorEvent>(_onSelectColor);
    on<SelectSizeEvent>(_onSelectSize);
    on<SelectCityEvent>(_onSelectCity);
  }

  void _onSelectColor(
    SelectColorEvent event,
    Emitter<ProductDetailState> emit,
  ) {
    emit(state.copyWith(selectedColorIndex: event.index));
  }

  void _onSelectSize(
    SelectSizeEvent event,
    Emitter<ProductDetailState> emit,
  ) {
    emit(state.copyWith(selectedSizeIndex: event.index));
  }

  void _onSelectCity(
    SelectCityEvent event,
    Emitter<ProductDetailState> emit,
  ) {
    emit(state.copyWith(selectedCity: event.city));
  }
}
