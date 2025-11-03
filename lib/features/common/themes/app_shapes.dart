import 'package:flutter/material.dart';

/// Neo-Brutalist shape specifications
///
/// This class defines all shape-related tokens including border radii,
/// border widths, shadows, and spacing. These values work together to
/// create the distinctive Neo-Brutalist aesthetic.
///
/// **Neo-Brutalist Design Principles:**
/// - **Thick Borders**: 1.5px borders (thicker than typical 1px)
/// - **Hard Shadows**: No blur radius, pure offset shadows (3x3 default)
/// - **Bold Corners**: Generous border radii for friendly feel
/// - **8px Grid**: All spacing is multiples of 8 for consistency
///
/// **Shadow States:**
/// - Default: 3x3 offset for prominent depth
/// - Pressed: 1x1 offset for "pushed in" feel
/// - Disabled: No shadow for flat, inactive appearance
///
/// **Usage:**
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: BorderRadius.circular(AppShapes.radiusMedium),
///     border: Border.all(width: AppShapes.borderWidth),
///     boxShadow: [BoxShadow(offset: AppShapes.offset, blurRadius: 0)],
///   ),
/// )
/// ```
class AppShapes {
  // Prevent instantiation
  AppShapes._();

  // ==================== Border Radii ====================

  /// Large border radius - 20px
  /// Used for: Cards, bottom navigation bar
  static const double radiusLarge = 20.0;

  /// Medium border radius - 16px
  /// Used for: Buttons, medium containers
  static const double radiusMedium = 16.0;

  /// Small border radius - 8px
  /// Used for: Indicators, small elements
  static const double radiusSmall = 8.0;

  /// Circle radius - 99px
  /// Used for: Avatars, circular icon buttons
  static const double radiusCircle = 99.0;

  // ==================== Border Specifications ====================

  /// Standard border width - 1.5px
  /// Used for: All borders (thick Neo-Brutalist style)
  static const double borderWidth = 1.5;

  // ==================== Shadow Specifications ====================

  /// Default shadow offset - (3, 3)
  /// Used for: Default state hard shadows (no blur)
  static const Offset offset = Offset(3, 3);

  /// Pressed shadow offset - (1, 1)
  /// Used for: Pressed/active state shadows
  static const Offset offsetPressed = Offset(1, 1);

  /// Shadow blur radius - 0px
  /// Neo-Brutalist shadows are hard (no blur)
  static const double blurRadius = 0.0;

  // ==================== Spacing (Grid-based) ====================

  /// Base grid unit - 8px
  /// All spacing should be multiples of this value
  static const double gridUnit = 8.0;

  /// Page padding - 16px
  /// Used for: Page edge padding, screen margins
  static const double pagePadding = 16.0;

  /// Card padding - 20px
  /// Used for: Internal padding of cards and containers
  static const double cardPadding = 20.0;

  /// List item vertical padding - 12px
  /// Used for: Vertical padding in list items
  static const double listItemPaddingV = 12.0;

  /// List item horizontal padding - 16px
  /// Used for: Horizontal padding in list items
  static const double listItemPaddingH = 16.0;
}
