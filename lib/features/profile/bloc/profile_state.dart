import 'package:flutter/foundation.dart';

@immutable
class ProfileState {
  final bool darkMode;
  final bool showTooltip;

  const ProfileState({
    this.darkMode = false,
    this.showTooltip = false,
  });

  ProfileState copyWith({
    bool? darkMode,
    bool? showTooltip,
  }) {
    return ProfileState(
      darkMode: darkMode ?? this.darkMode,
      showTooltip: showTooltip ?? this.showTooltip,
    );
  }
}
