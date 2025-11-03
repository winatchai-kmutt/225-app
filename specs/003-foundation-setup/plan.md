# Implementation Plan: Foundation, Architecture & Theme Setup

**Branch**: `003-foundation-setup` | **Date**: 2025-11-03 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/003-foundation-setup/spec.md`

**Note**: This plan establishes the foundational structure, theme system, and core reusable components that all future features will build upon.

## Summary

This feature creates the complete foundational layer for the a255_app Flutter project by:

1. **Establishing Clean Architecture** - Creating the canonical folder structure per `1_appendix.md` with proper separation of concerns (config, features, storage layers)
2. **Implementing Neo-Brutalist Theme** - Defining all color tokens, typography roles, and shape specifications from `2_theme.md` as reusable Dart constants
3. **Building Core Components** - Creating the `NeoContainer` widget and custom scaffold that enforce the design system
4. **Bootstrapping App Infrastructure** - Setting up dependency injection, routing (go_router), and state management (flutter_bloc/Cubit) patterns
5. **Configuring Dependencies** - Installing required packages and declaring assets per project requirements

**Technical Approach**: This is a pure infrastructure feature with no business logic. All code directly implements specifications from the constitutional rule files (`1_appendix.md` and `2_theme.md`). The architecture supports future feature development through:
- Centralized theme tokens preventing magic numbers
- Routing ownership pattern for scalable navigation
- Storage layer separation for testable data access
- Cubit-based state management with clear file separation

## Technical Context

**Language/Version**: Dart 3.9.2+ / Flutter 3.9.2+  
**Primary Dependencies**: 
- `go_router` ^14.0.0 (declarative routing)
- `flutter_bloc` ^8.1.0 (Cubit state management)
- `equatable` ^2.0.5 (value equality for state classes)

**Storage**: N/A (this feature only creates structure; actual storage implementations come with data features)  
**Testing**: `flutter test` (not part of this feature scope)  
**Target Platform**: Android & iOS (mobile-only per 1_appendix.md scope)  
**Project Type**: Mobile (Flutter single codebase targeting Android/iOS)  
**Performance Goals**: 
- App cold start < 3 seconds on mid-range devices
- Route transitions maintain 60 fps
- Theme token access has zero runtime overhead (compile-time constants)

**Constraints**: 
- MUST pass `flutter analyze` with zero errors (Principle 5: Quality Gates)
- MUST match folder structure exactly per `1_appendix.md`
- MUST match all hex color values exactly per `2_theme.md`
- MUST implement Neo-Brutalist styling (thick borders, hard shadows, no blur)
- Files > 300 LOC must be split per 1_appendix.md hygiene rules

**Scale/Scope**: 
- Foundation for ~10-20 feature modules
- Theme system supporting ~50+ screens
- Single theme variant (light mode only initially)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Principle 1: Spec-Driven Development (SDD)
✅ **PASS** - This plan directly implements the approved spec.md with all requirements traced to constitutional rules

### Principle 2: Separation of Rules (CRITICAL)
✅ **PASS** - Plan references all three rule files:
- `constitution.md` → Governs this planning process
- `1_appendix.md` → Defines all folder structure and architecture patterns
- `2_theme.md` → Defines all theme tokens and component styles

### Principle 3: Strict Architecture Compliance
✅ **PASS** - Folder structure matches `1_appendix.md` exactly:
- `lib/config/` for app_router.dart and app_config.dart
- `lib/features/common/themes/` for color and typography tokens
- `lib/features/common/widgets/` for custom_scaffold.dart
- `lib/features/storage/` structure created (empty, ready for future data features)
- Top-level `lib/app.dart` and `lib/main.dart` per specification

### Principle 4: Strict Theme Compliance
✅ **PASS** - All theme files implement `2_theme.md` specifications:
- Color tokens: All 17 color tokens with exact hex values
- Typography: All 6 text roles with specified weights and sizes
- Shapes: Border widths, radii, and shadow offsets per spec
- Components: NeoContainer widget enforcing Neo-Brutalist styling

### Principle 5: Quality Gates
✅ **PASS** - Plan includes validation steps:
- `flutter analyze` must pass with zero errors before completion
- File structure verification against `1_appendix.md`
- Theme token verification against `2_theme.md`
- Successful app build and launch as acceptance criteria

### Architecture Gate Checks

**Routing Ownership** (1_appendix.md Section 3)
✅ `app_router.dart` will own ALL path strings
✅ Feature route classes will receive paths (no hardcoded paths in features)

**State Management** (1_appendix.md Section 1)
✅ Cubit and State files will be separate
✅ MultiBlocProvider setup in app.dart (empty initially, ready for feature cubits)

**Data Layer Separation** (1_appendix.md Section 3)
✅ `features/storage/domain/` and `features/storage/data/` structure created
✅ Ready for repository interfaces and implementations in future features

**Theme System** (2_theme.md Sections 2-5)
✅ All color tokens defined as static constants
✅ All typography roles defined as TextStyle constants
✅ NeoContainer widget implements reusable Neo-Brutalist styling
✅ Custom scaffold provides consistent page structure

### Post-Phase 1 Re-check
(To be completed after design phase - no changes expected as this is pure infrastructure)

## Project Structure

### Documentation (this feature)

```text
specs/003-foundation-setup/
├── plan.md              # This file (implementation plan)
├── research.md          # Phase 0: Package versions, font sources, architecture patterns
├── data-model.md        # Phase 1: Theme token schemas, config structures
├── quickstart.md        # Phase 1: How to use theme system and add new features
├── contracts/           # Phase 1: N/A (no API contracts for infrastructure)
└── checklists/
    └── requirements.md  # Spec validation checklist (already complete)
```

### Source Code (repository root)

**Structure Decision**: Mobile single project (Flutter) per `1_appendix.md` canonical layout

```text
lib/
├── main.dart                                    # Entry point: runApp(App())
├── app.dart                                     # DI bootstrap + MultiBlocProvider + MaterialApp.router
├── config/                                      # Global configuration & routing
│   ├── app_config.dart                          # Environment/flavor flags, constants
│   └── app_router.dart                          # go_router config, owns ALL route paths
└── features/                                    # Feature modules
    ├── common/                                  # Shared design system & utilities
    │   ├── themes/
    │   │   ├── app_colors.dart                  # Color tokens (15+ semantic colors)
    │   │   ├── app_text_styles.dart             # Typography roles (6 text styles)
    │   │   └── app_shapes.dart                  # Shape tokens (radii, borders, shadows)
    │   ├── widgets/
    │   │   ├── custom_scaffold.dart             # Standard page wrapper
    │   │   └── neo_container.dart               # Reusable Neo-Brutalist container
    │   └── utils/                               # (empty for now, ready for pure utilities)
    └── storage/                                 # Centralized data layer (empty initially)
        ├── domain/                              # Pure domain (entities + repo interfaces)
        │   ├── entities/                        # (placeholder, no entities in this feature)
        │   └── repos/                           # (placeholder, no repos in this feature)
        └── data/                                # Implementations (Firebase/Hive/etc.)
                                                 # (placeholder, no implementations in this feature)

pubspec.yaml                                     # Updated with dependencies and assets
assets/
└── audio/                                       # (existing, just declared in pubspec)

android/                                         # (existing platform code)
ios/                                             # (existing platform code)
```

**Key Files Created (11 new files)**:
1. `lib/main.dart` - App entry point
2. `lib/app.dart` - App root with DI and routing
3. `lib/config/app_config.dart` - Environment configuration
4. `lib/config/app_router.dart` - Centralized routing
5. `lib/features/common/themes/app_colors.dart` - Color tokens
6. `lib/features/common/themes/app_text_styles.dart` - Typography
7. `lib/features/common/themes/app_shapes.dart` - Shape specifications
8. `lib/features/common/widgets/custom_scaffold.dart` - Page wrapper
9. `lib/features/common/widgets/neo_container.dart` - Neo-Brutalist container
10. `pubspec.yaml` - Updated with dependencies
11. Placeholder `.gitkeep` files in storage structure directories

## Complexity Tracking

**No violations** - This feature has zero complexity concerns:

- ✅ Pure infrastructure with no business logic
- ✅ All specifications come directly from constitutional rule files
- ✅ No custom patterns or deviations from standard Flutter practices
- ✅ No performance concerns (compile-time constants, stateless widgets)
- ✅ Clear separation of concerns matching Clean Architecture
- ✅ Minimal file sizes (each < 200 LOC estimated)

**Justification**: N/A - All gates pass

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
