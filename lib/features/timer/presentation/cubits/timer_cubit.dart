import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_config.dart';
import '../../../../services/background_timer_service.dart';
import '../../../storage/domain/entities/timer_session.dart' as storage;
import '../../../storage/domain/repos/timer_persistence_repo.dart';
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
/// - State persistence across app closure (not device reboot)
class TimerCubit extends Cubit<TimerCubitState> with WidgetsBindingObserver {
  final TimerPersistenceRepo _persistenceRepo;
  final BackgroundTimerService _backgroundTimerService;

  Timer? _timer;
  DateTime? _startTime;
  Duration? _remainingDuration; // Remaining time for current countdown
  Duration? _totalDuration; // Original duration for progress calculation
  SessionType _currentSessionType = SessionType.work;
  bool _isRestoringState = false;

  TimerCubit({
    required TimerPersistenceRepo persistenceRepo,
    required BackgroundTimerService backgroundTimerService,
  }) : _persistenceRepo = persistenceRepo,
       _backgroundTimerService = backgroundTimerService,
       super(
         TimerInitialState(
           totalDuration: AppConfig.workDuration,
           sessionType: SessionType.work,
         ),
       ) {
    WidgetsBinding.instance.addObserver(this);
    _initializeFromPersistence();
  }

  /// Initialize timer state from persistence on app startup
  Future<void> _initializeFromPersistence() async {
    _isRestoringState = true;

    try {
      final session = await _persistenceRepo.loadTimerSession();

      if (session != null &&
          session.currentState == storage.TimerState.running) {
        // Restore running timer
        _startTime = session.startTimestamp;
        _totalDuration = session.totalDuration;
        _remainingDuration = session.totalDuration;
        _currentSessionType = _convertStorageSessionType(session.sessionType);

        // Calculate current remaining time
        final remaining = _backgroundTimerService.calculateRemainingTime(
          session,
        );

        if (remaining.isNegative || remaining.inSeconds <= 0) {
          // Timer completed while app was closed
          await _persistenceRepo.clearTimerSession();
          emit(TimerCompletedState(completedSessionType: _currentSessionType));
        } else {
          // Timer still running - restore state
          final progress = remaining.inSeconds / _totalDuration!.inSeconds;
          emit(
            TimerRunningState(
              remaining: remaining,
              progress: progress.clamp(0.0, 1.0),
              sessionType: _currentSessionType,
            ),
          );

          // Start local timer for UI updates
          _startTimer();
        }
      }
    } catch (e) {
      // If restoration fails, stay in initial state
      debugPrint('TimerCubit: Failed to restore timer state - $e');
    } finally {
      _isRestoringState = false;
    }
  }

  /// Convert storage SessionType to UI SessionType
  SessionType _convertStorageSessionType(storage.SessionType storageType) {
    switch (storageType) {
      case storage.SessionType.pomodoro:
        return SessionType.work;
      case storage.SessionType.shortBreak:
      case storage.SessionType.longBreak:
        return SessionType.breakTime;
    }
  }

  /// Convert UI SessionType to storage SessionType
  storage.SessionType _convertToStorageSessionType(SessionType uiType) {
    switch (uiType) {
      case SessionType.work:
        return storage.SessionType.pomodoro;
      case SessionType.breakTime:
        return storage.SessionType.shortBreak;
    }
  }

  /// Start the timer countdown
  Future<void> start() async {
    final currentState = state;

    if (currentState is TimerInitialState) {
      _remainingDuration = currentState.totalDuration;
      _totalDuration = currentState.totalDuration;
      _currentSessionType = currentState.sessionType;

      // Start timer via BackgroundTimerService
      final session = await _backgroundTimerService.startTimer(
        duration: currentState.totalDuration,
        sessionType: _convertToStorageSessionType(currentState.sessionType),
      );

      _startTime = session.startTimestamp;

      // Emit immediately for instant UI feedback
      emit(
        TimerRunningState(
          remaining: currentState.totalDuration,
          progress: 1.0,
          sessionType: currentState.sessionType,
        ),
      );

      // Start local timer for UI updates
      _startTimer();
    } else if (currentState is TimerPausedState) {
      // Keep precise duration with milliseconds to avoid time jumps
      _remainingDuration = currentState.remaining;
      // Keep original totalDuration for progress calculation
      _currentSessionType = currentState.sessionType;
      _startTime = DateTime.now();

      // Start timer via BackgroundTimerService
      await _backgroundTimerService.startTimer(
        duration: currentState.remaining,
        sessionType: _convertToStorageSessionType(currentState.sessionType),
      );

      // Emit immediately for instant UI feedback
      emit(
        TimerRunningState(
          remaining: currentState.remaining,
          progress: currentState.progress,
          sessionType: currentState.sessionType,
        ),
      );

      // Start local timer for UI updates
      _startTimer();
    }
  }

  /// Pause the timer countdown
  void pause() async {
    final currentState = state;

    await _backgroundTimerService.cancelTimer();

    if (currentState is TimerRunningState) {
      _timer?.cancel();
      _timer = null;

      // Use the current state's remaining time to avoid calculation drift
      // This ensures the paused time matches what user sees on screen
      final remaining = currentState.remaining;
      final progress = currentState.progress;

      // Update _remainingDuration for resume
      _remainingDuration = remaining;

      emit(
        TimerPausedState(
          remaining: remaining,
          progress: progress,
          sessionType: currentState.sessionType,
        ),
      );
    }
  }

  /// Reset the timer to initial state
  Future<void> reset() async {
    _timer?.cancel();
    _timer = null;
    _startTime = null;
    _remainingDuration = null;
    _totalDuration = null;

    // Cancel background timer and clear persistence
    await _backgroundTimerService.cancelTimer();

    final currentState = state;
    final sessionType = _getSessionType(currentState);

    emit(
      TimerInitialState(
        totalDuration: _getDurationForSessionType(sessionType),
        sessionType: sessionType,
      ),
    );
  }

  /// Skip the current timer and immediately complete
  ///
  /// Transitions from any state (Initial/Running/Paused) to Completed state.
  /// Triggers the same completion flow as natural countdown.
  Future<void> skip() async {
    _timer?.cancel();
    _timer = null;

    // Cancel background timer and clear persistence
    await _backgroundTimerService.cancelTimer();

    final currentState = state;
    final sessionType = _getSessionType(currentState);

    emit(TimerCompletedState(completedSessionType: sessionType));
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

      emit(
        TimerRunningState(
          remaining: remaining,
          progress: progress.clamp(0.0, 1.0),
          sessionType: _currentSessionType,
        ),
      );
    }
  }

  /// Handle timer completion
  void _onComplete() {
    _timer?.cancel();
    _timer = null;

    // Clear persisted session
    _persistenceRepo.clearTimerSession();

    final currentState = state;
    final sessionType = _getSessionType(currentState);

    emit(TimerCompletedState(completedSessionType: sessionType));
  }

  /// Get session type from current state
  SessionType _getSessionType(TimerCubitState currentState) {
    if (currentState is TimerInitialState) {
      return currentState.sessionType;
    } else if (currentState is TimerCompletedState) {
      return currentState.completedSessionType;
    } else if (currentState is TimerRunningState) {
      return currentState.sessionType;
    } else if (currentState is TimerPausedState) {
      return currentState.sessionType;
    }
    return SessionType.work; // Default
  }

  /// Get duration for a given session type from AppConfig
  Duration _getDurationForSessionType(SessionType sessionType) {
    switch (sessionType) {
      case SessionType.work:
        return AppConfig.workDuration;
      case SessionType.breakTime:
        return AppConfig.shortBreakDuration; // Use short break for UI breakTime
    }
  }

  /// Handle app lifecycle state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    super.didChangeAppLifecycleState(lifecycleState);

    if (lifecycleState == AppLifecycleState.resumed) {
      _handleAppResumed();
    } else if (lifecycleState == AppLifecycleState.paused) {
      _handleAppPaused();
    }
  }

  /// Persist timer state when app goes to background
  Future<void> _handleAppPaused() async {
    if (_isRestoringState) return;

    final currentState = state;

    // Only persist if timer is running
    if (currentState is TimerRunningState && _startTime != null) {
      final session = storage.TimerSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionType: _convertToStorageSessionType(currentState.sessionType),
        totalDuration: _totalDuration!,
        startTimestamp: _startTime!,
        currentState: storage.TimerState.running,
      );

      await _persistenceRepo.saveTimerSession(session);
    }
  }

  /// Recalculate remaining time when app is resumed
  Future<void> _handleAppResumed() async {
    if (_isRestoringState) return;

    final currentState = state;

    // Only recalculate if timer was running
    if (currentState is! TimerRunningState) return;

    // Try to get session from BackgroundTimerService
    final session = await _backgroundTimerService.getCurrentSession();

    if (session != null) {
      final remaining = _backgroundTimerService.calculateRemainingTime(session);

      if (remaining.isNegative || remaining.inSeconds <= 0) {
        // Timer completed while in background
        _onComplete();
      } else {
        // Update remaining time based on background calculation
        _startTime = session.startTimestamp;
        _remainingDuration = session.totalDuration;
        _totalDuration = session.totalDuration;

        final progress = remaining.inSeconds / _totalDuration!.inSeconds;

        emit(
          TimerRunningState(
            remaining: remaining,
            progress: progress.clamp(0.0, 1.0),
            sessionType: _currentSessionType,
          ),
        );
      }
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
