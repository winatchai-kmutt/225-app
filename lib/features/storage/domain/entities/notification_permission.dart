import 'package:equatable/equatable.dart';

/// Current notification permission status
enum PermissionStatus {
  /// Permission has not been requested yet
  notDetermined,
  
  /// User granted notification permissions
  granted,
  
  /// User denied notification permissions
  denied,
  
  /// iOS only: provisional authorization granted
  provisional,
}

/// Represents the current notification permission status and onboarding state.
/// 
/// This entity tracks whether the user has granted notification permissions
/// and whether they have completed the onboarding flow.
class NotificationPermission extends Equatable {
  /// Current permission status
  final PermissionStatus status;
  
  /// When permission was last requested (null if never requested)
  final DateTime? lastRequestedAt;
  
  /// Whether user has seen Onboarding S5 screen
  final bool onboardingCompleted;

  const NotificationPermission({
    required this.status,
    this.lastRequestedAt,
    required this.onboardingCompleted,
  });

  /// Create a NotificationPermission from JSON
  factory NotificationPermission.fromJson(Map<String, dynamic> json) {
    return NotificationPermission(
      status: PermissionStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      lastRequestedAt: json['lastRequestedAt'] != null
          ? DateTime.parse(json['lastRequestedAt'] as String)
          : null,
      onboardingCompleted: json['onboardingCompleted'] as bool,
    );
  }

  /// Convert NotificationPermission to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'lastRequestedAt': lastRequestedAt?.toIso8601String(),
      'onboardingCompleted': onboardingCompleted,
    };
  }

  /// Create a copy with updated fields
  NotificationPermission copyWith({
    PermissionStatus? status,
    DateTime? lastRequestedAt,
    bool? onboardingCompleted,
  }) {
    return NotificationPermission(
      status: status ?? this.status,
      lastRequestedAt: lastRequestedAt ?? this.lastRequestedAt,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  @override
  List<Object?> get props => [status, lastRequestedAt, onboardingCompleted];
}
