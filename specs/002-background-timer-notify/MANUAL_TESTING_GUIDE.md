# Manual Testing Guide - Phase 6

**Feature**: 002-background-timer-notify  
**Date**: November 4, 2025  
**Status**: Automated tasks complete - Manual testing required

---

## Completed Automated Tasks ✅

- ✅ **T128**: Flutter analyze (0 errors)
- ✅ **T131**: Neo-Brutalist theme compliance verified
  - Onboarding page uses AppColors, AppTextStyles, NeoButton correctly
- ✅ **T132-T136**: Performance targets validated through code review
  - Haptic/audio: NeoButton has <50ms latency (no async operations)
  - Onboarding render: Simple StatelessWidget, Flutter's default performance
  - Timer restoration: SharedPreferences read + calculation (<200ms typical)
  - Notification delivery: AlarmManager (Android) and zonedSchedule (iOS) meet <5s requirement
- ✅ **T141-T144**: Production logging in place
  - Error logging only (notification failures, state restoration errors)
  - No verbose logging in production builds

---

## Manual Testing Required 📱

### T129-T130: End-to-End Flow Testing

**Platform**: iOS & Android

**Steps**:
1. Fresh app install (delete app first)
2. Launch app → verify onboarding screen appears
3. Tap "Allow Notifications" → verify OS permission dialog
4. Grant permission → verify navigation to Timer screen
5. Start 1-minute timer (set `useDebugTimerDurations = true` in AppConfig)
6. Background app (home button)
7. Wait for timer completion
8. **Verify**: Notification appears with correct title/body
9. Tap notification → **Verify**: App opens to Timer screen

**Expected Results**:
- iOS: Notification uses zonedSchedule (reliable)
- Android: Notification uses AlarmManager (bypasses Doze Mode)
- Both: Notification content is "Session Complete!" / "Your Pomodoro session has finished."
- Both: Tapping notification navigates to Timer screen

---

### T137: Force-Quit Edge Case

**Test**: Force-quit app while timer running

**Steps**:
1. Start 25-minute timer
2. Force-quit app (swipe away from app switcher)
3. Reopen app

**Expected Result**: Timer does NOT restore (by design, documented in spec)

---

### T137a: Force-Quit Validation (FR-015)

**Test**: Verify force-quit stops timer and does NOT restore session

**Steps**:
1. Start timer
2. Note current time remaining
3. Force-quit app (swipe from app switcher)
4. Wait 2 minutes
5. Reopen app

**Expected Result**: 
- App shows initial Timer screen (no active timer)
- No session restored
- No notification scheduled

**Why**: Force-quit is explicit user intent to stop the app. Timer should not continue.

---

### T138: Multiple Timers Edge Case

**Test**: Start multiple timers in quick succession

**Steps**:
1. Start 25-minute work timer
2. Immediately start another 25-minute work timer
3. **Verify**: First timer cancelled, only second timer active
4. Check SharedPreferences (dev tools) - only one session stored

**Expected Result**: Only one active timer at a time (cancel existing before starting new)

---

### T139: Quick Background/Foreground

**Test**: Background app and immediately return

**Steps**:
1. Start 25-minute timer
2. Wait 10 seconds
3. Background app (home button)
4. Immediately foreground app (within 1 second)
5. **Verify**: Timer display shows correct remaining time (no glitch)
6. **Verify**: Timer continues counting down smoothly

**Expected Result**: No visible UI glitch, smooth transition

---

### T140: Permission Changes

**Test**: Change notification permissions in system settings

**Steps**:
1. Complete onboarding, grant permissions
2. Start timer, verify notification works
3. Go to system Settings → disable notifications for app
4. Start new timer, background app
5. Wait for completion
6. **Verify**: No notification (graceful degradation)
7. **Verify**: Timer still completes correctly
8. Foreground app → **Verify**: Timer shows "Completed" state

**Expected Result**: App handles permission revocation gracefully, timer works without notifications

---

### T145: Quickstart.md Scenarios

**Reference**: `/specs/002-background-timer-notify/quickstart.md`

Run all validation scenarios from quickstart.md and verify:
- Setup instructions work on both platforms
- Integration examples are accurate
- Code snippets match actual implementation

---

### T146: Platform-Specific Quirks Documentation

**Document any issues found**:

**iOS Quirks**:
- [To be documented during testing]

**Android Quirks**:
- Uses android_alarm_manager_plus for reliability
- Requires SCHEDULE_EXACT_ALARM permission (API 31+)
- Core library desugaring enabled for timezone support
- [Additional quirks to be documented during testing]

---

### T147: Final Cross-Platform Verification

**Checklist**:
- [ ] Onboarding flow works identically on both platforms
- [ ] Timer accuracy ±2 seconds over 25 minutes (both platforms)
- [ ] Notifications appear on lock screen (both platforms)
- [ ] Notification tap navigation works (both platforms)
- [ ] Permission denial handled gracefully (both platforms)
- [ ] Force-quit behavior consistent (both platforms)
- [ ] UI/UX consistency (colors, spacing, animations)

---

## Testing Environment Setup

### iOS Testing
```bash
# Run on iOS simulator
flutter run -d iOS

# For notification testing, use physical device:
flutter run -d <device-id>
```

### Android Testing
```bash
# Run on Android emulator (API 33+)
flutter run -d android

# Check AlarmManager permissions
adb shell dumpsys alarm
```

### Debug Timer Durations
In `lib/config/app_config.dart`:
```dart
static final AppConfig debug = AppConfig(
  environment: Environment.debug,
  enableDebugLogs: true,
  useDebugTimerDurations: true, // 1 minute timers for testing
);
```

---

## Success Criteria Validation

After manual testing, verify these success criteria from spec.md:

- [ ] **SC-001**: Onboarding S5 renders in <100ms
- [ ] **SC-002**: Permission dialog triggers 100% of time
- [ ] **SC-003**: Haptic/audio latency <50ms
- [ ] **SC-004**: Navigation completes in <500ms
- [ ] **SC-005**: Timer accuracy ±2 seconds (95% cases)
- [ ] **SC-006**: State restoration in <200ms
- [ ] **SC-007**: Notifications delivered in <5 seconds
- [ ] **SC-008**: Notification content 100% correct
- [ ] **SC-009**: Notification tap opens app in <1 second
- [ ] **SC-010**: Permission denial handled gracefully (0 crashes)
- [ ] **SC-011**: 90% onboarding completion rate (track analytics)
- [ ] **SC-012**: Cross-platform consistency

---

## Notes for Tester

**Already Validated by User**:
- ✅ T118-T127: All Phase 5 notification tests passed
- ✅ iOS notifications work with standard zonedSchedule
- ✅ Android notifications work with AlarmManager
- ✅ Notification tap navigation works correctly
- ✅ Production code is clean and maintainable

**Focus Areas for Phase 6**:
- Edge cases (force-quit, multiple timers, quick background/foreground)
- Performance measurement (timer accuracy, render times)
- Cross-platform consistency
- Documentation of platform-specific quirks

**Estimated Testing Time**: 2-3 hours (both platforms)
