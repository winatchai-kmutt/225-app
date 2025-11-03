import 'package:equatable/equatable.dart';

/// Type of Pomodoro timer session
enum SessionType {
  /// 25-minute work session
  pomodoro,
  
  /// 5-minute break
  shortBreak,
  
  /// 15-minute break
  longBreak,
}

/// Current state of the timer
enum TimerState {
  /// Timer is actively running
  running,
  
  /// Timer is paused (not used in MVP)
  paused,
  
  /// Timer has finished
  completed,
  
  /// Timer was cancelled by user
  cancelled,
}

/// Represents an active or completed Pomodoro timer session.
/// 
/// This entity contains all state needed for background execution and persistence.
/// The timer uses timestamp-based calculation to maintain accuracy when the app
/// is backgrounded or closed.
class TimerSession extends Equatable {
  /// Unique identifier for this session
  final String id;
  
  /// Type of session (Pomodoro, Short Break, Long Break)
  final SessionType sessionType;
  
  /// Total duration of the session
  final Duration totalDuration;
  
  /// When the timer was started
  final DateTime startTimestamp;
  
  /// When the timer completed (null if not yet complete)
  final DateTime? completionTimestamp;
  
  /// Current state of the timer
  final TimerState currentState;

  const TimerSession({
    required this.id,
    required this.sessionType,
    required this.totalDuration,
    required this.startTimestamp,
    this.completionTimestamp,
    required this.currentState,
  });

  /// Create a TimerSession from JSON
  factory TimerSession.fromJson(Map<String, dynamic> json) {
    return TimerSession(
      id: json['id'] as String,
      sessionType: SessionType.values.firstWhere(
        (e) => e.name == json['sessionType'],
      ),
      totalDuration: Duration(seconds: json['totalDurationSeconds'] as int),
      startTimestamp: DateTime.parse(json['startTimestamp'] as String),
      completionTimestamp: json['completionTimestamp'] != null
          ? DateTime.parse(json['completionTimestamp'] as String)
          : null,
      currentState: TimerState.values.firstWhere(
        (e) => e.name == json['currentState'],
      ),
    );
  }

  /// Convert TimerSession to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionType': sessionType.name,
      'totalDurationSeconds': totalDuration.inSeconds,
      'startTimestamp': startTimestamp.toIso8601String(),
      'completionTimestamp': completionTimestamp?.toIso8601String(),
      'currentState': currentState.name,
    };
  }

  /// Create a copy with updated fields
  TimerSession copyWith({
    String? id,
    SessionType? sessionType,
    Duration? totalDuration,
    DateTime? startTimestamp,
    DateTime? completionTimestamp,
    TimerState? currentState,
  }) {
    return TimerSession(
      id: id ?? this.id,
      sessionType: sessionType ?? this.sessionType,
      totalDuration: totalDuration ?? this.totalDuration,
      startTimestamp: startTimestamp ?? this.startTimestamp,
      completionTimestamp: completionTimestamp ?? this.completionTimestamp,
      currentState: currentState ?? this.currentState,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionType,
        totalDuration,
        startTimestamp,
        completionTimestamp,
        currentState,
      ];
}

/// Extension methods for Duration
extension DurationExtensions on Duration {
  /// Format Duration as "MM:SS" for UI display
  String toDisplayString() {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
