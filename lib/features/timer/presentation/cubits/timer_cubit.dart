import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'timer_state.dart';

/// Timer Cubit for managing timer state and countdown logic
///
/// Handles timer lifecycle, background countdown using DateTime calculations,
/// and app lifecycle events for accurate background tracking.
///
/// **Features:**
/// - DateTime-based countdown (not Timer.periodic) for accuracy
/// - Background tracking via WidgetsBindingObserver
/// - Automatic completion detection when backgrounded
/// - ±2 second accuracy over 25 minutes
class TimerCubit extends Cubit<TimerCubitState> with WidgetsBindingObserver {
  Timer? _timer;
  DateTime? _startTime;
  Duration? _remainingDuration; // Remaining time for current countdown
  Duration? _totalDuration;      // Original duration for progress calculation
  SessionType _currentSessionType = SessionType.work;
  
  TimerCubit() : super(const TimerInitialState(
    totalDuration: Duration(minutes: 25),
    sessionType: SessionType.work,
  )) {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Start the timer countdown
  void start() {
    final currentState = state;
    
    if (currentState is TimerInitialState) {
      _remainingDuration = currentState.totalDuration;
      _totalDuration = currentState.totalDuration;
      _currentSessionType = currentState.sessionType;
      _startTime = DateTime.now();
      
      // Emit immediately for instant UI feedback
      emit(TimerRunningState(
        remaining: currentState.totalDuration,
        progress: 1.0,
        sessionType: currentState.sessionType,
      ));
      
      // Start timer after emit for smooth experience
      _startTimer();
    } else if (currentState is TimerPausedState) {
      // Keep precise duration with milliseconds to avoid time jumps
      _remainingDuration = currentState.remaining;
      // Keep original totalDuration for progress calculation
      _currentSessionType = currentState.sessionType;
      _startTime = DateTime.now();
      
      // Emit immediately for instant UI feedback
      emit(TimerRunningState(
        remaining: currentState.remaining,
        progress: currentState.progress,
        sessionType: currentState.sessionType,
      ));
      
      // Start timer after emit for smooth experience
      _startTimer();
    }
  }

  /// Pause the timer countdown
  void pause() {
    final currentState = state;
    
    if (currentState is TimerRunningState) {
      _timer?.cancel();
      _timer = null;
      
      // Calculate exact remaining time using DateTime
      final elapsed = DateTime.now().difference(_startTime!);
      final remaining = _remainingDuration! - elapsed;
      
      final progress = remaining.inSeconds / _totalDuration!.inSeconds;
      
      emit(TimerPausedState(
        remaining: remaining.isNegative ? Duration.zero : remaining,
        progress: progress.clamp(0.0, 1.0),
        sessionType: currentState.sessionType,
      ));
    }
  }

  /// Reset the timer to initial state
  void reset() {
    _timer?.cancel();
    _timer = null;
    _startTime = null;
    _remainingDuration = null;
    _totalDuration = null;
    
    final currentState = state;
    final sessionType = _getSessionType(currentState);
    
    emit(TimerInitialState(
      totalDuration: const Duration(minutes: 25),
      sessionType: sessionType,
    ));
  }

  /// Skip the current timer and immediately complete
  /// 
  /// Transitions from any state (Initial/Running/Paused) to Completed state.
  /// Triggers the same completion flow as natural countdown.
  void skip() {
    _timer?.cancel();
    _timer = null;
    
    final currentState = state;
    final sessionType = _getSessionType(currentState);
    
    emit(TimerCompletedState(
      completedSessionType: sessionType,
    ));
  }

  /// Start the periodic timer
  void _startTimer() {
    _timer?.cancel();
    
    // Calculate time until next whole second for smooth countdown
    final now = DateTime.now();
    final millisUntilNextSecond = 1000 - now.millisecond;
    
    // First tick at the next whole second
    _timer = Timer(Duration(milliseconds: millisUntilNextSecond), () {
      _tick();
      
      // Then continue ticking every second
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _tick();
      });
    });
  }

  /// Timer tick - calculate remaining time using DateTime
  void _tick() {
    if (_startTime == null || _remainingDuration == null) return;
    
    final elapsed = DateTime.now().difference(_startTime!);
    final remaining = _remainingDuration! - elapsed;
    
    if (remaining.isNegative || remaining.inSeconds <= 0) {
      _onComplete();
    } else {
      final progress = remaining.inSeconds / _totalDuration!.inSeconds;
      
      emit(TimerRunningState(
        remaining: remaining,
        progress: progress.clamp(0.0, 1.0),
        sessionType: _currentSessionType,
      ));
    }
  }

  /// Handle timer completion
  void _onComplete() {
    _timer?.cancel();
    _timer = null;
    
    final currentState = state;
    final sessionType = _getSessionType(currentState);
    
    emit(TimerCompletedState(
      completedSessionType: sessionType,
    ));
  }

  /// Get session type from current state
  SessionType _getSessionType(TimerCubitState currentState) {
    if (currentState is TimerInitialState) {
      return currentState.sessionType;
    } else if (currentState is TimerCompletedState) {
      return currentState.completedSessionType;
    }
    return SessionType.work; // Default
  }

  /// Handle app lifecycle state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    super.didChangeAppLifecycleState(lifecycleState);
    
    if (lifecycleState == AppLifecycleState.resumed) {
      _handleAppResumed();
    }
  }

  /// Recalculate remaining time when app is resumed
  void _handleAppResumed() {
    final currentState = state;
    
    // Only recalculate if timer was running
    if (currentState is! TimerRunningState) return;
    
    if (_startTime == null || _remainingDuration == null) return;
    
    // Calculate elapsed time while app was in background
    final elapsed = DateTime.now().difference(_startTime!);
    final remaining = _remainingDuration! - elapsed;
    
    if (remaining.isNegative || remaining.inSeconds <= 0) {
      // Timer completed while in background
      _onComplete();
    } else {
      // Update remaining time
      final progress = remaining.inSeconds / _totalDuration!.inSeconds;
      
      emit(TimerRunningState(
        remaining: remaining,
        progress: progress.clamp(0.0, 1.0),
        sessionType: _currentSessionType,
      ));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
