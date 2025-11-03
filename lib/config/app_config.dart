/// Global application configuration
///
/// Manages environment-specific settings and feature flags.
class AppConfig {
  /// Whether to use Firebase emulator for local development
  final bool useFirebaseEmulator;

  /// Firebase project identifier
  final String firestoreProjectId;

  /// Enable verbose debug logging
  final bool enableDebugLogs;

  /// Enable debug timer durations for testing (1 minute instead of 25)
  final bool useDebugTimerDurations;

  const AppConfig({
    required this.useFirebaseEmulator,
    required this.firestoreProjectId,
    required this.enableDebugLogs,
    required this.useDebugTimerDurations,
  });

  /// Production configuration
  static const AppConfig production = AppConfig(
    useFirebaseEmulator: false,
    firestoreProjectId: 'a255-app-prod',
    enableDebugLogs: false,
    useDebugTimerDurations: false,
  );

  /// Development configuration
  static const AppConfig development = AppConfig(
    useFirebaseEmulator: true,
    firestoreProjectId: 'a255-app-dev',
    enableDebugLogs: true,
    useDebugTimerDurations: true, // Changed to false for production-like timers
  );

  /// Current active configuration
  static const AppConfig current = AppConfig.development;

  // ==================== Timer Durations ====================
  
  /// Work session duration (Pomodoro)
  static Duration get workDuration => 
    current.useDebugTimerDurations
      ? const Duration(minutes: 1)   // Debug: 1 minute for quick testing
      : const Duration(minutes: 25); // Production: 25 minutes
  
  /// Short break duration
  static Duration get shortBreakDuration => 
    current.useDebugTimerDurations
      ? const Duration(seconds: 30)  // Debug: 30 seconds
      : const Duration(minutes: 5);  // Production: 5 minutes
  
  /// Long break duration
  static Duration get longBreakDuration => 
    current.useDebugTimerDurations
      ? const Duration(seconds: 45)  // Debug: 45 seconds
      : const Duration(minutes: 15); // Production: 15 minutes
}
