import 'package:go_router/go_router.dart';
import '../features/common/widgets/home_page.dart';

/// Centralized routing configuration
///
/// All route paths are owned by this class to maintain single source of truth.
/// Feature modules reference these paths but do not define them.
class AppRouter {
  /// Route path constants
  static const String home = '/';

  /// GoRouter instance with route configuration
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
