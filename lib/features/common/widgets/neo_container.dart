import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_shapes.dart';

/// Neo-Brutalist container widget
///
/// A reusable container that implements the Neo-Brutalist design aesthetic:
/// - Thick black borders (1.5px)
/// - Hard drop shadows (no blur)
/// - State-dependent styling (default, disabled, pressed)
/// - Smooth animations between states
///
/// Usage:
/// ```dart
/// NeoContainer(
///   child: Text('Hello'),
///   backgroundColor: AppColors.primary,
///   onTap: () => print('Tapped!'),
/// )
/// ```
class NeoContainer extends StatefulWidget {
  /// The widget to display inside the container
  final Widget child;

  /// Background color of the container
  final Color backgroundColor;

  /// Border radius for rounded corners
  final double borderRadius;

  /// Internal padding
  final EdgeInsets? padding;

  /// Whether the container is disabled (gray style, no interaction)
  final bool isDisabled;

  /// Callback when container is tapped
  final VoidCallback? onTap;

  /// Callback when container is long pressed
  final VoidCallback? onLongPress;

  /// Animation duration for state transitions
  final Duration animationDuration;

  /// Animation curve for state transitions
  final Curve animationCurve;

  const NeoContainer({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderRadius = 16.0,
    this.padding,
    this.isDisabled = false,
    this.onTap,
    this.onLongPress,
    this.animationDuration = const Duration(milliseconds: 150),
    this.animationCurve = Curves.easeOut,
  });

  @override
  State<NeoContainer> createState() => _NeoContainerState();
}

class _NeoContainerState extends State<NeoContainer> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled && (widget.onTap != null || widget.onLongPress != null)) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isDisabled) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (!widget.isDisabled) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on state
    final backgroundColor = widget.isDisabled 
        ? AppColors.surfaceDisabled 
        : widget.backgroundColor;
    
    final borderColor = widget.isDisabled 
        ? AppColors.borderDisabled 
        : AppColors.border;

    // Determine shadow offset based on state
    final shadowOffset = widget.isDisabled 
        ? Offset.zero 
        : (_isPressed ? AppShapes.offsetPressed : AppShapes.offset);

    // Build box decoration with Neo-Brutalist styling
    final decoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      border: Border.all(
        color: borderColor,
        width: AppShapes.borderWidth,
      ),
      boxShadow: widget.isDisabled ? [] : [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: AppShapes.blurRadius,
          offset: shadowOffset,
        ),
      ],
    );

    Widget container = AnimatedContainer(
      duration: widget.animationDuration,
      curve: widget.animationCurve,
      decoration: decoration,
      padding: widget.padding,
      child: widget.child,
    );

    // Wrap with GestureDetector if interactive
    if (widget.onTap != null || widget.onLongPress != null) {
      container = GestureDetector(
        onTap: widget.isDisabled ? null : widget.onTap,
        onLongPress: widget.isDisabled ? null : widget.onLongPress,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: container,
      );
    }

    return container;
  }
}
