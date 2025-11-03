# Timer Lifecycle Contract

**Feature**: Main Timer UI & Controls  
**Date**: 2025-11-03  
**Version**: 1.0

## Purpose

This contract defines how `TimerCubit` and `TimerPage` must handle Flutter's app lifecycle events to maintain timer accuracy and state consistency when the app is backgrounded, resumed, or terminated.

---

## App Lifecycle States (Flutter)

Flutter exposes the following lifecycle states via `AppLifecycleState`:

| State | Description | Example Scenarios |
|-------|-------------|------------------|
| `resumed` | App is visible and responsive | User is actively using the app |
| `inactive` | App is transitioning or in interrupted state | Phone call incoming, control center open (iOS) |
| `paused` | App is in background but still in memory | Home button pressed, app switcher |
| `detached` | App is being terminated | OS killing app for memory, user force-quit |

---

## Timer Behavior by Lifecycle State

### 1. Resumed (App Active)

**Expected Behavior**:
- Timer operates normally
- UI updates every second via `Timer.periodic`
- All user interactions (play, pause, reset, skip) are responsive

**Implementation**:
- Standard `TimerCubit` operation (no special handling needed)

---

### 2. Inactive (Transient State)

**Expected Behavior**:
- Treat as still active (do not pause timer)
- Continue countdown calculations
- UI may not update (acceptable during transition)

**Implementation**:
- No special handling needed
- `Timer.periodic` continues firing
- Brief UI freeze is acceptable (< 1 second)

**Rationale**: Inactive is transient - pausing/resuming would cause jarring UX for quick interruptions

---

### 3. Paused (App Backgrounded)

**Expected Behavior**:
- **If timer was RUNNING**: Continue countdown using DateTime calculations
- **If timer was STOPPED/PAUSED**: Maintain current state
- Stop `Timer.periodic` (Flutter pauses it automatically on iOS, best to cancel explicitly)
- Persist `startTime` and `totalDuration` in memory

**Implementation**:

```dart
// In TimerCubit (mixin WidgetsBindingObserver)
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    // App going to background
    if (this.state is TimerRunningState) {
      _timer?.cancel(); // Stop periodic updates
      // Keep _startTime and _totalDuration in memory
      // DO NOT emit new state (preserve RUNNING state)
    }
  }
}
```

**Data Preserved**:
- `_startTime` (DateTime when countdown started)
- `_totalDuration` (e.g., 25 minutes)
- `_sessionType` (WORK or BREAK)
- Current state type (RUNNING, PAUSED, STOPPED)

---

### 4. Resumed (Return from Background)

**Expected Behavior**:
- **If timer was RUNNING before backgrounding**:
  1. Recalculate `remainingTime` from `DateTime.now() - startTime`
  2. If `remainingTime <= 0`: Trigger completion flow immediately
  3. If `remainingTime > 0`: Resume `Timer.periodic` and update UI
- **If timer was STOPPED/PAUSED**: No action needed (maintain state)

**Implementation**:

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    // App returning to foreground
    if (_startTime != null) { // Timer was running
      final elapsed = DateTime.now().difference(_startTime!);
      _remainingTime = _totalDuration - elapsed;
      
      if (_remainingTime <= Duration.zero) {
        // Timer completed while in background
        _onComplete();
      } else {
        // Resume periodic updates
        _timer = Timer.periodic(Duration(seconds: 1), _onTick);
        emit(TimerRunningState(
          remaining: _remainingTime,
          progress: _calculateProgress(),
        ));
      }
    }
  }
}
```

**Accuracy Requirement**: 
- Elapsed time calculation must be accurate within ±2 seconds
- Use `DateTime.now()` instead of accumulating `Timer.periodic` ticks

---

### 5. Detached (App Termination)

**Expected Behavior**:
- Timer state is lost (no persistence in this US)
- Next launch starts fresh with STOPPED state
- **Future Enhancement** (not in this US): Persist timer state to local storage

**Implementation**:
- No special handling needed
- Cubit is disposed automatically
- `_timer?.cancel()` in `close()` method ensures cleanup

```dart
@override
Future<void> close() {
  _timer?.cancel();
  return super.close();
}
```

---

## Lifecycle Integration Checklist

### TimerCubit Requirements

- [ ] Implement `WidgetsBindingObserver` mixin
- [ ] Override `didChangeAppLifecycleState(AppLifecycleState state)`
- [ ] Register observer in `init()`: `WidgetsBinding.instance.addObserver(this)`
- [ ] Unregister observer in `close()`: `WidgetsBinding.instance.removeObserver(this)`
- [ ] Cancel `Timer.periodic` on `paused` lifecycle event
- [ ] Recalculate time and resume on `resumed` lifecycle event
- [ ] Handle "completed in background" scenario (emit COMPLETED state immediately)

### TimerPage Requirements

- [ ] BlocProvider wraps `TimerCubit` (ensures lifecycle observer registration)
- [ ] BlocBuilder listens to state changes
- [ ] On `TimerCompletedState`: Show `AnimatedCompletionIcon`, wait 800ms, then navigate
- [ ] Navigation to break screen uses `context.go('/break')` (from go_router)

---

## Edge Cases & Scenarios

### Scenario 1: User Backgrounds App While Timer Running

**Steps**:
1. User starts timer (remaining: 20:00)
2. User presses home button (app goes to background)
3. 10 minutes pass
4. User returns to app

**Expected Result**:
- Timer shows 10:00 remaining
- Countdown resumes normally
- Accuracy: ±2 seconds (e.g., 10:01 or 9:59 is acceptable)

**Failure Mode**: If using `Timer.periodic` accumulation, timer would show 20:00 (frozen)

---

### Scenario 2: Timer Completes While App Backgrounded

**Steps**:
1. User starts timer (remaining: 5:00)
2. User backgrounds app immediately
3. 6 minutes pass
4. User returns to app

**Expected Result**:
- Completion animation plays immediately upon return
- Success chime plays
- After 800ms, navigates to break screen
- No "negative time" shown

---

### Scenario 3: User Pauses Timer, Then Backgrounds App

**Steps**:
1. User starts timer (remaining: 20:00)
2. User pauses timer (remaining: 15:00)
3. User backgrounds app for 10 minutes
4. User returns to app

**Expected Result**:
- Timer still shows 15:00 (paused state preserved)
- Play button available to resume
- No time has elapsed (correct behavior for paused state)

---

### Scenario 4: Rapid Background/Foreground Cycles

**Steps**:
1. User starts timer
2. User backgrounds app for 5 seconds
3. User foregrounds app
4. User backgrounds app again for 10 seconds
5. User foregrounds app again

**Expected Result**:
- Timer remains accurate across all cycles
- No cumulative drift beyond ±2 seconds total
- No UI glitches or state corruption

---

## Platform Differences

### iOS
- `Timer.periodic` automatically pauses when app is backgrounded
- App has ~30 seconds of background execution time before suspension
- Local notifications can be scheduled (not in this US)

### Android
- `Timer.periodic` may continue firing in background (unreliable)
- App may be killed by OS for memory at any time
- Foreground service would be needed for guaranteed background execution (not in this US)

**Unified Approach**: Use DateTime calculations on both platforms (platform-agnostic)

---

## Testing Strategy

### Unit Tests (TimerCubit)

```dart
test('Timer continues accurately when app backgrounds and resumes', () async {
  final cubit = TimerCubit(totalDuration: Duration(minutes: 25));
  cubit.start();
  
  // Simulate 5 minutes passing in background
  cubit.didChangeAppLifecycleState(AppLifecycleState.paused);
  await Future.delayed(Duration(seconds: 1)); // Simulate time passing
  cubit.didChangeAppLifecycleState(AppLifecycleState.resumed);
  
  // Assert remaining time is approximately 20 minutes (within ±2s)
  final state = cubit.state as TimerRunningState;
  expect(state.remaining.inSeconds, closeTo(1200, 2));
});
```

### Integration Tests

```dart
testWidgets('Timer completes in background and shows animation on return', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Start timer
  await tester.tap(find.byIcon(Icons.play_arrow));
  await tester.pump();
  
  // Simulate app backgrounding for 26 minutes (longer than timer duration)
  // ... (use WidgetsBinding lifecycle simulation)
  
  // Return to foreground
  await tester.pump();
  
  // Assert completion animation is visible
  expect(find.byType(AnimatedCompletionIcon), findsOneWidget);
  
  // Wait 800ms and verify navigation
  await tester.pump(Duration(milliseconds: 800));
  expect(find.text('Break Screen'), findsOneWidget);
});
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-11-03 | Initial lifecycle contract |
