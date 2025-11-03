# Implementation Tasks: Main Timer UI & Controls

**Feature Branch**: `001-main-timer-ui`  
**Created**: November 3, 2025  
**Status**: Ready for Implementation  
**Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

---

## Task Format

- `[P]` = Parallelizable (can work simultaneously with other [P] tasks)
- `[US#]` = User Story label (US1-US4 from spec)
- Each task includes **file path** for tracking

---

## Phase 1: Setup (T001-T004)

**Goal**: Initialize project structure, add dependencies, prepare audio assets

- [X] T001 Create feature directory structure at `lib/features/timer/` with subdirectories: `presentation/pages/`, `presentation/widgets/`, `presentation/cubits/`
- [X] T002 Add `audioplayers: ^5.2.1` dependency to `pubspec.yaml` and add `assets/audio/` to flutter assets configuration
- [X] T003 [P] Run `flutter pub get` to install dependencies
- [X] T004 [P] Create audio assets directory `assets/audio/` and add placeholder audio files `ui_click_neo.mp3` and `success_chime.mp3` (source separately or use free sound libraries)

**Deliverable**: Empty feature folder structure with dependencies ready

---

## Phase 2: Foundational Services & Common Widgets (T005-T011)

**Goal**: Build shared utilities and reusable components that all user stories depend on

**Blocks**: All user story phases (US1-US4)

- [X] T005 Create `lib/features/common/utils/audio_service.dart` - Singleton AudioService class with `preload()` and `playSound()` methods, graceful error handling
- [X] T006 Update `lib/main.dart` - Add `AudioService.instance.preload()` call in main() before runApp() to preload `audio/ui_click_neo.mp3` and `audio/success_chime.mp3`
- [X] T007 Create `lib/features/common/widgets/neo_button.dart` - Primary CTA button extending NeoContainer pattern with shadow animation (Offset(3,3) ↔ Offset(1,1)), haptic feedback via HapticFeedback.lightImpact(), audio playback via AudioService, backgroundColor/padding/borderRadius parameters
- [X] T008 Create `lib/features/common/widgets/neo_icon_button.dart` - Circular icon button variant of NeoButton with Icon child parameter, fixed circular shape (AppShapes.radiusCircle), same shadow/haptic/audio behavior
- [X] T009 [P] Write widget test for NeoButton at `test/features/common/widgets/neo_button_test.dart` - Verify tap callback fires, shadow animation triggers, audio service called
- [X] T010 [P] Write widget test for NeoIconButton at `test/features/common/widgets/neo_icon_button_test.dart` - Verify icon renders, tap works, shadow animates
- [X] T011 Verify audio files load without errors by running app and checking debug console for AudioService preload messages

**Deliverable**: AudioService utility + 2 reusable button widgets with tests

---

## Phase 3: User Story 1 - Complete Focus Session (P1) (T012-T024)

**Goal**: Implement core timer countdown with start/pause/reset controls and completion flow

**Priority**: P1 (MVP - must complete first)  
**Depends on**: Phase 2 (T005-T011)

### 3.1 State Management (T012-T015)

- [X] T012 [US1] Create `lib/features/timer/presentation/cubits/timer_state.dart` - Define abstract TimerCubitState base class and 4 concrete states: TimerInitialState (totalDuration, sessionType), TimerRunningState (remaining, progress), TimerPausedState (remaining, progress), TimerCompletedState (completedSessionType)
- [X] T013 [US1] Create `lib/features/timer/presentation/cubits/timer_cubit.dart` - Implement TimerCubit extending Cubit<TimerCubitState> with WidgetsBindingObserver mixin for lifecycle handling
- [X] T014 [US1] Implement timer methods in TimerCubit: `start()`, `pause()`, `reset()`, background countdown logic using DateTime calculations (not Timer.periodic), emit states accordingly
- [X] T015 [US1] Implement lifecycle methods in TimerCubit: `didChangeAppLifecycleState()` to recalculate remaining time on AppLifecycleState.resumed if timer was running, handle background completion detection

### 3.2 Custom Timer Display Widget (T016-T017)

- [X] T016 [US1] Create `lib/features/timer/presentation/widgets/neo_circular_timer.dart` - CustomPaint widget with CircularTimerPainter class, 280px diameter, 20px stroke width, rounded caps (StrokeCap.round), progress calculation from 0.0-1.0, implement shouldRepaint() to return true only when progress changes
- [X] T017 [US1] In NeoCircularTimer CustomPainter, draw background track circle (full ring in light gray) and foreground progress arc (partial ring in AppColors.primary) using `canvas.drawArc()`, use Curves.easeOut for smooth animation

### 3.3 Completion Animation Widget (T018-T019)

- [X] T018 [US1] Create `lib/features/timer/presentation/widgets/animated_completion_icon.dart` - AnimatedWidget that draws checkmark using CustomPaint with AnimationController (400ms duration, Curves.easeOut), 20px stroke width matching timer ring
- [X] T019 [US1] Implement checkmark drawing animation in AnimatedCompletionIcon - Use `canvas.drawPath()` with Path.lineTo() for checkmark shape, animate path progress from 0.0 to 1.0 using PathMetrics for stroke animation effect

### 3.4 Timer Page Assembly (T020-T022)

- [X] T020 [US1] Create `lib/features/timer/presentation/pages/timer_page.dart` - Scaffold with AppBar (title "App 25:5", zero elevation, backgroundColor: AppColors.background), body with Column layout for session indicator, timer display, control buttons
- [X] T021 [US1] In TimerPage, add BlocBuilder<TimerCubit, TimerCubitState> wrapping timer display area - Show NeoCircularTimer with countdown text overlay (MM:SS format using AppTextStyles.displayLarge) for Initial/Running/Paused states, show AnimatedCompletionIcon for Completed state
- [X] T022 [US1] In TimerPage, add placeholder Container widget for quick-adjust controls positioned between timer display and control button row - This is a non-functional placeholder for future US (displays empty space maintaining layout consistency per FR-043)
- [X] T023 [US1] In TimerPage, add control button row with Row widget containing: NeoIconButton for reset (Icons.refresh), NeoButton for play/pause toggle (Icons.play_arrow / Icons.pause with pill shape), NeoIconButton for skip (Icons.skip_next) - wire to TimerCubit methods

### 3.5 Routing & Navigation (T024-T026)

- [X] T024 [US1] Create `lib/features/timer/timer_route.dart` - Define GoRoute with path '/timer', builder returning BlocProvider wrapping TimerPage, name 'timer'
- [X] T025 [US1] Create placeholder break screen at `lib/features/timer/presentation/pages/break_placeholder_page.dart` - Simple Scaffold with "Break Time!" text (temporary route destination for FR-020 navigation until US 3.1 implements full break screen)
- [X] T026 [US1] Update `lib/config/app_router.dart` - Import timer_route.dart, add timer route and placeholder break route ('/break') to GoRouter routes list, set initialLocation to '/timer' for development

### 3.6 Testing & Validation (T027-T029)

- [X] T027 [US1] [P] Write widget test for NeoCircularTimer at `test/features/timer/presentation/widgets/neo_circular_timer_test.dart` - Verify CustomPaint renders, progress arc updates when progress changes, shouldRepaint returns true/false correctly
- [X] T028 [US1] [P] Write widget test for AnimatedCompletionIcon at `test/features/timer/presentation/widgets/animated_completion_icon_test.dart` - Verify animation completes in 400ms, checkmark path draws progressively
- [X] T029 [US1] Write Cubit test at `test/features/timer/presentation/cubits/timer_cubit_test.dart` - Test state transitions: initial → running → paused → running → completed, verify reset returns to initial, verify DateTime-based calculation maintains ±2s accuracy over 25min (use fake async)

**Deliverable**: Fully functional timer countdown with play/pause/reset controls, completion animation, accurate background tracking

---

## Phase 4: User Story 2 - Skip Session (P2) (T030-T031)

**Goal**: Add skip button functionality to immediately complete session

**Priority**: P2  
**Depends on**: Phase 3 (US1 complete - requires completion flow to exist)

- [X] T030 [US2] In TimerCubit at `lib/features/timer/presentation/cubits/timer_cubit.dart`, implement `skip()` method that transitions from any state (Initial/Running/Paused) to TimerCompletedState, trigger same completion flow as natural countdown
- [X] T031 [US2] In TimerPage at `lib/features/timer/presentation/pages/timer_page.dart`, wire skip button (already added in T023) to call `context.read<TimerCubit>().skip()` on tap

**Deliverable**: Skip button immediately triggers completion animation and navigation

---

## Phase 5: User Story 3 - Tactile Feedback (P2) (T032-T034)

**Goal**: Integrate haptic vibration and audio feedback on all button interactions

**Priority**: P2  
**Depends on**: Phase 2 (foundational widgets with feedback hooks exist)  
**Note**: This can be parallelized with US2 since they don't conflict

- [X] T032 [US3] [P] In NeoButton at `lib/features/common/widgets/neo_button.dart`, add `HapticFeedback.lightImpact()` call in onTapDown handler before shadow animation, wrap in try-catch for graceful degradation on unsupported devices
- [X] T033 [US3] [P] In NeoButton, add `AudioService.instance.playSound('audio/ui_click_neo.mp3')` call in onTapDown handler, ensure it doesn't await (fire-and-forget for <50ms latency)
- [X] T034 [US3] In AnimatedCompletionIcon at `lib/features/timer/presentation/widgets/animated_completion_icon.dart`, add `AudioService.instance.playSound('audio/success_chime.mp3')` in initState when animation starts

**Deliverable**: All buttons provide haptic + audio feedback, completion plays success sound

---

## Phase 6: User Story 4 - Session Type Awareness (P3) (T035-T036)

**Goal**: Display session type indicator showing "WORK" or "BREAK"

**Priority**: P3  
**Depends on**: Phase 3 (TimerPage layout exists)  
**Note**: Can be parallelized with US2/US3

- [X] T035 [US4] [P] Create `lib/features/timer/presentation/widgets/session_type_indicator.dart` - Stateless widget that receives SessionType enum parameter, returns Text widget displaying "WORK" or "BREAK" using AppTextStyles.bodyLarge with bold weight, centered alignment
- [X] T036 [US4] In TimerPage at `lib/features/timer/presentation/pages/timer_page.dart`, add SessionTypeIndicator widget at top of Column (below AppBar), pass sessionType from TimerCubitState

**Deliverable**: Session type label clearly visible at top of timer screen

---

## Phase 7: Polish & Quality Assurance (T037-T042)

**Goal**: Final testing, documentation, and code quality checks

**Depends on**: All user stories complete (US1-US4)

- [X] T037 [P] Write integration test at `test/features/timer/integration/timer_flow_test.dart` - Test complete user journey: app launch → start timer → pause → resume → wait for completion → verify navigation, verify audio plays, verify completion animation
- [X] T038 [P] Run `flutter analyze` and fix any linting errors or warnings in timer feature files
- [X] T039 [P] Run all tests with `flutter test` and verify 100% pass rate for timer feature tests
- [ ] T040 Test on physical device (iOS and Android) - Verify haptics work on supported devices, gracefully degrade on unsupported devices, audio plays correctly, timer accuracy is ±2s over 25min (use stopwatch comparison with logged timestamps for verification) **[BLOCKED: Requires physical devices - see test-report.md for automated test results]**
- [ ] T041 Test edge case: Background app during countdown - Lock screen at 20:00, wait 5 minutes, unlock, verify timer shows ~15:00, verify timer auto-completes if 25min elapsed (use device logs to verify lifecycle events) **[BLOCKED: Requires physical devices]**
- [X] T042 Update README.md with feature documentation - Add "Features" section describing timer functionality, add GIF/screenshot of timer screen

**Deliverable**: Fully tested, production-ready timer feature meeting all success criteria


---

## Task Dependencies & Execution Order

### Critical Path (Must Complete in Order)

1. **Setup** (T001-T004) → Foundation
2. **Foundational** (T005-T011) → Blocks all user stories
3. **US1 Core** (T012-T026) → Enables US2, US3, US4
4. **Polish** (T037-T042) → Final validation

### Parallelization Opportunities

**After Phase 2 complete, can work in parallel:**
- US1 State Management (T012-T015) + US1 Custom Widgets (T016-T019) [different developers]
- US1 Tests (T027-T029) while US1 implementation in progress

**After US1 complete, can work in parallel:**
- US2 (T030-T031) + US3 (T032-T034) + US4 (T035-T036) [independent features]

**During Polish:**
- T037, T038, T039 can run in parallel
- T040-T041 require sequential testing on devices

### Recommended Execution Strategy

**Week 1**: Setup + Foundational (T001-T011)  
**Week 2**: US1 Implementation (T012-T026)  
**Week 3**: US1 Testing (T027-T029) + US2/US3/US4 in parallel (T030-T036)  
**Week 4**: Polish & QA (T037-T042)

**MVP Scope**: Complete through T029 (US1 only) for minimal viable product

---

## Success Metrics Validation

Map each task to success criteria from spec.md:

| Success Criteria | Validated By | Task(s) |
|------------------|--------------|---------|
| SC-001: Identify session type in <1s | Session type indicator visible | T033-T034 |
| SC-002: Start timer in ≤2 taps | Play button immediately functional | T020-T022 |
| SC-003: 60fps animation | CustomPaint with shouldRepaint optimization | T016-T017 |
| SC-004: ±2s accuracy over 25min | DateTime-based calculation + test | T014, T027 |
| SC-005: Feedback <50ms | Haptic/audio fire-and-forget | T030-T032 |
| SC-006: Animation 100ms | Shadow offset animation duration | T007-T008 |
| SC-007: Completion <1.2s | 400ms checkmark + 800ms delay | T018-T019 |
| SC-008: 100% reliability | All button interactions tested | T027-T029, T037 |
| SC-009: Progress ring 1s update | Timer state emits every second | T014, T016 |
| SC-010: Skip <1.2s | Skip triggers same completion flow | T030-T031 |
| SC-011: No visual artifacts | CustomPaint with proper strokeWidth | T016-T017, T018-T019 |

---

## Notes

- **Audio Assets**: Tasks T004 and T011 require sourcing audio files from royalty-free libraries (e.g., freesound.org, zapsplat.com) or creating custom sounds. **Fallback**: Use silent placeholder MP3 files initially (empty 1-second audio files) to unblock development; defer actual audio sourcing to post-MVP phase.
- **Device Testing**: Task T040 requires testing on both iOS and Android physical devices to validate haptic feedback differences (iOS uses Taptic Engine, Android varies by device). Use stopwatch comparison with logged timestamps to verify ±2s accuracy.
- **Timer Accuracy**: Task T029 should use `fake_async` package to fast-forward time and verify DateTime calculation maintains accuracy without waiting real 25 minutes.
- **Constitution Compliance**: All tasks follow Clean Architecture (1_appendix.md) with feature folder structure and Neo-Brutalist design (2_theme.md) using AppColors/AppShapes tokens.
- **Break Screen Placeholder**: Task T025 creates a temporary placeholder for FR-020 navigation requirement. This will be replaced when US 3.1 (Break Screen feature) is implemented in a future specification.
- **Quick-Adjust Controls**: Task T022 adds empty placeholder space for future quick-adjust functionality (satisfies FR-043 layout requirement without implementing interactive controls).

---

**Total Tasks**: 42 (was 40, added T022 for quick-adjust placeholder, T025 for break screen placeholder)  
**Estimated Effort**: 3-4 weeks (1 developer)  
**MVP Scope**: T001-T029 (US1 only)  
**Parallelizable Tasks**: 12 tasks marked with [P]
