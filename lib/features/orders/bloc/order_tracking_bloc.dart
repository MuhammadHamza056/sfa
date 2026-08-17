import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_tracking_event.dart';
import 'order_tracking_state.dart';

class OrderTrackingBloc extends Bloc<OrderTrackingEvent, OrderTrackingState> {
  OrderTrackingBloc() : super(const OrderTrackingState()) {
    on<ChangeBottomNavIndexEvent>(_onChangeBottomNavIndex);
  }

  void _onChangeBottomNavIndex(
    ChangeBottomNavIndexEvent event,
    Emitter<OrderTrackingState> emit,
  ) {
    emit(state.copyWith(bottomNavIndex: event.index));
  }
}
