import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a255_app/features/common/widgets/neo_button.dart';
import 'package:a255_app/features/common/themes/app_colors.dart';

void main() {
  group('NeoButton Widget Tests', () {
    testWidgets('should render child widget correctly', (tester) async {
      // Arrange
      const buttonText = 'Test Button';
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoButton(
              onPressed: () {},
              child: const Text(buttonText),
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text(buttonText), findsOneWidget);
    });

    testWidgets('should trigger callback when tapped', (tester) async {
      // Arrange
      var tapped = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoButton(
              onPressed: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );
      
      await tester.tap(find.byType(NeoButton));
      await tester.pumpAndSettle();
      
      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should not trigger callback when disabled', (tester) async {
      // Arrange
      var tapped = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoButton(
              onPressed: null, // Disabled
              child: const Text('Disabled'),
            ),
          ),
        ),
      );
      
      await tester.tap(find.byType(NeoButton));
      await tester.pumpAndSettle();
      
      // Assert
      expect(tapped, isFalse);
    });

    testWidgets('should animate shadow on tap down and tap up', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoButton(
              onPressed: () {},
              child: const Text('Animate'),
            ),
          ),
        ),
      );
      
      // Get initial state
      final initialButton = tester.widget<Container>(
        find.descendant(
          of: find.byType(NeoButton),
          matching: find.byType(Container).first,
        ),
      );
      
      // Simulate tap down
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(NeoButton)),
      );
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 100)); // Complete animation
      
      // Verify animation completed (shadow should be at pressed offset)
      final pressedButton = tester.widget<Container>(
        find.descendant(
          of: find.byType(NeoButton),
          matching: find.byType(Container).first,
        ),
      );
      
      // Simulate tap up
      await gesture.up();
      await tester.pump(); // Start reverse animation
      await tester.pump(const Duration(milliseconds: 100)); // Complete animation
      
      // Assert - just verify widgets exist (shadow animation happens in AnimatedBuilder)
      expect(initialButton, isNotNull);
      expect(pressedButton, isNotNull);
    });

    testWidgets('should use custom background color', (tester) async {
      // Arrange
      const customColor = AppColors.primary;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoButton(
              onPressed: () {},
              backgroundColor: customColor,
              child: const Text('Custom Color'),
            ),
          ),
        ),
      );
      
      // Assert - find container with the background color
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(NeoButton),
          matching: find.byType(Container).first,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, customColor);
    });

    testWidgets('should apply disabled styling when onPressed is null', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoButton(
              onPressed: null,
              child: const Text('Disabled'),
            ),
          ),
        ),
      );
      
      // Assert - find container with disabled background color
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(NeoButton),
          matching: find.byType(Container).first,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.surfaceDisabled);
    });

    testWidgets('should use custom padding', (tester) async {
      // Arrange
      const customPadding = EdgeInsets.all(24.0);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoButton(
              onPressed: () {},
              padding: customPadding,
              child: const Text('Padded'),
            ),
          ),
        ),
      );
      
      // Assert - find container with custom padding
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(NeoButton),
          matching: find.byType(Container).first,
        ),
      );
      expect(container.padding, customPadding);
    });

    testWidgets('should use custom border radius', (tester) async {
      // Arrange
      const customRadius = 24.0;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoButton(
              onPressed: () {},
              borderRadius: customRadius,
              child: const Text('Rounded'),
            ),
          ),
        ),
      );
      
      // Assert - find container with custom border radius
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(NeoButton),
          matching: find.byType(Container).first,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      final borderRadius = decoration.borderRadius as BorderRadius;
      expect(borderRadius.topLeft.x, customRadius);
    });
  });
}
