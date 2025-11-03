/// Contract: NotificationPermissionRepo
///
/// Repository interface for managing notification permission state and onboarding completion.
/// Implementations must handle platform-specific permission APIs and persist onboarding state.
///
/// Location (implementation): lib/features/storage/domain/repos/notification_permission_repo.dart

abstract class NotificationPermissionRepo {
  /// Check the current notification permission status from the OS.
  ///
  /// Returns:
  /// - PermissionStatus.notDetermined: Permission not yet requested
  /// - PermissionStatus.granted: User granted permissions
  /// - PermissionStatus.denied: User denied permissions
  /// - PermissionStatus.provisional: iOS provisional auth (iOS only)
  ///
  /// This method queries the actual OS permission state, not just cached values.
  /// Call on app foreground to detect if user changed settings.
  Future<PermissionStatus> checkPermissionStatus();

  /// Request notification permissions from the OS.
  ///
  /// Triggers the native iOS/Android permission dialog.
  /// Returns the resulting permission status after user responds.
  ///
  /// Behavior:
  /// - First call: Shows OS permission dialog
  /// - Subsequent calls: Returns cached status (dialog not shown again by OS)
  ///
  /// Side effects:
  /// - Updates lastRequestedAt timestamp in persisted state
  /// - Caches result in SharedPreferences
  Future<PermissionStatus> requestPermission();

  /// Check if the user has completed the onboarding flow (seen Onboarding S5).
  ///
  /// Returns:
  /// - true: User has seen Onboarding S5 and responded to permission dialog
  /// - false: User has not yet seen Onboarding S5
  ///
  /// This flag is checked on app launch to determine whether to show onboarding screen.
  Future<bool> hasCompletedOnboarding();

  /// Mark the onboarding flow as complete.
  ///
  /// Called after user responds to the OS permission dialog on Onboarding S5.
  /// This is a write-once operation (flag never reset to false).
  ///
  /// Side effects:
  /// - Sets onboardingCompleted = true in SharedPreferences
  /// - Ensures Onboarding S5 is never shown again for this app installation
  Future<void> markOnboardingComplete();

  /// Load the complete NotificationPermission entity from storage.
  ///
  /// Returns:
  /// - NotificationPermission entity with current status and onboarding flag
  /// - null if no permission state exists yet (first app launch)
  ///
  /// Used by UI to determine whether to show onboarding and whether notifications will work.
  Future<NotificationPermission?> loadPermissionState();

  /// Save the complete NotificationPermission entity to storage.
  ///
  /// Persists all permission state including status, lastRequestedAt, and onboardingCompleted.
  /// Called after permission requests or status checks.
  Future<void> savePermissionState(NotificationPermission permission);
}

/// Contract: Expected behavior mapping to functional requirements
///
/// FR-002: requestPermission() triggers native OS dialog
/// FR-005: markOnboardingComplete() ensures navigation proceeds after dialog
/// FR-006: hasCompletedOnboarding() prevents showing Onboarding S5 twice
/// FR-012: checkPermissionStatus() determines if notifications should be delivered
/// FR-013: All methods handle denied status gracefully (no errors thrown)
