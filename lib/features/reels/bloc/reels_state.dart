import 'package:flutter/material.dart';

@immutable
class ReelsState {
  final int focusedIndex;
  final int updateTrigger;
  final bool showPlayPauseIcon;
  final IconData playPauseIcon;

  const ReelsState({
    this.focusedIndex = 0,
    this.updateTrigger = 0,
    this.showPlayPauseIcon = false,
    this.playPauseIcon = Icons.play_arrow,
  });

  ReelsState copyWith({
    int? focusedIndex,
    int? updateTrigger,
    bool? showPlayPauseIcon,
    IconData? playPauseIcon,
  }) {
    return ReelsState(
      focusedIndex: focusedIndex ?? this.focusedIndex,
      updateTrigger: updateTrigger ?? this.updateTrigger,
      showPlayPauseIcon: showPlayPauseIcon ?? this.showPlayPauseIcon,
      playPauseIcon: playPauseIcon ?? this.playPauseIcon,
    );
  }
}
