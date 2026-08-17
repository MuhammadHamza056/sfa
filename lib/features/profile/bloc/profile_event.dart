import 'package:flutter/foundation.dart';

@immutable
abstract class ProfileEvent {
  const ProfileEvent();
}

class ToggleDarkModeEvent extends ProfileEvent {
  final bool darkMode;
  const ToggleDarkModeEvent(this.darkMode);
}

class ToggleTooltipEvent extends ProfileEvent {
  const ToggleTooltipEvent();
}
