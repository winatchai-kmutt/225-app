import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:a255_app/features/timer/presentation/pages/timer_page.dart';
import 'package:a255_app/features/timer/presentation/cubits/timer_cubit.dart';
import 'package:a255_app/features/timer/presentation/cubits/timer_state.dart';
import 'package:a255_app/features/timer/presentation/widgets/neo_circular_timer.dart';
import 'package:a255_app/features/timer/presentation/widgets/animated_completion_icon.dart';

/// Integration test for complete timer flow
///
/// Tests the full user journey:
/// 1. App launch with timer in initial state
/// 2. Start timer
/// 3. Pause timer
/// 4. Resume timer
/// 5. Wait for completion
/// 6. Verify completion animation appears
///
/// This test validates:
/// - State transitions work correctly
/// - UI updates reflect state changes
/// - Timer countdown progresses
/// - Completion flow triggers properly
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Timer Flow Integration Tests', () {
    late TimerCubit timerCubit;

    setUp(() {
      timerCubit = TimerCubit();
    });

    tearDown(() {
      timerCubit.close();
    });

    testWidgets('Complete timer user journey', (WidgetTester tester) async {
      // Arrange - Build timer page with test cubit
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: timerCubit,
            child: const TimerPage(),
          ),
        ),
      );

      // Assert - Initial state shows 25:00 and timer ring
      expect(find.text('25:00'), findsOneWidget);
      expect(find.byType(NeoCircularTimer), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Act - Start timer
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - Timer is running, shows pause icon
      expect(find.text('24:59'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Act - Pause timer
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();

      // Assert - Timer is paused, shows play icon
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Act - Resume timer
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - Timer is running again
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Act - Reset timer
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Assert - Timer resets to 25:00
      expect(find.text('25:00'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('Timer completion flow', (WidgetTester tester) async {
      // Arrange - Build timer page with short duration
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: timerCubit,
            child: const TimerPage(),
          ),
        ),
      );

      // Act - Set short duration and start
      timerCubit.emit(const TimerInitialState(
        totalDuration: Duration(seconds: 2),
        sessionType: SessionType.work,
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      // Wait for completion (2 seconds + buffer)
      await tester.pump(const Duration(seconds: 3));

      // Assert - Completion animation appears
      expect(find.byType(AnimatedCompletionIcon), findsOneWidget);
      expect(find.byType(NeoCircularTimer), findsNothing);
    });

    testWidgets('Skip button immediately completes timer', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: timerCubit,
            child: const TimerPage(),
          ),
        ),
      );

      // Act - Start timer
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - Timer is running
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byType(NeoCircularTimer), findsOneWidget);

      // Act - Skip timer
      await tester.tap(find.byIcon(Icons.skip_next));
      await tester.pump();

      // Assert - Completion animation appears immediately
      expect(find.byType(AnimatedCompletionIcon), findsOneWidget);
      expect(find.byType(NeoCircularTimer), findsNothing);
    });

    testWidgets('All control buttons are interactive', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: timerCubit,
            child: const TimerPage(),
          ),
        ),
      );

      // Assert - All buttons are present
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.skip_next), findsOneWidget);

      // Act & Assert - Each button can be tapped
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(find.text('25:00'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byIcon(Icons.pause), findsOneWidget);

      await tester.tap(find.byIcon(Icons.skip_next));
      await tester.pump();
      expect(find.byType(AnimatedCompletionIcon), findsOneWidget);
    });

    testWidgets('Session type indicator displays correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: timerCubit,
            child: const TimerPage(),
          ),
        ),
      );

      // Assert - WORK session type is displayed
      expect(find.text('WORK'), findsOneWidget);

      // Act - Change to break session
      timerCubit.emit(const TimerInitialState(
        totalDuration: Duration(minutes: 5),
        sessionType: SessionType.breakTime,
      ));
      await tester.pump();

      // Assert - BREAK session type is displayed
      expect(find.text('BREAK'), findsOneWidget);
    });

    testWidgets('Timer countdown progresses accurately', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: timerCubit,
            child: const TimerPage(),
          ),
        ),
      );

      // Set 10 second timer for faster test
      timerCubit.emit(const TimerInitialState(
        totalDuration: Duration(seconds: 10),
        sessionType: SessionType.work,
      ));
      await tester.pump();

      // Act - Start timer
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      // Initial state: 00:10
      expect(find.text('00:10'), findsOneWidget);

      // Wait 1 second
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:09'), findsOneWidget);

      // Wait 2 more seconds
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('00:07'), findsOneWidget);

      // Wait 3 more seconds
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('00:04'), findsOneWidget);
    });

    testWidgets('Reset button works from any state', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: timerCubit,
            child: const TimerPage(),
          ),
        ),
      );

      // Test reset from initial state
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(find.text('25:00'), findsOneWidget);

      // Test reset from running state
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(find.text('25:00'), findsOneWidget);

      // Test reset from paused state
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(find.text('25:00'), findsOneWidget);
    });
  });
}
