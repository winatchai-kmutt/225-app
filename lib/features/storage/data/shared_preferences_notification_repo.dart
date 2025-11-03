import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/notification_permission.dart';
import '../domain/repos/notification_permission_repo.dart';

/// SharedPreferences implementation of NotificationPermissionRepo.
/// 
/// Handles notification permission management using permission_handler and
/// flutter_local_notifications, with state persistence via SharedPreferences.
class SharedPreferencesNotificationRepo implements NotificationPermissionRepo {
  static const String _keyPermissionState = 'notification_permission_state';
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final Future<SharedPreferences> _prefs;

  SharedPreferencesNotificationRepo({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
    Future<SharedPreferences>? prefs,
  })  : _notificationsPlugin = notificationsPlugin ?? FlutterLocalNotificationsPlugin(),
        _prefs = prefs ?? SharedPreferences.getInstance();

  @override
  Future<PermissionStatus> checkPermissionStatus() async {
    // First, try to load saved permission state
    final savedPermission = await loadPermissionState();
    if (savedPermission != null && savedPermission.lastRequestedAt != null) {
      // Use saved state if we have it
      return savedPermission.status;
    }
    
    // For Android - can check directly without triggering dialog
    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final granted = await androidImpl.areNotificationsEnabled();
      final status = granted == true ? PermissionStatus.granted : PermissionStatus.denied;
      return status;
    }
    
    // For iOS - use permission_handler as fallback
    final status = await ph.Permission.notification.status;
    final result = _convertPermissionStatus(status);
    return result;
  }

  @override
  Future<PermissionStatus> requestPermission() async {
    // Request permission using flutter_local_notifications
    // This will trigger the native OS dialog
    final granted = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ?? await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Determine status from the result
    final status = granted == true 
        ? PermissionStatus.granted 
        : PermissionStatus.denied;
    
    // Save the permission state with timestamp
    final permission = NotificationPermission(
      status: status,
      lastRequestedAt: DateTime.now(),
      onboardingCompleted: await hasCompletedOnboarding(),
    );
    await savePermissionState(permission);
    
    return status;
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  @override
  Future<void> markOnboardingComplete() async {
    final prefs = await _prefs;
    await prefs.setBool(_keyOnboardingCompleted, true);
  }

  @override
  Future<NotificationPermission?> loadPermissionState() async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_keyPermissionState);
    
    if (jsonString == null) {
      return null;
    }
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return NotificationPermission.fromJson(json);
    } catch (e) {
      // If JSON is invalid, return null (graceful degradation)
      return null;
    }
  }

  @override
  Future<void> savePermissionState(NotificationPermission permission) async {
    final prefs = await _prefs;
    final jsonString = jsonEncode(permission.toJson());
    await prefs.setString(_keyPermissionState, jsonString);
  }

  /// Convert permission_handler status to our domain enum
  PermissionStatus _convertPermissionStatus(ph.PermissionStatus status) {
    switch (status) {
      case ph.PermissionStatus.granted:
        return PermissionStatus.granted;
      case ph.PermissionStatus.denied:
        return PermissionStatus.denied;
      case ph.PermissionStatus.restricted:
        return PermissionStatus.denied;
      case ph.PermissionStatus.limited:
        return PermissionStatus.provisional;
      case ph.PermissionStatus.provisional:
        return PermissionStatus.provisional;
      case ph.PermissionStatus.permanentlyDenied:
        return PermissionStatus.denied;
    }
  }
}
