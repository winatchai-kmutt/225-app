import 'package:equatable/equatable.dart';

/// Base class for onboarding states
sealed class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// Initial state when onboarding screen loads
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// Loading state while requesting permission
class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

/// Permission request completed (regardless of grant/deny)
/// Navigation to paywall should happen after this state
class OnboardingComplete extends OnboardingState {
  const OnboardingComplete();
}
