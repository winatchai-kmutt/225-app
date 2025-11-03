# Phase 1: Data Models & Structure Schemas

**Feature**: Foundation, Architecture & Theme Setup  
**Date**: 2025-11-03  
**Status**: Complete

## Overview

This feature is pure infrastructure and does not introduce domain entities or data models in the traditional sense. Instead, this document defines the **structural schemas** for theme tokens, configuration objects, and architectural patterns that future features will consume.

---

## 1. Theme Token Schemas

### 1.1 Color Token Schema

**Purpose**: Define all semantic color tokens per 2_theme.md

**Structure**:
```dart
class AppColors {
  // Core Palette (8 tokens)
  static const Color background;       // #FAF8F1 - App background
  static const Color surface;          // #FFFFFF - Cards, containers
  static const Color surfaceDisabled;  // #E0E0E0 - Disabled backgrounds
  static const Color textPrimary;      // #000000 - Primary text
  static const Color textSecondary;    // #8A8A8E - Secondary text
  static const Color border;           // #000000 - Border color
  static const Color borderDisabled;   // #BDBDBD - Disabled borders
  static const Color shadow;           // #000000 - Shadow color
  
  // Action Colors (4 tokens)
  static const Color primary;          // #FDEE8A - Primary CTA
  static const Color onPrimary;        // #000000 - Text on primary
  static const Color secondary;        // #F0E4FF - Secondary CTA
  static const Color onSecondary;      // #000000 - Text on secondary
  
  // Accent Colors (3 tokens)
  static const Color accentPink;       // #FFD6F5 - Pink accent
  static const Color accentGreen;      // #D3FFAE - Green accent
  static const Color accentPurple;     // #E4D6FF - Purple accent
  
  // Semantic Colors (2 tokens)
  static const Color success;          // #4CAF50 - Success states
  static const Color error;            // #F44336 - Error states
}
```

**Total Tokens**: 17 color constants

**Validation Rules**:
- All values MUST match 2_theme.md hex codes exactly
- All fields MUST be `static const Color`
- No runtime color computation allowed

---

### 1.2 Typography Token Schema

**Purpose**: Define all text style roles per 2_theme.md

**Structure**:
```dart
class AppTextStyles {
  // Typography Roles (6 styles)
  static TextStyle display;      // Bold 28 - Large headings
  static TextStyle titleLarge;   // Bold 26 - Important numbers/titles
  static TextStyle titleMedium;  // SemiBold 20 - Section headers
  static TextStyle bodyLarge;    // SemiBold 16 - Body text, button labels
  static TextStyle bodySmall;    // Regular 14 - Secondary body text
  static TextStyle caption;      // Regular 12 - Captions, timestamps
  
  // Optional: Thai variants (if text direction differs)
  static TextStyle displayThai;     // Same as display but Noto Sans Thai
  static TextStyle titleLargeThai;  // ...
  // (Can be added later if needed)
}
```

**Properties Per Style**:
- `fontSize`: double (exact px value from spec)
- `fontWeight`: FontWeight (w400 = Regular, w600 = SemiBold, w700 = Bold)
- `fontFamily`: String ('Inter' via google_fonts)
- `color`: Inherited from context or AppColors.textPrimary by default

**Validation Rules**:
- Font sizes MUST match 2_theme.md exactly
- Font weights MUST match spec (Regular/SemiBold/Bold)
- Must use google_fonts package, not local fonts

---

### 1.3 Shape Token Schema

**Purpose**: Define all shape specifications per 2_theme.md

**Structure**:
```dart
class AppShapes {
  // Border Radii (4 tokens)
  static const double radiusLarge = 20.0;   // Cards, bottom bar
  static const double radiusMedium = 16.0;  // Buttons
  static const double radiusSmall = 8.0;    // Indicators
  static const double radiusCircle = 99.0;  // Avatars, icon buttons
  
  // Border Specifications (1 token)
  static const double borderWidth = 1.5;    // All borders
  
  // Shadow Specifications (3 tokens)
  static const Offset offset = Offset(3, 3);           // Default shadow
  static const Offset offsetPressed = Offset(1, 1);    // Pressed state
  static const double blurRadius = 0.0;                // No blur
  
  // Spacing (Grid-based, 4 tokens)
  static const double gridUnit = 8.0;       // Base unit
  static const double pagePadding = 16.0;   // Page edges
  static const double cardPadding = 20.0;   // Inside cards
  static const double listItemPaddingV = 12.0;  // List item vertical
  static const double listItemPaddingH = 16.0;  // List item horizontal
}
```

**Validation Rules**:
- All radii MUST match 2_theme.md specs
- Shadow offset MUST be hard (blurRadius = 0)
- Spacing MUST be multiples of 8 (grid system)

---

## 2. Configuration Object Schemas

### 2.1 AppConfig Schema

**Purpose**: Environment/flavor configuration

**Structure**:
```dart
class AppConfig {
  final bool useFirebaseEmulator;
  final String firestoreProjectId;
  final bool enableDebugLogs;
  
  const AppConfig({
    this.useFirebaseEmulator = false,
    this.firestoreProjectId = '',
    this.enableDebugLogs = false,
  });
  
  // Default production config
  static const AppConfig production = AppConfig(
    useFirebaseEmulator: false,
    firestoreProjectId: 'a255-app-prod',
    enableDebugLogs: false,
  );
  
  // Development config
  static const AppConfig development = AppConfig(
    useFirebaseEmulator: true,
    firestoreProjectId: 'a255-app-dev',
    enableDebugLogs: true,
  );
  
  // Current active config
  static const AppConfig current = AppConfig.development;
}
```

**Fields**:
- `useFirebaseEmulator`: bool - Use local Firebase emulator
- `firestoreProjectId`: String - Firebase project identifier
- `enableDebugLogs`: bool - Enable verbose logging

**Usage Pattern**:
```dart
if (AppConfig.current.enableDebugLogs) {
  print('Debug info...');
}
```

---

### 2.2 Router Configuration Schema

**Purpose**: Centralized route path management

**Structure**:
```dart
class AppRouter {
  // Route Paths (constants)
  static const String home = '/home';
  static const String exams = '/exams';
  static const String settings = '/settings';
  // Future routes added here as constants
  
  // Router Instance
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      // Routes added here as features are built
    ],
    redirect: (BuildContext context, GoRouterState state) {
      // Future: Add authentication guards
      return null; // No redirect for now
    },
    errorBuilder: (context, state) {
      return ErrorPage(error: state.error);
    },
  );
}
```

**Pattern for Future Features**:
```dart
// In feature route file
class ExamRoute {
  final String path;
  final List<GoRoute> subroutes;
  
  ExamRoute({
    required this.path,
    this.subroutes = const [],
  });
  
  GoRoute get route => GoRoute(
    path: path,
    routes: subroutes,
    builder: (context, state) => ExamsPage(),
  );
}

// In app_router.dart
static const String exams = '/exams';
static const String examDetail = 'detail'; // relative path

routes: [
  ExamRoute(
    path: exams,
    subroutes: [
      ExamDetailRoute(path: examDetail).route,
    ],
  ).route,
]
```

---

## 3. Widget Component Schemas

### 3.1 NeoContainer Props Schema

**Purpose**: Define the interface for the reusable Neo-Brutalist container

**Structure**:
```dart
class NeoContainer extends StatelessWidget {
  // Required Props
  final Widget child;                          // Content to wrap
  
  // Style Props
  final Color backgroundColor;                 // Default: AppColors.surface
  final double borderRadius;                   // Default: AppShapes.radiusMedium
  final EdgeInsets? padding;                   // Optional internal padding
  
  // State Props
  final bool isDisabled;                       // Default: false
  final bool isPressed;                        // Default: false (managed internally or externally)
  
  // Interaction Props
  final VoidCallback? onTap;                   // Tap handler (makes interactive)
  final VoidCallback? onLongPress;             // Long press handler
  
  // Animation Props
  final Duration animationDuration;            // Default: 150ms
  final Curve animationCurve;                  // Default: Curves.easeOut
  
  const NeoContainer({
    Key? key,
    required this.child,
    this.backgroundColor = AppColors.surface,
    this.borderRadius = AppShapes.radiusMedium,
    this.padding,
    this.isDisabled = false,
    this.isPressed = false,
    this.onTap,
    this.onLongPress,
    this.animationDuration = const Duration(milliseconds: 150),
    this.animationCurve = Curves.easeOut,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Implementation returns AnimatedContainer with Neo-Brutalist styling
  }
}
```

**State Computation Logic**:
```dart
// Computed values based on state
final effectiveBackgroundColor = isDisabled 
  ? AppColors.surfaceDisabled 
  : backgroundColor;

final effectiveBorderColor = isDisabled 
  ? AppColors.borderDisabled 
  : AppColors.border;

final effectiveShadowOffset = isDisabled 
  ? Offset.zero 
  : (isPressed ? AppShapes.offsetPressed : AppShapes.offset);

final effectiveBoxShadow = isDisabled 
  ? [] 
  : [BoxShadow(
      color: AppColors.shadow,
      blurRadius: AppShapes.blurRadius,
      offset: effectiveShadowOffset,
    )];
```

**Usage Examples**:
```dart
// Static card
NeoContainer(
  child: Text('Hello'),
)

// Interactive button
NeoContainer(
  onTap: () => print('Tapped'),
  backgroundColor: AppColors.primary,
  child: Text('Button'),
)

// Disabled state
NeoContainer(
  isDisabled: true,
  child: Text('Disabled'),
)
```

---

### 3.2 CustomScaffold Props Schema

**Purpose**: Standard page wrapper

**Structure**:
```dart
class CustomScaffold extends StatelessWidget {
  // Required Props
  final Widget body;                           // Main page content
  
  // Optional Props
  final PreferredSizeWidget? appBar;           // Top app bar
  final Widget? bottomNavigationBar;           // Bottom navigation
  final Color? backgroundColor;                // Override background color
  final EdgeInsets? padding;                   // Override default padding
  final bool useSafeArea;                      // Default: true
  
  const CustomScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.padding,
    this.useSafeArea = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Returns Scaffold with consistent safe area and padding
  }
}
```

**Default Values**:
- `backgroundColor`: AppColors.background (#FAF8F1)
- `padding`: EdgeInsets.all(16.0)
- `useSafeArea`: true

---

## 4. Architectural Structure Schemas

### 4.1 Feature Module Structure

**Purpose**: Define standard feature organization per 1_appendix.md

**Template**:
```
lib/features/<feature-name>/
├── <feature-name>_route.dart       # Route class (returns GoRoute)
└── presentation/                   # UI layer
    ├── pages/
    │   └── <page>_page.dart        # Full screens
    ├── components/                 # (Optional) Sub-widgets
    │   └── <component>.dart
    └── cubits/
        ├── <feature>_cubit.dart    # State management logic
        └── <feature>_state.dart    # State classes
```

**Rules**:
- Route file MUST NOT contain hardcoded paths
- Cubit and State MUST be in separate files
- Components are optional (only if needed for complex pages)
- All files use snake_case naming

---

### 4.2 Storage Layer Structure

**Purpose**: Centralized data access per 1_appendix.md

**Template**:
```
lib/features/storage/
├── domain/                         # Pure domain layer
│   ├── entities/
│   │   └── <entity>.dart           # Data models (immutable)
│   └── repos/
│       └── <entity>_repo.dart      # Repository interfaces (abstract)
└── data/                           # Implementations
    └── firebase_<entity>_repo.dart # Concrete implementation
```

**Entity Schema Example**:
```dart
class Exam extends Equatable {
  final String id;
  final String title;
  final int questionCount;
  final bool isCompleted;
  
  const Exam({
    required this.id,
    required this.title,
    required this.questionCount,
    required this.isCompleted,
  });
  
  // Factory from JSON
  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] as String,
      title: json['title'] as String,
      questionCount: json['questionCount'] as int,
      isCompleted: json['isCompleted'] as bool,
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'questionCount': questionCount,
    'isCompleted': isCompleted,
  };
  
  // Copy with
  Exam copyWith({
    String? id,
    String? title,
    int? questionCount,
    bool? isCompleted,
  }) => Exam(
    id: id ?? this.id,
    title: title ?? this.title,
    questionCount: questionCount ?? this.questionCount,
    isCompleted: isCompleted ?? this.isCompleted,
  );
  
  @override
  List<Object?> get props => [id, title, questionCount, isCompleted];
}
```

**Repository Interface Example**:
```dart
abstract class ExamRepo {
  Future<List<Exam>> getAll();
  Future<Exam?> getById(String id);
  Future<void> create(Exam exam);
  Future<void> update(Exam exam);
  Future<void> delete(String id);
}
```

---

## 5. Validation Schemas

### 5.1 Folder Structure Validation

**Expected Structure** (from 1_appendix.md):
```
lib/
├── main.dart                                    ✓
├── app.dart                                     ✓
├── config/
│   ├── app_config.dart                          ✓
│   └── app_router.dart                          ✓
└── features/
    ├── common/
    │   ├── themes/
    │   │   ├── app_colors.dart                  ✓
    │   │   ├── app_text_styles.dart             ✓
    │   │   └── app_shapes.dart                  ✓
    │   ├── widgets/
    │   │   ├── custom_scaffold.dart             ✓
    │   │   └── neo_container.dart               ✓
    │   └── utils/                               ✓ (empty)
    └── storage/
        ├── domain/
        │   ├── entities/                        ✓ (empty)
        │   └── repos/                           ✓ (empty)
        └── data/                                ✓ (empty)
```

**Validation Script**:
```bash
#!/bin/bash
required_files=(
  "lib/main.dart"
  "lib/app.dart"
  "lib/config/app_config.dart"
  "lib/config/app_router.dart"
  "lib/features/common/themes/app_colors.dart"
  "lib/features/common/themes/app_text_styles.dart"
  "lib/features/common/themes/app_shapes.dart"
  "lib/features/common/widgets/custom_scaffold.dart"
  "lib/features/common/widgets/neo_container.dart"
)

for file in "${required_files[@]}"; do
  if [ ! -f "$file" ]; then
    echo "❌ Missing: $file"
    exit 1
  fi
done

echo "✅ All required files present"
```

---

### 5.2 Theme Token Validation

**Color Values Checklist**:
| Token | Expected | Validation |
|-------|----------|------------|
| background | #FAF8F1 | Color(0xFFFAF8F1) |
| surface | #FFFFFF | Color(0xFFFFFFFF) |
| surfaceDisabled | #E0E0E0 | Color(0xFFE0E0E0) |
| textPrimary | #000000 | Color(0xFF000000) |
| textSecondary | #8A8A8E | Color(0xFF8A8A8E) |
| border | #000000 | Color(0xFF000000) |
| borderDisabled | #BDBDBD | Color(0xFFBDBDBD) |
| shadow | #000000 | Color(0xFF000000) |
| primary | #FDEE8A | Color(0xFFFDEE8A) |
| onPrimary | #000000 | Color(0xFF000000) |
| secondary | #F0E4FF | Color(0xFFF0E4FF) |
| onSecondary | #000000 | Color(0xFF000000) |
| accentPink | #FFD6F5 | Color(0xFFFFD6F5) |
| accentGreen | #D3FFAE | Color(0xFFD3FFAE) |
| accentPurple | #E4D6FF | Color(0xFFE4D6FF) |
| success | #4CAF50 | Color(0xFF4CAF50) |
| error | #F44336 | Color(0xFFF44336) |

**Typography Values Checklist**:
| Role | Font Size | Weight | Family |
|------|-----------|--------|--------|
| display | 28 | w700 | Inter |
| titleLarge | 26 | w700 | Inter |
| titleMedium | 20 | w600 | Inter |
| bodyLarge | 16 | w600 | Inter |
| bodySmall | 14 | w400 | Inter |
| caption | 12 | w400 | Inter |

---

## Summary

This foundation feature defines:

1. **17 Color Tokens** - All semantic colors from 2_theme.md
2. **6 Typography Roles** - All text styles from 2_theme.md
3. **11 Shape Tokens** - Radii, borders, shadows, spacing
4. **2 Configuration Objects** - AppConfig, AppRouter
5. **2 Reusable Widgets** - NeoContainer, CustomScaffold
6. **Architectural Templates** - Feature and storage layer structures

**No traditional domain entities** in this feature - those come with feature development (exams, courses, users, etc.).

**Next Phase**: Generate quickstart.md with usage guidelines for future developers.
