import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service that uses Android Alarm Manager to trigger notifications
/// This is more reliable than zonedSchedule for background notifications
@pragma('vm:entry-point')
class AlarmNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize the alarm manager
  @pragma('vm:entry-point')
  static Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }

  /// Schedule a notification using alarm manager
  @pragma('vm:entry-point')
  static Future<void> scheduleNotification({
    required Duration delay,
    String title = 'Session Complete!',
    String body = 'Your Pomodoro session has finished.',
  }) async {
    // Cancel any existing alarms
    await AndroidAlarmManager.cancel(0);
    
    // Schedule alarm to fire after delay
    final scheduledTime = DateTime.now().add(delay);
    
    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      0, // alarm ID
      _showNotificationCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: false,
      params: {'title': title, 'body': body},
    );
  }

  /// Callback function that runs when alarm fires
  /// This must be a top-level function or static method
  @pragma('vm:entry-point')
  static Future<void> _showNotificationCallback(
    int id,
    Map<String, dynamic>? params,
  ) async {
    final title = params?['title'] as String? ?? 'Session Complete!';
    final body = params?['body'] as String? ?? 'Your Pomodoro session has finished.';
    
    // Initialize notifications plugin
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
    
    // Create notification channel first (required for Android 8+)
    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImpl != null) {
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
      
      await androidImpl.createNotificationChannel(channel);
    }
    
    // Show notification
    const androidDetails = AndroidNotificationDetails(
      'timer_completion',
      'Timer Completion',
      channelDescription: 'Notifications for Pomodoro timer completion',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      visibility: NotificationVisibility.public,
      showWhen: true,
    );
    
    const notificationDetails = NotificationDetails(android: androidDetails);
    
    await _notificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  /// Cancel scheduled notification
  @pragma('vm:entry-point')
  static Future<void> cancel() async {
    await AndroidAlarmManager.cancel(0);
  }
}
