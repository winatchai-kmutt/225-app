# Implementation Plan: Background Timer & Notification Permission

**Branch**: `002-background-timer-notify` | **Date**: November 3, 2025 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-background-timer-notify/spec.md`

**Note**: This plan is filled in by the `/speckit.plan` command following the workflow defined in `.github/prompts/speckit.plan.prompt.md`.

## Summary

This feature implements background timer execution and notification permission management for the a255 Pomodoro timer app. The primary requirements are:

1. **Notification Permission Onboarding** (US1): Add Onboarding S5 screen to request notification permissions with clear explanation, native OS dialog integration, and automatic navigation to Paywall Screen
2. **Background Timer Execution** (US2): Maintain accurate timer countdown when app is backgrounded, locked, or user switches to another app, using timestamp-based calculation for ±2 second accuracy over 25 minutes
3. **Background Completion Notification** (US3): Deliver local notifications when timer completes in background, with title "Session Complete!" and body "Time for a 5-minute break.", respecting device notification settings

**Technical Approach**: Use timestamp-based timer calculation (not continuous background execution) with `WidgetsBindingObserver` for lifecycle tracking, `flutter_local_notifications` for notification delivery, `permission_handler` for permission management, and `shared_preferences` for timer state persistence across app closures.

## Technical Context

**Language/Version**: Dart 3.9.2 / Flutter 3.x  
**Primary Dependencies**: 
- **Existing**: flutter_bloc 8.1.6 (state management), go_router 14.6.1 (navigation), equatable 2.0.7 (value semantics), audioplayers 6.0.0 (audio playback)
- **New**: flutter_local_notifications ^17.0.0 (local notification delivery), permission_handler ^11.0.0 (notification permission management), shared_preferences ^2.2.0 (timer state persistence)

**Storage**: SharedPreferences (local key-value storage for timer session state and notification permission state, ~350 bytes total)  
**Testing**: flutter_test (unit/widget tests), integration_test (background flow testing)  
**Target Platform**: iOS 15+ and Android API 33+ (Android 13)  
**Project Type**: Mobile (Flutter) - follows Clean Architecture with presentation/domain/data layer separation  
**Performance Goals**: 
- Timer accuracy: ±2 seconds over 25-minute period when backgrounded
- UI render: <100ms for Timer Screen updates
- Haptic/audio latency: <50ms from tap detection
- State restoration: <200ms when returning from background

**Constraints**: 
- Only one active timer at a time (starting new timer cancels previous)
- No continuous background execution (use timestamp-based calculation)
- Notification delivery only when permissions granted (graceful degradation)
- Timer state persists across app switcher closure but NOT device reboot
- Force-quit stops timer (expected behavior, documented)

**Scale/Scope**: 
- 3 user stories (US1: Onboarding, US2: Background Timer, US3: Notifications)
- 1 new feature module (`onboarding/`) with 1 screen (Notification Permission)
- 1 feature extension (`timer/`) with background execution and lifecycle handling
- 2 new entities (`TimerSession`, `NotificationPermission`)
- 3 new repositories (2 domain + 1 service)
- 18 functional requirements

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

This section verifies compliance with all governance rules:
- **constitution.md**: Spec-driven development, quality gates, governance procedures
- **1_appendix.md**: Flutter Clean Architecture, folder structure, layer separation
- **2_theme.md**: Neo-Brutalist design system, color tokens, typography, component patterns

### Principle 1: Spec-Driven Development (SDD)
**Status**: ✅ PASS

- Specification document created at `/specs/002-background-timer-notify/spec.md` with 3 user stories, 18 functional requirements, 12 success criteria
- Clarification session completed (3 Q&A pairs integrated)
- This implementation plan follows specification-first workflow
- All code changes will reference specification document

### Principle 2: Separation of Rules (CRITICAL)
**Status**: ✅ PASS

- This plan reads and adheres to all three rule files:
  - `constitution.md`: Meta-principles (this check)
  - `1_appendix.md`: Clean Architecture structure (see Principle 3)
  - `2_theme.md`: Neo-Brutalist theme (see Principle 4)
- Each rule file consulted independently
- No conflicts between rule files identified

### Principle 3: Strict Architecture Compliance
**Status**: ✅ PASS (with extensions)

**Compliance verification against `.specify/memory/1_appendix.md`:**

1. **Folder Structure**:
   - ✅ New `onboarding/` feature under `lib/features/` with `presentation/` layer
   - ✅ Extends existing `timer/` feature with lifecycle handling
   - ✅ New entities in `lib/features/storage/domain/entities/` (`timer_session.dart`, `notification_permission.dart`)
   - ✅ New repos in `lib/features/storage/domain/repos/` (interfaces) and `lib/features/storage/data/` (implementations)
   - ✅ Routing via `onboarding_route.dart` (no hardcoded paths)

2. **State Management** (`flutter_bloc` Cubit-only):
   - ✅ Separate `*_cubit.dart` and `*_state.dart` files required
   - ✅ Immutable states with `Equatable`
   - ✅ Cubits provided via `MultiBlocProvider` in `app.dart`
   - ✅ New: `OnboardingCubit` + `OnboardingState`
   - ✅ Extends: `TimerCubit` with lifecycle persistence logic

3. **Navigation** (`go_router`):
   - ✅ All path strings owned by `config/app_router.dart`
   - ✅ Feature route files return `GoRoute` classes with injected paths
   - ✅ New: `OnboardingRoute` class in `onboarding_route.dart`
   - ✅ Update: `app_router.dart` to include `/onboarding/notification-permission` path

4. **Data Layer** (Clean Architecture):
   - ✅ Domain interfaces in `storage/domain/repos/`
   - ✅ Concrete implementations in `storage/data/`
   - ✅ CRUD-focused repositories (no heavy business logic)
   - ✅ New interfaces:
     - `NotificationPermissionRepo` (check status, request permission, save state)
     - `TimerPersistenceRepo` (save/load/clear timer session)
   - ✅ New implementations:
     - `SharedPreferencesNotificationPermissionRepo`
     - `SharedPreferencesTimerPersistenceRepo`
   - ✅ New service: `BackgroundTimerService` (coordinates notification delivery)

5. **UI & Theming**:
   - ✅ Reuse `ColorSystem` from `lib/features/common/themes/app_colors.dart`
   - ✅ Reuse `Typography` from `lib/features/common/themes/app_text_styles.dart`
   - ✅ Reuse `NeoButton` from `lib/features/common/widgets/neo_button.dart`
   - ✅ No new custom widgets required (spec does not define any)

6. **Clean Code Hygiene**:
   - ✅ Pure utilities only in `common/utils/`
   - ✅ Intention-revealing names
   - ✅ Separate files for Cubit and State

### Principle 4: Strict Theme Compliance
**Status**: ✅ PASS

**Compliance verification against `.specify/memory/2_theme.md`:**

1. **Color System** (Neo-Brutalist Fintech):
   - ✅ Background: `ColorSystem.background` (#FAF8F1 beige)
   - ✅ Surface: `ColorSystem.surface` (#FFFFFF white for cards)
   - ✅ Text: `ColorSystem.textPrimary` (black), `ColorSystem.textSecondary` (gray #8A8A8E)
   - ✅ Primary button: `ColorSystem.primary` (#FDEE8A creamy yellow)
   - ✅ Border: `ColorSystem.border` (black), width 1.5
   - ✅ Shadow: `ColorSystem.shadow` (black), `Offset(3, 3)`, no blur

2. **Typography**:
   - ✅ Title: `Typography.TitleMedium` (SemiBold, 20pt) for "Enable Notifications"
   - ✅ Body: `Typography.BodyLarge` (SemiBold, 16pt) for button text
   - ✅ Body: `Typography.BodyLarge` (Regular, 16pt) for explanatory text
   - ✅ Fonts: Inter (English), Noto Sans Thai (Thai)

3. **Shape & Shadows**:
   - ✅ Border radius: `Radii.Medium` (16.0) for buttons
   - ✅ Border width: 1.5 on all elements
   - ✅ Shadow: Hard shadow (blurRadius: 0.0), Offset(3, 3)
   - ✅ Pressed state: Offset(1, 1) animation on tap

4. **Components**:
   - ✅ Button: Reuse existing `NeoButton` component (already implements Neo-Brutalist style)
   - ✅ Haptic feedback: `HapticFeedback.lightImpact()` on `onTapDown`
   - ✅ Audio: Play `assets/audio/ui_click_neo.mp3` on `onTapDown` (using existing `audioplayers` package)
   - ✅ Icon: `Icons.notifications_active_outlined` (size 48, color `textSecondary`)
   - ✅ Layout: `Scaffold` + `SafeArea` + `Padding(24.0)` + `Column(mainAxisAlignment.center, crossAxisAlignment.stretch)`

5. **Motion & Animation**:
   - ✅ Button press: `shadowOffset` animation (100ms easeOut to Offset(1,1), 150ms easeOutBack to Offset(3,3))
   - ✅ Page transition: `SlideTransition` (handled by go_router, no custom animation needed)

### Principle 5: Quality Gates
**Status**: ✅ PASS (to be enforced)

**Pre-commit requirements**:
- ✅ All code must pass `flutter analyze` with zero errors
- ✅ Unit tests for all entities, repositories, cubits
- ✅ Widget tests for Onboarding S5 screen
- ✅ Integration tests for background timer flow
- ✅ Code organization follows 1_appendix.md structure
- ✅ UI follows 2_theme.md design system

**Test coverage targets**:
- Entities: 100% (simple data classes with validation)
- Repositories: 90%+ (CRUD operations)
- Cubits: 85%+ (state transitions and business logic)
- Widgets: 80%+ (UI rendering and interactions)

### Gate Decision: ✅ PROCEED

All 5 constitution principles pass. No violations detected. No complexity justification required.

## Project Structure

### Documentation (this feature)

```text
specs/002-background-timer-notify/
├── spec.md              # Feature specification (3 user stories, 18 FRs, 12 SCs)
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output: Technology decisions & alternatives
├── data-model.md        # Phase 1 output: Entities (TimerSession, NotificationPermission)
├── quickstart.md        # Phase 1 output: Developer setup guide (deps, iOS/Android config)
├── contracts/           # Phase 1 output: Repository interfaces & service contracts
│   ├── notification_permission_repo.dart
│   ├── timer_persistence_repo.dart
│   └── background_timer_service.dart
├── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created yet)
└── checklists/
    └── requirements.md  # Specification quality checklist (already validated)
```

### Source Code (repository root)

**Structure Decision**: Mobile (Flutter) with Clean Architecture - follows Option 3 pattern from template but uses existing `lib/` structure per `1_appendix.md`.

```text
lib/
├── app.dart                          # [EXTEND] Add new Cubits to MultiBlocProvider
├── main.dart                         # [EXTEND] Initialize notification services
├── config/
│   ├── app_config.dart               # [NO CHANGE] Existing config
│   └── app_router.dart               # [EXTEND] Add /onboarding/notification-permission route
├── features/
│   ├── common/                       # [REUSE] Existing design system
│   │   ├── themes/
│   │   │   ├── app_colors.dart       # [REUSE] ColorSystem tokens
│   │   │   └── app_text_styles.dart  # [REUSE] Typography tokens
│   │   └── widgets/
│   │       └── neo_button.dart       # [REUSE] Neo-Brutalist button component
│   ├── onboarding/                   # [NEW] Notification permission onboarding
│   │   ├── onboarding_route.dart     # [NEW] Route definition (no hardcoded paths)
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── notification_permission_page.dart  # [NEW] Onboarding S5 screen
│   │       └── cubits/
│   │           ├── onboarding_cubit.dart              # [NEW] Permission request logic
│   │           └── onboarding_state.dart              # [NEW] Onboarding states
│   ├── timer/                        # [EXTEND] Existing timer feature
│   │   ├── timer_route.dart          # [NO CHANGE] Existing route
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── timer_page.dart   # [MINOR CHANGE] Update to show notification prompts if needed
│   │       └── cubits/
│   │           ├── timer_cubit.dart  # [EXTEND] Add persistence, lifecycle handling
│   │           └── timer_state.dart  # [EXTEND] Add completed state if not exists
│   └── storage/                      # [EXTEND] Centralized data layer
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── timer_session.dart              # [NEW] Timer session entity
│       │   │   └── notification_permission.dart    # [NEW] Permission status entity
│       │   └── repos/
│       │       ├── notification_permission_repo.dart  # [NEW] Permission repo interface
│       │       └── timer_persistence_repo.dart        # [NEW] Timer persistence interface
│       └── data/
│           ├── shared_preferences_notification_permission_repo.dart  # [NEW] Implementation
│           ├── shared_preferences_timer_persistence_repo.dart        # [NEW] Implementation
│           └── background_timer_service.dart                        # [NEW] Service coordinator
│
test/
├── features/
│   ├── onboarding/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── notification_permission_page_test.dart  # [NEW] Widget tests
│   │       └── cubits/
│   │           └── onboarding_cubit_test.dart              # [NEW] Unit tests
│   ├── timer/
│   │   └── presentation/
│   │       └── cubits/
│   │           └── timer_cubit_test.dart                   # [EXTEND] Add lifecycle tests
│   └── storage/
│       ├── domain/
│       │   └── entities/
│       │       ├── timer_session_test.dart                 # [NEW] Entity validation tests
│       │       └── notification_permission_test.dart        # [NEW] Entity tests
│       └── data/
│           ├── shared_preferences_notification_permission_repo_test.dart  # [NEW] Repo tests
│           ├── shared_preferences_timer_persistence_repo_test.dart        # [NEW] Repo tests
│           └── background_timer_service_test.dart                        # [NEW] Service tests
│
integration_test/
└── background_timer_flow_test.dart   # [NEW] Full background flow integration test
│
android/
└── app/
    └── src/
        └── main/
            └── AndroidManifest.xml   # [EXTEND] Add POST_NOTIFICATIONS permission
│
ios/
└── Runner/
    └── Info.plist                    # [EXTEND] Add NSUserNotificationsUsageDescription
│
pubspec.yaml                          # [EXTEND] Add new dependencies
```

**Key Changes Summary**:
- **New Feature Module**: `lib/features/onboarding/` (1 screen, 1 cubit, 1 route)
- **Extended Feature**: `lib/features/timer/` (lifecycle handling in cubit)
- **New Domain Layer**: 2 entities, 2 repository interfaces in `storage/domain/`
- **New Data Layer**: 2 repository implementations, 1 service in `storage/data/`
- **Configuration**: Update `app_router.dart`, `app.dart`, `main.dart`
- **Platform Config**: Update `AndroidManifest.xml`, `Info.plist`
- **Dependencies**: Add 3 new packages to `pubspec.yaml`

**File Count Estimate**:
- New files: ~15
- Modified files: ~6
- Total test files: ~8

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

**Status**: No complexity violations detected. All architecture patterns follow established Flutter Clean Architecture conventions from `1_appendix.md`. No justification needed.

## Phase Completion Summary

### Phase 0: Research & Technology Selection ✅ COMPLETE

**Artifacts Created**:
- ✅ `research.md` - Technology decisions documented with rationale and alternatives

**Key Decisions**:
1. **Background Timer**: Timestamp-based calculation (not continuous execution)
2. **Notifications**: flutter_local_notifications ^17.0.0
3. **Permissions**: permission_handler ^11.0.0
4. **Persistence**: shared_preferences ^2.2.0
5. **Lifecycle**: Extend existing WidgetsBindingObserver in TimerCubit
6. **Delivery Timing**: Check and deliver on app resume (not scheduled notifications)

**All NEEDS CLARIFICATION items resolved**: ✅ Yes (research.md contains no uncertainties)

---

### Phase 1: Design & Contracts ✅ COMPLETE

**Artifacts Created**:
- ✅ `data-model.md` - Entities: TimerSession, NotificationPermission with validation rules
- ✅ `contracts/notification_permission_repo.dart` - 6 methods (check status, request, save state)
- ✅ `contracts/timer_persistence_repo.dart` - 4 methods (save, load, clear session)
- ✅ `contracts/background_timer_service.dart` - 7 methods (initialize, schedule, deliver, cleanup)
- ✅ `quickstart.md` - Developer setup guide (10 steps: dependencies, iOS/Android config, service init)
- ✅ Agent context updated - `.github/copilot-instructions.md` updated with new technologies

**Entities Defined**:
1. **TimerSession**: 6 attributes (id, sessionType, totalDuration, startTimestamp, completionTimestamp, currentState)
   - Enums: SessionType (work, shortBreak, longBreak), TimerSessionState (running, paused, completed, cancelled)
   - Derived properties: elapsed, remaining, isComplete, progress
   - Validation: timestamp constraints, state transitions, duration limits

2. **NotificationPermission**: 3 attributes (status, lastRequestedAt, onboardingCompleted)
   - Enum: PermissionStatus (notDetermined, granted, denied, provisional, permanentlyDenied)
   - Derived properties: shouldShowOnboarding, canRequestPermission, canDeliverNotifications
   - Validation: timestamp constraints, status consistency

**Repository Contracts**:
1. **NotificationPermissionRepo**: 
   - `checkStatus() → PermissionStatus`
   - `requestPermission() → PermissionStatus`
   - `savePermission(NotificationPermission)`
   - `loadPermission() → NotificationPermission?`
   - `markOnboardingComplete()`
   - `shouldShowOnboarding() → bool`

2. **TimerPersistenceRepo**:
   - `saveSession(TimerSession)`
   - `loadSession() → TimerSession?`
   - `clearSession()`
   - `hasActiveSession() → bool`

3. **BackgroundTimerService** (coordinator):
   - `initialize(FlutterLocalNotificationsPlugin)`
   - `scheduleCompletion(TimerSession)`
   - `cancelScheduled()`
   - `deliverCompletion(SessionType)`
   - `handleNotificationTap()`
   - `checkPermissionStatus() → bool`
   - `requestPermission() → bool`

**Agent Context Update**: ✅ Complete
- Added new technologies to `.github/copilot-instructions.md`
- Preserved manual additions between markers

---

### Phase 2: Implementation (Next - via /speckit.tasks)

**NOT STARTED** - This phase will be executed by the `/speckit.tasks` command.

**Planned Outputs**:
- `tasks.md` - Detailed task breakdown with:
  - Phase-by-phase task grouping
  - File paths for each task
  - Priority and dependency markers
  - User story traceability
  - Parallel execution opportunities

**Estimated Task Scope**:
- Setup & Dependencies: ~10 tasks (pubspec, platform config, service init)
- Domain Layer: ~15 tasks (entities, validation, serialization, tests)
- Data Layer: ~20 tasks (repo implementations, service, persistence logic, tests)
- Onboarding Feature: ~25 tasks (route, page, cubit, state, tests, integration with app_router)
- Timer Extension: ~20 tasks (lifecycle handling, persistence integration, state transitions, tests)
- Integration Testing: ~10 tasks (background flow, permission flow, edge cases)
- Polish: ~10 tasks (error handling, documentation, analytics if applicable)

**Total Estimated Tasks**: ~110 tasks

---

## Re-Constitution Check (Post-Design)

*Required by constitution.md: "Re-check after Phase 1 design"*

### Principle 1: Spec-Driven Development
**Status**: ✅ PASS - All design artifacts trace back to spec.md requirements

### Principle 2: Separation of Rules
**Status**: ✅ PASS - All three rule files consulted and followed

### Principle 3: Strict Architecture Compliance
**Status**: ✅ PASS - Design follows 1_appendix.md:
- Entities in `storage/domain/entities/`
- Repo interfaces in `storage/domain/repos/`
- Implementations in `storage/data/`
- Cubits with separate state files
- Routes with injected paths

### Principle 4: Strict Theme Compliance
**Status**: ✅ PASS - Design reuses existing components per 2_theme.md:
- `NeoButton` (no new widgets created)
- `ColorSystem` tokens
- `Typography` roles
- Neo-Brutalist spacing and shadows

### Principle 5: Quality Gates
**Status**: ✅ PASS - Test strategy defined:
- Unit tests for all entities and repos
- Widget tests for Onboarding S5
- Integration tests for background flow
- Target coverage: 85%+ overall

**Final Gate Decision**: ✅ PROCEED TO IMPLEMENTATION

---

## Next Steps

1. **Run `/speckit.tasks` command** to generate `tasks.md` with detailed implementation breakdown
2. **Review tasks.md** for accuracy and completeness
3. **Begin implementation** following task order in tasks.md
4. **Run `flutter analyze`** frequently to catch issues early
5. **Write tests** alongside implementation (not after)
6. **Test on real devices** (iOS and Android) for background behavior validation

---

## Risk Register

| Risk | Likelihood | Impact | Mitigation | Status |
|------|------------|--------|------------|--------|
| iOS notification permission denied by user | High | Low | Graceful degradation, timer works without notifications | Accepted |
| Timer inaccuracy on battery saver mode | Low | Medium | Timestamp calculation immune to throttling | Mitigated |
| SharedPreferences corruption | Low | Medium | Graceful fallback to clean state | Mitigated |
| Notification not delivered on iOS | Low | High | Deliver on app resume (not scheduled) | Mitigated |
| Force-quit loses timer state | High | Low | Expected behavior per spec | Accepted |
| Cross-platform inconsistencies | Medium | High | Extensive testing on both platforms | In Progress |

---

## Appendix: Key Files Reference

**Constitution & Rules**:
- `.specify/memory/constitution.md` - Governance principles
- `.specify/memory/1_appendix.md` - Flutter Clean Architecture rules
- `.specify/memory/2_theme.md` - Neo-Brutalist design system

**Feature Specification**:
- `specs/002-background-timer-notify/spec.md` - 3 user stories, 18 FRs, 12 SCs

**Research & Design**:
- `specs/002-background-timer-notify/research.md` - Technology decisions
- `specs/002-background-timer-notify/data-model.md` - Entity definitions
- `specs/002-background-timer-notify/contracts/` - Repository interfaces

**Developer Resources**:
- `specs/002-background-timer-notify/quickstart.md` - Setup guide
- `lib/features/timer/presentation/cubits/timer_cubit.dart` - Existing timer implementation (to be extended)

---

**Plan Version**: 1.0.0  
**Status**: Phase 0 & 1 Complete | Ready for Phase 2 (Tasks)  
**Last Updated**: November 3, 2025
