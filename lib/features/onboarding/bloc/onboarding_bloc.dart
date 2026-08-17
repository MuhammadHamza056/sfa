import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingState()) {
    on<ChangePageEvent>(_onChangePage);
  }

  void _onChangePage(ChangePageEvent event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(currentPage: event.pageIndex));
  }
}
