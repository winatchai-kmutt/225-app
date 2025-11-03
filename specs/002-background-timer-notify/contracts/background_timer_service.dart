/// Contract: BackgroundTimerService
///
/// Service interface for managing background timer execution and notification scheduling.
/// Coordinates timer lifecycle with notification delivery and app lifecycle state.
///
/// Location (implementation): lib/services/background_timer_service.dart

abstract class BackgroundTimerService {
  /// Initialize the service and register app lifecycle observers.
  ///
  /// Behavior:
  /// - Registers WidgetsBindingObserver for lifecycle changes
  /// - Checks for active timer session on startup
  /// - Schedules pending notifications if timer is running
  ///
  /// Called:
  /// - Once during app initialization in main.dart
  ///
  /// Side effects:
  /// - Adds lifecycle observer to WidgetsBinding
  /// - May trigger notification scheduling if active session exists
  Future<void> initialize();

  /// Start a new timer session with the given duration.
  ///
  /// Parameters:
  /// - duration: Total duration for the timer (e.g., Duration(minutes: 25))
  /// - sessionType: Type of session (pomodoro, shortBreak, longBreak)
  ///
  /// Behavior:
  /// - Creates TimerSession entity with current timestamp
  /// - Persists session via TimerPersistenceRepo
  /// - Schedules local notification for completion time
  /// - Returns immediately (non-blocking)
  ///
  /// Preconditions:
  /// - If a timer is already running, it will be cancelled first
  ///
  /// Returns:
  /// - TimerSession: The newly created session
  ///
  /// Side effects:
  /// - Cancels any existing timer
  /// - Writes to SharedPreferences
  /// - Schedules notification at startTime + duration
  Future<TimerSession> startTimer({
    required Duration duration,
    required SessionType sessionType,
  });

  /// Get the current timer session state.
  ///
  /// Returns:
  /// - TimerSession if a timer is active or recently completed
  /// - null if no timer session exists
  ///
  /// Behavior:
  /// - Loads from persistence layer
  /// - Calculates current remaining time based on timestamps
  /// - Updates state to 'completed' if elapsed >= total duration
  ///
  /// This method is called:
  /// - On app foreground (to update UI)
  /// - Periodically by TimerCubit (to keep UI in sync)
  Future<TimerSession?> getCurrentSession();

  /// Cancel the currently active timer.
  ///
  /// Behavior:
  /// - Updates session state to 'cancelled'
  /// - Clears persisted session
  /// - Cancels scheduled notification
  /// - Idempotent (safe to call if no active timer)
  ///
  /// Called when:
  /// - User explicitly stops/cancels timer
  /// - New timer started (implicitly cancels previous)
  ///
  /// Side effects:
  /// - Removes SharedPreferences entry
  /// - Cancels pending notification
  Future<void> cancelTimer();

  /// Calculate remaining time for the current timer session.
  ///
  /// Parameters:
  /// - session: The active TimerSession
  ///
  /// Returns:
  /// - Duration: Remaining time (may be negative if completed)
  ///
  /// Calculation:
  /// - elapsed = now - startTimestamp
  /// - remaining = totalDuration - elapsed
  ///
  /// This is a pure calculation (no side effects, no async)
  Duration calculateRemainingTime(TimerSession session);

  /// Handle app lifecycle state changes.
  ///
  /// Parameters:
  /// - state: New app lifecycle state (resumed, paused, inactive, detached)
  ///
  /// Behavior:
  /// - On resumed: Recalculate timer state, update UI
  /// - On paused: Ensure persistence is up to date
  /// - On detached: No action (timer continues via timestamp)
  ///
  /// Called automatically by WidgetsBindingObserver.
  void onAppLifecycleStateChanged(AppLifecycleState state);

  /// Dispose resources and remove lifecycle observer.
  ///
  /// Called when service is no longer needed (rare, typically on app termination).
  void dispose();
}

/// Contract: Expected behavior mapping to functional requirements
///
/// FR-007: onAppLifecycleStateChanged() handles backgrounding (timer continues)
/// FR-008: calculateRemainingTime() ensures ±2 second accuracy via timestamp calculation
/// FR-009: getCurrentSession() loads persisted state on app restore
/// FR-010: startTimer() schedules notification for completion time
/// FR-011: Notification includes title "Session Complete!" and body "Time for a 5-minute break."
/// FR-015: cancelTimer() called when app is force-quit (detected via lifecycle)
/// FR-016: startTimer() cancels existing timer before creating new one
///
/// Performance Targets:
/// - SC-006: getCurrentSession() completes within 200ms (UI update latency)
/// - SC-007: Notification delivered within 5 seconds of timer completion
