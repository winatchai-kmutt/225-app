import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/app_router.dart';
import 'features/common/themes/app_colors.dart';

/// Root application widget
///
/// Initializes dependency injection (BLoC providers) and routing.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Future Cubit/Bloc providers will be added here
      ],
      child: MaterialApp.router(
        title: 'A255 App',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        theme: ThemeData(
          // Using theme system from US3
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
        ),
      ),
    );
  }
}
