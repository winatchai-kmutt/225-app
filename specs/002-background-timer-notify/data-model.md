# Data Model: Background Timer & Notification Permission

**Date**: November 3, 2025  
**Feature**: 002-background-timer-notify  
**Phase**: 1 (Design & Contracts)

## Overview

This document defines the domain entities for background timer execution and notification permission management, extracted from the feature specification and aligned with Flutter Clean Architecture principles.

---

## Entities

### 1. TimerSession

**Purpose**: Represents an active or completed Pomodoro timer session with all state needed for background execution and persistence.

**Location**: `lib/features/storage/domain/entities/timer_session.dart`

**Attributes**:

| Attribute | Type | Description | Validation Rules |
|-----------|------|-------------|------------------|
| `id` | `String` | Unique identifier for this session | Non-empty, UUID format |
| `sessionType` | `SessionType` (enum) | Type of session (Pomodoro, Short Break, Long Break) | Must be valid enum value |
| `totalDuration` | `Duration` | Total duration of the session in seconds | Must be positive, typically 1500s (25min) |
| `startTimestamp` | `DateTime` | When the timer was started | Must be in the past or present |
| `completionTimestamp` | `DateTime?` | When the timer completed (null if not yet complete) | Must be after startTimestamp if not null |
| `currentState` | `TimerState` (enum) | Current state of the timer | Must be valid enum value |

**Enums**:

```dart
enum SessionType {
  pomodoro,      // 25-minute work session
  shortBreak,    // 5-minute break
  longBreak,     // 15-minute break
}

enum TimerState {
  running,       // Timer is actively running
  paused,        // Timer is paused (not used in MVP per spec)
  completed,     // Timer has finished
  cancelled,     // Timer was cancelled by user
}
```

**State Transitions**:
- `running` → `completed`: When elapsed time >= totalDuration
- `running` → `cancelled`: When user explicitly cancels timer
- `completed` → `running`: Never (new session created instead)
- `cancelled` → `running`: Never (new session created instead)

**Persistence Rules**:
- Serialize to JSON for SharedPreferences storage
- Persist immediately when state changes to `running`
- Clear persistence when state is `completed` or `cancelled`
- Clear persistence on device reboot (detected by timestamp validation)

**Business Rules**:
- Only one TimerSession can be in `running` state at a time (enforced by TimerCubit)
- Starting a new timer when one is running automatically cancels the previous one
- Elapsed time calculation: `DateTime.now().difference(startTimestamp)`
- Remaining time calculation: `totalDuration - elapsed`
- Timer is considered complete when `elapsed >= totalDuration`

**Example JSON**:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "sessionType": "pomodoro",
  "totalDurationSeconds": 1500,
  "startTimestamp": "2025-11-03T10:30:00.000Z",
  "completionTimestamp": null,
  "currentState": "running"
}
```

---

### 2. NotificationPermission

**Purpose**: Represents the current notification permission status and onboarding completion state for the user.

**Location**: `lib/features/storage/domain/entities/notification_permission.dart`

**Attributes**:

| Attribute | Type | Description | Validation Rules |
|-----------|------|-------------|------------------|
| `status` | `PermissionStatus` (enum) | Current permission status | Must be valid enum value |
| `lastRequestedAt` | `DateTime?` | When permission was last requested | Must be in the past if not null |
| `onboardingCompleted` | `bool` | Whether user has seen Onboarding S5 screen | Defaults to false |

**Enums**:

```dart
enum PermissionStatus {
  notDetermined,   // Permission has not been requested yet
  granted,         // User granted notification permissions
  denied,          // User denied notification permissions
  provisional,     // iOS only: provisional authorization granted
}
```

**State Transitions**:
- `notDetermined` → `granted`: User taps "Allow" in OS permission dialog
- `notDetermined` → `denied`: User taps "Don't Allow" in OS permission dialog
- `notDetermined` → `provisional`: iOS grants provisional auth automatically
- `denied` → `granted`: User manually enables in system settings (rare)
- `granted` → `denied`: User manually disables in system settings
- All transitions set `lastRequestedAt` to current timestamp

**Persistence Rules**:
- Serialize to JSON for SharedPreferences storage
- Persist immediately after permission request
- Check on every app launch to detect system settings changes
- `onboardingCompleted` flag is write-once (never reset)

**Business Rules**:
- Onboarding S5 screen only shown if `onboardingCompleted == false`
- After onboarding, `onboardingCompleted` set to `true` regardless of permission result
- Notification delivery only attempted if `status == granted`
- Timer functionality works normally even if `status == denied`
- Permission status checked on app foreground to detect system settings changes

**Example JSON**:
```json
{
  "status": "granted",
  "lastRequestedAt": "2025-11-03T09:15:00.000Z",
  "onboardingCompleted": true
}
```

---

## Relationships

```
┌─────────────────────┐
│  NotificationPermission  │
│  - status             │
│  - onboardingCompleted │
└─────────────────────┘
         ↓ (affects)
         ↓
┌─────────────────────┐
│    TimerSession     │
│  - startTimestamp   │
│  - totalDuration    │
│  - currentState     │
└─────────────────────┘
         ↓ (triggers)
         ↓
┌─────────────────────┐
│  Local Notification │
│  (if permission     │
│   granted)          │
└─────────────────────┘
```

**Relationship Rules**:
- `NotificationPermission.status` determines whether notifications are delivered
- `TimerSession.currentState == completed` triggers notification attempt
- Multiple `TimerSession` records may exist in history, but only one can be `running`
- `NotificationPermission` is singleton per user (one instance per app installation)

---

## Value Objects

### Duration Extensions

**Purpose**: Helper methods for Duration serialization and display formatting.

**Location**: `lib/features/storage/domain/entities/timer_session.dart` (extension)

**Methods**:
- `toSeconds()`: Convert Duration to integer seconds for JSON serialization
- `toDisplayString()`: Format Duration as "MM:SS" for UI display
- `fromSeconds(int seconds)`: Create Duration from integer seconds

---

## Validation Rules Summary

| Rule | Entity | Enforcement Location |
|------|--------|---------------------|
| Only one running timer | TimerSession | TimerCubit (before starting new timer) |
| Timer accuracy ±2 seconds | TimerSession | Background calculation logic + integration tests |
| Onboarding shown once | NotificationPermission | OnboardingCubit (check before navigation) |
| Permission status sync | NotificationPermission | App foreground lifecycle observer |
| State persistence | Both entities | Repository layer (SharedPreferences) |
| Device reboot detection | TimerSession | App startup logic (compare timestamps) |

---

## Lifecycle Management

### TimerSession Lifecycle

```
┌──────────┐
│  Create  │
└────┬─────┘
     ↓
┌────────────┐
│  Running   │ ← Backgrounded: Continue via timestamp calculation
└─────┬──────┘
      │
      ├─→ (elapsed >= total) ─→ [Completed] → Clear persistence
      │
      └─→ (user cancels) ─────→ [Cancelled] → Clear persistence
```

### NotificationPermission Lifecycle

```
┌──────────────┐
│ Not Determined │ (First app launch)
└───────┬────────┘
        ↓
   [Show Onboarding S5]
        ↓
   [Request Permission]
        ↓
    ┌───┴────┐
    ↓        ↓
[Granted] [Denied]
    │        │
    └────┬───┘
         ↓
  [Mark onboarding complete]
         ↓
  [Never show onboarding again]
```

---

## Storage Schema

### SharedPreferences Keys

| Key | Entity | Data Type | Example Value |
|-----|--------|-----------|---------------|
| `timer_active_session` | TimerSession | JSON String | `{"id":"...", "sessionType":"pomodoro", ...}` |
| `notification_permission` | NotificationPermission | JSON String | `{"status":"granted", "onboardingCompleted":true, ...}` |

**Key Design Rationale**:
- Simple string keys for easy debugging
- Namespaced with entity type to avoid collisions
- Single active session (no array storage needed)
- Permission is singleton (one record per app)

---

## Testing Considerations

### Entity Tests
- [ ] TimerSession JSON serialization/deserialization round-trip
- [ ] TimerSession state transition validation
- [ ] NotificationPermission status enum coverage
- [ ] Duration helper methods accuracy

### Integration Tests
- [ ] TimerSession persistence across app closure
- [ ] TimerSession cleared on device reboot simulation
- [ ] NotificationPermission status detection
- [ ] Onboarding completion flag persistence

---

## Migration Strategy

**Current State**: Timer feature exists but lacks background execution and persistence.

**Migration Path**:
1. Add new entities (TimerSession, NotificationPermission) to `storage/domain/entities/`
2. Create repository interfaces in `storage/domain/repos/`
3. Implement SharedPreferences repositories in `storage/data/`
4. Modify existing `TimerCubit` to use new persistence layer
5. No data migration needed (fresh feature, no existing stored state)

**Backward Compatibility**: N/A (new feature, no existing data)

---

## Next Steps

- [x] Define entities (this document)
- [ ] Generate repository contracts (contracts/)
- [ ] Generate quickstart guide (quickstart.md)
- [ ] Update agent context
- [ ] Proceed to Phase 2 (tasks)
