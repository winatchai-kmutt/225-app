import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system using Inter font family
///
/// This class defines all text style roles for the application. Each role
/// has a specific purpose and should be used consistently across the app
/// to maintain a clear typographic hierarchy.
///
/// **When to use each style:**
/// - **display**: Large headings, hero text, important announcements
/// - **titleLarge**: Timer displays, prominent numbers, key metrics
/// - **titleMedium**: Section headers, card titles, dialog titles
/// - **bodyLarge**: Primary body text, button labels, list items
/// - **bodySmall**: Secondary descriptions, helper text, metadata
/// - **caption**: Timestamps, labels, fine print
///
/// **Font Family:** Inter (loaded via Google Fonts)
/// **Line Height:** Optimized for readability (1.2-1.5)
///
/// **Usage:**
/// ```dart
/// Text('Welcome', style: AppTextStyles.display)
/// Text('Section Title', style: AppTextStyles.titleMedium)
/// Text('Body content...', style: AppTextStyles.bodyLarge)
/// ```
class AppTextStyles {
  // Prevent instantiation
  AppTextStyles._();

  /// Display Large text style - Bold 48
  /// Used for: Timer countdown display, very large numbers
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w700, // Bold
        color: AppColors.textPrimary,
        height: 1.1,
      );

  /// Display text style - Bold 28
  /// Used for: Large headings, important titles
  static TextStyle get display => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700, // Bold
        color: AppColors.textPrimary,
        height: 1.2,
      );

  /// Title Large text style - Bold 26
  /// Used for: Important numbers, prominent titles
  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w700, // Bold
        color: AppColors.textPrimary,
        height: 1.2,
      );

  /// Title Medium text style - SemiBold 20
  /// Used for: Section headers, card titles
  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600, // SemiBold
        color: AppColors.textPrimary,
        height: 1.3,
      );

  /// Body Large text style - SemiBold 16
  /// Used for: Body text, button labels, emphasized content
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600, // SemiBold
        color: AppColors.textPrimary,
        height: 1.5,
      );

  /// Body Small text style - Regular 14
  /// Used for: Secondary body text, descriptions
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400, // Regular
        color: AppColors.textPrimary,
        height: 1.5,
      );

  /// Caption text style - Regular 12
  /// Used for: Captions, timestamps, small labels
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400, // Regular
        color: AppColors.textSecondary,
        height: 1.3,
      );
}
