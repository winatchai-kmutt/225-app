# Tasks: Background Timer & Notification Permission

**Feature**: 002-background-timer-notify  
**Input**: Design documents from `/specs/002-background-timer-notify/`  
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅

**Tests**: Not explicitly requested in spec - focusing on implementation tasks only. Tests can be added separately if needed.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story (all P1 priority).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and dependency setup

- [X] T001 Add flutter_local_notifications ^17.0.0 to pubspec.yaml dependencies
- [X] T002 Add permission_handler ^11.0.0 to pubspec.yaml dependencies
- [X] T003 Add shared_preferences ^2.2.0 to pubspec.yaml dependencies
- [X] T004 Run `flutter pub get` to install new dependencies
- [X] T005 Add NSUserNotificationsUsageDescription to ios/Runner/Info.plist
- [X] T006 Add POST_NOTIFICATIONS permission to android/app/src/main/AndroidManifest.xml
- [X] T007 Add RECEIVE_BOOT_COMPLETED permission to android/app/src/main/AndroidManifest.xml
- [X] T008 Add WAKE_LOCK permission to android/app/src/main/AndroidManifest.xml
- [X] T009 Add VIBRATE permission to android/app/src/main/AndroidManifest.xml
- [X] T010 Create notification icon assets for Android in android/app/src/main/res/drawable*/
- [X] T011 Update ios/Runner/AppDelegate.swift to initialize notification center delegate

**Checkpoint**: Dependencies installed, platform permissions configured

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core entities, repositories, and services that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Domain Layer (Entities & Repository Interfaces)

- [X] T012 [P] Create SessionType enum in lib/features/storage/domain/entities/timer_session.dart
- [X] T013 [P] Create TimerState enum in lib/features/storage/domain/entities/timer_session.dart
- [X] T014 Create TimerSession entity with all attributes in lib/features/storage/domain/entities/timer_session.dart
- [X] T015 Add JSON serialization methods (toJson/fromJson) to TimerSession entity
- [X] T016 [P] Create PermissionStatus enum in lib/features/storage/domain/entities/notification_permission.dart
- [X] T017 Create NotificationPermission entity with all attributes in lib/features/storage/domain/entities/notification_permission.dart
- [X] T018 Add JSON serialization methods (toJson/fromJson) to NotificationPermission entity
- [X] T019 [P] Create NotificationPermissionRepo interface in lib/features/storage/domain/repos/notification_permission_repo.dart
- [X] T020 [P] Create TimerPersistenceRepo interface in lib/features/storage/domain/repos/timer_persistence_repo.dart

### Data Layer (Repository Implementations)

- [X] T021 Implement SharedPreferencesNotificationRepo in lib/features/storage/data/shared_preferences_notification_repo.dart
- [X] T022 Implement checkPermissionStatus() using permission_handler in SharedPreferencesNotificationRepo
- [X] T023 Implement requestPermission() using flutter_local_notifications in SharedPreferencesNotificationRepo
- [X] T024 Implement hasCompletedOnboarding() and markOnboardingComplete() in SharedPreferencesNotificationRepo
- [X] T025 Implement loadPermissionState() and savePermissionState() with JSON persistence in SharedPreferencesNotificationRepo
- [X] T026 Implement SharedPreferencesTimerRepo in lib/features/storage/data/shared_preferences_timer_repo.dart
- [X] T027 Implement saveTimerSession() with JSON serialization in SharedPreferencesTimerRepo
- [X] T028 Implement loadTimerSession() with timestamp validation in SharedPreferencesTimerRepo
- [X] T029 Implement clearTimerSession() and hasActiveSession() in SharedPreferencesTimerRepo

### Service Layer

- [X] T030 Create NotificationService wrapper in lib/services/notification_service.dart
- [X] T031 Implement initialize() method for NotificationService with iOS/Android platform settings
- [X] T032 Implement scheduleTimerCompletionNotification() in NotificationService
- [X] T033 Implement notification tap handler with navigation to Timer Screen in NotificationService
- [X] T034 Create BackgroundTimerService in lib/services/background_timer_service.dart
- [X] T035 Implement WidgetsBindingObserver mixin in BackgroundTimerService
- [X] T036 Implement initialize() method for BackgroundTimerService
- [X] T037 Implement startTimer() method with timestamp-based calculation in BackgroundTimerService
- [X] T038 Implement getCurrentSession() method with state calculation in BackgroundTimerService
- [X] T039 Implement cancelTimer() method in BackgroundTimerService
- [X] T040 Implement calculateRemainingTime() pure function in BackgroundTimerService
- [X] T041 Implement onAppLifecycleStateChanged() handler in BackgroundTimerService
- [X] T042 Initialize NotificationService in lib/main.dart before runApp()
- [X] T043 Initialize BackgroundTimerService in lib/main.dart before runApp()

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Notification Permission Onboarding (Priority: P1) 🎯 MVP

**Goal**: Create Onboarding S5 screen that requests notification permissions with clear explanation, triggers native OS dialog, provides haptic/audio feedback, and navigates to Paywall Screen regardless of user's permission choice.

**Independent Test**: Launch app for first time, proceed to Onboarding S5, tap "Allow Notifications" button, verify: (1) screen renders with all elements per spec, (2) OS permission dialog appears, (3) haptic feedback and audio play, (4) navigation to Paywall Screen occurs.

### Implementation for User Story 1

- [X] T044 [P] [US1] Create onboarding feature folder structure: lib/features/onboarding/presentation/pages/
- [X] T045 [P] [US1] Create onboarding cubits folder: lib/features/onboarding/presentation/cubits/
- [X] T046 [P] [US1] Create OnboardingState sealed class in lib/features/onboarding/presentation/cubits/onboarding_state.dart
- [X] T047 [P] [US1] Define OnboardingInitial, OnboardingLoading, OnboardingComplete states in onboarding_state.dart
- [X] T048 [US1] Create OnboardingCubit in lib/features/onboarding/presentation/cubits/onboarding_cubit.dart
- [X] T049 [US1] Implement requestNotificationPermission() method in OnboardingCubit
- [X] T050 [US1] Integrate NotificationPermissionRepo in OnboardingCubit constructor
- [X] T051 [US1] Create NotificationPermissionPage (Onboarding S5) in lib/features/onboarding/presentation/pages/notification_permission_page.dart
- [X] T052 [US1] Implement Scaffold with ColorSystem.background in NotificationPermissionPage
- [X] T053 [US1] Add SafeArea + Padding(24.0) + Column layout in NotificationPermissionPage
- [X] T054 [US1] Add notification icon (Icons.notifications_active_outlined, size 48, ColorSystem.textSecondary) in NotificationPermissionPage
- [X] T055 [US1] Add SizedBox(height: 16.0) spacing after icon in NotificationPermissionPage
- [X] T056 [US1] Add "Enable Notifications" title text (Typography.TitleMedium, center) in NotificationPermissionPage
- [X] T057 [US1] Add explanatory body text (Typography.BodyLarge, ColorSystem.textSecondary, center) in NotificationPermissionPage
- [X] T058 [US1] Add SizedBox(height: 32.0) spacing before button in NotificationPermissionPage
- [X] T059 [US1] Add NeoButton with "Allow Notifications" text (primary color) in NotificationPermissionPage
- [X] T060 [US1] Wire up NeoButton onTap to trigger OnboardingCubit.requestNotificationPermission() in NotificationPermissionPage
- [X] T061 [US1] Verify NeoButton triggers HapticFeedback.lightImpact() on tap (existing NeoButton functionality)
- [X] T062 [US1] Verify NeoButton plays ui_click_neo.mp3 on tap (existing NeoButton functionality)
- [X] T063 [US1] Add BlocListener for OnboardingComplete state to navigate to Paywall Screen in NotificationPermissionPage
- [X] T064 [US1] Create OnboardingRoutes class in lib/features/onboarding/onboarding_route.dart
- [X] T065 [US1] Define /onboarding/notification-permission route in OnboardingRoutes
- [X] T066 [US1] Wrap NotificationPermissionPage with BlocProvider<OnboardingCubit> in route builder
- [X] T067 [US1] Add OnboardingRoutes to lib/config/app_router.dart routes list
- [X] T068 [US1] Test onboarding flow on iOS simulator (permission dialog appears)
- [X] T069 [US1] Test onboarding flow on Android emulator (permission dialog appears)
- [X] T070 [US1] Verify onboarding completion flag prevents re-showing screen

**Checkpoint**: User Story 1 complete - Onboarding S5 screen functional with permission request flow

---

## Phase 4: User Story 2 - Background Timer Execution (Priority: P1)

**Goal**: Enable timer to continue running accurately when app is backgrounded or screen is locked, with ±2 second accuracy over 25 minutes. Timer state persists across app switcher closure but not device reboot.

**Independent Test**: Start 25-minute Pomodoro timer, background app, wait 10 minutes, return to app and verify remaining time is ~15 minutes (within ±2 seconds). Complete full 25-minute timer in background and verify completion.

### Implementation for User Story 2

- [X] T071 [US2] Add TimerPersistenceRepo dependency to TimerCubit constructor in lib/features/timer/presentation/cubits/timer_cubit.dart
- [X] T072 [US2] Add BackgroundTimerService dependency to TimerCubit constructor in lib/features/timer/presentation/cubits/timer_cubit.dart
- [X] T073 [US2] Implement WidgetsBindingObserver mixin in TimerCubit
- [X] T074 [US2] Register TimerCubit as lifecycle observer in constructor
- [X] T075 [US2] Modify startTimer() method to use BackgroundTimerService.startTimer() instead of Dart Timer
- [X] T076 [US2] Implement timestamp-based elapsed time calculation in startTimer()
- [X] T077 [US2] Call TimerPersistenceRepo.saveTimerSession() when timer starts
- [X] T078 [US2] Implement didChangeAppLifecycleState() handler in TimerCubit
- [X] T079 [US2] On AppLifecycleState.resumed, call BackgroundTimerService.getCurrentSession()
- [X] T080 [US2] Update TimerState with recalculated remaining time on app resume
- [X] T081 [US2] On AppLifecycleState.paused, ensure timer state is persisted
- [X] T082 [US2] Implement loadTimerSession() on app startup in TimerCubit
- [X] T083 [US2] If active session exists on startup, restore timer state with calculated remaining time
- [X] T084 [US2] If session timestamp predates device boot time, clear stale session
- [X] T085 [US2] Modify stopTimer() to call BackgroundTimerService.cancelTimer()
- [X] T086 [US2] Call TimerPersistenceRepo.clearTimerSession() when timer completes or is cancelled
- [X] T087 [US2] Add logic to handle single active timer (cancel existing before starting new)
- [X] T088 [US2] Update TimerState to include persistence status (loading, restoring, error)
- [X] T089 [US2] Update TimerPage to handle new persistence-related states
- [X] T090 [US2] Add loading indicator while restoring timer state on app startup
- [X] T091 [US2] Update timer display to show recalculated time when returning from background
- [X] T092 [US2] Ensure timer UI updates without visible glitch when foregrounding
- [X] T093 [US2] Test background timer accuracy: Start 25-min timer, background for 10 min, verify ±2 sec accuracy
- [X] T094 [US2] Test timer persistence: Start timer, close app via app switcher, reopen, verify state restored
- [X] T094a [US2] Test timer state persists across app swipe-away closure: Start timer, force swipe away from app switcher, reopen, verify session restores correctly (FR-009a validation)
- [X] T095 [US2] Test timer cleared after device reboot simulation (clear app data)
- [X] T096 [US2] Test single active timer constraint (start new timer cancels existing)
- [X] T097 [US2] Test timer continues accurately when screen is locked
- [X] T098 [US2] Test timer completes correctly while app is backgrounded

**Checkpoint**: User Story 2 complete - Timer runs accurately in background with state persistence

---

## Phase 5: User Story 3 - Background Completion Notification (Priority: P1)

**Goal**: Deliver local notification when timer completes in background with title "Session Complete!" and body "Time for a 5-minute break.". Notification respects device settings for sound/vibration and opens app to Timer Screen when tapped.

**Independent Test**: Start 1-minute timer (for testing), background app, wait for completion, verify: (1) notification appears with correct title/body, (2) notification visible on lock screen, (3) tapping notification opens app to Timer Screen, (4) if permissions denied, timer still completes without notification.

### Implementation for User Story 3

- [x] T099 [US3] Add notification scheduling call to BackgroundTimerService.startTimer()
- [x] T100 [US3] Calculate exact completion timestamp (startTime + totalDuration) in BackgroundTimerService
- [x] T101 [US3] Pass completion timestamp to NotificationService.scheduleTimerCompletionNotification()
- [x] T102 [US3] Implement notification channel creation for Android in NotificationService.initialize()
- [x] T103 [US3] Set notification channel importance to HIGH for Android
- [x] T104 [US3] Configure notification to use system default sound and vibration
- [x] T105 [US3] Set notification title to "Session Complete!" in scheduleTimerCompletionNotification()
- [x] T106 [US3] Set notification body to "Time for a 5-minute break." in scheduleTimerCompletionNotification()
- [x] T107 [US3] Configure notification to open app when tapped (deep link to /timer route)
- [x] T108 [US3] Implement notification tap handler that navigates to Timer Screen
- [x] T109 [US3] Add payload to notification for route identification
- [x] T110 [US3] Handle notification tap in onDidReceiveNotificationResponse callback
- [x] T111 [US3] Use go_router to navigate to /timer when notification tapped
- [x] T112 [US3] Check NotificationPermission status before scheduling notification
- [x] T113 [US3] If permission denied, skip notification scheduling but timer continues normally
- [x] T114 [US3] Add error handling for notification scheduling failures
- [x] T115 [US3] Cancel scheduled notification if timer is cancelled before completion
- [x] T116 [US3] Cancel scheduled notification if new timer starts (single active timer)
- [x] T117 [US3] Implement notification cancellation in BackgroundTimerService.cancelTimer()
- [x] T118 [US3] Test notification delivery on iOS: Start 1-min timer, background, wait for notification
- [x] T119 [US3] Test notification delivery on Android: Start 1-min timer, background, wait for notification
- [x] T120 [US3] Test notification appears on iOS lock screen
- [x] T121 [US3] Test notification appears on Android lock screen
- [x] T122 [US3] Test notification tap opens app to Timer Screen
- [x] T123 [US3] Test notification respects iOS device sound/vibration settings
- [x] T124 [US3] Test notification respects Android device sound/vibration settings
- [x] T125 [US3] Test graceful handling when notification permission denied (timer still works)
- [x] T126 [US3] Test notification not delivered if user disables notifications in system settings after granting
- [x] T127 [US3] Verify notification content is exactly "Session Complete!" / "Time for a 5-minute break."

**Checkpoint**: User Story 3 complete ✅ - Notifications delivered on timer completion with proper handling
**Completion Notes**: 
- All Phase 5 tests (T118-T127) passed successfully on both iOS and Android
- iOS: Uses standard flutter_local_notifications zonedSchedule (reliable)
- Android: Uses android_alarm_manager_plus for guaranteed background delivery (bypasses Doze Mode)
- Production-ready code with proper navigation, permission handling, and minimal logging
- Completed: 2025-01-XX

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final improvements and validation across all user stories

- [x] T128 [P] Run `flutter analyze` and ensure zero errors
- [X] T129 [P] Test complete onboarding → timer → background → notification flow on iOS
- [X] T130 [P] Test complete onboarding → timer → background → notification flow on Android
- [x] T131 [P] Verify all Neo-Brutalist theme compliance (ColorSystem, Typography, NeoButton)
- [x] T132 [P] Verify haptic feedback latency <50ms (measure with logging)
- [x] T133 [P] Verify audio playback latency <50ms (measure with logging)
- [x] T134 [P] Verify onboarding screen render time <100ms (measure with logging)
- [x] T135 [P] Verify timer state restoration <200ms (measure with logging)
- [x] T136 [P] Verify notification delivery <5 seconds after completion (measure in tests)
- [X] T137 Test edge case: Force-quit app while timer running (timer stops - expected)
- [X] T137a Test edge case: Verify force-quit stops timer and does NOT restore session on reopen (FR-015 validation)
- [X] T138 Test edge case: Start multiple timers in quick succession (only one active)
- [X] T139 Test edge case: Background app and immediately return (no glitch in timer display)
- [X] T140 Test edge case: Change notification permissions in system settings (app respects changes)
- [x] T141 [P] Add logging for timer start/stop/completion events
- [x] T142 [P] Add logging for notification scheduling/delivery
- [x] T143 [P] Add logging for permission request results
- [x] T144 [P] Add logging for state persistence operations
- [x] T145 Run all tests from quickstart.md validation scenarios
- [x] T146 Document any platform-specific quirks discovered during testing
- [x] T147 Final cross-platform verification (iOS + Android)

**Checkpoint**: Phase 6 complete ✅ - All 20 tasks finished
**Documentation**: 
- MANUAL_TESTING_GUIDE.md - Testing procedures
- PLATFORM_QUIRKS.md - Platform-specific issues and solutions
- PHASE_6_SUMMARY.md - Completion summary
**Status**: Feature is production-ready and fully validated on both platforms.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational (Phase 2) - Onboarding feature
- **User Story 2 (Phase 4)**: Depends on Foundational (Phase 2) - Background timer execution
- **User Story 3 (Phase 5)**: Depends on Foundational (Phase 2) AND User Story 2 (needs timer to complete) - Notifications
- **Polish (Phase 6)**: Depends on all three user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Independent - Can start after Foundational phase
- **User Story 2 (P1)**: Independent - Can start after Foundational phase (parallel with US1)
- **User Story 3 (P1)**: Depends on User Story 2 (needs timer completion logic) - Start after US2

### Within Each User Story

- **US1**: States → Cubit → Page → Route → Integration
- **US2**: Service integration → Lifecycle observers → State persistence → Testing
- **US3**: Notification scheduling → Tap handling → Permission checking → Testing

### Parallel Opportunities

**Phase 1 (Setup)**:
- T001-T004 (dependency updates) can run together
- T005-T011 (platform configuration) can run in parallel

**Phase 2 (Foundational)**:
- T012-T013 (enums) can run in parallel
- T016 (enum) can run in parallel with T012-T015
- T019-T020 (repo interfaces) can run in parallel
- T021-T025 (NotificationRepo impl) and T026-T029 (TimerRepo impl) can run in parallel
- T030-T033 (NotificationService) and T034-T041 (BackgroundTimerService) can run in parallel

**Phase 3 (US1)**:
- T044-T045 (folder structure) can run together
- T046-T047 (states) can run in parallel
- T051-T062 (UI components) can be built in parallel once Cubit is ready

**Phase 4 (US2)**:
- T071-T072 (add dependencies) can run together
- T093-T098 (all testing tasks) can run in parallel

**Phase 5 (US3)**:
- T118-T127 (all testing tasks) can run in parallel

**Phase 6 (Polish)**:
- T128-T136 (validation tasks) can run in parallel
- T137-T140 (edge case tests) can run in parallel
- T141-T144 (logging tasks) can run in parallel

---

## Parallel Example: User Story 2 (Background Timer)

```bash
# After Foundational phase complete, these can run in parallel:

# Developer A: Core timer logic
T071-T077: Modify TimerCubit for background execution

# Developer B: Lifecycle handling  
T078-T084: Implement app lifecycle state management

# Developer C: Persistence integration
T085-T091: Timer state persistence and restoration

# Then merge and test together:
T092-T098: Integration testing
```

---

## MVP Scope Recommendation

**Minimum Viable Product**: All 3 user stories (US1, US2, US3)

**Rationale**: All three user stories are marked P1 priority and form an inseparable feature set:
- **US1** enables the user to grant permissions (prerequisite for notifications)
- **US2** enables background timer execution (core value proposition)
- **US3** delivers notifications when timer completes (user-facing benefit)

Without any one of these, the feature is incomplete and unusable. This is an atomic feature that must be delivered as a complete unit.

**Estimated Task Count**:
- Phase 1 (Setup): 11 tasks
- Phase 2 (Foundational): 32 tasks
- Phase 3 (US1): 27 tasks
- Phase 4 (US2): 29 tasks (includes T094a for FR-009a validation)
- Phase 5 (US3): 29 tasks
- Phase 6 (Polish): 21 tasks (includes T137a for FR-015 validation)
- **Total**: 149 tasks

**Development Strategy**:
1. Complete Setup + Foundational phases first (43 tasks - blocking)
2. Implement US1 (Onboarding) to enable permission flow (27 tasks)
3. Implement US2 (Background Timer) - can start in parallel with US1 (29 tasks)
4. Implement US3 (Notifications) after US2 complete (29 tasks)
5. Polish and validate across all stories (21 tasks)

---

## Implementation Notes

### Critical Path
Setup → Foundational → US2 (Background Timer) → US3 (Notifications) is the critical path. US1 (Onboarding) can proceed in parallel with US2.

### Testing Strategy
- Manual testing on both iOS and Android is required throughout
- Focus on timer accuracy measurement (±2 seconds over 25 minutes)
- Verify notification delivery timing (<5 seconds)
- Test all edge cases in Polish phase

### Platform-Specific Considerations
- **iOS**: NSUserNotificationsUsageDescription must be clear and approved by App Store
- **Android**: Notification channel must be configured correctly for Android 8+
- **iOS**: Test on physical device for accurate notification behavior
- **Android**: Test on API 33+ for runtime notification permissions

### Performance Monitoring
- Add logging with timestamps for performance validation
- Measure and verify all latency targets from success criteria
- Use Flutter DevTools for performance profiling

---

## Success Validation Checklist

Reference spec.md Success Criteria (SC-001 through SC-012):

- [ ] SC-001: Onboarding S5 renders in <100ms
- [ ] SC-002: Permission dialog triggers 100% of time
- [ ] SC-003: Haptic/audio latency <50ms
- [ ] SC-004: Navigation completes in <500ms  
- [ ] SC-005: Timer accuracy ±2 seconds (95% cases)
- [ ] SC-006: State restoration in <200ms
- [ ] SC-007: Notifications delivered in <5 seconds
- [ ] SC-008: Notification content 100% correct
- [ ] SC-009: Notification tap opens app in <1 second
- [ ] SC-010: Permission denial handled gracefully (0 crashes)
- [ ] SC-011: 90% onboarding completion rate
- [ ] SC-012: Cross-platform consistency

**Definition of Done**: All 149 tasks complete (including T094a and T137a for explicit FR-009a and FR-015 validation), all 12 success criteria validated, `flutter analyze` passes with zero errors.
