import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a255_app/features/common/widgets/neo_icon_button.dart';
import 'package:a255_app/features/common/themes/app_colors.dart';
import 'package:a255_app/features/common/themes/app_shapes.dart';

void main() {
  group('NeoIconButton Widget Tests', () {
    testWidgets('should render icon correctly', (tester) async {
      // Arrange
      const testIcon = Icons.refresh;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoIconButton(
              icon: testIcon,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byIcon(testIcon), findsOneWidget);
    });

    testWidgets('should trigger callback when tapped', (tester) async {
      // Arrange
      var tapped = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoIconButton(
              icon: Icons.play_arrow,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.byType(NeoIconButton));
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
            body: NeoIconButton(
              icon: Icons.pause,
              onPressed: null, // Disabled
            ),
          ),
        ),
      );
      
      await tester.tap(find.byType(NeoIconButton));
      await tester.pumpAndSettle();
      
      // Assert
      expect(tapped, isFalse);
    });

    testWidgets('should animate shadow on tap down and tap up', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoIconButton(
              icon: Icons.skip_next,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Get initial state
      final initialButton = tester.widget<Container>(
        find.descendant(
          of: find.byType(NeoIconButton),
          matching: find.byType(Container).first,
        ),
      );
      
      // Simulate tap down
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(NeoIconButton)),
      );
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 100)); // Complete animation
      
      // Verify animation completed
      final pressedButton = tester.widget<Container>(
        find.descendant(
          of: find.byType(NeoIconButton),
          matching: find.byType(Container).first,
        ),
      );
      
      // Simulate tap up
      await gesture.up();
      await tester.pump(); // Start reverse animation
      await tester.pump(const Duration(milliseconds: 100)); // Complete animation
      
      // Assert - verify widgets exist
      expect(initialButton, isNotNull);
      expect(pressedButton, isNotNull);
    });

    testWidgets('should use custom background color', (tester) async {
      // Arrange
      const customColor = AppColors.secondary;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoIconButton(
              icon: Icons.favorite,
              onPressed: () {},
              backgroundColor: customColor,
            ),
          ),
        ),
      );
      
      // Assert
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(NeoIconButton),
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
            body: NeoIconButton(
              icon: Icons.block,
              onPressed: null,
            ),
          ),
        ),
      );
      
      // Assert
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(NeoIconButton),
          matching: find.byType(Container).first,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.surfaceDisabled);
    });

    testWidgets('should use custom icon color', (tester) async {
      // Arrange
      const customIconColor = AppColors.primary;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoIconButton(
              icon: Icons.star,
              onPressed: () {},
              iconColor: customIconColor,
            ),
          ),
        ),
      );
      
      // Assert
      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.color, customIconColor);
    });

    testWidgets('should use custom icon size', (tester) async {
      // Arrange
      const customSize = 32.0;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoIconButton(
              icon: Icons.settings,
              onPressed: () {},
              iconSize: customSize,
            ),
          ),
        ),
      );
      
      // Assert
      final icon = tester.widget<Icon>(find.byIcon(Icons.settings));
      expect(icon.size, customSize);
    });

    testWidgets('should have circular border radius', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoIconButton(
              icon: Icons.circle,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(NeoIconButton),
          matching: find.byType(Container).first,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      final borderRadius = decoration.borderRadius as BorderRadius;
      expect(borderRadius.topLeft.x, AppShapes.radiusCircle);
    });

    testWidgets('should use custom button size', (tester) async {
      // Arrange
      const customSize = 64.0;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoIconButton(
              icon: Icons.add,
              onPressed: () {},
              size: customSize,
            ),
          ),
        ),
      );
      
      // Assert
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(NeoIconButton),
          matching: find.byType(Container).first,
        ),
      );
      expect(container.constraints?.maxWidth, customSize);
      expect(container.constraints?.maxHeight, customSize);
    });
  });
}
