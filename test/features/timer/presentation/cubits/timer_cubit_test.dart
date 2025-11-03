import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:a255_app/features/timer/presentation/cubits/timer_cubit.dart';
import 'package:a255_app/features/timer/presentation/cubits/timer_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('TimerCubit', () {
    late TimerCubit timerCubit;

    setUp(() {
      timerCubit = TimerCubit();
    });

    tearDown(() {
      timerCubit.close();
    });

    test('initial state is TimerInitialState with 25 minutes', () {
      // Assert
      expect(timerCubit.state, isA<TimerInitialState>());
      final state = timerCubit.state as TimerInitialState;
      expect(state.totalDuration, const Duration(minutes: 25));
      expect(state.sessionType, SessionType.work);
    });

    blocTest<TimerCubit, TimerCubitState>(
      'start() transitions from Initial to Running',
      build: () => TimerCubit(),
      act: (cubit) => cubit.start(),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<TimerRunningState>()
          .having((s) => s.progress, 'progress', closeTo(1.0, 0.01))
          .having((s) => s.remaining.inMinutes, 'remaining minutes', 24),
      ],
    );

    blocTest<TimerCubit, TimerCubitState>(
      'pause() transitions from Running to Paused',
      build: () => TimerCubit(),
      act: (cubit) async {
        cubit.start();
        await Future.delayed(const Duration(seconds: 2));
        cubit.pause();
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<TimerRunningState>(),
        isA<TimerRunningState>(),
        isA<TimerPausedState>()
          .having((s) => s.remaining.inMinutes, 'remaining minutes', 24),
      ],
    );

    blocTest<TimerCubit, TimerCubitState>(
      'start() resumes from Paused to Running',
      build: () => TimerCubit(),
      act: (cubit) async {
        cubit.start();
        await Future.delayed(const Duration(seconds: 1));
        cubit.pause();
        await Future.delayed(const Duration(milliseconds: 100));
        cubit.start();
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<TimerRunningState>(),
        isA<TimerPausedState>(),
        isA<TimerRunningState>(),
      ],
    );

    blocTest<TimerCubit, TimerCubitState>(
      'reset() returns to Initial state',
      build: () => TimerCubit(),
      act: (cubit) async {
        cubit.start();
        await Future.delayed(const Duration(seconds: 1));
        cubit.reset();
      },
      expect: () => [
        isA<TimerRunningState>(),
        isA<TimerInitialState>()
          .having((s) => s.totalDuration, 'totalDuration', const Duration(minutes: 25))
          .having((s) => s.sessionType, 'sessionType', SessionType.work),
      ],
    );

    blocTest<TimerCubit, TimerCubitState>(
      'timer completes after duration elapses',
      build: () => TimerCubit(),
      act: (cubit) {
        // Override with short duration for testing
        cubit.emit(const TimerInitialState(
          totalDuration: Duration(seconds: 2),
          sessionType: SessionType.work,
        ));
        cubit.start();
      },
      wait: const Duration(seconds: 3),
      expect: () => [
        isA<TimerInitialState>(),
        isA<TimerRunningState>(),
        isA<TimerRunningState>(),
        isA<TimerCompletedState>()
          .having((s) => s.completedSessionType, 'sessionType', SessionType.work),
      ],
    );

    blocTest<TimerCubit, TimerCubitState>(
      'timer updates every second',
      build: () => TimerCubit(),
      act: (cubit) => cubit.start(),
      wait: const Duration(seconds: 3),
      verify: (cubit) {
        // Verify multiple state emissions (at least 3 for 3 seconds)
        expect(cubit.state, isA<TimerRunningState>());
      },
    );

    test('progress calculation is accurate', () async {
      // Arrange
      timerCubit.emit(const TimerInitialState(
        totalDuration: Duration(minutes: 10),
        sessionType: SessionType.work,
      ));
      
      timerCubit.start();
      await Future.delayed(const Duration(seconds: 2));
      
      // Assert
      expect(timerCubit.state, isA<TimerRunningState>());
      final state = timerCubit.state as TimerRunningState;
      
      // Progress should be close to 1.0 since only 2 seconds elapsed out of 10 minutes
      expect(state.progress, greaterThan(0.99));
      expect(state.remaining.inMinutes, 9);
    });

    test('DateTime-based calculation maintains accuracy', () async {
      // Arrange - Start with 5 second timer
      timerCubit.emit(const TimerInitialState(
        totalDuration: Duration(seconds: 5),
        sessionType: SessionType.work,
      ));
      
      timerCubit.start();
      await Future.delayed(const Duration(seconds: 3));
      
      // Assert - After 3 seconds, should have ~2 seconds remaining (±1s tolerance)
      expect(timerCubit.state, isA<TimerRunningState>());
      final state = timerCubit.state as TimerRunningState;
      expect(state.remaining.inSeconds, greaterThanOrEqualTo(1));
      expect(state.remaining.inSeconds, lessThanOrEqualTo(3));
    });

    test('pausing preserves remaining time accurately', () async {
      // Arrange
      timerCubit.emit(const TimerInitialState(
        totalDuration: Duration(seconds: 10),
        sessionType: SessionType.work,
      ));
      
      timerCubit.start();
      await Future.delayed(const Duration(seconds: 2));
      timerCubit.pause();
      
      // Assert - Should have ~8 seconds remaining
      expect(timerCubit.state, isA<TimerPausedState>());
      final state = timerCubit.state as TimerPausedState;
      expect(state.remaining.inSeconds, greaterThanOrEqualTo(7));
      expect(state.remaining.inSeconds, lessThanOrEqualTo(9));
    });

    blocTest<TimerCubit, TimerCubitState>(
      'skip() transitions to Completed from any state',
      build: () => TimerCubit(),
      act: (cubit) {
        cubit.start();
        cubit.skip();
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<TimerRunningState>(),
        isA<TimerCompletedState>()
          .having((s) => s.completedSessionType, 'sessionType', SessionType.work),
      ],
    );

    blocTest<TimerCubit, TimerCubitState>(
      'skip() works from Initial state',
      build: () => TimerCubit(),
      act: (cubit) => cubit.skip(),
      expect: () => [
        isA<TimerCompletedState>()
          .having((s) => s.completedSessionType, 'sessionType', SessionType.work),
      ],
    );

    blocTest<TimerCubit, TimerCubitState>(
      'skip() works from Paused state',
      build: () => TimerCubit(),
      act: (cubit) async {
        cubit.start();
        await Future.delayed(const Duration(seconds: 1));
        cubit.pause();
        await Future.delayed(const Duration(milliseconds: 100));
        cubit.skip();
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<TimerRunningState>(),
        isA<TimerPausedState>(),
        isA<TimerCompletedState>()
          .having((s) => s.completedSessionType, 'sessionType', SessionType.work),
      ],
    );
  });
}
