# Phase 0: Research & Technical Decisions

**Feature**: Foundation, Architecture & Theme Setup  
**Date**: 2025-11-03  
**Status**: Complete

## Research Overview

This document resolves all technical unknowns and establishes best practices for implementing the foundational architecture and theme system.

---

## 1. Package Versions & Compatibility

### Decision: Use Latest Stable Versions

**Packages Selected**:
- `go_router: ^14.6.1` (latest stable as of Nov 2025)
- `flutter_bloc: ^8.1.6` (latest stable)
- `equatable: ^2.0.7` (latest stable)

**Rationale**:
- All packages are mature, widely adopted in Flutter community
- go_router is now the official recommendation from Flutter team for declarative routing
- flutter_bloc with Cubit pattern is lighter than full Bloc and matches our needs (simple state transitions)
- equatable provides value equality without boilerplate, essential for state comparison

**Alternatives Considered**:
- ❌ **AutoRoute** - More boilerplate, code generation overhead
- ❌ **Riverpod** - Steeper learning curve, overkill for current needs
- ❌ **GetX** - Anti-pattern (service locator), violates Clean Architecture
- ✅ **go_router + flutter_bloc/Cubit** - Industry standard, matches 1_appendix.md patterns

**Compatibility Check**:
- Flutter SDK 3.9.2 supports all selected packages
- No known conflicts between packages
- All support null-safety (required since Dart 2.12+)

---

## 2. Font Integration Strategy

### Decision: Use Google Fonts Package + Local Fallback

**Approach**:
- Primary: Use `google_fonts` package for Inter and Noto Sans Thai
- Fallback: System fonts if network unavailable
- No local font files needed initially (reduces bundle size)

**Implementation**:
```dart
// In app_text_styles.dart
TextStyle get display => GoogleFonts.inter(
  fontSize: 28,
  fontWeight: FontWeight.w700,
  color: AppColors.textPrimary,
);

TextStyle get displayThai => GoogleFonts.notoSansThai(
  fontSize: 28,
  fontWeight: FontWeight.w700,
  color: AppColors.textPrimary,
);
```

**Rationale**:
- google_fonts package handles caching automatically
- Supports both Inter and Noto Sans Thai
- Zero configuration for basic usage
- Can add local fonts later if offline requirement emerges

**Alternatives Considered**:
- ❌ **Local font files in assets/** - Increases app bundle size (~500KB per font family)
- ❌ **Platform fonts only** - Doesn't match design spec (needs Inter specifically)
- ✅ **google_fonts package** - Best balance of quality, bundle size, and ease of use

**Additional Package**:
- Add `google_fonts: ^6.1.0` to pubspec.yaml

---

## 3. Routing Architecture Pattern

### Decision: Centralized Path Ownership with Feature Route Classes

**Pattern** (from 1_appendix.md Section 3):
1. `config/app_router.dart` owns ALL path strings as constants
2. Feature modules expose route classes that accept path parameter
3. Route classes return `GoRoute` objects with builder functions
4. No hardcoded paths in feature modules

**Example Implementation**:
```dart
// config/app_router.dart
class AppRouter {
  static const String home = '/home';
  static const String exams = '/exams';
  
  static final router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => HomePage(),
      ),
      // Future feature routes added here
    ],
  );
}
```

**For Future Features** (template):
```dart
// features/exam/exam_route.dart
class ExamRoute {
  final String path;
  final List<GoRoute> subroutes;
  
  ExamRoute({required this.path, this.subroutes = const []});
  
  GoRoute get route => GoRoute(
    path: path,
    routes: subroutes,
    builder: (context, state) => ExamsPage(),
  );
}

// Usage in app_router.dart
ExamRoute(path: AppRouter.exams, subroutes: [...]).route
```

**Rationale**:
- Single source of truth for all navigation paths
- Easy to refactor routes without touching feature code
- Type-safe navigation (can use constants)
- Supports nested routes cleanly

---

## 4. State Management Hygiene

### Decision: Strict Cubit/State File Separation

**Rules** (from 1_appendix.md Section 1):
- MUST separate `*_cubit.dart` and `*_state.dart` into distinct files
- State classes MUST be immutable
- State classes MUST extend Equatable
- Provide `copyWith` for state updates
- Initialize cubits in `app.dart` via MultiBlocProvider

**Foundation Setup Impact**:
- Create `app.dart` with empty MultiBlocProvider (ready for future cubits)
- No actual cubits in this feature (pure infrastructure)
- Pattern documented in quickstart.md for future features

**Best Practices**:
```dart
// feature_state.dart
abstract class FeatureState extends Equatable {
  const FeatureState();
  @override
  List<Object?> get props => [];
}

class FeatureInitial extends FeatureState {}

class FeatureLoaded extends FeatureState {
  final List<Item> items;
  const FeatureLoaded({required this.items});
  @override
  List<Object?> get props => [items];
}

// feature_cubit.dart
class FeatureCubit extends Cubit<FeatureState> {
  FeatureCubit() : super(FeatureInitial());
  
  Future<void> loadItems() async {
    // business logic
    emit(FeatureLoaded(items: []));
  }
}
```

---

## 5. Neo-Brutalist Component Architecture

### Decision: Reusable NeoContainer Widget with State Management

**Core Component** (from 2_theme.md Section 5.1):
- Build a single `NeoContainer` widget that handles all Neo-Brutalist styling
- Support `isPressed`, `isDisabled` states via AnimatedContainer
- All interactive components (buttons, cards) wrap NeoContainer

**Implementation Approach**:
```dart
class NeoContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double borderRadius;
  final bool isDisabled;
  final bool isPressed;
  final VoidCallback? onTap;
  
  const NeoContainer({
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderRadius = 16.0,
    this.isDisabled = false,
    this.isPressed = false,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final offset = isPressed 
      ? AppShapes.offsetPressed 
      : (isDisabled ? Offset.zero : AppShapes.offset);
    
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.surfaceDisabled : backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isDisabled ? AppColors.borderDisabled : AppColors.border,
            width: AppShapes.borderWidth,
          ),
          boxShadow: isDisabled ? [] : [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 0.0,
              offset: offset,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
```

**For Interactive States**:
- Use `GestureDetector` with `onTapDown` / `onTapUp` to drive `isPressed`
- OR wrap in `StatefulWidget` that manages pressed state internally
- Disabled state passed from parent (e.g., button disabled logic)

**Rationale**:
- Single widget enforces consistency
- AnimatedContainer provides smooth state transitions (150ms per spec)
- Eliminates duplicated styling code across components
- Easy to maintain (change shadow offset in one place)

---

## 6. Theme Token Organization

### Decision: Three-File Theme System

**Structure**:
1. `app_colors.dart` - All color tokens (15+ semantic colors)
2. `app_text_styles.dart` - All typography roles (6 text styles)
3. `app_shapes.dart` - Shape specifications (radii, borders, shadows)

**Color Tokens** (from 2_theme.md Section 2):
```dart
class AppColors {
  // Core Palette
  static const background = Color(0xFFFAF8F1);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDisabled = Color(0xFFE0E0E0);
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF8A8A8E);
  static const border = Color(0xFF000000);
  static const borderDisabled = Color(0xFFBDBDBD);
  static const shadow = Color(0xFF000000);
  
  // Action Colors
  static const primary = Color(0xFFFDEE8A);
  static const onPrimary = Color(0xFF000000);
  static const secondary = Color(0xFFF0E4FF);
  static const onSecondary = Color(0xFF000000);
  
  // Accents
  static const accentPink = Color(0xFFFFD6F5);
  static const accentGreen = Color(0xFFD3FFAE);
  static const accentPurple = Color(0xFFE4D6FF);
  
  // Semantic
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFF44336);
}
```

**Typography Roles** (from 2_theme.md Section 3):
```dart
class AppTextStyles {
  static final display = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );
  
  static final titleLarge = GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w700,
  );
  
  static final titleMedium = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  
  static final bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  
  static final bodySmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  
  static final caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}
```

**Shape Specifications** (from 2_theme.md Section 4):
```dart
class AppShapes {
  // Radii
  static const radiusLarge = 20.0;
  static const radiusMedium = 16.0;
  static const radiusSmall = 8.0;
  static const radiusCircle = 99.0;
  
  // Borders
  static const borderWidth = 1.5;
  
  // Shadows
  static const offset = Offset(3, 3);
  static const offsetPressed = Offset(1, 1);
  static const blurRadius = 0.0; // No blur in Neo-Brutalism
}
```

**Rationale**:
- Compile-time constants (zero runtime overhead)
- Easy to maintain (change color in one place)
- Type-safe (Color vs int mistakes caught at compile time)
- Self-documenting (semantic names)
- Can extend without breaking existing code

---

## 7. Custom Scaffold Pattern

### Decision: StandardPage Wrapper Widget

**Purpose**: Provide consistent page structure (safe area, padding, app bar support)

**Implementation**:
```dart
class CustomScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  
  const CustomScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.backgroundColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: appBar,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: body,
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
```

**Usage Pattern**:
```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(title: Text('Home')),
      body: Column(
        children: [
          // page content
        ],
      ),
    );
  }
}
```

**Rationale**:
- Consistent safe area handling
- Standard 16px padding per 2_theme.md
- Easy to add global features (loading overlays, etc.) later
- Eliminates boilerplate in feature pages

---

## 8. Dependency Injection Strategy

### Decision: Constructor Injection with Manual Wiring

**Pattern** (from 1_appendix.md):
- Initialize services/repos in `app.dart` build method
- Pass dependencies via constructor to Cubits
- Provide Cubits via MultiBlocProvider

**Foundation Setup**:
```dart
class App extends StatelessWidget {
  const App({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Future: Initialize Firebase, Hive, repos here
    // final examRepo = FirebaseExamRepo();
    
    return MultiBlocProvider(
      providers: [
        // Future: Add feature cubits here
        // BlocProvider(create: (_) => ExamsCubit(examRepo: examRepo)),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          // ... theme configuration
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
```

**Rationale**:
- Simple, explicit, no magic
- Easy to understand dependency graph
- No service locator anti-pattern
- Testable (can mock dependencies in tests)

**Alternatives Considered**:
- ❌ **GetIt** - Service locator anti-pattern, violates Clean Architecture
- ❌ **Provider-only** - Less ergonomic for state management than Bloc
- ✅ **Manual constructor injection** - Explicit, simple, testable

---

## 9. Asset Management

### Decision: Declare in pubspec.yaml, Use AssetImage/AssetSound

**Current Assets**:
- `assets/audio/` - Audio files (existing directory)

**pubspec.yaml Configuration**:
```yaml
flutter:
  uses-material-design: true
  
  assets:
    - assets/audio/
```

**Future Font Assets** (if needed):
```yaml
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

**Rationale**:
- Standard Flutter asset management
- Directory declaration loads all files in directory
- google_fonts package handles fonts, so no local files needed initially

---

## 10. Build & Quality Validation

### Decision: Multi-Step Validation Process

**Validation Steps**:
1. **Structure Check**: Verify all folders exist per 1_appendix.md
2. **Static Analysis**: Run `flutter analyze` (must pass with zero errors)
3. **Build Check**: Run `flutter build apk --debug` (must succeed)
4. **Launch Check**: Run `flutter run` (must launch successfully)
5. **Theme Verification**: Manual inspection of color values against 2_theme.md

**Acceptance Criteria**:
```bash
# 1. Analyze
flutter analyze
# Expected: No issues found!

# 2. Build
flutter build apk --debug
# Expected: Built build/app/outputs/flutter-apk/app-debug.apk

# 3. Run
flutter run
# Expected: App launches and displays white screen (no features yet)

# 4. Structure verification
ls -R lib/ | grep -E "config/|features/common/themes/|features/common/widgets/"
# Expected: All paths exist
```

---

## Summary of Decisions

| Area | Decision | Rationale |
|------|----------|-----------|
| Routing | go_router with centralized paths | Official Flutter recommendation, type-safe |
| State | flutter_bloc (Cubit) with file separation | Lightweight, matches 1_appendix.md patterns |
| Fonts | google_fonts package | Zero-config, automatic caching |
| Theme | Three-file token system | Compile-time constants, easy maintenance |
| Components | NeoContainer reusable widget | Single source of styling, state management |
| Scaffold | CustomScaffold wrapper | Consistent structure, eliminates boilerplate |
| DI | Manual constructor injection | Explicit, testable, no anti-patterns |
| Quality | Multi-step validation | Ensures compliance with all rules |

**All research complete. Ready for Phase 1: Design & Contracts.**
