import 'package:flutter/foundation.dart';

@immutable
abstract class OnboardingEvent {
  const OnboardingEvent();
}

class ChangePageEvent extends OnboardingEvent {
  final int pageIndex;
  const ChangePageEvent(this.pageIndex);
}
