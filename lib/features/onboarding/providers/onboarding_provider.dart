import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  final int currentPage;

  const OnboardingState({this.currentPage = 0});

  OnboardingState copyWith({int? currentPage}) {
    return OnboardingState(currentPage: currentPage ?? this.currentPage);
  }
}

/// Replaces the old per-screen `OnboardingBloc`. `.autoDispose` reproduces
/// the same lifecycle — a fresh state every time the onboarding screen is
/// pushed.
class OnboardingNotifier extends AutoDisposeNotifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void changePage(int pageIndex) {
    state = state.copyWith(currentPage: pageIndex);
  }
}

final onboardingProvider =
    NotifierProvider.autoDispose<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );
