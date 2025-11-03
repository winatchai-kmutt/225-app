# Quickstart Guide: Background Timer & Notification Permission

**Feature**: 002-background-timer-notify  
**Date**: November 3, 2025  
**For**: Developers implementing this feature

## Overview

This guide helps you set up your development environment and understand the implementation flow for the background timer and notification permission feature.

---

## Prerequisites

### Required Tools
- **Flutter**: 3.x (SDK version ^3.9.2)
- **Dart**: 3.9.2+
- **Xcode**: 15+ (for iOS development)
- **Android Studio**: Latest (for Android development)
- **iOS Simulator**: iOS 15+ target
- **Android Emulator**: API level 33+ (Android 13+) for notification testing

### Existing Project Dependencies
- `flutter_bloc`: 8.1.6
- `go_router`: 14.6.1
- `equatable`: 2.0.7
- `audioplayers`: 6.0.0

---

## Step 1: Add New Dependencies

Add the following to `pubspec.yaml`:

```yaml
dependencies:
  # ... existing dependencies ...
  flutter_local_notifications: ^17.0.0
  permission_handler: ^11.0.0
  shared_preferences: ^2.2.0
```

Run:
```bash
flutter pub get
```

---

## Step 2: iOS Platform Configuration

### Info.plist Changes

Add notification permission description to `ios/Runner/Info.plist`:

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>We need notifications to alert you when timer sessions complete.</string>
```

### Initialize Notifications in AppDelegate

Modify `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import flutter_local_notifications  // Add this import

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Add notification initialization
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## Step 3: Android Platform Configuration

### AndroidManifest.xml Changes

Add permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    
    <application ...>
        <!-- Your existing application config -->
    </application>
</manifest>
```

### Add Notification Icon

Create notification icon assets in `android/app/src/main/res/`:

```
res/
├── drawable/
│   └── notification_icon.png  (24x24dp, white transparent PNG)
├── drawable-hdpi/
│   └── notification_icon.png  (36x36px)
├── drawable-mdpi/
│   └── notification_icon.png  (24x24px)
├── drawable-xhdpi/
│   └── notification_icon.png  (48x48px)
├── drawable-xxhdpi/
│   └── notification_icon.png  (72x72px)
└── drawable-xxxhdpi/
    └── notification_icon.png  (96x96px)
```

---

## Step 4: Initialize Notification Service

Create `lib/services/notification_service.dart`:

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('notification_icon');
    
    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings(
      requestSoundPermission: false,  // We'll request explicitly
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );
    
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Navigate to Timer Screen (implemented in Phase 2)
  }

  static Future<void> scheduleTimerCompletionNotification({
    required DateTime scheduledTime,
  }) async {
    // Implementation in Phase 2
  }
}
```

Call `NotificationService.initialize()` in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  runApp(const MyApp());
}
```

---

## Step 5: Project Structure Setup

Create the following folder structure:

```bash
# Create onboarding feature
mkdir -p lib/features/onboarding/presentation/pages
mkdir -p lib/features/onboarding/presentation/cubits

# Create storage entities and repos
mkdir -p lib/features/storage/domain/entities
mkdir -p lib/features/storage/domain/repos
mkdir -p lib/features/storage/data

# Create services
mkdir -p lib/services

# Create test structure
mkdir -p test/features/onboarding/presentation/pages
mkdir -p test/features/onboarding/presentation/cubits
mkdir -p test/features/timer/integration
mkdir -p test/services
```

---

## Step 6: Verify Setup

### Test iOS Notifications

```bash
flutter run -d "iPhone 15 Pro"  # Or your simulator
```

Check that:
- App launches without errors
- No permission errors in console
- iOS simulator shows app in notification settings

### Test Android Notifications

```bash
flutter run -d emulator-5554  # Or your emulator
```

Check that:
- App launches without errors
- Android notification permissions are recognized
- Notification icon appears correctly

---

## Step 7: Development Workflow

### Recommended Implementation Order

1. **Phase 2.1**: Entities (`TimerSession`, `NotificationPermission`)
2. **Phase 2.2**: Repository interfaces
3. **Phase 2.3**: Repository implementations (SharedPreferences)
4. **Phase 2.4**: Background timer service
5. **Phase 2.5**: Onboarding S5 screen + cubit
6. **Phase 2.6**: Extend existing Timer feature with background logic
7. **Phase 2.7**: Platform-specific testing (iOS + Android)

### Testing Strategy

For each component:
1. Write unit tests first (TDD approach)
2. Implement component
3. Run `flutter analyze` (must pass with zero errors)
4. Run unit tests: `flutter test`
5. Manual testing on both iOS and Android

### Running Tests

```bash
# All tests
flutter test

# Specific feature tests
flutter test test/features/onboarding/

# Integration tests (requires simulator/emulator)
flutter test integration_test/
```

---

## Step 8: Common Issues & Solutions

### Issue: iOS Notification Permission Not Working

**Symptom**: Permission dialog never appears on iOS  
**Solution**: 
1. Check Info.plist has `NSUserNotificationsUsageDescription`
2. Uninstall app from simulator and reinstall
3. Reset simulator: Device > Erase All Content and Settings

### Issue: Android Notification Not Appearing

**Symptom**: Notification scheduled but never appears  
**Solution**:
1. Check AndroidManifest.xml has `POST_NOTIFICATIONS` permission
2. Verify notification icon exists in all drawable folders
3. Check Android version (API 33+ requires runtime permission)
4. Verify notification channel is created (Android 8+)

### Issue: Timer Inaccurate After Backgrounding

**Symptom**: Timer shows wrong time after returning from background  
**Solution**:
1. Ensure timestamp-based calculation (not Dart Timer)
2. Verify `WidgetsBindingObserver` is registered
3. Check `didChangeAppLifecycleState` is called on resume
4. Add logging to track timestamp differences

### Issue: State Not Persisting

**Symptom**: Timer state lost when app is closed  
**Solution**:
1. Verify SharedPreferences initialization
2. Check JSON serialization/deserialization
3. Confirm repository methods are called
4. Add logging to persistence layer

---

## Step 9: Debugging Tools

### Enable Logging

Add to `main.dart`:

```dart
void main() async {
  // Enable Flutter framework debugging
  debugPrintBeginFrameBanner = false;
  debugPrintEndFrameBanner = false;
  
  // Enable notification plugin logging
  NotificationService.enableDebugLogging();
  
  runApp(const MyApp());
}
```

### Test Notification Scheduling

Use short timers during development:

```dart
// In TimerCubit for testing
void startTestTimer() {
  startTimer(const Duration(seconds: 10));  // Instead of 25 minutes
}
```

### Monitor App Lifecycle

Add lifecycle logging:

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  print('App lifecycle: $state');
  // Your implementation
}
```

---

## Step 10: Code Style & Standards

### Follow Constitution Rules

- **1_appendix.md**: Clean Architecture (presentation, domain, data layers)
- **2_theme.md**: Neo-Brutalist theme (ColorSystem, Typography, NeoButton)
- **constitution.md**: Quality gates (`flutter analyze` must pass)

### Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables**: `camelCase`
- **Constants**: `camelCase` or `SCREAMING_SNAKE_CASE` for compile-time constants

### Required Documentation

Each file must include:
- File-level doc comment explaining purpose
- Public API doc comments (methods, classes)
- Complex logic inline comments

---

## Next Steps

1. ✅ Setup complete (this guide)
2. → Review `data-model.md` (understand entities)
3. → Review `contracts/` (understand repository interfaces)
4. → Run `/speckit.tasks` to generate task breakdown
5. → Start implementation following task order

---

## Resources

- [flutter_local_notifications docs](https://pub.dev/packages/flutter_local_notifications)
- [permission_handler docs](https://pub.dev/packages/permission_handler)
- [shared_preferences docs](https://pub.dev/packages/shared_preferences)
- [Flutter lifecycle docs](https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver-class.html)
- [iOS notification setup](https://developer.apple.com/documentation/usernotifications)
- [Android notification setup](https://developer.android.com/develop/ui/views/notifications)

---

## Support

If you encounter issues not covered in this guide:
1. Check error logs (`flutter run --verbose`)
2. Review specification (`spec.md`)
3. Check contracts (`contracts/`)
4. Review research decisions (`research.md`)
