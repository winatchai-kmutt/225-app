import 'package:equatable/equatable.dart';

/// Session type enum
enum SessionType {
  work,
  breakTime,
}

/// Abstract base class for timer states
abstract class TimerCubitState extends Equatable {
  const TimerCubitState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state - timer not started or after reset
class TimerInitialState extends TimerCubitState {
  final Duration totalDuration;
  final SessionType sessionType;
  
  const TimerInitialState({
    required this.totalDuration,
    required this.sessionType,
  });
  
  @override
  List<Object?> get props => [totalDuration, sessionType];
}

/// Running state - timer actively counting down
class TimerRunningState extends TimerCubitState {
  final Duration remaining;
  final double progress; // 0.0 to 1.0 for UI progress ring
  final SessionType sessionType;
  
  const TimerRunningState({
    required this.remaining,
    required this.progress,
    required this.sessionType,
  });
  
  @override
  List<Object?> get props => [remaining, progress, sessionType];
}

/// Paused state - timer stopped mid-countdown
class TimerPausedState extends TimerCubitState {
  final Duration remaining;
  final double progress;
  final SessionType sessionType;
  
  const TimerPausedState({
    required this.remaining,
    required this.progress,
    required this.sessionType,
  });
  
  @override
  List<Object?> get props => [remaining, progress, sessionType];
}

/// Completed state - countdown reached 00:00
class TimerCompletedState extends TimerCubitState {
  final SessionType completedSessionType;
  
  const TimerCompletedState({
    required this.completedSessionType,
  });
  
  @override
  List<Object?> get props => [completedSessionType];
}
