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

  const AppConfig({
    required this.useFirebaseEmulator,
    required this.firestoreProjectId,
    required this.enableDebugLogs,
  });

  /// Production configuration
  static const AppConfig production = AppConfig(
    useFirebaseEmulator: false,
    firestoreProjectId: 'a255-app-prod',
    enableDebugLogs: false,
  );

  /// Development configuration
  static const AppConfig development = AppConfig(
    useFirebaseEmulator: true,
    firestoreProjectId: 'a255-app-dev',
    enableDebugLogs: true,
  );

  /// Current active configuration
  static const AppConfig current = AppConfig.development;
}
