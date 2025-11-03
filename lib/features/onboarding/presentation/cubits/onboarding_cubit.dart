import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_router.dart';
import '../../../storage/domain/repos/notification_permission_repo.dart';
import 'onboarding_state.dart';

/// Cubit for managing notification permission onboarding flow
class OnboardingCubit extends Cubit<OnboardingState> {
  final NotificationPermissionRepo _permissionRepo;

  OnboardingCubit({
    required NotificationPermissionRepo permissionRepo,
  })  : _permissionRepo = permissionRepo,
        super(const OnboardingInitial());

  /// Request notification permission from the OS
  /// 
  /// Shows native permission dialog and marks onboarding as complete
  /// regardless of user's choice (grant/deny).
  Future<void> requestNotificationPermission() async {
    emit(const OnboardingLoading());

    try {
      // Request permission (triggers OS dialog)
      await _permissionRepo.requestPermission();

      // Mark onboarding as complete (write-once flag)
      await _permissionRepo.markOnboardingComplete();
      
      // Update global router flag so redirect knows onboarding is done
      AppRouter.hasCompletedOnboarding = true;

      // Emit complete state (triggers navigation to timer)
      emit(const OnboardingComplete());
    } catch (e) {
      // Even if there's an error, mark onboarding complete
      // to prevent user from being stuck on this screen
      await _permissionRepo.markOnboardingComplete();
      AppRouter.hasCompletedOnboarding = true;
      emit(const OnboardingComplete());
    }
  }
}
