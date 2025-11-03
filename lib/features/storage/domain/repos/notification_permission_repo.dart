import '../entities/notification_permission.dart';

/// Repository interface for managing notification permission state and onboarding completion.
/// 
/// Implementations must handle platform-specific permission APIs and persist onboarding state.
abstract class NotificationPermissionRepo {
  /// Check the current notification permission status from the OS.
  ///
  /// Returns the actual OS permission state, not just cached values.
  /// Call on app foreground to detect if user changed settings.
  Future<PermissionStatus> checkPermissionStatus();

  /// Request notification permissions from the OS.
  ///
  /// Triggers the native iOS/Android permission dialog.
  /// Returns the resulting permission status after user responds.
  ///
  /// First call shows OS dialog, subsequent calls return cached status.
  Future<PermissionStatus> requestPermission();

  /// Check if the user has completed the onboarding flow (seen Onboarding S5).
  ///
  /// Returns true if user has seen Onboarding S5 and responded to permission dialog.
  Future<bool> hasCompletedOnboarding();

  /// Mark the onboarding flow as complete.
  ///
  /// Called after user responds to the OS permission dialog on Onboarding S5.
  /// This is a write-once operation (flag never reset to false).
  Future<void> markOnboardingComplete();

  /// Load the complete NotificationPermission entity from storage.
  ///
  /// Returns null if no permission state exists yet (first app launch).
  Future<NotificationPermission?> loadPermissionState();

  /// Save the complete NotificationPermission entity to storage.
  ///
  /// Persists all permission state including status, lastRequestedAt, and onboardingCompleted.
  Future<void> savePermissionState(NotificationPermission permission);
}
