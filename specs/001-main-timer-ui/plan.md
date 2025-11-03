# Implementation Plan: Main Timer UI & Controls

**Branch**: `001-main-timer-ui` | **Date**: 2025-11-03 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-main-timer-ui/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

This feature implements the main timer screen for a Pomodoro-style productivity app with Neo-Brutalist design aesthetics. Users can start, pause, reset, and skip 25-minute work sessions with rich visual, tactile (haptic), and audio feedback. The timer displays a large circular progress indicator with a countdown, includes a session type indicator ("WORK"/"BREAK"), and provides four control buttons (play/pause, reset, skip). Upon completion, an animated checkmark appears with a success sound before auto-navigating to a break screen. The implementation emphasizes smooth 60fps animations, sub-50ms feedback latency, and graceful degradation for devices without haptic support. Timer state persists across app backgrounding with accurate background countdown tracking (±2 second accuracy over 25 minutes).

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: 
- `flutter_bloc` (state management via Cubit)
- `go_router` (navigation)
- `audioplayers` (sound effects)
- Standard Flutter services (HapticFeedback for vibration)

**Storage**: In-memory state management (timer state via Cubit); no persistent storage required for this US  
**Testing**: Flutter widget tests, integration tests for timer accuracy  
**Target Platform**: iOS 14+ and Android 7+ (mobile)  
**Project Type**: Mobile (Flutter) - follows Clean Architecture with feature-based structure  
**Performance Goals**: 
- 60fps UI animations (progress ring, button shadows)
- <50ms haptic/audio feedback latency
- ±2 second timer accuracy over 25 minutes
- <100ms button press animation

**Constraints**: 
- Must gracefully handle devices without haptic capability
- Must maintain timer accuracy when app is backgrounded
- Timer must continue running in background (platform lifecycle handling)
- Audio files must not block UI if loading fails

**Scale/Scope**: 
- Single feature module (`timer`)
- 4 new custom widgets (NeoButton, NeoIconButton, NeoCircularTimer, AnimatedCompletionIcon)
- 1 main screen (TimerPage)
- 1 Cubit for state management
- 2-3 audio assets (ui_click_neo.mp3, success_chime.mp3)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

This section verifies compliance with all governance rules:
- **constitution.md**: Spec-driven development, quality gates, governance procedures
- **1_appendix.md**: Flutter Clean Architecture, folder structure, layer separation
- **2_theme.md**: Neo-Brutalist design system, color tokens, typography, component patterns

### Compliance Status

#### ✅ constitution.md Compliance

| Principle | Status | Notes |
|-----------|--------|-------|
| **Spec-Driven Development** | ✅ PASS | This plan derives from approved spec.md with all requirements traced |
| **Separation of Rules** | ✅ PASS | Plan references all three rule files appropriately |
| **Strict Architecture Compliance** | ✅ PASS | Feature follows `lib/features/timer/` structure per 1_appendix.md |
| **Strict Theme Compliance** | ✅ PASS | All UI components use AppColors, AppShapes, reuse NeoContainer where possible |
| **Quality Gates** | ✅ PASS | `flutter analyze` will be run; widget tests required for custom widgets |

#### ✅ 1_appendix.md Compliance (Flutter Clean Architecture)

| Requirement | Status | Implementation |
|-------------|--------|----------------|
| **Feature Folder Structure** | ✅ PASS | `lib/features/timer/` with `presentation/` subfolder |
| **Route File Separation** | ✅ PASS | `timer_route.dart` at feature root (receives path from app_router.dart) |
| **Cubit/State Separation** | ✅ PASS | `timer_cubit.dart` and `timer_state.dart` in separate files under `presentation/cubits/` |
| **Presentation Layer Only** | ✅ PASS | No repository/data layer needed (pure UI state management) |
| **Widget Organization** | ✅ PASS | Custom widgets go in `presentation/widgets/` (feature-specific) or `features/common/widgets/` (reusable) |
| **Naming Conventions** | ✅ PASS | All files use `lower_snake_case` (e.g., `neo_circular_timer.dart`) |

**Folder Structure Preview:**
```
lib/
├── features/
│   ├── common/
│   │   ├── themes/           # ✅ Already exists (AppColors, AppShapes, AppTextStyles)
│   │   └── widgets/          # ✅ Extend with NeoButton, NeoIconButton
│   │       ├── neo_container.dart        # ✅ Already exists - reuse for buttons
│   │       ├── neo_button.dart           # 🆕 NEW (Primary/Secondary CTA)
│   │       └── neo_icon_button.dart      # 🆕 NEW (Circular icon buttons)
│   └── timer/                # 🆕 NEW FEATURE
│       ├── timer_route.dart
│       └── presentation/
│           ├── pages/
│           │   └── timer_page.dart
│           ├── widgets/
│           │   ├── neo_circular_timer.dart           # 🆕 CustomPaint timer ring
│           │   ├── animated_completion_icon.dart     # 🆕 Checkmark animation
│           │   └── session_type_indicator.dart       # 🆕 "WORK"/"BREAK" label
│           └── cubits/
│               ├── timer_cubit.dart
│               └── timer_state.dart
```

#### ✅ 2_theme.md Compliance (Neo-Brutalist Design)

| Requirement | Status | Implementation |
|-------------|--------|----------------|
| **Color System Usage** | ✅ PASS | All widgets use `AppColors.*` tokens (no hardcoded hex values) |
| **Typography Roles** | ✅ PASS | Timer display uses `AppTextStyles.displayLarge`, labels use `bodyLarge`, etc. |
| **NeoContainer Pattern** | ✅ PASS | NeoButton and NeoIconButton extend NeoContainer behavior |
| **Hard Shadows (no blur)** | ✅ PASS | All custom widgets use `blurRadius: 0.0`, `offset: Offset(3,3)` |
| **Thick Borders** | ✅ PASS | All widgets use `AppShapes.borderWidth` (1.5px) with `AppColors.border` |
| **Shadow Animation** | ✅ PASS | Button press animations: `Offset(3,3)` → `Offset(1,1)` on tap (100ms, easeOut) |
| **Circular Progress Style** | ✅ PASS | NeoCircularTimer uses 20px stroke width, rounded caps, CustomPaint implementation |
| **Motion/Transitions** | ✅ PASS | Completion flow uses vertical SlideTransition per 2_theme.md modal pattern |

**Design Token Mapping:**
- Background: `AppColors.background` (#FAF8F1)
- Primary Button: `AppColors.primary` (#FDEE8A) with `AppShapes.radiusMedium` (16.0)
- Secondary Buttons: `AppColors.surface` (white) with `AppShapes.radiusCircle` (99.0)
- Timer Text: `AppTextStyles.displayLarge` (48px, bold)
- Session Label: `AppTextStyles.bodyLarge` (16px, semibold)

### Gates Summary

**All gates PASS** - No violations detected. Feature adheres to:
1. ✅ Spec-driven workflow (traceable requirements)
2. ✅ Clean Architecture folder structure
3. ✅ Neo-Brutalist design system
4. ✅ Quality standards (analyze + tests)

**No complexity justification required.**

## Project Structure

### Documentation (this feature)

```text
specs/001-main-timer-ui/
├── spec.md              # Feature specification (input)
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (background timer strategies, audio handling)
├── data-model.md        # Phase 1 output (TimerSession, TimerState entities)
├── quickstart.md        # Phase 1 output (developer onboarding guide)
├── contracts/           # Phase 1 output (State contracts, Timer API)
│   ├── timer_state_contract.md
│   └── timer_lifecycle_contract.md
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT YET CREATED)
```

### Source Code (repository root)

```text
lib/
├── app.dart                          # ✅ Existing - App root with DI + routing
├── main.dart                         # ✅ Existing - Entry point
├── config/
│   ├── app_config.dart               # ✅ Existing - Global config
│   └── app_router.dart               # 🔧 MODIFY - Add timer routes
├── features/
│   ├── common/
│   │   ├── themes/
│   │   │   ├── app_colors.dart       # ✅ Existing - Reuse ColorSystem
│   │   │   ├── app_shapes.dart       # ✅ Existing - Reuse Radii, BorderWidth
│   │   │   └── app_text_styles.dart  # ✅ Existing - Reuse Typography
│   │   └── widgets/
│   │       ├── neo_container.dart    # ✅ Existing - Base for NeoButton
│   │       ├── neo_button.dart       # 🆕 NEW - Primary/Secondary CTA buttons
│   │       └── neo_icon_button.dart  # 🆕 NEW - Circular icon buttons
│   ├── storage/                      # ✅ Existing (unused for this feature)
│   └── timer/                        # 🆕 NEW FEATURE MODULE
│       ├── timer_route.dart          # 🆕 Timer route definitions
│       └── presentation/
│           ├── pages/
│           │   └── timer_page.dart   # 🆕 Main timer screen
│           ├── widgets/
│           │   ├── neo_circular_timer.dart       # 🆕 CustomPaint circular progress
│           │   ├── animated_completion_icon.dart # 🆕 Checkmark animation
│           │   └── session_type_indicator.dart   # 🆕 "WORK"/"BREAK" label
│           └── cubits/
│               ├── timer_cubit.dart              # 🆕 Timer state management
│               └── timer_state.dart              # 🆕 Timer state classes
└── assets/
    └── audio/                        # 🆕 NEW DIRECTORY
        ├── ui_click_neo.mp3          # 🆕 Button click sound
        └── success_chime.mp3         # 🆕 Completion sound

test/
└── features/
    └── timer/                        # 🆕 NEW TEST DIRECTORY
        ├── presentation/
        │   ├── widgets/
        │   │   ├── neo_circular_timer_test.dart
        │   │   └── animated_completion_icon_test.dart
        │   └── cubits/
        │       └── timer_cubit_test.dart
        └── integration/
            └── timer_flow_test.dart  # 🆕 Complete timer flow test
```

**Structure Decision**: 
This follows **Flutter Mobile Clean Architecture** (Option 3 from template). The timer feature is self-contained under `lib/features/timer/` with only presentation layer (no domain/data layers needed as this is pure UI state). Common reusable widgets (NeoButton, NeoIconButton) are placed in `features/common/widgets/` to be shared across future features. Feature-specific widgets (NeoCircularTimer, AnimatedCompletionIcon) stay within `features/timer/presentation/widgets/` as they're unlikely to be reused elsewhere. This structure supports the Clean Architecture principle while maintaining feature independence.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

**No violations detected** - This section is intentionally left empty as all constitution gates passed.

---

## Phase Completion Summary

### ✅ Phase 0: Research Complete

**Artifacts Generated**:
- [`research.md`](./research.md) - Technical decisions and best practices research

**Key Decisions**:
1. Background timer strategy: DateTime-based calculations (not Timer.periodic accumulation)
2. Audio playback: `audioplayers` package with graceful failure handling
3. Haptic compatibility: Flutter's HapticFeedback with built-in silent-fail
4. CustomPaint performance: Optimized with `shouldRepaint` for 60fps
5. Timer accuracy: DateTime calculations for ±2s accuracy over 25 minutes
6. Break screen navigation: Placeholder route until US 3.1 implementation

### ✅ Phase 1: Design & Contracts Complete

**Artifacts Generated**:
- [`data-model.md`](./data-model.md) - Entity definitions and state structures
- [`contracts/timer_state_contract.md`](./contracts/timer_state_contract.md) - State machine specification
- [`contracts/timer_lifecycle_contract.md`](./contracts/timer_lifecycle_contract.md) - App lifecycle handling
- [`quickstart.md`](./quickstart.md) - Developer onboarding guide

**Design Highlights**:
- **State Machine**: 4 states (STOPPED, RUNNING, PAUSED, COMPLETED) with 5 transitions
- **Lifecycle Handling**: WidgetsBindingObserver pattern for background/foreground accuracy
- **Widget Architecture**: 
  - Reusable: NeoButton, NeoIconButton (extend NeoContainer)
  - Feature-specific: NeoCircularTimer, AnimatedCompletionIcon, SessionTypeIndicator
- **Audio Service**: Singleton pattern with preloading for <50ms latency

**Agent Context Updated**:
- ✅ GitHub Copilot instructions updated with Dart 3.x / Flutter 3.x
- ✅ Project type added: Mobile (Flutter Clean Architecture)
- ✅ State management approach documented: flutter_bloc (Cubit pattern)

---

## Next Steps

### For Developers

1. **Start Implementation**: Follow [`quickstart.md`](./quickstart.md) step-by-step guide
2. **Reference Contracts**: Adhere strictly to state machine and lifecycle contracts
3. **Test Continuously**: Run unit tests after each component completion
4. **Quality Gates**: Ensure `flutter analyze` passes with zero errors

### For Project Management

1. **Generate Tasks**: Run `/speckit.tasks` to break down into granular development tasks
2. **Assign Work**: Distribute tasks based on developer expertise (UI vs. state management)
3. **Track Progress**: Monitor against success criteria in `spec.md`
4. **Schedule Review**: Plan code review with architecture + theme compliance checklist

---

## Planning Completion Report

**Status**: ✅ **COMPLETE** (Phases 0-1)  
**Branch**: `001-main-timer-ui`  
**Plan File**: `/Users/jojo/Documents/a255_app/specs/001-main-timer-ui/plan.md`

**Artifacts Summary**:
| Artifact | Status | Purpose |
|----------|--------|---------|
| `spec.md` | ✅ Input | Feature requirements and success criteria |
| `plan.md` | ✅ Complete | This file - implementation strategy |
| `research.md` | ✅ Complete | Technical decisions and best practices |
| `data-model.md` | ✅ Complete | Entity definitions and state structures |
| `contracts/timer_state_contract.md` | ✅ Complete | State machine specification |
| `contracts/timer_lifecycle_contract.md` | ✅ Complete | App lifecycle handling contract |
| `quickstart.md` | ✅ Complete | Developer onboarding guide |
| `tasks.md` | ⏳ Pending | Awaiting `/speckit.tasks` command |

**Constitution Compliance**: ✅ All gates passed (no violations)

**Ready for**: Task generation (`/speckit.tasks`) and implementation phase

---

**Plan completed on**: 2025-11-03  
**Estimated implementation effort**: 3-5 developer days  
**Risk level**: Low (no external dependencies, proven patterns)
