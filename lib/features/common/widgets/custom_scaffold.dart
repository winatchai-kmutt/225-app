import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_shapes.dart';

/// Custom scaffold with consistent page styling
///
/// Provides a standardized page wrapper with:
/// - Safe area handling
/// - Consistent padding (16px by default)
/// - Neo-Brutalist background color
/// - Optional app bar and bottom navigation
///
/// Usage:
/// ```dart
/// CustomScaffold(
///   appBar: AppBar(title: Text('Page Title')),
///   body: MyPageContent(),
/// )
/// ```
class CustomScaffold extends StatelessWidget {
  /// The primary content of the scaffold
  final Widget body;

  /// Optional app bar at the top
  final PreferredSizeWidget? appBar;

  /// Optional bottom navigation bar
  final Widget? bottomNavigationBar;

  /// Background color (defaults to theme background)
  final Color? backgroundColor;

  /// Padding around the body content
  final EdgeInsets? padding;

  /// Whether to wrap body in SafeArea
  final bool useSafeArea;

  /// Floating action button
  final Widget? floatingActionButton;

  /// Position of floating action button
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const CustomScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.padding,
    this.useSafeArea = true,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    // Apply padding if specified (default to page padding)
    final effectivePadding = padding ?? const EdgeInsets.all(AppShapes.pagePadding);
    content = Padding(
      padding: effectivePadding,
      child: content,
    );

    // Wrap in SafeArea if requested
    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: appBar,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
