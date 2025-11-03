import 'package:go_router/go_router.dart';
import '../features/timer/timer_route.dart';
import '../features/onboarding/onboarding_route.dart';

/// Centralized routing configuration
///
/// All route paths are owned by this class to maintain single source of truth.
/// Feature modules reference these paths but do not define them.
class AppRouter {
  /// Route path constants
  static const String timer = '/';  // Timer is now the home/root page
  static const String breakTime = '/break';
  static const String onboardingNotificationPermission = '/onboarding/notification-permission';

  // Flag to track if onboarding is completed (set from main.dart)
  static bool hasCompletedOnboarding = false;

  /// GoRouter instance with route configuration
  static final GoRouter router = GoRouter(
    initialLocation: timer, // Start at timer (root)
    routes: [
      ...TimerRoutes.routes,
      ...OnboardingRoutes.routes,
    ],
    redirect: (context, state) {
      // Only redirect on app start, not when navigating via notification
      final isOnboardingRoute = state.matchedLocation == onboardingNotificationPermission;
      
      // If onboarding not completed and not already on onboarding, redirect there
      if (!hasCompletedOnboarding && !isOnboardingRoute) {
        return onboardingNotificationPermission;
      }
      
      // No redirect
      return null;
    },
  );
}
