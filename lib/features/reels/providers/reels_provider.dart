import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Replaces the old `ReelsBloc`. The Reels tab stays alive in the bottom
/// nav's `IndexedStack`, so a plain (non-autoDispose) notifier mirrors the
/// bloc's original lifetime — created once and kept for as long as the tab
/// exists.
class ReelsNotifier extends Notifier<ReelsState> {
  @override
  ReelsState build() => const ReelsState();

  void changeFocusedIndex(int index) {
    state = state.copyWith(focusedIndex: index);
  }

  void videoControllerUpdated() {
    state = state.copyWith(updateTrigger: state.updateTrigger + 1);
  }

  void togglePlayPauseIcon(bool show, IconData icon) {
    state = state.copyWith(showPlayPauseIcon: show, playPauseIcon: icon);
  }
}

final reelsProvider = NotifierProvider<ReelsNotifier, ReelsState>(
  ReelsNotifier.new,
);
