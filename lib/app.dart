import 'package:flutter/material.dart';
import 'config/app_router.dart';
import 'features/common/themes/app_colors.dart';

/// Root application widget
///
/// Initializes dependency injection (BLoC providers) and routing.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'A255 App',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      theme: ThemeData(
        // Using theme system from US3
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        // Disable implicit text animations to prevent fade effects
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        // Set animation duration to zero for text
        textTheme: const TextTheme(),
      ),
    );
  }
}
