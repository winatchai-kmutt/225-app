/// Contract: TimerPersistenceRepo
///
/// Repository interface for persisting and loading active timer session state.
/// Enables timer continuation across app backgrounding, closure, and restoration.
///
/// Location (implementation): lib/features/storage/domain/repos/timer_persistence_repo.dart

abstract class TimerPersistenceRepo {
  /// Save the current active timer session to persistent storage.
  ///
  /// Parameters:
  /// - session: Complete TimerSession entity including timestamps and state
  ///
  /// Behavior:
  /// - Overwrites any existing active session (only one timer can be active)
  /// - Serializes to JSON and stores in SharedPreferences
  /// - Should complete within 50ms to avoid blocking UI
  ///
  /// Called when:
  /// - User starts a new timer
  /// - Timer state changes (e.g., running → completed)
  ///
  /// Side effects:
  /// - Writes to SharedPreferences key 'timer_active_session'
  Future<void> saveTimerSession(TimerSession session);

  /// Load the active timer session from persistent storage.
  ///
  /// Returns:
  /// - TimerSession if an active session exists
  /// - null if no active session (user hasn't started a timer)
  ///
  /// Behavior:
  /// - Reads from SharedPreferences and deserializes JSON
  /// - Validates timestamps (detects stale sessions from device reboot)
  /// - Should complete within 100ms to meet SC-006 restoration target
  ///
  /// Called when:
  /// - App launches (restore last session)
  /// - App returns from background (check if timer still valid)
  ///
  /// Validation:
  /// - If startTimestamp is older than device boot time, return null
  /// - If session state is 'completed' or 'cancelled', return null
  Future<TimerSession?> loadTimerSession();

  /// Clear the active timer session from persistent storage.
  ///
  /// Behavior:
  /// - Removes 'timer_active_session' key from SharedPreferences
  /// - Should complete within 50ms
  ///
  /// Called when:
  /// - Timer completes successfully
  /// - User cancels the timer
  /// - App detects invalid/stale session on startup
  ///
  /// Idempotent: Safe to call multiple times (no error if no session exists)
  Future<void> clearTimerSession();

  /// Check if an active timer session exists in storage.
  ///
  /// Returns:
  /// - true if a valid active session exists
  /// - false if no session or session is stale/invalid
  ///
  /// This is a lightweight check (doesn't deserialize full entity).
  /// Useful for quick app startup decisions.
  Future<bool> hasActiveSession();
}

/// Contract: Expected behavior mapping to functional requirements
///
/// FR-007: saveTimerSession() called when app backgrounds (preserves state)
/// FR-008: loadTimerSession() validates timestamps to ensure ±2 second accuracy
/// FR-009: saveTimerSession()/loadTimerSession() enable state preservation
/// FR-009a: State persists across app switcher closure (not cleared on app termination)
/// FR-015: clearTimerSession() called when user force-quits (via app lifecycle detection)
/// FR-016: saveTimerSession() overwrites previous session (single active timer)
///
/// Edge Cases:
/// - Device reboot: loadTimerSession() returns null (timestamp validation fails)
/// - Invalid JSON: loadTimerSession() returns null (graceful degradation)
/// - Missing key: loadTimerSession() returns null (no error thrown)
