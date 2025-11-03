# Timer State Contract

**Feature**: Main Timer UI & Controls  
**Date**: 2025-11-03  
**Version**: 1.0

## Purpose

This contract defines the formal state machine for `TimerCubit`, including all valid states, transitions, guards, and side effects. Implementations MUST adhere to this contract to ensure predictable timer behavior.

---

## State Definitions

### State Enumeration

```dart
enum TimerStateType {
  STOPPED,    // Timer not started or reset
  RUNNING,    // Timer actively counting down
  PAUSED,     // Timer stopped mid-countdown
  COMPLETED   // Countdown reached 00:00
}
```

### State Properties

Each state carries specific data:

| State | Properties | Constraints |
|-------|-----------|-------------|
| `STOPPED` | `totalDuration`, `sessionType` | `remainingTime == totalDuration` |
| `RUNNING` | `remainingTime`, `progress`, `startTime` | `startTime != null`, `remainingTime > 0` |
| `PAUSED` | `remainingTime`, `progress` | `startTime == null`, `remainingTime > 0` |
| `COMPLETED` | `completedSessionType` | `remainingTime == 0` |

---

## State Transitions

### 1. Start Transition

**Trigger**: User taps play button  
**From**: `STOPPED` or `PAUSED`  
**To**: `RUNNING`  
**Guards**: None (always allowed from STOPPED/PAUSED)  
**Side Effects**:
1. If from `STOPPED`: Set `remainingTime = totalDuration`
2. Set `startTime = DateTime.now()`
3. Start `Timer.periodic(Duration(seconds: 1), _onTick)`
4. Play `audio/ui_click_neo.mp3`
5. Trigger `HapticFeedback.lightImpact()`
6. Emit `TimerRunningState(remaining: remainingTime, progress: calculated)`

**Pseudocode**:
```dart
void start() {
  if (state is TimerStoppedState) {
    _remainingTime = _totalDuration;
  }
  _startTime = DateTime.now();
  _timer = Timer.periodic(Duration(seconds: 1), _onTick);
  _playSound('audio/ui_click_neo.mp3');
  HapticFeedback.lightImpact();
  emit(TimerRunningState(
    remaining: _remainingTime,
    progress: _calculateProgress(),
  ));
}
```

---

### 2. Pause Transition

**Trigger**: User taps pause button  
**From**: `RUNNING`  
**To**: `PAUSED`  
**Guards**: `state is TimerRunningState`  
**Side Effects**:
1. Calculate current `remainingTime` from `DateTime.now() - startTime`
2. Cancel `Timer.periodic` instance
3. Clear `startTime` (set to null)
4. Play `audio/ui_click_neo.mp3`
5. Trigger `HapticFeedback.lightImpact()`
6. Emit `TimerPausedState(remaining: remainingTime, progress: calculated)`

**Pseudocode**:
```dart
void pause() {
  if (state is! TimerRunningState) return; // Guard
  
  final elapsed = DateTime.now().difference(_startTime!);
  _remainingTime = _totalDuration - elapsed;
  _timer?.cancel();
  _startTime = null;
  _playSound('audio/ui_click_neo.mp3');
  HapticFeedback.lightImpact();
  emit(TimerPausedState(
    remaining: _remainingTime,
    progress: _calculateProgress(),
  ));
}
```

---

### 3. Reset Transition

**Trigger**: User taps reset button  
**From**: Any state (STOPPED, RUNNING, PAUSED, COMPLETED)  
**To**: `STOPPED`  
**Guards**: None  
**Side Effects**:
1. Cancel `Timer.periodic` if running
2. Reset `remainingTime = totalDuration`
3. Clear `startTime` (set to null)
4. Play `audio/ui_click_neo.mp3`
5. Trigger `HapticFeedback.lightImpact()`
6. Emit `TimerStoppedState(totalDuration: totalDuration)`

**Pseudocode**:
```dart
void reset() {
  _timer?.cancel();
  _remainingTime = _totalDuration;
  _startTime = null;
  _playSound('audio/ui_click_neo.mp3');
  HapticFeedback.lightImpact();
  emit(TimerStoppedState(
    totalDuration: _totalDuration,
    sessionType: _sessionType,
  ));
}
```

---

### 4. Skip Transition

**Trigger**: User taps skip button  
**From**: Any state (STOPPED, RUNNING, PAUSED)  
**To**: `COMPLETED`  
**Guards**: None  
**Side Effects**:
1. Cancel `Timer.periodic` if running
2. Set `remainingTime = Duration.zero`
3. Clear `startTime`
4. Play `audio/ui_click_neo.mp3` + `HapticFeedback.lightImpact()`
5. Immediately trigger completion flow (same as natural completion)
6. Emit `TimerCompletedState`

**Pseudocode**:
```dart
void skip() {
  _timer?.cancel();
  _remainingTime = Duration.zero;
  _startTime = null;
  _playSound('audio/ui_click_neo.mp3');
  HapticFeedback.lightImpact();
  _onComplete(); // Shared completion logic
}
```

---

### 5. Auto-Complete Transition

**Trigger**: Timer countdown reaches 00:00  
**From**: `RUNNING`  
**To**: `COMPLETED`  
**Guards**: `remainingTime <= Duration.zero`  
**Side Effects**:
1. Cancel `Timer.periodic`
2. Clear `startTime`
3. Play `audio/success_chime.mp3` (no haptics for natural completion)
4. Emit `TimerCompletedState`
5. UI shows `AnimatedCompletionIcon` (handled by widget layer)
6. After 800ms, navigate to break screen (handled by widget layer)

**Pseudocode**:
```dart
void _onTick(Timer timer) {
  final elapsed = DateTime.now().difference(_startTime!);
  _remainingTime = _totalDuration - elapsed;
  
  if (_remainingTime <= Duration.zero) {
    _onComplete();
  } else {
    emit(TimerRunningState(
      remaining: _remainingTime,
      progress: _calculateProgress(),
    ));
  }
}

void _onComplete() {
  _timer?.cancel();
  _startTime = null;
  _remainingTime = Duration.zero;
  _playSound('audio/success_chime.mp3');
  // No haptics on natural completion (only on manual skip)
  emit(TimerCompletedState(
    completedSessionType: _sessionType,
  ));
}
```

---

## State Machine Diagram (Formal)

```
     ┌──────────────────────────────────────────────┐
     │                                              │
     │            start()                           │
     │  ┌───────────────────┐                       │
     └─→│     STOPPED       │←──────────────┐       │
        │  (25:00, WORK)    │               │       │
        └────────┬──────────┘               │       │
                 │ start()           reset()│       │
                 ↓                           │       │
        ┌────────────────────┐               │       │
    ┌──→│     RUNNING        │               │       │
    │   │  (countdown active)│               │       │
    │   └────────┬───────────┘               │       │
    │            │                            │       │
    │            │ pause()                    │       │
    │            ↓                            │       │
    │   ┌────────────────────┐               │       │
    │   │      PAUSED        │               │       │
    │   │  (frozen at time)  │───────────────┘       │
    │   └────────┬───────────┘                       │
    │            │                                    │
    │            │ resume (start)                     │
    └────────────┘                                    │
                 │                                    │
                 │ skip() OR countdown hits 00:00     │
                 ↓                                    │
        ┌────────────────────┐                       │
        │    COMPLETED       │                       │
        │  (show animation)  │                       │
        └────────┬───────────┘                       │
                 │                                    │
                 │ navigate to break screen           │
                 └────────────────────────────────────┘
                                (loop for next session)
```

---

## Invariants (Must Always Hold)

1. **Mutual Exclusion**: Timer can only be in ONE state at a time
2. **Time Consistency**: `0 ≤ remainingTime ≤ totalDuration`
3. **StartTime Nullability**: `startTime != null` ⟺ `state == RUNNING`
4. **Timer Lifecycle**: `Timer.periodic` instance exists ⟺ `state == RUNNING`
5. **Progress Calculation**: `progress = 1.0 - (remainingTime / totalDuration)` (range [0.0, 1.0])
6. **Accuracy**: Drift over 25 minutes ≤ ±2 seconds

---

## Concurrency Guarantees

- **Thread Safety**: All state mutations must occur on the main UI thread (Cubit pattern ensures this)
- **Reentrancy**: Multiple rapid taps on the same button should debounce naturally (state guards prevent invalid transitions)
- **Race Conditions**: DateTime-based calculations prevent race conditions between timer ticks and user input

---

## Error Handling

| Error Scenario | Expected Behavior | Recovery |
|---------------|-------------------|----------|
| `_timer?.cancel()` throws | Log error, continue state transition | Graceful degradation |
| Audio playback fails | Silent failure, state transition proceeds | No user impact |
| Haptics unavailable | Silent no-op, state transition proceeds | No user impact |
| Invalid state transition | Guard clause returns early, log warning | Maintain current state |

---

## Validation Checklist

Before marking implementation complete:

- [ ] All 5 transitions implemented with correct guards
- [ ] All 6 invariants verified in unit tests
- [ ] DateTime-based calculation used (not Timer.periodic accumulation)
- [ ] Audio/haptic failures handled gracefully
- [ ] State machine diagram matches code behavior
- [ ] Background/foreground cycle maintains accuracy (±2s over 25min)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-11-03 | Initial contract |
