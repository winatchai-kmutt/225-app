# Phase 1: Data Model

**Feature**: Main Timer UI & Controls  
**Date**: 2025-11-03  
**Status**: Complete

## Overview

This document defines the data entities and state structures for the timer feature. Since this feature is purely UI-focused with no persistent storage requirements, all entities represent in-memory state managed by `TimerCubit`.

---

## Core Entities

### 1. TimerSession

**Purpose**: Represents a single work or break timer session.

**Attributes**:
| Field | Type | Description | Validation Rules |
|-------|------|-------------|------------------|
| `sessionType` | `SessionType` enum | Whether this is a WORK or BREAK session | Required; one of [WORK, BREAK] |
| `totalDuration` | `Duration` | Initial duration for this session (e.g., 25 minutes) | Required; > 0 seconds |
| `remainingTime` | `Duration` | Current countdown time left | Required; 0 ≤ remainingTime ≤ totalDuration |
| `state` | `TimerState` enum | Current operational state | Required; one of [STOPPED, RUNNING, PAUSED, COMPLETED] |
| `startTime` | `DateTime?` | Timestamp when timer was started (null if not running) | Nullable; set only when state == RUNNING |

**Lifecycle**:
```
[Create] → STOPPED (remainingTime = totalDuration)
  ↓ [Start]
RUNNING (startTime = DateTime.now())
  ↓ [Pause]           ↓ [Countdown reaches 0]
PAUSED              COMPLETED
  ↓ [Resume]           ↓ [Navigate away]
RUNNING              [Dispose]
  ↓ [Reset]
STOPPED (remainingTime = totalDuration, startTime = null)
```

**Relationships**: None (self-contained)

**Persistence**: In-memory only (managed by `TimerCubit`)

---

### 2. SessionType (Enum)

**Purpose**: Distinguishes between work and break periods.

**Values**:
- `WORK`: Focused work session (default 25 minutes)
- `BREAK`: Rest period (not implemented in this US, reserved for US 3.1)

**Usage**: Displayed in `SessionTypeIndicator` widget, determines timer duration

---

### 3. TimerState (Enum)

**Purpose**: Represents the operational state of the timer.

**Values**:
| State | Description | UI Behavior | Valid Transitions |
|-------|-------------|-------------|-------------------|
| `STOPPED` | Timer not started or reset | Play button visible | → RUNNING |
| `RUNNING` | Timer actively counting down | Pause button visible, progress animating | → PAUSED, COMPLETED |
| `PAUSED` | Timer stopped mid-countdown | Play button visible, progress frozen | → RUNNING, STOPPED |
| `COMPLETED` | Countdown reached 00:00 | Show completion animation | → (navigate away) |

**State Machine Diagram**:
```
     ┌─────────┐
     │ STOPPED │ (Initial state, after reset)
     └────┬────┘
          │ Start
          ↓
     ┌─────────┐
     │ RUNNING │ (Countdown active)
     └────┬────┘
          │ Pause ←──┐
          ↓          │ Resume
     ┌─────────┐     │
     │ PAUSED  │─────┘
     └────┬────┘
          │ Reset → STOPPED
          │
     (Timer hits 00:00)
          │
          ↓
   ┌───────────┐
   │ COMPLETED │ (Show animation, then navigate)
   └───────────┘
```

**Skip Behavior**: Skip button triggers transition from any state (STOPPED/RUNNING/PAUSED) → COMPLETED

---

### 4. VisualFeedbackState

**Purpose**: Tracks the press state of interactive buttons for shadow animations.

**Attributes**:
| Field | Type | Description |
|-------|------|-------------|
| `buttonId` | `String` | Identifier for the button (e.g., "play", "reset", "skip") |
| `isPressed` | `bool` | Whether button is currently pressed |
| `shadowOffset` | `Offset` | Current shadow offset (animates between (3,3) and (1,1)) |

**Lifecycle**: Managed internally by `NeoButton` / `NeoIconButton` widgets (not exposed to Cubit)

**Animation**: 
- On `TapDown`: `shadowOffset` animates from `Offset(3,3)` to `Offset(1,1)` over 100ms
- On `TapUp`/`TapCancel`: Animates back to `Offset(3,3)` over 100ms

---

## State Management Structure (Cubit)

### TimerCubit States

```dart
// Abstract base class
abstract class TimerCubitState {}

// Concrete states
class TimerInitialState extends TimerCubitState {
  final Duration totalDuration;
  final SessionType sessionType;
}

class TimerRunningState extends TimerCubitState {
  final Duration remaining;
  final double progress; // 0.0 to 1.0 (for UI progress ring)
}

class TimerPausedState extends TimerCubitState {
  final Duration remaining;
  final double progress;
}

class TimerCompletedState extends TimerCubitState {
  final SessionType completedSessionType;
}
```

### State Transitions (Cubit Events)

| Method | From State | To State | Side Effects |
|--------|-----------|----------|--------------|
| `start()` | Initial, Paused | Running | Start periodic timer, play click sound, haptics |
| `pause()` | Running | Paused | Cancel periodic timer, play click sound, haptics |
| `reset()` | Any | Initial | Cancel timer, reset remaining time, play click sound, haptics |
| `skip()` | Any | Completed | Cancel timer, trigger completion flow |
| `_onTick()` | Running | Running or Completed | Update remaining time, check if 00:00 reached |
| `_onComplete()` | Running | Completed | Play success sound, show checkmark animation |

---

## Validation Rules

### Duration Constraints
- `totalDuration` must be > 0 seconds
- `remainingTime` must be ≥ 0 and ≤ `totalDuration`
- Work session default: `Duration(minutes: 25)`
- Break session default: `Duration(minutes: 5)` (for future US 3.1)

### Accuracy Requirements
- Timer must update UI every 1 second (±100ms jitter acceptable)
- Total drift over 25 minutes must be ≤ ±2 seconds
- Background calculation must remain accurate when app is backgrounded

### State Consistency
- `startTime` must be non-null if and only if `state == RUNNING`
- `remainingTime == totalDuration` when `state == STOPPED`
- Progress percentage: `(remainingTime.inSeconds / totalDuration.inSeconds)`

---

## Error Handling

### Edge Cases
| Scenario | Expected Behavior |
|----------|------------------|
| Rapid start/pause taps | Debounce not required - each tap toggles state cleanly |
| Timer at 00:01, user pauses | Timer pauses at 00:01; user can resume or skip |
| App backgrounded while running | Continue countdown using DateTime calculations |
| App returns after timer completed in background | Show completion animation immediately |
| Audio file missing | Silent failure, visual/haptic feedback still works |
| Device without haptics | Silent no-op, audio/visual feedback still works |

---

## Data Flow Diagram

```
┌──────────────┐
│  User Input  │ (Tap play/pause/reset/skip)
└──────┬───────┘
       │
       ↓
┌────────────────┐
│  TimerCubit    │ (State machine logic)
│  - start()     │
│  - pause()     │
│  - reset()     │
│  - skip()      │
└────────┬───────┘
         │
         ├─→ Timer.periodic(1s) → _onTick() → Update remaining time
         │
         ├─→ HapticFeedback.lightImpact()
         │
         ├─→ AudioService.playSound('ui_click_neo.mp3')
         │
         └─→ emit(TimerRunningState/TimerPausedState/TimerCompletedState)
                │
                ↓
         ┌─────────────────┐
         │   TimerPage     │ (BlocBuilder listens to state)
         │   - Updates UI  │
         │   - Triggers    │
         │     animations  │
         └─────────────────┘
```

---

## Testing Considerations

### Unit Tests (TimerCubit)
- ✅ Initial state is STOPPED with 25:00 remaining
- ✅ Start transitions to RUNNING and begins countdown
- ✅ Pause transitions to PAUSED and preserves remaining time
- ✅ Reset transitions to STOPPED and resets to 25:00
- ✅ Skip from any state transitions to COMPLETED
- ✅ Countdown reaching 00:00 auto-transitions to COMPLETED
- ✅ Background/foreground cycle maintains accuracy (within ±2s)

### Widget Tests (NeoCircularTimer)
- ✅ Renders at 280x280 size
- ✅ Progress arc updates when progress value changes
- ✅ Stroke width is 20px
- ✅ Uses rounded caps

### Integration Tests
- ✅ Complete timer flow: Start → Pause → Resume → Complete → Navigate
- ✅ Skip flow: Start → Skip → Show completion → Navigate
- ✅ Reset flow: Start → Pause → Reset → Verify 25:00
- ✅ Background accuracy: Start → Background for 5 minutes → Return → Verify time accurate

---

## Next Steps

1. ✅ Data model defined - proceed to contract generation
2. Generate `contracts/timer_state_contract.md` (state machine formalization)
3. Generate `contracts/timer_lifecycle_contract.md` (app lifecycle handling)
4. Generate `quickstart.md` (developer setup)