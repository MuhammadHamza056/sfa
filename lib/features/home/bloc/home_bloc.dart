import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<ChangeCategoryIndexEvent>((event, emit) {
      emit(state.copyWith(selectedCategoryIndex: event.index));
    });

    on<ChangeFeaturedTabEvent>((event, emit) {
      emit(state.copyWith(selectedFeaturedTab: event.index));
    });
  }
}
