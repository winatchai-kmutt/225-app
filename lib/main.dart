import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'app.dart';
import 'config/app_router.dart';
import 'features/common/utils/audio_service.dart';
import 'services/notification_service.dart';
import 'services/background_timer_service.dart';
import 'services/alarm_notification_service.dart';
import 'features/storage/data/shared_preferences_timer_repo.dart';
import 'features/storage/data/shared_preferences_notification_repo.dart';

// Global service instances
late final NotificationService notificationService;
late final BackgroundTimerService backgroundTimerService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone database
  tz.initializeTimeZones();
  
  // Set timezone to Bangkok
  try {
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));
  } catch (e) {
    // Fallback to UTC if timezone setting fails
  }
  
  // Initialize notification service
  notificationService = NotificationService();
  await notificationService.initialize();
  
  // Initialize alarm manager for Android
  try {
    await AlarmNotificationService.initialize();
  } catch (e) {
    // AlarmManager only works on Android
  }
  
  // Set up notification tap handler to navigate to timer screen
  notificationService.onNotificationTap = (payload) {
    if (payload != null) {
      // Use the global router to navigate
      AppRouter.router.go(payload);
    }
  };
  
  // Initialize background timer service with permission checking
  final timerRepo = SharedPreferencesTimerRepo();
  final permissionRepo = SharedPreferencesNotificationRepo();
  backgroundTimerService = BackgroundTimerService(
    persistenceRepo: timerRepo,
    notificationService: notificationService,
    permissionRepo: permissionRepo,
  );
  await backgroundTimerService.initialize();
  
  // Check if user has completed onboarding and set flag
  AppRouter.hasCompletedOnboarding = await permissionRepo.hasCompletedOnboarding();
  
  // Preload audio files in background (non-blocking)
  // Audio will be ready within ~100ms, app starts immediately
  AudioService.instance.preload();
  
  runApp(const App());
}
