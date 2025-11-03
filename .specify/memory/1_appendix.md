## Appendix — Project Structure & Code Philosophy (Flutter + Clean Architecture)

### Scope
### All new Flutter projects (Android&IOS) MUST follow this layout and rules to ensure consistent structure, predictable code, and easy agent automation. Out of scope: Subscription/IAP (RevenueCat) and Sentry — OMIT or MOCK only in starters.
### Flutter projects  only Android&IOS
---
### Folder Structure (Flutter + Clean Architecture)

> This document defines the canonical **folders and files** under `lib/`.  
> It is **structure-only** (no code philosophy), designed to be copy-pasted into your docs.

---

#### Top-Level Overview (`lib/`)
```
lib/
  app.dart                 # App root: DI bootstrap, MultiBlocProvider, MaterialApp.router
  main.dart                # Entry point
  config/                  # Global config & routing
  features/                # All app features
```

---

#### 1) `config/` — Global Configuration & Routing
```
lib/
└─ config/
   ├─ app_config.dart      # Env/Flavor flags, constants, feature switches
   └─ app_router.dart      # go_router: owns ALL path strings + nesting + guards; assembles feature routes
```

**Rules**
- `app_router.dart` is the **single owner** of all route paths.
- Feature route files **do not** hardcode paths; they expose classes that return `GoRoute` and receive `path` from `app_router.dart`.

---

#### 2) `features/` — Feature Modules (UI + Cubit) and Shared Storage
```
lib/
└─ features/
   ├─ common/              # Design system, shared widgets, pure utilities
   ├─ <feature-name>/      # A feature (e.g., home, exam, setting)
   └─ storage/             # Centralized cross-feature data/services (domain + data)
```

##### 2.1 `features/common/` — Shared UI / Utilities
```
lib/
└─ features/
   └─ common/
      ├─ themes/
      │  ├─ app_colors.dart       # Color tokens / ColorScheme
      │  └─ app_text_styles.dart  # Typography tokens
      ├─ widgets/
      │  └─ custom_scaffold.dart  # Shared page wrapper (safe area, padding, etc.)
      └─ utils/
         └─ calculate_util.dart   # Pure utilities only (no IO/side-effects)
```

##### 2.2 `features/<feature-name>/` — Feature Skeleton (UI + Cubit)
```
lib/
└─ features/
   └─ <feature-name>/
      ├─ <feature-name>_route.dart       # Defines classes returning GoRoute (no hardcoded paths)
      └─ presentation/                   # UI-only layer for this feature
         ├─ pages/
         │  └─ <feature>_page.dart       # Screen/pages for this feature
         ├─ components/                  # (optional) Sub-widgets that belong to pages
         └─ cubits/
            ├─ <feature>_cubit.dart      # Cubit (state machine / event handlers)
            └─ <feature>_state.dart      # State class(es) for the Cubit
```

**Notes**
- `presentation/` contains **only UI and Cubit** (no repository implementations here).
- `cubits/` must separate `*_cubit.dart` and `*_state.dart` **into distinct files**.

##### Example — `features/home/`
```
lib/
└─ features/
   └─ home/
      ├─ home_route.dart
      └─ presentation/
         ├─ pages/
         │  └─ home_page.dart
         └─ cubits/
            ├─ home_cubit.dart
            └─ home_state.dart
```

##### Example — `features/exam/`
```
lib/
└─ features/
   └─ exam/
      ├─ exam_route.dart
      └─ presentation/
         ├─ pages/
         │  ├─ exams_page.dart
         │  ├─ prepare_page.dart
         │  ├─ exam_multiple_choice_page.dart
         │  └─ exam_result_page.dart
         ├─ components/
         │  └─ unlock_exam_by_code.dart
         └─ cubits/
            ├─ exams_cubit.dart
            └─ exams_state.dart
```

##### 2.3 `features/storage/` — Centralized Data & Services
```
lib/
└─ features/
   └─ storage/
      ├─ domain/                      # Pure domain layer (entities + repository interfaces)
      │  ├─ entities/
      │  │  ├─ app-level models (e.g., exam.dart, course.dart, ...)
      │  │  └─ value objects / aggregates
      │  └─ repos/
      │     ├─ <entity>_repo.dart     # Abstract interfaces (CRUD-focused)
      │     └─ ...                    # More repo contracts
      └─ data/                        # Implementations (Firebase/Hive/etc.)
         ├─ firebase_*.dart           # Firebase implementations
         ├─ hive_*.dart               # Hive/Isar/SQLite implementations
         └─ ...                       # Adapters, mappers
```

**Rules**
- `domain/` contains only **entities** and **repository interfaces**.
- `data/` contains only **concrete implementations** of repository interfaces.
- All storage services are **centralized** here to be shared across features.

##### Example — Storage (Selected Files)
```
lib/
└─ features/storage/
   ├─ domain/
   │  ├─ entities/
   │  │  └─ course_purchase_count.dart
   │  └─ repos/
   │     └─ course_purchase_count_repo.dart
   └─ data/
      └─ firebase_course_purchase_count_repo.dart
```

---

#### 3) Route Ownership Pattern (where files live)
```
lib/
├─ config/
│  └─ app_router.dart           # Assembles the entire route tree and OWNS all path strings
└─ features/
   └─ <feature>/
      └─ <feature>_route.dart   # Classes that return GoRoute; receive `path` from app_router.dart
```

**Example wiring (files only, no code):**
```
lib/config/app_router.dart
lib/features/home/home_route.dart
lib/features/exam/exam_route.dart
```

---

#### 4) Minimal Top-Level Files
```
lib/
├─ main.dart     # Entry point: runApp(App)
└─ app.dart      # App root: service bootstrap + MultiBlocProvider + MaterialApp.router
```

---

#### 5) Naming Conventions (Folders & Files)
- Feature folder names: **lower_snake_case** (e.g., `exam`, `home`, `setting`, `auth`).
- Route files: `<feature>_route.dart` (e.g., `exam_route.dart`).
- Cubits & States: `<feature>_cubit.dart`, `<feature>_state.dart` (separate files).
- Entity files: **singular** nouns (e.g., `course.dart`, `exam.dart`).
- Repository interfaces: `<entity>_repo.dart` (e.g., `course_purchase_count_repo.dart`).
- Data implementations: prefix with backend/local tech (e.g., `firebase_*`, `hive_*`).

---

#### 6) Optional (If Present)
```
assets/               # Images, fonts, lottie (referenced in pubspec.yaml)
test/                 # Unit/widget tests mirroring lib/ structure
integration_test/     # Integration tests
```

> Keep this structure **strict** across projects. Adding a new feature should mirror `features/<feature-name>/` exactly, and storage changes should appear under `features/storage` only.

---

### Non-Negotiable Code Philosophy

#### 1) State Management — `flutter_bloc` (Cubit-only) — **files clearly separated**
- MUST place **Cubit** and **State** in different files under `presentation/cubits/`:
  - `.../exams_cubit.dart`
  - `.../exams_state.dart`
- MUST keep `State` immutable; use `copyWith` when applicable; prefer `Equatable` for value semantics.
- MUST provide all cubits via **`MultiBlocProvider` in `app.dart`** and inject dependencies via constructors.
- MUST keep heavy business rules out of Widgets; put them in Cubits/use-cases.

**Minimal shape (mirrors practice in real files):**
```dart
// exams_state.dart
abstract class ExamsState extends Equatable { const ExamsState(); @override List<Object?> get props => []; }
class ExamsInitial extends ExamsState {}
class ExamsLoading extends ExamsState {}
class ExamsLoaded extends ExamsState {
  final List<Exam> exams; final Field field; final Law law; final bool isLock; final bool isSignIn;
  const ExamsLoaded({required this.exams, required this.field, required this.law, required this.isLock, required this.isSignIn});
  @override List<Object?> get props => [exams, field, law, isLock, isSignIn];
}
class ExamsSnackBar extends ExamsState { /* ephemeral message with unique id */ }
class ExamsOverlay  extends ExamsState { /* overlay loading flag */ }
class ExamsError    extends ExamsState { /* error message */ }

// exams_cubit.dart
class ExamsCubit extends Cubit<ExamsState> {
  ExamsCubit({ required LocalExamRepo localExamRepo, required MetadataRepo metadataRepo,
               required ExamOwnerRepo examOwnerRepo, required AuthRepo authRepo, })
      : _localExamRepo = localExamRepo, _metadataRepo = metadataRepo,
        _examOwnerRepo = examOwnerRepo, _authRepo = authRepo, super(ExamsInitial());

  // deps + caches ...

  Future<void> onNewExamCompleted({required int id, required int nCorrected}) async {
    emit(ExamsLoading());
    await _localExamRepo.updateByNewCompletedExam(examId: id, nCorrected: nCorrected);
    await _metadataRepo.updateMetadata(needsSyncToCloud: true);
    final all = await _localExamRepo.getAllExams();
    final filtered = _filter(all, _lastFieldSelected, _lastLawSelected);
    emit(ExamsLoaded(exams: filtered, field: _lastFieldSelected, law: _lastLawSelected, isLock: _isLock, isSignIn: _isSignIn));
  }
}
```
(Use the above structure consistently for every feature.)

#### 2) Navigation — `go_router` (correct ownership pattern)
- **Single owner for paths:** **ALL** path strings and nesting live in `config/app_router.dart`.
- Feature `*_route.dart` files define tiny classes that **produce `GoRoute`** and accept an injected `path` (no path literals inside).
- Use type-safe params and add guards/redirects centrally in `app_router.dart`.
- MUST NOT use raw `Navigator.push` in UI.

**Feature route classes (no hardcoded paths)**
```dart
class ExamPageRoute { final String path; final List<GoRoute> routes;
  ExamPageRoute({required this.path, required this.routes});
  GoRoute get route => GoRoute(path: path, routes: routes, builder: (c,s) => const ExamsPage());
}
class ExamMCRoute { final String path; ExamMCRoute({required this.path});
  GoRoute get route => GoRoute(path: path, builder: (c,s){
    final data = s.extra as ExamMultipleChoicePageData;
    return ExamMultipleChoicePage(examMCD: data);
  });
}
```
**Central assembly (`app_router.dart`)**
```dart
final router = GoRouter(
  initialLocation: '/home',
  routes: [
    HomeRoute(path: '/home').route,
    ExamPageRoute(path: '/exams', routes: [
      ExamMCRoute(path: 'multiple-choice').route,
      PrepareRoute(path: 'prepare').route,
      ExamAnswersRoute(path: 'answers').route,
    ]).route,
  ],
  redirect: (ctx, state) => null,
);
```

#### 3) Data Layer — Firebase + Hive (centralized) — **clear separation + CRUD examples**
- MUST centralize repositories/services in `features/storage`.
- MUST keep repositories CRUD-focused (get/create/update/delete/sync); **no heavy business rules** here.
- MUST initialize Firebase/Hive in `app.dart` and inject repos/services into Cubits via DI.
- MUST NOT couple UI directly to Firebase/Hive SDKs.
- MUST separate **domain** (entities + repo interfaces) from **data** (concrete implementations).

**Domain (entity + interface)**
```dart
// domain/entities/course_purchase_count.dart
class CoursePurchaseCount extends Equatable {
  final int courseId; final int count;
  const CoursePurchaseCount({required this.courseId, required this.count});
  CoursePurchaseCount copyWith({int? courseId, int? count}) => CoursePurchaseCount(
    courseId: courseId ?? this.courseId, count: count ?? this.count);
  factory CoursePurchaseCount.fromJson(Map<String,dynamic> m){
    return CoursePurchaseCount(courseId: m['courseId'] as int, count: m['count'] as int);
  }
  Map<String, dynamic> toJson() => {'courseId': courseId, 'count': count};
}

// domain/repos/course_purchase_count_repo.dart
abstract class CoursePurchaseCountRepo {
  Future<List<CoursePurchaseCount>> getAll(); // READ
  Future<void> increment(int courseId);       // UPDATE (atomic)
}
```

**Data (Firebase implementation) — example of UPDATE + READ**
```dart
class FirebaseCoursePurchaseCountRepo implements CoursePurchaseCountRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const _collection = 'course_purchase_counts';
  CollectionReference<Map<String,dynamic>> get _col => _firestore.collection(_collection);

  @override
  Future<List<CoursePurchaseCount>> getAll() async {
    final qs = await _col.get();
    return qs.docs.map((d){
      final courseId = int.tryParse(d.id) ?? 0;
      return CoursePurchaseCount(courseId: courseId, count: d.data()['count'] as int);
    }).toList();
  }

  @override
  Future<void> increment(int courseId) async {
    final doc = _col.doc(courseId.toString());
    await doc.set({'count': FieldValue.increment(1)}, SetOptions(merge=True));
  }
}
```
**Local repo contract focused on GET / UPDATE / DELETE** (Hive/Isar/etc. impl can follow the same shape)
```dart
abstract class LocalExamRepo {
  Future<List<Exam>> getAll();                    // GET
  Future<void> upsertAll(List<Exam> exams);       // UPDATE (bulk)
  Future<void> delete(String id);                 // DELETE
}
```
> Business rules (e.g., scoring, filtering, syncing flags) should live in the **Cubit**, calling these CRUD-focused methods.

#### 4) UI & Theming
- MUST use `app_colors.dart` & `app_text_styles.dart` as the single source of truth.
- MUST use `custom_scaffold.dart` as the standard page shell (safe area, padding).
- MUST centralize spacing/shapes/tokens (no magic numbers sprinkled across pages).

#### 5) Clean Code Hygiene
- Utilities under `common/utils` MUST be pure (no IO/side-effects).
- Split files > 300 LOC into subcomponents/extensions.
- Names MUST be intention-revealing and concise.

#### 6) Micro-state vs `setState` (When & How)
**Use `ValueNotifier + ValueListenableBuilder` when:**
- The widget is **large/complex**, and only **small portions** need to update frequently.
- You want to avoid rebuilding parent/expensive layouts.
```dart
class MultipleChoiceBox extends StatelessWidget {
  final ValueNotifier<int?> selectedIndex;
  const MultipleChoiceBox({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<int?>(
          valueListenable: selectedIndex,
          builder: (_, value, __) {
            return /* render options highlighting `value` */ Container();
          },
        ),
        // other children...
      ],
    );
  }
}
```

**Use `setState` when:**
- The widget is **already small & isolated** (e.g., a tiny leaf widget) and a simple rebuild is fine.
```dart
class TinyToggle extends StatefulWidget { const TinyToggle({super.key}); @override State<TinyToggle> createState() => _TinyToggleState(); }
class _TinyToggleState extends State<TinyToggle> {
  bool on = false;
  @override
  Widget build(BuildContext context) {
    return Switch(value: on, onChanged: (v){ setState(()=> on = v); });
  }
}
```
**Rule of thumb**: For **big pages**, prefer `ValueNotifier` micro-state (or extract to a tiny widget); for **tiny widgets**, `setState` is acceptable.

---

### Route Extras — DTOs & Safety (Recommended)

To keep feature routes type-safe and decoupled from domain models, define **small DTOs** that carry only what the page needs. Pass these via `state.extra`. Validate and provide fallbacks where appropriate.

```dart
// features/exam/presentation/pages/exam_multiple_choice_dto.dart
class ExamMultipleChoicePageData {
  final int examId; // avoid passing entire Exam entity
  final String? title;
  const ExamMultipleChoicePageData({required this.examId, this.title});
}
```

Use it in your route builder with checks:

```dart
class ExamMCRoute {
  final String path;
  ExamMCRoute({required this.path});

  GoRoute get route => GoRoute(
    path: path,
    builder: (context, state) {
      final data = state.extra;
      assert(
        data is ExamMultipleChoicePageData,
        'ExamMCRoute requires ExamMultipleChoicePageData via `state.extra`',
      );
      final dto = data is ExamMultipleChoicePageData
          ? data
          : const ExamMultipleChoicePageData(examId: -1);
      return ExamMultipleChoicePage(examMCD: dto);
    },
  );
}
```

**Guidelines**
- Prefer DTOs over full domain entities in navigation payloads.
- Keep DTOs **small & serializable**.
- Add `assert` in debug; add **safe fallback** in release (avoid crashes).

---

### Equatable & Immutability Hygiene

Ensure all **State** and **Entity** classes are immutable, value-based, and consistently comparable.

**Rules**
- Extend **`Equatable`** and implement `props` for all state & entity classes that participate in rebuild decisions.
- Use **`const` constructors** where possible.
- Expose **unmodifiable** lists/maps from state (e.g., `UnmodifiableListView`) or copy on write.
- Provide a **`copyWith`** on state for ergonomic updates.

**Examples**
```dart
class CoursePurchaseCount extends Equatable {
  final int courseId;
  final int count;
  const CoursePurchaseCount({required this.courseId, required this.count});
  CoursePurchaseCount copyWith({int? courseId, int? count}) =>
      CoursePurchaseCount(courseId: courseId ?? this.courseId, count: count ?? this.count);
  @override List<Object?> get props => [courseId, count];
}

class ExamsLoaded extends ExamsState {
  final List<Exam> exams;
  final Field field;
  final Law law;
  final bool isLock;
  final bool isSignIn;
  const ExamsLoaded({
    required this.exams,
    required this.field,
    required this.law,
    required this.isLock,
    required this.isSignIn,
  });
  // Optional: wrap in UnmodifiableListView if you expose exams publicly
  @override List<Object?> get props => [exams, field, law, isLock, isSignIn];
}
```

Lint recommendation (optional but helpful):
- Add to `analysis_options.yaml` → enforce `prefer_const_constructors`, `avoid_mutable_fields`, and `always_use_package_imports`.

---

### File Contracts (Minimal Implementations)

#### `lib/main.dart`
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Load AppConfig/flavor if needed.
  runApp(const App());
}
```

#### `lib/app.dart`
```dart
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // 1) Initialize services (Firebase/Hive) and repositories
    // 2) Provide cubits via MultiBlocProvider
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeCubit(/* deps */)),
        BlocProvider(create: (_) => ExamsCubit(/* deps */)),
        // Add more cubits here...
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
```

#### `lib/config/app_config.dart`
```dart
class AppConfig {
  final bool useFirebaseEmulator;
  final String firestoreProjectId;
  const AppConfig({ this.useFirebaseEmulator = false, this.firestoreProjectId = '' });
  static const current = AppConfig();
}
```

#### `lib/config/app_router.dart` (owns ALL paths + nesting)
```dart
class AppRouter {
  static final router = GoRouter(
    initialLocation: '/home',
    routes: [
      HomeRoute(path: '/home').route,
      ExamPageRoute(
        path: '/exams',
        routes: [
          ExamMCRoute(path: 'multiple-choice').route,
          PrepareRoute(path: 'prepare').route,
          ExamAnswersRoute(path: 'answers').route,
        ],
      ).route,
      SettingRoute(path: '/setting').route,
      AuthRoute(path: '/auth').route,
    ],
    redirect: (ctx, state) => null,
  );
}
```

#### Feature route classes (no hardcoded paths inside)
```dart
class HomeRoute {
  final String path; final List<GoRoute> routes;
  HomeRoute({required this.path, this.routes = const []});
  GoRoute get route => GoRoute(path: path, routes: routes, builder: (c,s) => const HomePage());
}
```

#### Themes
```dart
class AppColors {
  static const primary    = Color(0xFF0F62FE);
  static const background = Color(0xFFF7F8FA);
  // Add semantic tokens as needed (success, warning, error, surface, etc.)
}

class AppTextStyles {
  static const title = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  static const body  = TextStyle(fontSize: 14);
}
```

#### Shared scaffolding
```dart
class CustomScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar; final Widget body;
  const CustomScaffold({super.key, this.appBar, required this.body});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: body)),
    );
  }
}
```

#### Repository contracts (centralized)
```dart
abstract class LocalExamRepo {
  Future<List<Exam>> getAll();              // GET
  Future<void> upsertAll(List<Exam> exams); // UPDATE
  Future<void> delete(String id);           // DELETE
}
```

---

### Agent Rules (for Spec-kit)
- MUST scaffold the tree exactly as defined.
- MUST create file stubs per “File Contracts” when missing.
- MUST assemble **all** paths and nesting in `config/app_router.dart` and inject into feature route classes.
- MUST place all repositories/services under `features/storage` and inject via `app.dart` → Cubits.
- MUST NOT include IAP/RevenueCat/Sentry/in_app_review in starters (mock only if referenced).
- SHOULD use `ValueNotifier` for high-frequency UI micro-state.

### Quality Gates
- `flutter analyze` passes; no dead code in starters.
- All navigation via `go_router` (no raw `Navigator.push`).
- Every Cubit has its own immutable State in a separate file.
- Repositories are CRUD-focused; heavy domain/business rules live in Cubits/use-cases.
- No `setState` in large widgets (only isolated, tiny widgets if absolutely necessary).