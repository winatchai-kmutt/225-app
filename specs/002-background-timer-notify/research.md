# Research: Background Timer & Notification Permission

**Date**: November 3, 2025  
**Feature**: 002-background-timer-notify  
**Phase**: 0 (Research & Technology Selection)

## Overview

This document captures research findings and technology decisions for implementing background timer execution and notification permission management in Flutter.

## Research Areas

### 1. Flutter Background Execution

**Question**: How to maintain timer accuracy when app is backgrounded in Flutter?

**Research Findings**:
- **Flutter Isolates**: Dart isolates can run in background but are terminated when app is suspended
- **Platform Channels**: Native iOS/Android timers are more reliable for background execution
- **WidgetsBindingObserver**: Can detect app lifecycle changes (resumed, paused, inactive, detached)
- **Timestamp-based calculation**: Most reliable approach - store start timestamp, calculate elapsed on resume

**Decision**: Use **timestamp-based timer calculation** with `WidgetsBindingObserver`

**Rationale**:
- Eliminates need for continuous background execution (battery efficient)
- Works reliably across both iOS and Android
- Simple to implement and test
- Maintains accuracy within ±2 seconds over 25 minutes
- Complies with mobile OS background restrictions

**Alternatives Considered**:
- ❌ **workmanager** package: Overkill for this use case, designed for periodic background tasks
- ❌ **flutter_background_service**: Requires persistent foreground service, poor battery life
- ❌ **Dart Timer in isolate**: Unreliable when app is suspended by OS

**Implementation Approach**:
1. Store timer start timestamp when user starts timer
2. Use `WidgetsBindingObserver` to detect when app resumes from background
3. Calculate elapsed time = `DateTime.now().difference(startTimestamp)`
4. Update UI with calculated remaining time
5. Schedule local notification at exact completion timestamp

---

### 2. Local Notifications

**Question**: Which Flutter package for local notification delivery?

**Research Findings**:
- **flutter_local_notifications**: Most popular (11k+ stars), mature, cross-platform
- **awesome_notifications**: Newer, feature-rich but less battle-tested
- **firebase_messaging**: Requires Firebase, overkill for local-only notifications

**Decision**: Use **flutter_local_notifications** (^17.0.0)

**Rationale**:
- Industry standard for local notifications in Flutter
- Excellent iOS and Android support with consistent API
- Supports scheduled notifications (critical for timer completion)
- Handles notification permissions on both platforms
- Strong community support and documentation
- Respects device notification settings automatically

**Alternatives Considered**:
- ❌ **awesome_notifications**: Less mature, smaller community
- ❌ **firebase_messaging**: Requires Firebase setup, unnecessary for local notifications

**Implementation Approach**:
1. Initialize plugin in `main.dart` with iOS/Android settings
2. Request permissions through plugin's permission API
3. Schedule notification at timer completion timestamp
4. Configure notification to open app on tap (deep linking to Timer Screen)
5. Notification content: Title "Session Complete!", body "Time for a 5-minute break."

---

### 3. Notification Permission Management

**Question**: How to request and track notification permissions in Flutter?

**Research Findings**:
- **permission_handler**: General permission management (location, camera, notifications, etc.)
- **flutter_local_notifications**: Has built-in permission request methods
- iOS requires Info.plist configuration for permission descriptions
- Android requires AndroidManifest.xml permission declarations

**Decision**: Use **permission_handler** (^11.0.0) + **flutter_local_notifications** permissions API

**Rationale**:
- `permission_handler` provides unified API for checking permission status across platforms
- `flutter_local_notifications` has native permission request UI trigger
- Combination provides both status checking and request triggering
- Supports all permission states: notDetermined, granted, denied, provisional (iOS)
- Handles iOS/Android platform differences transparently

**Alternatives Considered**:
- ❌ **flutter_local_notifications only**: Can request but status checking is less robust
- ❌ **Platform channels only**: Reinventing the wheel, more maintenance burden

**Implementation Approach**:
1. Check permission status using `permission_handler` when app launches
2. Show Onboarding S5 screen if status is `notDetermined`
3. Trigger native permission dialog using `flutter_local_notifications.requestPermissions()`
4. Store onboarding completion flag in SharedPreferences (never show again)
5. Handle all permission states gracefully (granted, denied, provisional)

---

### 4. Timer State Persistence

**Question**: How to persist timer state across app closures?

**Research Findings**:
- **shared_preferences**: Simple key-value storage, synchronous API, suitable for small data
- **hive**: Fast NoSQL database, requires schema, more complex setup
- **sqflite**: SQLite database, overkill for simple timer state
- Timer state is small: ~200 bytes (timestamps, duration, session type, state enum)

**Decision**: Use **shared_preferences** (^2.2.0)

**Rationale**:
- Perfect for small, flat data structures (timer state fits this profile)
- Synchronous write/read operations (fast state restoration)
- Built-in JSON serialization support
- No schema migration concerns
- Already commonly used in Flutter apps
- Fast enough for <200ms restoration target

**Alternatives Considered**:
- ❌ **hive**: Overkill for ~200 bytes of data, requires type adapters
- ❌ **sqflite**: SQL database unnecessary for simple key-value persistence

**Implementation Approach**:
1. Create `TimerPersistenceRepo` interface in `storage/domain/repos/`
2. Implement `SharedPreferencesTimerRepo` in `storage/data/`
3. Serialize `TimerSession` entity to JSON map
4. Store under key `timer_active_session`
5. Load on app startup, check if timer should still be running
6. Clear state on device reboot (detect via comparing stored timestamp vs boot time)

---

### 5. Haptic Feedback & Audio

**Question**: How to implement haptic feedback and button sounds?

**Research Findings**:
- **Haptics**: Built-in `HapticFeedback` class in Flutter framework (no package needed)
- **Audio**: `audioplayers` package already in project (6.0.0)
- Audio file: `assets/audio/ui_click_neo.mp3` already exists
- `HapticFeedback.lightImpact()` is appropriate for button taps

**Decision**: Use **built-in HapticFeedback** + existing **audioplayers** package

**Rationale**:
- No new dependencies required
- `HapticFeedback` is part of Flutter Services library (zero overhead)
- `audioplayers` already set up and working in project
- Audio asset already exists and tested

**Implementation Approach**:
1. In `NeoButton` widget (already exists), add `onTapDown` callback
2. Call `HapticFeedback.lightImpact()` on tap down
3. Use existing `AudioPlayer` instance to play `ui_click_neo.mp3`
4. Ensure both fire within <50ms of tap detection (measured in tests)

---

### 6. Platform-Specific Configuration

**Question**: What iOS/Android configuration is required for notifications and background execution?

**Research Findings**:

**iOS (Info.plist)**:
- No special background modes needed for timestamp-based timers
- Notification permission description required: `NSUserNotificationsUsageDescription`
- Notification categories and actions supported but not needed (no action buttons per clarification)

**Android (AndroidManifest.xml)**:
- Permission: `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` (Android 13+)
- Permission: `<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>` (to clear state on reboot)
- Notification icons required in `res/drawable/` (notification_icon.png)
- No foreground service needed (timestamp-based approach)

**Decision**: Minimal platform configuration per above requirements

**Rationale**:
- Timestamp-based approach avoids complex background mode requirements
- Only notification permissions needed, not background execution permissions
- Simpler configuration = fewer edge cases and better reliability

**Implementation Steps**:
1. Add iOS Info.plist key: `NSUserNotificationsUsageDescription` with value "We need notifications to alert you when timer sessions complete."
2. Add Android permissions to AndroidManifest.xml
3. Add notification icon assets for Android
4. Configure notification channels in Android (required for Android 8+)
5. Test permission flows on both platforms

---

## Technology Stack Summary

| Category | Technology | Version | Rationale |
|----------|-----------|---------|-----------|
| **Background Timer** | Timestamp-based calculation + WidgetsBindingObserver | Built-in | Battery efficient, reliable, simple |
| **Local Notifications** | flutter_local_notifications | ^17.0.0 | Industry standard, mature, cross-platform |
| **Permission Management** | permission_handler | ^11.0.0 | Unified API, robust status checking |
| **State Persistence** | shared_preferences | ^2.2.0 | Perfect for small key-value data |
| **Haptic Feedback** | HapticFeedback (Flutter) | Built-in | Zero overhead, native support |
| **Audio Playback** | audioplayers | 6.0.0 (existing) | Already in project, proven to work |
| **State Management** | flutter_bloc | 8.1.6 (existing) | Consistent with project architecture |
| **Navigation** | go_router | 14.6.1 (existing) | Consistent with project routing |

---

## Best Practices & Patterns

### Background Timer Pattern
```dart
// Pseudo-code for timestamp-based timer
class TimerCubit extends Cubit<TimerState> with WidgetsBindingObserver {
  DateTime? _startTimestamp;
  Duration _totalDuration;
  
  void startTimer(Duration duration) {
    _startTimestamp = DateTime.now();
    _totalDuration = duration;
    _scheduleNotification(_startTimestamp.add(duration));
    emit(TimerRunning(remaining: duration));
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _startTimestamp != null) {
      final elapsed = DateTime.now().difference(_startTimestamp!);
      final remaining = _totalDuration - elapsed;
      
      if (remaining.isNegative) {
        emit(TimerCompleted());
      } else {
        emit(TimerRunning(remaining: remaining));
      }
    }
  }
}
```

### Notification Permission Pattern
```dart
// Pseudo-code for permission flow
class OnboardingCubit extends Cubit<OnboardingState> {
  final NotificationPermissionRepo _permissionRepo;
  
  Future<void> requestNotificationPermission() async {
    final status = await _permissionRepo.requestPermission();
    await _permissionRepo.markOnboardingComplete();
    
    // Navigate regardless of permission result (per spec)
    emit(OnboardingComplete(permissionGranted: status.isGranted));
  }
}
```

### State Persistence Pattern
```dart
// Pseudo-code for persistence
class SharedPreferencesTimerRepo implements TimerPersistenceRepo {
  final SharedPreferences _prefs;
  
  @override
  Future<void> saveTimerSession(TimerSession session) async {
    final json = session.toJson();
    await _prefs.setString('timer_active_session', jsonEncode(json));
  }
  
  @override
  Future<TimerSession?> loadTimerSession() async {
    final jsonString = _prefs.getString('timer_active_session');
    if (jsonString == null) return null;
    
    final json = jsonDecode(jsonString);
    return TimerSession.fromJson(json);
  }
}
```

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| iOS kills background timer | Low | High | Use timestamp calculation (not continuous execution) |
| Android battery optimization kills app | Medium | Medium | User education, timestamp-based approach minimizes impact |
| Notification permission denied | High | Low | Graceful handling, timer still works (per spec) |
| Timer drift over 25 minutes | Low | Medium | Timestamp calculation eliminates drift risk |
| State persistence failure | Low | Medium | Robust error handling, fallback to clean state |
| Cross-platform inconsistencies | Medium | Medium | Extensive testing on both iOS and Android |

---

## Next Steps (Phase 1)

1. ✅ Research complete
2. → Generate data-model.md (entity definitions)
3. → Generate contracts/ (repository interfaces)
4. → Generate quickstart.md (developer setup guide)
5. → Update agent context (.github/copilot-instructions.md)

---

## References

- [flutter_local_notifications documentation](https://pub.dev/packages/flutter_local_notifications)
- [permission_handler documentation](https://pub.dev/packages/permission_handler)
- [shared_preferences documentation](https://pub.dev/packages/shared_preferences)
- [Flutter WidgetsBindingObserver API](https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver-class.html)
- [iOS Notification Permission Best Practices](https://developer.apple.com/documentation/usernotifications)
- [Android Notification Best Practices](https://developer.android.com/develop/ui/views/notifications)
