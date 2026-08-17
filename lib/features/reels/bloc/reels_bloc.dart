import 'package:flutter_bloc/flutter_bloc.dart';
import 'reels_event.dart';
import 'reels_state.dart';

class ReelsBloc extends Bloc<ReelsEvent, ReelsState> {
  ReelsBloc() : super(const ReelsState()) {
    on<ChangeFocusedIndexEvent>(_onChangeFocusedIndex);
    on<VideoControllerUpdatedEvent>(_onVideoControllerUpdated);
    on<TogglePlayPauseIconEvent>(_onTogglePlayPauseIcon);
  }

  void _onChangeFocusedIndex(
    ChangeFocusedIndexEvent event,
    Emitter<ReelsState> emit,
  ) {
    emit(state.copyWith(focusedIndex: event.index));
  }

  void _onVideoControllerUpdated(
    VideoControllerUpdatedEvent event,
    Emitter<ReelsState> emit,
  ) {
    emit(state.copyWith(updateTrigger: state.updateTrigger + 1));
  }

  void _onTogglePlayPauseIcon(
    TogglePlayPauseIconEvent event,
    Emitter<ReelsState> emit,
  ) {
    emit(state.copyWith(
      showPlayPauseIcon: event.show,
      playPauseIcon: event.icon,
    ));
  }
}
