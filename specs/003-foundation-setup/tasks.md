# Tasks: Foundation, Architecture & Theme Setup

**Input**: Design documents from `/specs/003-foundation-setup/`
**Prerequisites**: plan.md (✓), spec.md (✓), research.md (✓), data-model.md (✓), quickstart.md (✓)

**Tests**: Not applicable for this infrastructure feature - testing will be done through build verification and visual inspection.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4, US5)
- Include exact file paths in descriptions

## Path Conventions

This is a Flutter mobile project. All paths are relative to repository root.
- Source code: `lib/`
- Configuration: `pubspec.yaml`
- Assets: `assets/`

---

## Phase 1: Setup (Project Initialization)

**Purpose**: Prepare development environment and install dependencies

- [X] T001 Update pubspec.yaml with required dependencies: go_router ^14.6.1, flutter_bloc ^8.1.6, equatable ^2.0.7, google_fonts ^6.1.0
- [X] T002 Declare assets in pubspec.yaml: assets/audio/ directory
- [X] T003 Run flutter pub get to install all dependencies
- [X] T004 Verify Flutter SDK version is 3.9.2 or higher with flutter --version

**Checkpoint**: Dependencies installed and ready for implementation ✓

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core folder structure that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 Create lib/config/ directory for global configuration
- [X] T006 Create lib/features/ directory for feature modules
- [X] T007 Create lib/features/common/ directory for shared components
- [X] T008 Create lib/features/common/themes/ directory for theme tokens
- [X] T009 Create lib/features/common/widgets/ directory for reusable widgets
- [X] T010 Create lib/features/common/utils/ directory for utilities (empty initially)
- [X] T011 Create lib/features/storage/ directory for data layer
- [X] T012 Create lib/features/storage/domain/ directory for domain layer
- [X] T013 Create lib/features/storage/domain/entities/ directory with .gitkeep placeholder
- [X] T014 Create lib/features/storage/domain/repos/ directory with .gitkeep placeholder
- [X] T015 Create lib/features/storage/data/ directory with .gitkeep placeholder

**Checkpoint**: Foundation folder structure complete - user story implementation can now begin in parallel ✓

---

## Phase 3: User Story 1 - Core Architecture Setup (Priority: P1) 🎯 MVP

**Goal**: Establish the Flutter Clean Architecture folder structure per 1_appendix.md

**Independent Test**: Run `flutter analyze` and verify zero errors; manually inspect folder structure matches 1_appendix.md

**Success Criteria**:
- All required directories exist under lib/
- Folder hierarchy matches 1_appendix.md canonical layout
- Project builds without errors

### Implementation for User Story 1

- [X] T016 [US1] Verify all directories from Phase 2 exist and match 1_appendix.md structure
- [X] T017 [US1] Create validation script to check folder structure compliance in .specify/scripts/
- [X] T018 [US1] Run flutter analyze to verify project structure is valid
- [X] T019 [US1] Document folder structure in README.md with brief description of each directory

**Checkpoint**: Core architecture is established and validated ✓

---

## Phase 4: User Story 2 - Core Application Files (Priority: P1)

**Goal**: Create essential application bootstrap files (main.dart, app.dart, app_router.dart) per project standards

**Independent Test**: Run `flutter run` and verify app launches successfully with a basic screen

**Success Criteria**:
- App launches without errors
- Routing system is initialized
- Dependency injection is bootstrapped

### Implementation for User Story 2

- [X] T020 [P] [US2] Create lib/main.dart with entry point calling runApp(App())
- [X] T021 [P] [US2] Create lib/config/app_config.dart with environment configuration class (useFirebaseEmulator, firestoreProjectId, enableDebugLogs fields)
- [X] T022 [US2] Create lib/config/app_router.dart with GoRouter configuration owning all route paths (initially just '/' route)
- [X] T023 [US2] Create lib/app.dart with MultiBlocProvider (empty providers list initially) and MaterialApp.router using AppRouter.router
- [X] T024 [US2] Add import statements in app.dart for app_router.dart and future theme files
- [X] T025 [US2] Configure MaterialApp theme property to use scaffoldBackgroundColor temporarily (will be replaced with full theme in US3)
- [X] T026 [US2] Create a temporary HomePage widget in lib/features/common/widgets/ for testing app launch
- [X] T027 [US2] Run flutter run to verify app launches successfully
- [X] T028 [US2] Run flutter analyze to verify zero errors

**Checkpoint**: Core application files created and app launches successfully ✓

---

## Phase 5: User Story 3 - Theme System Implementation (Priority: P2)

**Goal**: Create all theme definition files (colors, typography, shapes) per Neo-Brutalist design system from 2_theme.md

**Independent Test**: Import theme files in a test widget and verify all tokens are accessible and match 2_theme.md specifications

**Success Criteria**:
- All color tokens defined with exact hex values
- All typography roles defined with correct properties
- All shape tokens defined per spec
- Theme files can be imported without errors

### Implementation for User Story 3

- [X] T029 [P] [US3] Create lib/features/common/themes/app_colors.dart with all 17 color tokens from 2_theme.md (background: #FAF8F1, surface: #FFFFFF, surfaceDisabled: #E0E0E0, textPrimary: #000000, textSecondary: #8A8A8E, border: #000000, borderDisabled: #BDBDBD, shadow: #000000, primary: #FDEE8A, onPrimary: #000000, secondary: #F0E4FF, onSecondary: #000000, accentPink: #FFD6F5, accentGreen: #D3FFAE, accentPurple: #E4D6FF, success: #4CAF50, error: #F44336)
- [X] T030 [P] [US3] Create lib/features/common/themes/app_text_styles.dart with all 6 typography roles using GoogleFonts.inter (display: Bold 28, titleLarge: Bold 26, titleMedium: SemiBold 20, bodyLarge: SemiBold 16, bodySmall: Regular 14, caption: Regular 12)
- [X] T031 [P] [US3] Create lib/features/common/themes/app_shapes.dart with all shape tokens (radiusLarge: 20.0, radiusMedium: 16.0, radiusSmall: 8.0, radiusCircle: 99.0, borderWidth: 1.5, offset: Offset(3,3), offsetPressed: Offset(1,1), blurRadius: 0.0, pagePadding: 16.0, cardPadding: 20.0, listItemPaddingV: 12.0, listItemPaddingH: 16.0)
- [X] T032 [US3] Add import for google_fonts package in app_text_styles.dart
- [X] T033 [US3] Update lib/app.dart to import and use AppColors.background for scaffoldBackgroundColor
- [X] T034 [US3] Create a test widget in temporary HomePage that displays text using AppTextStyles to verify typography
- [X] T035 [US3] Verify all color hex values match 2_theme.md exactly by visual inspection
- [X] T036 [US3] Run flutter analyze to verify zero errors
- [X] T037 [US3] Run flutter run to verify theme tokens work correctly

**Checkpoint**: Theme system fully implemented and verified ✓

---

## Phase 6: User Story 4 - Core Reusable Widgets (Priority: P2)

**Goal**: Create foundational reusable widgets (custom scaffold, NeoContainer) following Neo-Brutalist style

**Independent Test**: Create a sample page using CustomScaffold and NeoContainer, verify proper Neo-Brutalist styling (thick borders, hard shadows, correct spacing)

**Success Criteria**:
- CustomScaffold provides safe area handling and consistent padding
- NeoContainer renders with thick black borders and hard black shadows
- Widgets display Neo-Brutalist aesthetic correctly

### Implementation for User Story 4

- [X] T038 [P] [US4] Create lib/features/common/widgets/neo_container.dart with StatelessWidget implementing Neo-Brutalist container (props: child, backgroundColor, borderRadius, padding, isDisabled, isPressed, onTap, onLongPress, animationDuration, animationCurve)
- [X] T039 [P] [US4] Create lib/features/common/widgets/custom_scaffold.dart with StatelessWidget providing page wrapper (props: body, appBar, bottomNavigationBar, backgroundColor, padding, useSafeArea)
- [X] T040 [US4] Implement NeoContainer build method using AnimatedContainer with BoxDecoration (border: Border.all with AppColors.border and AppShapes.borderWidth, borderRadius using provided radius, boxShadow with AppColors.shadow and AppShapes.offset with blurRadius 0)
- [X] T041 [US4] Implement state-dependent styling in NeoContainer (isDisabled → surfaceDisabled background + borderDisabled + no shadow, isPressed → offsetPressed shadow)
- [X] T042 [US4] Add GestureDetector wrapper in NeoContainer to handle onTap/onLongPress with tap state management
- [X] T043 [US4] Implement CustomScaffold build method using Scaffold with SafeArea wrapper and EdgeInsets.all(AppShapes.pagePadding) padding
- [X] T044 [US4] Update temporary HomePage to use CustomScaffold instead of bare Scaffold
- [X] T045 [US4] Add test content to HomePage using NeoContainer with various props (default, with primary background, disabled state, with onTap)
- [X] T046 [US4] Run flutter run and visually verify Neo-Brutalist styling: thick borders (1.5px), hard shadows (no blur), correct offsets (3,3 default, 1,1 pressed)
- [X] T047 [US4] Test disabled state rendering (gray background, gray border, no shadow)
- [X] T048 [US4] Run flutter analyze to verify zero errors

**Checkpoint**: Core reusable widgets created and Neo-Brutalist styling verified ✓

---

## Phase 7: User Story 5 - Dependencies & Assets Configuration (Priority: P3)

**Goal**: Ensure pubspec.yaml is fully configured with all required packages and asset declarations

**Independent Test**: Run `flutter pub get` successfully and verify all imports work without errors

**Success Criteria**:
- All required packages install without conflicts
- Assets load correctly
- All package imports are available in codebase

### Implementation for User Story 5

- [X] T049 [US5] Verify pubspec.yaml contains all dependencies from T001 (go_router, flutter_bloc, equatable, google_fonts)
- [X] T050 [US5] Verify pubspec.yaml declares assets/audio/ directory under flutter.assets
- [X] T051 [US5] Add uses-material-design: true in flutter section of pubspec.yaml if not already present
- [X] T052 [US5] Run flutter pub get and verify successful installation with no conflicts
- [X] T053 [US5] Test import of go_router in app_router.dart compiles successfully
- [X] T054 [US5] Test import of flutter_bloc in app.dart compiles successfully
- [X] T055 [US5] Test import of google_fonts in app_text_styles.dart compiles successfully
- [X] T056 [US5] Run flutter analyze to verify zero errors

**Checkpoint**: All dependencies configured and working ✓

---

## Phase 8: Polish & Final Validation

**Purpose**: Cross-cutting concerns, documentation, and final quality checks

- [X] T057 Remove temporary HomePage widget or convert it to a proper demo/example page
- [X] T058 Add comprehensive documentation comments to AppColors class explaining semantic meaning of each token
- [X] T059 Add comprehensive documentation comments to AppTextStyles class explaining when to use each role
- [X] T060 Add comprehensive documentation comments to AppShapes class explaining Neo-Brutalist design principles
- [X] T061 Add comprehensive documentation comments to NeoContainer explaining all props and states
- [X] T062 Add comprehensive documentation comments to CustomScaffold explaining usage pattern
- [X] T063 Verify all files have proper imports and no unused imports
- [X] T064 Run flutter analyze and ensure zero errors and zero warnings
- [X] T065 Run flutter build apk --debug to verify project builds successfully
- [X] T066 Create a visual verification checklist comparing rendered UI against 2_theme.md specifications
- [X] T067 Test app launch time is under 3 seconds on mid-range device
- [X] T068 Verify folder structure exactly matches 1_appendix.md by running validation script from T017
- [X] T069 Review quickstart.md and ensure all code examples match implemented code
- [X] T070 Update README.md with quick start guide referencing quickstart.md
- [X] T071 Run final flutter analyze to confirm zero errors before completion

**Final Checkpoint**: All quality gates passed ✅

---

## Dependencies & Implementation Strategy

### User Story Dependencies

```
US1 (Core Architecture) [MUST BE FIRST]
  ↓
US2 (Core Application Files) [DEPENDS ON US1]
  ↓
US3 (Theme System) [DEPENDS ON US2] ──┐
  ↓                                    │
US4 (Core Widgets) [DEPENDS ON US3] ←─┘
  ↓
US5 (Dependencies Config) [INDEPENDENT, CAN BE DONE ANYTIME]
```

**Critical Path**: US1 → US2 → US3 → US4

**Parallelization Opportunities**:
- US3 theme files (T029, T030, T031) can be done in parallel
- US4 widget files (T038, T039) can be done in parallel
- US5 is independent and can be done early (already done in Phase 1)

### MVP Scope (Minimum Viable Product)

**Recommended MVP**: US1 + US2 only
- **Delivers**: Working app with proper architecture that launches successfully
- **Estimated Effort**: ~12 tasks (T005-T028 excluding polish)
- **Testing**: App launches and displays basic screen

**Full Foundation**: US1 + US2 + US3 + US4
- **Delivers**: Complete foundation with theme system and reusable widgets
- **Estimated Effort**: ~48 tasks (excluding polish)
- **Testing**: Full Neo-Brutalist design system operational

**Polish**: Add Phase 8 tasks
- **Delivers**: Production-ready foundation with documentation
- **Estimated Effort**: +15 tasks
- **Testing**: Complete quality validation

### Execution Recommendations

1. **Start with US1**: Complete Phase 2 and Phase 3 (T005-T019)
2. **Then US2**: Complete Phase 4 (T020-T028) to get a working app
3. **Validate MVP**: Ensure app launches before proceeding
4. **Build Theme**: Complete US3 (T029-T037) for design system
5. **Add Widgets**: Complete US4 (T038-T048) for reusable components
6. **Verify Config**: Quick check of US5 (T049-T056)
7. **Polish**: Add documentation and final validation (T057-T071)

### Task Count Summary

- **Phase 1 (Setup)**: 4 tasks
- **Phase 2 (Foundational)**: 11 tasks
- **Phase 3 (US1)**: 4 tasks
- **Phase 4 (US2)**: 9 tasks
- **Phase 5 (US3)**: 9 tasks
- **Phase 6 (US4)**: 11 tasks
- **Phase 7 (US5)**: 8 tasks
- **Phase 8 (Polish)**: 15 tasks

**Total**: 71 tasks

**Parallel Tasks**: 8 tasks marked with [P] can run in parallel with other tasks in same phase

**Critical Tasks**: T005-T019 (foundational structure) must complete before any user story work

---

## Format Validation ✅

All tasks follow required format:
- ✅ Checkbox prefix `- [ ]`
- ✅ Sequential task IDs (T001-T071)
- ✅ [P] markers for parallelizable tasks (8 tasks)
- ✅ [US#] labels for user story tasks (37 tasks across 5 stories)
- ✅ Exact file paths in descriptions
- ✅ Clear, actionable descriptions

## Independent Testing Criteria

### US1: Core Architecture Setup
**Test**: Run folder structure validation script; run `flutter analyze`
**Pass**: All directories exist per 1_appendix.md; zero errors

### US2: Core Application Files
**Test**: Run `flutter run` on device/emulator
**Pass**: App launches and displays basic screen without crashes

### US3: Theme System Implementation
**Test**: Import theme files in test widget; compare hex values against 2_theme.md
**Pass**: All tokens accessible; values match spec exactly

### US4: Core Reusable Widgets
**Test**: Create sample page with NeoContainer and CustomScaffold; visual inspection
**Pass**: Thick borders (1.5px), hard shadows (no blur), correct spacing, state transitions work

### US5: Dependencies & Assets Configuration
**Test**: Run `flutter pub get`; test all imports compile
**Pass**: No dependency conflicts; all packages available

---

**Ready for Implementation** 🚀

All tasks are specific, have clear file paths, and follow the constitutional rules from 1_appendix.md and 2_theme.md.
