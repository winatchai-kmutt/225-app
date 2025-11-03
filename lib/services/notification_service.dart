import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service for managing local notifications.
/// 
/// Handles notification initialization, scheduling, and tap handling
/// for timer completion notifications.
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  
  // Callback for navigation when notification is tapped
  void Function(String?)? onNotificationTap;

  NotificationService({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin = notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  /// Initialize the notification service with platform-specific settings.
  /// 
  /// Should be called once during app initialization in main.dart.
  Future<void> initialize() async {
    // Initialize timezone for scheduled notifications
    tz.initializeTimeZones();
    
    // Android initialization settings - use app_icon instead of custom icon
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // We'll request permissions explicitly
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    // Initialize with tap callback
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
    
    // Create Android notification channel for timer completion
    await _createAndroidNotificationChannel();
  }

  /// Create notification channel for Android (required for Android 8+)
  Future<void> _createAndroidNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'timer_completion',
      'Timer Completion',
      description: 'Notifications for Pomodoro timer completion',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      showBadge: true,
    );

    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImpl != null) {
      await androidImpl.createNotificationChannel(channel);
    }
  }

  /// Schedule a timer completion notification.
  /// 
  /// Shows notification at [completionTime] with configurable title and body.
  Future<void> scheduleTimerCompletionNotification({
    required Duration duration, // Changed to duration-based scheduling
    String title = 'Session Complete!',
    String body = 'Your Pomodoro session has finished.',
  }) async {
    const notificationId = 0;

    try {
      // Get Bangkok timezone directly instead of relying on tz.local
      final location = tz.getLocation('Asia/Bangkok');
      final scheduledDate = tz.TZDateTime.now(location).add(duration);

      // Android-specific notification details with wake-up capabilities
      const androidDetails = AndroidNotificationDetails(
        'timer_completion', // channel ID
        'Timer Completion', // channel name
        channelDescription: 'Notifications for Pomodoro timer completion',
        importance: Importance.max, // Changed from high to max
        priority: Priority.max, // Changed from high to max
        playSound: true,
        enableVibration: true,
        enableLights: true,
        // Critical settings for scheduled notifications
        ongoing: false,
        autoCancel: true,
        // Wake up screen when notification arrives
        visibility: NotificationVisibility.public,
        // Show on lock screen
        showWhen: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      );

      // Try scheduling with exact alarm
      try {
        // Check if we can use exact alarms (Android 12+)
        final androidImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        
        bool canScheduleExactAlarms = true;
        if (androidImpl != null) {
          canScheduleExactAlarms = await androidImpl.canScheduleExactNotifications() ?? false;
          
          if (!canScheduleExactAlarms) {
            await androidImpl.requestExactAlarmsPermission();
            canScheduleExactAlarms = await androidImpl.canScheduleExactNotifications() ?? false;
          }
        }
        
        // Use exact or inexact mode based on permission
        final scheduleMode = canScheduleExactAlarms 
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle;
        
        await _notificationsPlugin.zonedSchedule(
          notificationId,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e) {
        // Fallback to inexact mode if exact scheduling fails
        await _notificationsPlugin.zonedSchedule(
          notificationId,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  /// Cancel a scheduled notification
  Future<void> cancelNotification(int notificationId) async {
    await _notificationsPlugin.cancel(notificationId);
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Test notification - show immediately (for debugging)
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'timer_completion',
      'Timer Completion',
      channelDescription: 'Notifications for Pomodoro timer completion',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // Show immediate notification
    await _notificationsPlugin.show(
      999, // Test notification ID
      'Test Notification',
      'Notifications are working correctly!',
      notificationDetails,
      payload: '/timer',
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(NotificationResponse response) {
    // Call the navigation callback if set
    onNotificationTap?.call(response.payload);
  }
}
