# Quickstart Guide: Main Timer UI & Controls

**Feature**: Main Timer UI & Controls  
**Branch**: `001-main-timer-ui`  
**Date**: 2025-11-03  
**Target Audience**: Developers implementing this feature

---

## Prerequisites

Before starting implementation, ensure you have:

- [ ] Flutter SDK 3.x installed (`flutter --version`)
- [ ] Dart 3.x installed (comes with Flutter)
- [ ] IDE setup (VS Code with Flutter extension OR Android Studio)
- [ ] Device/emulator ready for testing (iOS Simulator or Android Emulator)
- [ ] Feature branch checked out: `git checkout 001-main-timer-ui`
- [ ] Read: `spec.md`, `plan.md`, `data-model.md`
- [ ] Read: `.specify/memory/1_appendix.md` (architecture rules)
- [ ] Read: `.specify/memory/2_theme.md` (theme rules)

---

## Step 1: Add Dependencies

Add the `audioplayers` package to `pubspec.yaml`:

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  go_router: ^12.1.3
  audioplayers: ^5.2.1  # NEW: For sound effects

flutter:
  assets:
    - assets/audio/  # NEW: Audio assets directory
```

Run:
```bash
flutter pub get
```

---

## Step 2: Add Audio Assets

Create the audio directory and add sound files:

```bash
mkdir -p assets/audio
```

Place these files in `assets/audio/`:
- `ui_click_neo.mp3` (button click sound, ~50ms duration)
- `success_chime.mp3` (completion sound, ~500ms duration)

**Note**: Audio files must be sourced separately (royalty-free or created).

---

## Step 3: Create AudioService Utility

Create `lib/features/common/utils/audio_service.dart`:

```dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Singleton service for playing sound effects
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();

  /// Preload audio files at app startup
  Future<void> preload(List<String> assetPaths) async {
    for (final path in assetPaths) {
      try {
        await _player.setSource(AssetSource(path));
      } catch (e) {
        debugPrint('Failed to preload $path: $e');
      }
    }
  }

  /// Play a sound effect (fire-and-forget)
  Future<void> playSound(String assetPath) async {
    try {
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Audio playback failed: $e');
      // Silent failure - don't block UI
    }
  }

  void dispose() {
    _player.dispose();
  }
}
```

Update `lib/main.dart` to preload audio:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Preload audio assets
  await AudioService.instance.preload([
    'audio/ui_click_neo.mp3',
    'audio/success_chime.mp3',
  ]);
  
  runApp(const App());
}
```

---

## Step 4: Create Common Widgets

### 4.1 NeoButton (lib/features/common/widgets/neo_button.dart)

Extend `NeoContainer` to create a reusable button:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'neo_container.dart';
import '../themes/app_colors.dart';
import '../themes/app_shapes.dart';
import '../utils/audio_service.dart';

class NeoButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsets padding;

  const NeoButton({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor = AppColors.primary,
    this.borderRadius = AppShapes.radiusMedium,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    return NeoContainer(
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      padding: padding,
      onTap: onTap != null
          ? () {
              HapticFeedback.lightImpact();
              AudioService.instance.playSound('audio/ui_click_neo.mp3');
              onTap!();
            }
          : null,
      child: Center(child: child),
    );
  }
}
```

### 4.2 NeoIconButton (lib/features/common/widgets/neo_icon_button.dart)

Similar to NeoButton but optimized for circular icon buttons:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'neo_container.dart';
import '../themes/app_colors.dart';
import '../themes/app_shapes.dart';
import '../utils/audio_service.dart';

class NeoIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  const NeoIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.backgroundColor = AppColors.surface,
    this.iconColor = AppColors.textPrimary,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return NeoContainer(
      backgroundColor: backgroundColor,
      borderRadius: AppShapes.radiusCircle,
      padding: EdgeInsets.all(12),
      onTap: onTap != null
          ? () {
              HapticFeedback.lightImpact();
              AudioService.instance.playSound('audio/ui_click_neo.mp3');
              onTap!();
            }
          : null,
      child: Icon(icon, color: iconColor, size: 24),
    );
  }
}
```

---

## Step 5: Create Timer Feature Structure

Create the feature directory:

```bash
mkdir -p lib/features/timer/presentation/{pages,widgets,cubits}
```

---

## Step 6: Implement TimerCubit

See `contracts/timer_state_contract.md` for full state machine specification.

**Key files to create**:
1. `lib/features/timer/presentation/cubits/timer_state.dart` (state classes)
2. `lib/features/timer/presentation/cubits/timer_cubit.dart` (state logic)

**Critical implementation notes**:
- Use `DateTime.now()` for accuracy, not `Timer.periodic` accumulation
- Implement `WidgetsBindingObserver` for lifecycle handling
- Follow state machine transitions from contract exactly

---

## Step 7: Implement Custom Widgets

### 7.1 NeoCircularTimer (CustomPaint)

Create `lib/features/timer/presentation/widgets/neo_circular_timer.dart`:

- Size: 280x280 pixels
- Stroke width: 20 pixels
- Track color: `AppColors.surface` with border
- Progress color: `AppColors.textPrimary`
- Use `CustomPainter` with `shouldRepaint` optimization

### 7.2 AnimatedCompletionIcon

Create `lib/features/timer/presentation/widgets/animated_completion_icon.dart`:

- CustomPaint checkmark path
- AnimationController (400ms duration, easeOut curve)
- Stroke width: 20 pixels (matches timer ring)
- Draws checkmark over 400ms

### 7.3 SessionTypeIndicator

Create `lib/features/timer/presentation/widgets/session_type_indicator.dart`:

- Simple Text widget
- Uses `AppTextStyles.bodyLarge` with `fontWeight: FontWeight.w700`
- Color: `AppColors.textSecondary`

---

## Step 8: Build TimerPage

Create `lib/features/timer/presentation/pages/timer_page.dart`:

**Layout structure**:
```
SafeArea
└─ Padding (16.0)
   └─ Column
      ├─ SessionTypeIndicator (top-center)
      ├─ Spacer
      ├─ Stack (centered)
      │  ├─ NeoCircularTimer
      │  └─ Text (countdown display)
      ├─ Spacer
      ├─ Row (Quick adjust - layout only, non-functional)
      ├─ SizedBox (height: 24)
      └─ Row (Control buttons)
         ├─ NeoIconButton (reset)
         ├─ NeoButton (play/pause, large)
         └─ NeoIconButton (skip)
```

**BlocBuilder**: Listen to `TimerCubit` states and update UI accordingly.

---

## Step 9: Add Routing

Update `lib/config/app_router.dart`:

```dart
// Add timer route
GoRoute(
  path: '/timer',
  name: 'timer',
  builder: (context, state) => BlocProvider(
    create: (context) => TimerCubit(
      totalDuration: Duration(minutes: 25),
      sessionType: SessionType.WORK,
    ),
    child: TimerPage(),
  ),
),

// Add placeholder break route (for US 3.1)
GoRoute(
  path: '/break',
  name: 'break',
  builder: (context, state) => Scaffold(
    body: Center(child: Text('Break Screen (US 3.1)')),
  ),
),
```

Create `lib/features/timer/timer_route.dart` (follows 1_appendix.md pattern):

```dart
class TimerRoute {
  static GoRoute create(String path) {
    return GoRoute(
      path: path,
      name: 'timer',
      builder: (context, state) => BlocProvider(
        create: (context) => TimerCubit(
          totalDuration: Duration(minutes: 25),
          sessionType: SessionType.WORK,
        ),
        child: TimerPage(),
      ),
    );
  }
}
```

---

## Step 10: Test Locally

### Run the app:
```bash
flutter run
```

### Manual test checklist:
- [ ] Timer starts at 25:00
- [ ] Play button starts countdown
- [ ] Pause button stops countdown
- [ ] Reset button returns to 25:00
- [ ] Skip button triggers completion animation
- [ ] Countdown reaches 00:00 → completion animation → navigates to break screen
- [ ] Haptic feedback works on tap (device-dependent)
- [ ] Audio plays on tap (check device volume)
- [ ] Background app → return → timer shows correct elapsed time (±2s)

---

## Step 11: Run Tests

```bash
# Unit tests
flutter test test/features/timer/cubits/timer_cubit_test.dart

# Widget tests
flutter test test/features/timer/widgets/

# Integration tests
flutter test integration_test/timer_flow_test.dart
```

---

## Step 12: Run Quality Gates

```bash
# Static analysis
flutter analyze

# Ensure zero errors before committing
```

---

## Troubleshooting

### Audio not playing
- Check `pubspec.yaml` has `assets/audio/` listed under `flutter > assets`
- Verify audio files exist in `assets/audio/` directory
- Check device volume is not muted
- Review AudioService logs in console

### Haptics not working
- iOS Simulator does NOT support haptics (test on real device)
- Some Android devices lack haptic hardware (expected graceful degradation)

### Timer drifts more than ±2 seconds
- Verify using DateTime calculations, not Timer.periodic accumulation
- Check background lifecycle handling is implemented correctly

### Button animations not smooth
- Verify `AnimatedContainer` duration is 100ms
- Check `Curve.easeOut` is used
- Ensure no heavy computations in build method

---

## Next Steps

After implementation complete:

1. Run `/speckit.tasks` to generate detailed task breakdown
2. Commit code following commit message conventions
3. Create PR referencing `specs/001-main-timer-ui/spec.md`
4. Request code review with architecture compliance checklist
5. Merge to main after approval

---

## Support Resources

- **Spec**: `specs/001-main-timer-ui/spec.md`
- **Plan**: `specs/001-main-timer-ui/plan.md`
- **State Contract**: `specs/001-main-timer-ui/contracts/timer_state_contract.md`
- **Lifecycle Contract**: `specs/001-main-timer-ui/contracts/timer_lifecycle_contract.md`
- **Architecture Rules**: `.specify/memory/1_appendix.md`
- **Theme Rules**: `.specify/memory/2_theme.md`

---

**Happy Coding! 🚀**
