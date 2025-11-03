import 'package:flutter/material.dart';

/// Neo-Brutalist color palette
///
/// This class defines all semantic color tokens for the application following
/// the Neo-Brutalist design system. All colors are carefully selected to work
/// together and create a bold, high-contrast visual hierarchy.
///
/// **Design Principles:**
/// - High contrast (black borders on white/colored backgrounds)
/// - Vibrant accent colors for visual interest
/// - Semantic naming (what the color represents, not how it looks)
/// - Consistent application across all UI components
///
/// **Usage:**
/// Always use these constants - never hardcode color values in widgets.
/// ```dart
/// Container(
///   color: AppColors.surface,
///   child: Text('Hello', style: TextStyle(color: AppColors.textPrimary)),
/// )
/// ```
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ==================== Core Palette ====================

  /// App background color - warm off-white
  /// Used for: Main app background, page backgrounds
  static const Color background = Color(0xFFFAF8F1);

  /// Surface color - pure white
  /// Used for: Cards, containers, elevated surfaces
  static const Color surface = Color(0xFFFFFFFF);

  /// Disabled surface color - light gray
  /// Used for: Disabled buttons, inactive containers
  static const Color surfaceDisabled = Color(0xFFE0E0E0);

  /// Primary text color - black
  /// Used for: Headings, body text, high emphasis content
  static const Color textPrimary = Color(0xFF000000);

  /// Secondary text color - medium gray
  /// Used for: Captions, labels, low emphasis content
  static const Color textSecondary = Color(0xFF8A8A8E);

  /// Border color - black
  /// Used for: All borders in default state (1.5px thick)
  static const Color border = Color(0xFF000000);

  /// Disabled border color - medium gray
  /// Used for: Borders on disabled components
  static const Color borderDisabled = Color(0xFFBDBDBD);

  /// Shadow color - black
  /// Used for: Hard drop shadows (no blur, 3x3 offset)
  static const Color shadow = Color(0xFF000000);

  // ==================== Action Colors ====================

  /// Primary action color - soft yellow
  /// Used for: Primary buttons, CTAs, active states
  static const Color primary = Color(0xFFFDEE8A);

  /// Text on primary color - black
  /// Used for: Text/icons on primary colored backgrounds
  static const Color onPrimary = Color(0xFF000000);

  /// Secondary action color - soft purple
  /// Used for: Secondary buttons, alternative actions
  static const Color secondary = Color(0xFFF0E4FF);

  /// Text on secondary color - black
  /// Used for: Text/icons on secondary colored backgrounds
  static const Color onSecondary = Color(0xFF000000);

  // ==================== Accent Colors ====================

  /// Accent color - pink
  /// Used for: Timer colors, decorative elements
  static const Color accentPink = Color(0xFFFFD6F5);

  /// Accent color - green
  /// Used for: Success indicators, positive feedback
  static const Color accentGreen = Color(0xFFD3FFAE);

  /// Accent color - purple
  /// Used for: Exam context, special states
  static const Color accentPurple = Color(0xFFE4D6FF);

  // ==================== Semantic Colors ====================

  /// Success state color
  /// Used for: Success messages, confirmations
  static const Color success = Color(0xFF4CAF50);

  /// Error state color
  /// Used for: Error messages, warnings, destructive actions
  static const Color error = Color(0xFFF44336);
}
