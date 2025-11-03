import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/app_colors.dart';
import '../themes/app_shapes.dart';
import '../utils/audio_service.dart';

/// Primary CTA button with Neo-Brutalist design
///
/// Extends the NeoContainer pattern with built-in haptic feedback,
/// audio feedback, and shadow animation on press. Designed for
/// primary and secondary action buttons.
///
/// **Features:**
/// - Shadow animation: Offset(3,3) → Offset(1,1) on press (100ms)
/// - Haptic feedback: Light impact on tap
/// - Audio feedback: Click sound on tap
/// - Customizable colors, padding, and border radius
///
/// **Usage:**
/// ```dart
/// NeoButton(
///   onPressed: () => print('Tapped!'),
///   child: Text('Start Timer'),
///   backgroundColor: AppColors.primary,
/// )
/// ```
class NeoButton extends StatefulWidget {
  /// The widget to display inside the button (typically Text or Icon+Text)
  final Widget child;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Background color of the button
  final Color backgroundColor;

  /// Internal padding
  final EdgeInsets padding;

  /// Border radius for rounded corners
  final double borderRadius;

  /// Whether to disable haptic feedback (for testing or accessibility)
  final bool enableHaptics;

  /// Whether to disable audio feedback (for testing or accessibility)
  final bool enableAudio;

  const NeoButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    this.borderRadius = AppShapes.radiusMedium,
    this.enableHaptics = true,
    this.enableAudio = true,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _shadowAnimation = Tween<Offset>(
      begin: AppShapes.offset,
      end: AppShapes.offsetPressed,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    
    _controller.forward();
    
    // Trigger haptic feedback
    if (widget.enableHaptics) {
      try {
        HapticFeedback.lightImpact();
      } catch (e) {
        // Graceful degradation on devices without haptic support
        debugPrint('NeoButton: Haptic feedback not available - $e');
      }
    }
    
    // Trigger audio feedback (fire-and-forget)
    if (widget.enableAudio) {
      AudioService.instance.playSound('audio/ui_click_neo.mp3');
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    
    // Determine colors based on state
    final backgroundColor = isDisabled 
        ? AppColors.surfaceDisabled 
        : widget.backgroundColor;
    
    final borderColor = isDisabled 
        ? AppColors.borderDisabled 
        : AppColors.border;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _shadowAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: borderColor,
                width: AppShapes.borderWidth,
              ),
              boxShadow: isDisabled ? [] : [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: AppShapes.blurRadius,
                  offset: _shadowAnimation.value,
                ),
              ],
            ),
            padding: widget.padding,
            child: widget.child,
          );
        },
      ),
    );
  }
}
