# Phase 0: Research & Technical Decisions

**Feature**: Main Timer UI & Controls  
**Date**: 2025-11-03  
**Status**: Complete

## Overview

This document consolidates research findings and technical decisions for implementing the timer feature. All "NEEDS CLARIFICATION" items from Technical Context have been resolved through best practices research and pattern evaluation.

---

## Research Topics

### 1. Background Timer Management (Flutter)

**Question**: How to maintain timer accuracy when app is backgrounded while continuing countdown?

**Decision**: Use `DateTime`-based calculation with `AppLifecycleState` monitoring

**Rationale**:
- Flutter's `Timer` class stops when app is backgrounded on iOS
- `DateTime.now()` calculations remain accurate across app lifecycle transitions
- Approach: Store `startTime` and `duration`, calculate `remaining = duration - DateTime.now().difference(startTime)`
- Listen to `WidgetsBindingObserver.didChangeAppLifecycleState` to recalculate on resume

**Alternatives Considered**:
1. ❌ **Background isolate with Timer**: Overkill for simple countdown; isolates have platform limitations
2. ❌ **WorkManager/background tasks**: Not needed for passive countdown; adds complexity
3. ✅ **DateTime-based calculation**: Industry standard for countdown timers (used by Google Clock, Focus apps)

**Implementation Notes**:
- `TimerCubit` should store: `DateTime? startTime`, `Duration totalDuration`, `Duration remaining`
- On `pause`: Calculate and store current `remaining` time, clear `startTime`
- On `resume from background`: Recalculate `remaining = totalDuration - DateTime.now().difference(startTime!)`
- Update UI via `Stream.periodic(Duration(seconds: 1))` to trigger state emissions

**References**:
- Flutter Clock sample app (datetime-based approach)
- Stack Overflow: "Flutter timer in background" (consensus on DateTime approach)

---

### 2. Audio Playback with Graceful Failure

**Question**: How to play short sound effects (<1s) with graceful failure if audio assets are missing or devices lack audio?

**Decision**: Use `audioplayers` package with try-catch and silent failure

**Rationale**:
- `audioplayers` is the de facto Flutter package for short sound effects (vs. `just_audio` for music/streaming)
- Supports both iOS and Android with minimal setup
- Can preload audio files at app startup for <50ms playback latency
- Allows try-catch around playback calls to gracefully handle missing files

**Alternatives Considered**:
1. ❌ **just_audio**: Optimized for music streaming, overkill for button clicks
2. ❌ **soundpool**: Lower latency but more complex setup, less maintained
3. ✅ **audioplayers**: Balanced approach with good Flutter integration

**Implementation Notes**:
- Create `AudioService` singleton in `lib/features/common/utils/audio_service.dart`
- Preload assets in `main.dart`: `await AudioService.instance.preload(['ui_click_neo.mp3', 'success_chime.mp3'])`
- Playback wrapper:
  ```dart
  Future<void> playSound(String assetPath) async {
    try {
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Audio playback failed: $e');
      // Silent failure - don't block UI
    }
  }
  ```
- Call from Cubit or widgets: `AudioService.instance.playSound('audio/ui_click_neo.mp3')`

**Dependencies to Add**:
```yaml
# pubspec.yaml
dependencies:
  audioplayers: ^5.2.1  # Latest stable as of Nov 2025
```

---

### 3. Haptic Feedback Device Compatibility

**Question**: How to handle haptic feedback on devices that don't support it (older Android phones, some tablets)?

**Decision**: Use Flutter's `HapticFeedback` class with no error handling (already silent-fail)

**Rationale**:
- `HapticFeedback.lightImpact()` is a no-op on devices without haptic capability
- Flutter framework already handles platform differences internally
- No try-catch needed - method simply returns without error

**Alternatives Considered**:
1. ❌ **Manual capability detection**: Adds complexity for no benefit (framework handles it)
2. ✅ **Direct HapticFeedback calls**: Recommended Flutter approach

**Implementation Notes**:
- Import: `import 'package:flutter/services.dart';`
- Call directly in button press handlers: `HapticFeedback.lightImpact();`
- No wrapper service needed - framework provides graceful degradation
- On iOS: Uses `UIImpactFeedbackGenerator` (light style)
- On Android: Uses `VibrationEffect` if API 26+, silent fail on older versions

---

### 4. CustomPaint Performance for 60fps Animation

**Question**: Can `CustomPaint` maintain 60fps for a 280x280 circular progress ring updating every second?

**Decision**: Yes, with proper `shouldRepaint` optimization

**Rationale**:
- `CustomPaint` is Flutter's recommended approach for custom graphics
- A single circular arc is a trivial drawing operation (<1ms on modern devices)
- Key: Implement `shouldRepaint(oldDelegate)` to only repaint when progress changes

**Alternatives Considered**:
1. ❌ **Canvas with manual frame scheduling**: Over-engineered
2. ❌ **Lottie animation**: Cannot dynamically update progress percentage
3. ✅ **CustomPaint with CustomPainter**: Standard Flutter pattern

**Implementation Notes**:
```dart
class CircularTimerPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw background track (full circle)
    // Draw progress arc (progress * 2π radians)
  }
  
  @override
  bool shouldRepaint(CircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress; // Only repaint if progress changed
  }
}
```

**Performance Target**: ~0.1ms paint time (well under 16ms frame budget)

---

### 5. Timer Accuracy Strategy (±2 seconds over 25 minutes)

**Question**: How to achieve ±2 second accuracy over 25 minutes with Flutter's event loop?

**Decision**: Use `DateTime`-based calculations instead of `Timer.periodic` accumulation

**Rationale**:
- `Timer.periodic(Duration(seconds: 1))` has ~10-50ms drift per tick (compounds over time)
- Over 1500 ticks (25 minutes), this can accumulate to 15-75 seconds of error
- DateTime calculations eliminate accumulation error - each tick independently calculates from `startTime`

**Implementation Pattern**:
```dart
void _startTimer() {
  _startTime = DateTime.now();
  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    final elapsed = DateTime.now().difference(_startTime!);
    final remaining = _totalDuration - elapsed;
    
    if (remaining.isNegative) {
      _onComplete();
    } else {
      emit(TimerRunningState(remaining: remaining));
    }
  });
}
```

**Accuracy Analysis**:
- Max error per tick: ~50ms (system clock precision)
- Over 25 minutes: Max accumulated error = ~50ms (not 1500 * 50ms)
- Well within ±2 second requirement

---

### 6. Navigation to Break Screen (Future Story)

**Question**: How to navigate to a screen that doesn't exist yet (US 3.1)?

**Decision**: Create placeholder route in `app_router.dart` with simple "Break Screen Coming Soon" page

**Rationale**:
- Allows timer completion flow to work end-to-end
- Avoids navigation errors during testing
- Can be replaced with full implementation in US 3.1

**Implementation Notes**:
```dart
// lib/config/app_router.dart
GoRoute(
  path: '/break',
  name: 'break',
  builder: (context, state) => Scaffold(
    body: Center(child: Text('Break Screen (US 3.1)')),
  ),
),
```

---

## Technology Stack Summary

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| State Management | `flutter_bloc` | 8.x | Cubit for timer state |
| Routing | `go_router` | 12.x | Navigation to break screen |
| Audio | `audioplayers` | 5.2.1 | Sound effects |
| Haptics | `HapticFeedback` (Flutter SDK) | Built-in | Vibration |
| Graphics | `CustomPaint` | Built-in | Circular progress ring |
| Lifecycle | `WidgetsBindingObserver` | Built-in | Background state tracking |

---

## Open Questions (Deferred to Implementation)

None - all critical technical decisions resolved.

---

## Next Steps

1. ✅ Research complete - proceed to Phase 1 (Design & Contracts)
2. Generate `data-model.md` (TimerSession, TimerState entities)
3. Generate `contracts/` (State machine diagram, lifecycle contract)
4. Generate `quickstart.md` (developer setup guide)
