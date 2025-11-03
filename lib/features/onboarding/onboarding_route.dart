import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../storage/data/shared_preferences_notification_repo.dart';
import 'presentation/cubits/onboarding_cubit.dart';
import 'presentation/pages/notification_permission_page.dart';

/// Onboarding feature routes
///
/// Defines routes for the onboarding flow:
/// - /onboarding/notification-permission - Notification permission request screen (S5)
class OnboardingRoutes {
  static List<RouteBase> routes = [
    GoRoute(
      path: '/onboarding/notification-permission',
      name: 'onboarding-notification-permission',
      builder: (context, state) {
        return BlocProvider(
          create: (context) => OnboardingCubit(
            permissionRepo: SharedPreferencesNotificationRepo(),
          ),
          child: const NotificationPermissionPage(),
        );
      },
    ),
  ];
}
