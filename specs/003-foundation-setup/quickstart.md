# Quickstart: Using the Foundation Architecture & Theme

**For**: Developers building new features on top of this foundation  
**Prerequisites**: Foundation setup complete (all files from plan.md exist)  
**Date**: 2025-11-03

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Adding a New Feature](#2-adding-a-new-feature)
3. [Using the Theme System](#3-using-the-theme-system)
4. [Building UI Components](#4-building-ui-components)
5. [Adding Routes](#5-adding-routes)
6. [State Management with Cubit](#6-state-management-with-cubit)
7. [Working with Storage Layer](#7-working-with-storage-layer)
8. [Quality Checklist](#8-quality-checklist)

---

## 1. Project Overview

### Architecture at a Glance

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # App bootstrap (DI + routing)
├── config/                      # Global configuration
│   ├── app_config.dart          # Environment settings
│   └── app_router.dart          # Centralized routing
└── features/                    # Feature modules
    ├── common/                  # Shared design system
    │   ├── themes/              # Color, typography, shapes
    │   └── widgets/             # Reusable components
    └── storage/                 # Centralized data layer
        ├── domain/              # Entities + repo interfaces
        └── data/                # Repo implementations
```

### Key Principles

1. **Spec-Driven**: All features start with a specification
2. **Clean Architecture**: Strict layer separation (UI → Domain → Data)
3. **Theme Compliance**: All UI uses theme tokens (no magic numbers)
4. **Route Ownership**: `app_router.dart` owns all paths
5. **State Hygiene**: Cubit/State in separate files

---

## 2. Adding a New Feature

### Step-by-Step Guide

#### Step 1: Create Feature Structure

```bash
mkdir -p lib/features/my_feature/presentation/{pages,components,cubits}
touch lib/features/my_feature/my_feature_route.dart
```

Expected structure:
```
lib/features/my_feature/
├── my_feature_route.dart
└── presentation/
    ├── pages/
    │   └── my_feature_page.dart
    ├── components/           # (optional)
    └── cubits/
        ├── my_feature_cubit.dart
        └── my_feature_state.dart
```

#### Step 2: Create Route Class

**File**: `lib/features/my_feature/my_feature_route.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'presentation/pages/my_feature_page.dart';

class MyFeatureRoute {
  final String path;
  final List<GoRoute> subroutes;
  
  MyFeatureRoute({
    required this.path,
    this.subroutes = const [],
  });
  
  GoRoute get route => GoRoute(
    path: path,
    routes: subroutes,
    builder: (context, state) => const MyFeaturePage(),
  );
}
```

#### Step 3: Register Route in AppRouter

**File**: `lib/config/app_router.dart`

```dart
class AppRouter {
  // Add path constant
  static const String myFeature = '/my-feature';
  
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      HomeRoute(path: home).route,
      
      // Add your feature route
      MyFeatureRoute(path: myFeature).route,
    ],
  );
}
```

#### Step 4: Create Page

**File**: `lib/features/my_feature/presentation/pages/my_feature_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/my_feature_cubit.dart';
import '../cubits/my_feature_state.dart';
import '../../../../features/common/widgets/custom_scaffold.dart';
import '../../../../features/common/themes/app_colors.dart';
import '../../../../features/common/themes/app_text_styles.dart';

class MyFeaturePage extends StatelessWidget {
  const MyFeaturePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        title: Text(
          'My Feature',
          style: AppTextStyles.titleMedium,
        ),
        backgroundColor: AppColors.surface,
      ),
      body: BlocBuilder<MyFeatureCubit, MyFeatureState>(
        builder: (context, state) {
          if (state is MyFeatureLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (state is MyFeatureLoaded) {
            return Column(
              children: [
                Text('Feature content', style: AppTextStyles.bodyLarge),
              ],
            );
          }
          
          return SizedBox();
        },
      ),
    );
  }
}
```

---

## 3. Using the Theme System

### Color Tokens

**Always use**: `AppColors.*` constants (never hardcode colors)

```dart
// ✅ GOOD - Using theme tokens
Container(
  color: AppColors.surface,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.textPrimary),
  ),
)

// ❌ BAD - Hardcoded colors
Container(
  color: Color(0xFFFFFFFF),  // Don't do this!
  child: Text(
    'Hello',
    style: TextStyle(color: Colors.black),  // Don't do this!
  ),
)
```

**Available Color Tokens**:
```dart
// Core Palette
AppColors.background        // #FAF8F1 - App background
AppColors.surface           // #FFFFFF - Cards, containers
AppColors.surfaceDisabled   // #E0E0E0 - Disabled states
AppColors.textPrimary       // #000000 - Primary text
AppColors.textSecondary     // #8A8A8E - Secondary text
AppColors.border            // #000000 - Borders
AppColors.borderDisabled    // #BDBDBD - Disabled borders
AppColors.shadow            // #000000 - Shadows

// Actions
AppColors.primary           // #FDEE8A - Primary buttons
AppColors.onPrimary         // #000000 - Text on primary
AppColors.secondary         // #F0E4FF - Secondary buttons
AppColors.onSecondary       // #000000 - Text on secondary

// Accents
AppColors.accentPink        // #FFD6F5
AppColors.accentGreen       // #D3FFAE
AppColors.accentPurple      // #E4D6FF

// Semantic
AppColors.success           // #4CAF50
AppColors.error             // #F44336
```

### Typography Tokens

**Always use**: `AppTextStyles.*` constants

```dart
// ✅ GOOD - Using typography tokens
Text('Large Title', style: AppTextStyles.titleLarge)
Text('Body text', style: AppTextStyles.bodyLarge)
Text('Caption', style: AppTextStyles.caption)

// ❌ BAD - Hardcoded text styles
Text('Title', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))
```

**Available Typography Tokens**:
```dart
AppTextStyles.display        // Bold 28 - Large headings
AppTextStyles.titleLarge     // Bold 26 - Important numbers
AppTextStyles.titleMedium    // SemiBold 20 - Section headers
AppTextStyles.bodyLarge      // SemiBold 16 - Body text, buttons
AppTextStyles.bodySmall      // Regular 14 - Secondary text
AppTextStyles.caption        // Regular 12 - Captions, timestamps
```

### Shape Tokens

**Always use**: `AppShapes.*` constants

```dart
// ✅ GOOD - Using shape tokens
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppShapes.radiusMedium),
    border: Border.all(
      color: AppColors.border,
      width: AppShapes.borderWidth,
    ),
  ),
)

// ❌ BAD - Hardcoded values
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),  // Don't do this!
    border: Border.all(width: 1.5),  // Don't do this!
  ),
)
```

**Available Shape Tokens**:
```dart
AppShapes.radiusLarge       // 20.0 - Cards, bottom bar
AppShapes.radiusMedium      // 16.0 - Buttons
AppShapes.radiusSmall       // 8.0 - Indicators
AppShapes.radiusCircle      // 99.0 - Avatars, icon buttons
AppShapes.borderWidth       // 1.5 - All borders
AppShapes.offset            // Offset(3, 3) - Default shadow
AppShapes.offsetPressed     // Offset(1, 1) - Pressed shadow
AppShapes.blurRadius        // 0.0 - No blur (Neo-Brutalism)
AppShapes.pagePadding       // 16.0 - Page edges
AppShapes.cardPadding       // 20.0 - Inside cards
```

---

## 4. Building UI Components

### Using NeoContainer

The `NeoContainer` widget enforces Neo-Brutalist styling automatically.

#### Basic Usage

```dart
NeoContainer(
  child: Padding(
    padding: EdgeInsets.all(AppShapes.cardPadding),
    child: Text('Card content'),
  ),
)
```

#### Interactive Button

```dart
NeoContainer(
  backgroundColor: AppColors.primary,
  onTap: () {
    print('Button tapped');
  },
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Text(
      'Primary Button',
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.onPrimary,
      ),
    ),
  ),
)
```

#### Disabled State

```dart
NeoContainer(
  backgroundColor: AppColors.primary,
  isDisabled: true,
  onTap: null,  // Tap ignored when disabled
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Text(
      'Disabled Button',
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.textSecondary,
      ),
    ),
  ),
)
```

#### Custom Styling

```dart
NeoContainer(
  backgroundColor: AppColors.accentPink,
  borderRadius: AppShapes.radiusLarge,
  padding: EdgeInsets.all(20),
  child: Column(
    children: [
      Text('Custom Card', style: AppTextStyles.titleMedium),
      Text('With pink background', style: AppTextStyles.caption),
    ],
  ),
)
```

### Using CustomScaffold

Provides consistent page structure with safe area and padding.

```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        title: Text('Page Title', style: AppTextStyles.titleMedium),
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          // Your page content
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        // Navigation bar
      ),
    );
  }
}
```

---

## 5. Adding Routes

### Simple Route

**Feature Route File**:
```dart
class SettingsRoute {
  final String path;
  
  SettingsRoute({required this.path});
  
  GoRoute get route => GoRoute(
    path: path,
    builder: (context, state) => SettingsPage(),
  );
}
```

**In app_router.dart**:
```dart
static const String settings = '/settings';

routes: [
  SettingsRoute(path: settings).route,
]
```

### Nested Routes

**Feature Route File**:
```dart
class ExamRoute {
  final String path;
  final List<GoRoute> subroutes;
  
  ExamRoute({required this.path, required this.subroutes});
  
  GoRoute get route => GoRoute(
    path: path,
    routes: subroutes,
    builder: (context, state) => ExamsPage(),
  );
}

class ExamDetailRoute {
  final String path;
  
  ExamDetailRoute({required this.path});
  
  GoRoute get route => GoRoute(
    path: path,
    builder: (context, state) {
      final examId = state.pathParameters['id'];
      return ExamDetailPage(examId: examId!);
    },
  );
}
```

**In app_router.dart**:
```dart
static const String exams = '/exams';
static const String examDetail = ':id';  // Relative path

routes: [
  ExamRoute(
    path: exams,
    subroutes: [
      ExamDetailRoute(path: examDetail).route,
    ],
  ).route,
]
```

### Navigation

```dart
// Navigate to route
context.go('/exams');

// Navigate with parameters
context.go('/exams/123');

// Navigate with extra data
context.go('/exams/multiple-choice', extra: ExamData(...));

// Go back
context.pop();
```

---

## 6. State Management with Cubit

### Step 1: Define State Classes

**File**: `my_feature_state.dart`

```dart
import 'package:equatable/equatable.dart';

abstract class MyFeatureState extends Equatable {
  const MyFeatureState();
  
  @override
  List<Object?> get props => [];
}

class MyFeatureInitial extends MyFeatureState {}

class MyFeatureLoading extends MyFeatureState {}

class MyFeatureLoaded extends MyFeatureState {
  final List<String> items;
  
  const MyFeatureLoaded({required this.items});
  
  @override
  List<Object?> get props => [items];
}

class MyFeatureError extends MyFeatureState {
  final String message;
  
  const MyFeatureError({required this.message});
  
  @override
  List<Object?> get props => [message];
}
```

### Step 2: Create Cubit

**File**: `my_feature_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_feature_state.dart';

class MyFeatureCubit extends Cubit<MyFeatureState> {
  MyFeatureCubit() : super(MyFeatureInitial());
  
  Future<void> loadItems() async {
    emit(MyFeatureLoading());
    
    try {
      // Fetch data (e.g., from repository)
      await Future.delayed(Duration(seconds: 1));
      final items = ['Item 1', 'Item 2', 'Item 3'];
      
      emit(MyFeatureLoaded(items: items));
    } catch (e) {
      emit(MyFeatureError(message: e.toString()));
    }
  }
  
  void clearItems() {
    emit(MyFeatureInitial());
  }
}
```

### Step 3: Provide Cubit in App

**File**: `app.dart`

```dart
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Add your cubit here
        BlocProvider(create: (_) => MyFeatureCubit()),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
      ),
    );
  }
}
```

### Step 4: Use Cubit in UI

```dart
class MyFeaturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              context.read<MyFeatureCubit>().loadItems();
            },
            child: Text('Load Items'),
          ),
          BlocBuilder<MyFeatureCubit, MyFeatureState>(
            builder: (context, state) {
              if (state is MyFeatureLoading) {
                return CircularProgressIndicator();
              }
              
              if (state is MyFeatureLoaded) {
                return Column(
                  children: state.items.map((item) => Text(item)).toList(),
                );
              }
              
              if (state is MyFeatureError) {
                return Text('Error: ${state.message}');
              }
              
              return Text('Initial state');
            },
          ),
        ],
      ),
    );
  }
}
```

---

## 7. Working with Storage Layer

### Step 1: Define Entity

**File**: `lib/features/storage/domain/entities/exam.dart`

```dart
import 'package:equatable/equatable.dart';

class Exam extends Equatable {
  final String id;
  final String title;
  final int questionCount;
  
  const Exam({
    required this.id,
    required this.title,
    required this.questionCount,
  });
  
  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] as String,
      title: json['title'] as String,
      questionCount: json['questionCount'] as int,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'questionCount': questionCount,
  };
  
  @override
  List<Object?> get props => [id, title, questionCount];
}
```

### Step 2: Define Repository Interface

**File**: `lib/features/storage/domain/repos/exam_repo.dart`

```dart
import '../entities/exam.dart';

abstract class ExamRepo {
  Future<List<Exam>> getAll();
  Future<Exam?> getById(String id);
  Future<void> create(Exam exam);
  Future<void> update(Exam exam);
  Future<void> delete(String id);
}
```

### Step 3: Implement Repository

**File**: `lib/features/storage/data/firebase_exam_repo.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/exam.dart';
import '../domain/repos/exam_repo.dart';

class FirebaseExamRepo implements ExamRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('exams');
  
  @override
  Future<List<Exam>> getAll() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => Exam.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }
  
  @override
  Future<Exam?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Exam.fromJson({...doc.data()!, 'id': doc.id});
  }
  
  @override
  Future<void> create(Exam exam) async {
    await _collection.doc(exam.id).set(exam.toJson());
  }
  
  @override
  Future<void> update(Exam exam) async {
    await _collection.doc(exam.id).update(exam.toJson());
  }
  
  @override
  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }
}
```

### Step 4: Inject Repository into Cubit

**In app.dart**:
```dart
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize repositories
    final examRepo = FirebaseExamRepo();
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ExamsCubit(examRepo: examRepo),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
      ),
    );
  }
}
```

**In cubit**:
```dart
class ExamsCubit extends Cubit<ExamsState> {
  final ExamRepo _examRepo;
  
  ExamsCubit({required ExamRepo examRepo})
      : _examRepo = examRepo,
        super(ExamsInitial());
  
  Future<void> loadExams() async {
    emit(ExamsLoading());
    try {
      final exams = await _examRepo.getAll();
      emit(ExamsLoaded(exams: exams));
    } catch (e) {
      emit(ExamsError(message: e.toString()));
    }
  }
}
```

---

## 8. Quality Checklist

Before committing code, ensure:

### Architecture Compliance
- [ ] Feature follows folder structure from `1_appendix.md`
- [ ] Cubit and State are in separate files
- [ ] Route class receives path from `app_router.dart` (no hardcoded paths)
- [ ] Repository interface is in `domain/repos/`
- [ ] Repository implementation is in `data/`

### Theme Compliance
- [ ] All colors use `AppColors.*` constants
- [ ] All text styles use `AppTextStyles.*` constants
- [ ] All shapes use `AppShapes.*` constants
- [ ] Interactive components use `NeoContainer`
- [ ] Pages use `CustomScaffold`

### Code Quality
- [ ] `flutter analyze` passes with zero errors
- [ ] No files > 300 LOC (split into smaller files)
- [ ] All state classes extend `Equatable`
- [ ] All state classes are immutable (final fields)
- [ ] Repository methods are CRUD-focused (no business logic)

### Testing
- [ ] Run `flutter build apk --debug` (must succeed)
- [ ] Run `flutter run` (must launch)
- [ ] Visual inspection matches Neo-Brutalist spec (thick borders, hard shadows)

---

## Need Help?

**Reference Documents**:
- `.specify/memory/constitution.md` - Project principles
- `.specify/memory/1_appendix.md` - Architecture rules
- `.specify/memory/2_theme.md` - Design system rules

**Common Issues**:
- **Route not found**: Check path constant in `app_router.dart`
- **State not updating**: Ensure `emit()` is called in cubit
- **Colors look wrong**: Verify hex values against `2_theme.md`
- **Build fails**: Run `flutter pub get` and check dependencies

Happy coding! 🎉
