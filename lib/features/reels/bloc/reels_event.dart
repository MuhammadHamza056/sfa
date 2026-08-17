import 'package:flutter/material.dart';

@immutable
abstract class ReelsEvent {
  const ReelsEvent();
}

class ChangeFocusedIndexEvent extends ReelsEvent {
  final int index;
  const ChangeFocusedIndexEvent(this.index);
}

class VideoControllerUpdatedEvent extends ReelsEvent {
  const VideoControllerUpdatedEvent();
}

class TogglePlayPauseIconEvent extends ReelsEvent {
  final bool show;
  final IconData icon;
  const TogglePlayPauseIconEvent(this.show, this.icon);
}
