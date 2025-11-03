import '../entities/timer_session.dart';

/// Repository interface for persisting and loading active timer session state.
/// 
/// Enables timer continuation across app backgrounding, closure, and restoration.
abstract class TimerPersistenceRepo {
  /// Save the current active timer session to persistent storage.
  ///
  /// Overwrites any existing active session (only one timer can be active).
  /// Called when user starts a new timer or when timer state changes.
  Future<void> saveTimerSession(TimerSession session);

  /// Load the active timer session from persistent storage.
  ///
  /// Returns null if no active session exists or if session is stale/invalid.
  /// Validates timestamps to detect sessions from before device reboot.
  Future<TimerSession?> loadTimerSession();

  /// Clear the active timer session from persistent storage.
  ///
  /// Called when timer completes, is cancelled, or becomes invalid.
  /// Idempotent - safe to call multiple times.
  Future<void> clearTimerSession();

  /// Check if an active timer session exists in storage.
  ///
  /// Lightweight check that doesn't deserialize full entity.
  Future<bool> hasActiveSession();
}
