import 'package:flutter_bloc/flutter_bloc.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc() : super(const OrdersState()) {
    on<ChangeOrdersTabEvent>((event, emit) {
      emit(state.copyWith(selectedTab: event.index));
    });

    on<ToggleFirstCardExpandedEvent>((event, emit) {
      emit(state.copyWith(isFirstCardExpanded: !state.isFirstCardExpanded));
    });

    on<ToggleSecondCardExpandedEvent>((event, emit) {
      emit(state.copyWith(isSecondCardExpanded: !state.isSecondCardExpanded));
    });

    on<TogglePrevFirstCardExpandedEvent>((event, emit) {
      emit(state.copyWith(isPrevFirstCardExpanded: !state.isPrevFirstCardExpanded));
    });

    on<TogglePrevSecondCardExpandedEvent>((event, emit) {
      emit(state.copyWith(isPrevSecondCardExpanded: !state.isPrevSecondCardExpanded));
    });

    on<ToggleProductsExpandedEvent>((event, emit) {
      emit(state.copyWith(isProductsExpanded: !state.isProductsExpanded));
    });

    on<ToggleProductSelectionEvent>((event, emit) {
      final updated = Map<String, bool>.from(state.selectedProducts);
      updated[event.productId] = event.isSelected;
      emit(state.copyWith(selectedProducts: updated));
    });

    on<ChangeRefundReasonEvent>((event, emit) {
      emit(state.copyWith(selectedReason: event.reason));
    });
  }
}
