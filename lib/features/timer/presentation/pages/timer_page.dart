import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/themes/app_colors.dart';
import '../../../common/themes/app_text_styles.dart';
import '../../../common/widgets/neo_button.dart';
import '../../../common/widgets/neo_icon_button.dart';
import '../cubits/timer_cubit.dart';
import '../cubits/timer_state.dart';
import '../widgets/neo_circular_timer.dart';
import '../widgets/animated_completion_icon.dart';
import '../widgets/session_type_indicator.dart';

/// Main timer page displaying circular timer and controls
///
/// Shows:
/// - Session type indicator ("WORK" or "BREAK")
/// - Circular timer with countdown text
/// - Control buttons (reset, play/pause, skip)
/// - Placeholder for quick-adjust controls (future feature)
class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'App 25:5',
          style: AppTextStyles.titleMedium,
        ),
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Session type indicator
              BlocBuilder<TimerCubit, TimerCubitState>(
                builder: (context, state) {
                  SessionType sessionType = SessionType.work; // Default
                  
                  if (state is TimerInitialState) {
                    sessionType = state.sessionType;
                  } else if (state is TimerRunningState) {
                    sessionType = state.sessionType;
                  } else if (state is TimerPausedState) {
                    sessionType = state.sessionType;
                  } else if (state is TimerCompletedState) {
                    sessionType = state.completedSessionType;
                  }
                  
                  return SessionTypeIndicator(sessionType: sessionType);
                },
              ),
              const SizedBox(height: 48),
              
              // Timer display area
              BlocBuilder<TimerCubit, TimerCubitState>(
                buildWhen: (previous, current) {
                  // Only rebuild when state type changes or time changes
                  // This prevents unnecessary rebuilds that cause flicker
                  if (previous.runtimeType != current.runtimeType) return true;
                  
                  if (previous is TimerRunningState && current is TimerRunningState) {
                    return previous.remaining != current.remaining;
                  }
                  if (previous is TimerPausedState && current is TimerPausedState) {
                    return previous.remaining != current.remaining;
                  }
                  
                  return true;
                },
                builder: (context, state) {
                  if (state is TimerCompletedState) {
                    // Show completion animation
                    return const AnimatedCompletionIcon(
                      size: 280.0,
                      strokeWidth: 20.0,
                    );
                  }
                  
                  // Show timer for Initial, Running, Paused states
                  final progress = _getProgress(state);
                  final timeText = _getTimeText(state);
                  
                  return RepaintBoundary(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        NeoCircularTimer(
                          progress: progress,
                          size: 280.0,
                          strokeWidth: 20.0,
                        ),
                        // Use Key to prevent text fade animation artifacts
                        // Use tabular-nums feature for fixed-width digits
                        // Wrap in RepaintBoundary to isolate repaints
                        // Use AnimatedSwitcher with zero duration to prevent fade
                        AnimatedSwitcher(
                          duration: Duration.zero, // No animation
                          switchInCurve: Curves.linear,
                          switchOutCurve: Curves.linear,
                          child: RepaintBoundary(
                            child: Text(
                              timeText,
                              key: ValueKey(timeText), // Force rebuild on text change
                              style: AppTextStyles.displayLarge.copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures(), // Fixed-width digits
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 48),
              
              // Placeholder for quick-adjust controls (future feature)
              // This maintains layout consistency per FR-043
              Container(
                height: 60,
                color: Colors.transparent,
              ),
              
              const SizedBox(height: 24),
              
              // Control buttons
              BlocBuilder<TimerCubit, TimerCubitState>(
                builder: (context, state) {
                  final cubit = context.read<TimerCubit>();
                  final isRunning = state is TimerRunningState;
                  
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Reset button
                      NeoIconButton(
                        icon: Icons.refresh,
                        onPressed: () => cubit.reset(),
                        backgroundColor: AppColors.surface,
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Play/Pause button
                      NeoButton(
                        onPressed: () {
                          if (isRunning) {
                            cubit.pause();
                          } else {
                            cubit.start();
                          }
                        },
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        child: Icon(
                          isRunning ? Icons.pause : Icons.play_arrow,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Skip button
                      NeoIconButton(
                        icon: Icons.skip_next,
                        onPressed: () => cubit.skip(),
                        backgroundColor: AppColors.surface,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get progress value from state (0.0 to 1.0)
  double _getProgress(TimerCubitState state) {
    if (state is TimerRunningState) {
      return state.progress;
    } else if (state is TimerPausedState) {
      return state.progress;
    } else if (state is TimerInitialState) {
      return 1.0; // Full circle
    }
    return 0.0;
  }

  /// Get countdown text from state (MM:SS format)
  String _getTimeText(TimerCubitState state) {
    Duration duration;
    
    if (state is TimerInitialState) {
      duration = state.totalDuration;
    } else if (state is TimerRunningState) {
      duration = state.remaining;
    } else if (state is TimerPausedState) {
      duration = state.remaining;
    } else {
      duration = Duration.zero;
    }
    
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    
    return '$minutes:$seconds';
  }
}
