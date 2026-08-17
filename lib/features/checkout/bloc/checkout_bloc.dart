import 'package:flutter_bloc/flutter_bloc.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc() : super(const CheckoutState()) {
    on<ChangeBottomNavIndexEvent>(_onChangeBottomNavIndex);
    on<ChangeRegionIndexEvent>(_onChangeRegionIndex);
    on<ChangePaymentEvent>(_onChangePayment);
  }

  void _onChangeBottomNavIndex(
    ChangeBottomNavIndexEvent event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(bottomNavIndex: event.index));
  }

  void _onChangeRegionIndex(
    ChangeRegionIndexEvent event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(selectedRegionIndex: event.index));
  }

  void _onChangePayment(
    ChangePaymentEvent event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(selectedPayment: event.paymentOption));
  }
}
