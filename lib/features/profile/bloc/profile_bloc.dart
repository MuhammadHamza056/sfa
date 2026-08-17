import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<ToggleDarkModeEvent>(_onToggleDarkMode);
    on<ToggleTooltipEvent>(_onToggleTooltip);
  }

  void _onToggleDarkMode(ToggleDarkModeEvent event, Emitter<ProfileState> emit) {
    emit(state.copyWith(darkMode: event.darkMode));
  }

  void _onToggleTooltip(ToggleTooltipEvent event, Emitter<ProfileState> emit) {
    emit(state.copyWith(showTooltip: !state.showTooltip));
  }
}
