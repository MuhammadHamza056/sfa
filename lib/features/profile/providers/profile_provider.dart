import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_notifier.dart';
import 'profile_data_provider.dart';

class ProfileState {
  final bool darkMode;
  final bool showTooltip;

  const ProfileState({this.darkMode = false, this.showTooltip = false});

  ProfileState copyWith({bool? darkMode, bool? showTooltip}) {
    return ProfileState(
      darkMode: darkMode ?? this.darkMode,
      showTooltip: showTooltip ?? this.showTooltip,
    );
  }
}

/// Replaces the old `ProfileBloc`. `.autoDispose` reproduces the bloc's
/// original lifecycle — recreated (and reseeded from [themeNotifier]) on
/// each later visit to the account tab.
class ProfileNotifier extends AutoDisposeNotifier<ProfileState> {
  @override
  ProfileState build() => ProfileState(darkMode: themeNotifier.isDarkMode);

  void toggleDarkMode(bool darkMode) {
    themeNotifier.setDarkMode(darkMode);
    state = state.copyWith(darkMode: darkMode);
    // M76 — best-effort sync; the app already works fully offline of this.
    ref
        .read(profileRepositoryProvider)
        .updatePreferences(theme: darkMode ? 'dark' : 'light');
  }

  void toggleTooltip() {
    state = state.copyWith(showTooltip: !state.showTooltip);
  }
}

final profileProvider =
    NotifierProvider.autoDispose<ProfileNotifier, ProfileState>(
      ProfileNotifier.new,
    );
