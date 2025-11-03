import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a255_app/features/timer/presentation/widgets/animated_completion_icon.dart';

void main() {
  group('AnimatedCompletionIcon Widget Tests', () {
    testWidgets('should render CustomPaint widget', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCompletionIcon(),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(CustomPaint), findsOneWidget);
      expect(find.byType(AnimatedBuilder), findsOneWidget);
    });

    testWidgets('should complete animation in 400ms', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCompletionIcon(),
          ),
        ),
      );
      
      // Animation starts at 0
      await tester.pump();
      var painter = tester.widget<CustomPaint>(
        find.byType(CustomPaint),
      ).painter as CheckmarkPainter;
      expect(painter.progress, closeTo(0.0, 0.1));
      
      // Progress at 200ms (halfway)
      await tester.pump(const Duration(milliseconds: 200));
      painter = tester.widget<CustomPaint>(
        find.byType(CustomPaint),
      ).painter as CheckmarkPainter;
      expect(painter.progress, greaterThan(0.3));
      expect(painter.progress, lessThan(0.7));
      
      // Complete at 400ms
      await tester.pump(const Duration(milliseconds: 200));
      painter = tester.widget<CustomPaint>(
        find.byType(CustomPaint),
      ).painter as CheckmarkPainter;
      expect(painter.progress, closeTo(1.0, 0.1));
    });

    testWidgets('should animate checkmark path progressively', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCompletionIcon(),
          ),
        ),
      );
      
      // Start
      await tester.pump();
      var painter1 = tester.widget<CustomPaint>(
        find.byType(CustomPaint),
      ).painter as CheckmarkPainter;
      
      // Mid-animation
      await tester.pump(const Duration(milliseconds: 200));
      var painter2 = tester.widget<CustomPaint>(
        find.byType(CustomPaint),
      ).painter as CheckmarkPainter;
      
      // End
      await tester.pump(const Duration(milliseconds: 200));
      var painter3 = tester.widget<CustomPaint>(
        find.byType(CustomPaint),
      ).painter as CheckmarkPainter;
      
      // Assert - progress increases over time
      expect(painter2.progress, greaterThan(painter1.progress));
      expect(painter3.progress, greaterThan(painter2.progress));
    });

    testWidgets('should use custom size', (tester) async {
      // Arrange
      const customSize = 300.0;
      
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCompletionIcon(size: customSize),
          ),
        ),
      );
      
      // Assert
      final sizedBox = tester.widget<SizedBox>(
        find.byType(SizedBox),
      );
      expect(sizedBox.width, customSize);
      expect(sizedBox.height, customSize);
    });

    testWidgets('should use custom stroke width', (tester) async {
      // Arrange
      const customStrokeWidth = 30.0;
      
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCompletionIcon(strokeWidth: customStrokeWidth),
          ),
        ),
      );
      
      await tester.pump();
      
      // Assert
      final painter = tester.widget<CustomPaint>(
        find.byType(CustomPaint),
      ).painter as CheckmarkPainter;
      expect(painter.strokeWidth, customStrokeWidth);
    });

    testWidgets('should repaint when progress changes', (tester) async {
      // Arrange
      final painter1 = CheckmarkPainter(progress: 0.5, strokeWidth: 20.0);
      final painter2 = CheckmarkPainter(progress: 0.5, strokeWidth: 20.0);
      final painter3 = CheckmarkPainter(progress: 0.7, strokeWidth: 20.0);
      
      // Assert
      expect(painter1.shouldRepaint(painter2), isFalse);
      expect(painter1.shouldRepaint(painter3), isTrue);
    });

    testWidgets('animation should start automatically', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCompletionIcon(),
          ),
        ),
      );
      
      // Initial state
      await tester.pump();
      var painter1 = tester.widget<CustomPaint>(
        find.byType(CustomPaint),
      ).painter as CheckmarkPainter;
      
      // After some time, progress should increase
      await tester.pump(const Duration(milliseconds: 100));
      var painter2 = tester.widget<CustomPaint>(
        find.byType(CustomPaint),
      ).painter as CheckmarkPainter;
      
      // Assert - animation started automatically
      expect(painter2.progress, greaterThan(painter1.progress));
    });
  });
}
