import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'presentation/cubits/timer_cubit.dart';
import 'presentation/pages/timer_page.dart';
import 'presentation/pages/break_placeholder_page.dart';

/// Timer feature routes
///
/// Defines all routes for the timer feature:
/// - /timer - Main timer screen with BlocProvider
/// - /break - Placeholder break screen (temporary)
class TimerRoutes {
  static List<RouteBase> routes = [
    GoRoute(
      path: '/timer',
      name: 'timer',
      builder: (context, state) {
        return BlocProvider(
          create: (context) => TimerCubit(),
          child: const TimerPage(),
        );
      },
    ),
    GoRoute(
      path: '/break',
      name: 'break',
      builder: (context, state) => const BreakPlaceholderPage(),
    ),
  ];
}
