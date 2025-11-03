import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../common/themes/app_colors.dart';
import '../../../common/themes/app_text_styles.dart';
import '../../../common/widgets/neo_button.dart';
import '../cubits/onboarding_cubit.dart';
import '../cubits/onboarding_state.dart';

/// Onboarding S5 screen - Notification Permission Request
/// 
/// This screen explains why notifications are needed and triggers
/// the native OS permission dialog when user taps "Allow Notifications".
/// After permission request (regardless of grant/deny), navigates to Paywall.
class NotificationPermissionPage extends StatelessWidget {
  const NotificationPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingComplete) {
          // Navigate to timer screen (root) after permission request completes
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Notification icon
                Icon(
                  Icons.notifications_active_outlined,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                
                const SizedBox(height: 16.0),
                
                // Title
                Text(
                  'Enable Notifications',
                  style: AppTextStyles.titleMedium,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16.0),
                
                // Explanatory text
                Text(
                  'Get notified when your Pomodoro timer completes, so you know when it\'s time for a break. You can change this later in Settings.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400, // Regular weight for body text
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32.0),
                
                // Allow Notifications button
                BlocBuilder<OnboardingCubit, OnboardingState>(
                  builder: (context, state) {
                    final isLoading = state is OnboardingLoading;
                    
                    return NeoButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context
                                  .read<OnboardingCubit>()
                                  .requestNotificationPermission();
                            },
                      backgroundColor: AppColors.primary,
                      child: isLoading
                          ? const Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.onPrimary,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              'Allow Notifications',
                              style: AppTextStyles.bodyLarge,
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
