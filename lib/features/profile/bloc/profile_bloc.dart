import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/theme_notifier.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  // Seeded from the notifier so the switch still reflects the saved preference
  // after the bloc is recreated on a later visit to the account tab.
  ProfileBloc() : super(ProfileState(darkMode: themeNotifier.isDarkMode)) {
    on<ToggleDarkModeEvent>(_onToggleDarkMode);
    on<ToggleTooltipEvent>(_onToggleTooltip);
  }

  void _onToggleDarkMode(ToggleDarkModeEvent event, Emitter<ProfileState> emit) {
    themeNotifier.setDarkMode(event.darkMode);
    emit(state.copyWith(darkMode: event.darkMode));
  }

  void _onToggleTooltip(ToggleTooltipEvent event, Emitter<ProfileState> emit) {
    emit(state.copyWith(showTooltip: !state.showTooltip));
  }
}
