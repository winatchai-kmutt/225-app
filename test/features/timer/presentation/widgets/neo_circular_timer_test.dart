import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a255_app/features/timer/presentation/widgets/neo_circular_timer.dart';

void main() {
  group('NeoCircularTimer Widget Tests', () {
    testWidgets('should render CustomPaint widget', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeoCircularTimer(progress: 0.5),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('should update progress arc when progress changes', (tester) async {
      // Arrange - Start with 75% progress
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeoCircularTimer(progress: 0.75),
          ),
        ),
      );
      
      final initialPainter = tester.widget<CustomPaint>(
        find.byType(CustomPaint),
      ).painter as CircularTimerPainter;
      
      // Act - Update to 50% progress
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeoCircularTimer(progress: 0.5),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      final updatedPainter = tester.widget<CustomPaint>(
        find.byType(CustomPaint),
      ).painter as CircularTimerPainter;
      
      // Assert
      expect(initialPainter.progress, 0.75);
      expect(updatedPainter.progress, 0.5);
    });

    testWidgets('should have correct size', (tester) async {
      // Arrange
      const customSize = 300.0;
      
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeoCircularTimer(
              progress: 1.0,
              size: customSize,
            ),
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

    testWidgets('should repaint only when progress changes', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeoCircularTimer(progress: 0.5),
          ),
        ),
      );
      
      final painter1 = tester.widget<CustomPaint>(
        find.byType(CustomPaint),
      ).painter as CircularTimerPainter;
      
      // Create another painter with same progress
      final painter2 = CircularTimerPainter(
        progress: 0.5,
        strokeWidth: 20.0,
      );
      
      // Create painter with different progress
      final painter3 = CircularTimerPainter(
        progress: 0.7,
        strokeWidth: 20.0,
      );
      
      // Assert
      expect(painter1.shouldRepaint(painter2), isFalse);
      expect(painter1.shouldRepaint(painter3), isTrue);
    });

    testWidgets('should display full circle at 1.0 progress', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeoCircularTimer(progress: 1.0),
          ),
        ),
      );
      
      // Assert
      final painter = tester.widget<CustomPaint>(
        find.byType(CustomPaint),
      ).painter as CircularTimerPainter;
      expect(painter.progress, 1.0);
    });

    testWidgets('should display empty circle at 0.0 progress', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeoCircularTimer(progress: 0.0),
          ),
        ),
      );
      
      // Assert
      final painter = tester.widget<CustomPaint>(
        find.byType(CustomPaint),
      ).painter as CircularTimerPainter;
      expect(painter.progress, 0.0);
    });

    testWidgets('should use custom stroke width', (tester) async {
      // Arrange
      const customStrokeWidth = 30.0;
      
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeoCircularTimer(
              progress: 0.5,
              strokeWidth: customStrokeWidth,
            ),
          ),
        ),
      );
      
      // Assert
      final painter = tester.widget<CustomPaint>(
        find.byType(CustomPaint),
      ).painter as CircularTimerPainter;
      expect(painter.strokeWidth, customStrokeWidth);
    });
  });
}
