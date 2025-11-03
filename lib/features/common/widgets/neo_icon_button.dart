import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/app_colors.dart';
import '../themes/app_shapes.dart';
import '../utils/audio_service.dart';

/// Circular icon button with Neo-Brutalist design
///
/// A variant of NeoButton designed specifically for icon-only actions.
/// Features a circular shape with the same shadow animation, haptic,
/// and audio feedback as NeoButton.
///
/// **Features:**
/// - Circular shape (borderRadius: AppShapes.radiusCircle)
/// - Shadow animation: Offset(3,3) → Offset(1,1) on press (100ms)
/// - Haptic feedback: Light impact on tap
/// - Audio feedback: Click sound on tap
/// - Fixed size for consistency
///
/// **Usage:**
/// ```dart
/// NeoIconButton(
///   icon: Icons.refresh,
///   onPressed: () => resetTimer(),
///   backgroundColor: AppColors.surface,
/// )
/// ```
class NeoIconButton extends StatefulWidget {
  /// The icon to display in the button
  final IconData icon;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Background color of the button
  final Color backgroundColor;

  /// Icon color
  final Color iconColor;

  /// Icon size
  final double iconSize;

  /// Button size (width and height)
  final double size;

  /// Whether to disable haptic feedback (for testing or accessibility)
  final bool enableHaptics;

  /// Whether to disable audio feedback (for testing or accessibility)
  final bool enableAudio;

  const NeoIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = AppColors.surface,
    this.iconColor = AppColors.textPrimary,
    this.iconSize = 24.0,
    this.size = 56.0,
    this.enableHaptics = true,
    this.enableAudio = true,
  });

  @override
  State<NeoIconButton> createState() => _NeoIconButtonState();
}

class _NeoIconButtonState extends State<NeoIconButton> with SingleTickerProviderStateMixin {
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
        debugPrint('NeoIconButton: Haptic feedback not available - $e');
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

    final iconColor = isDisabled 
        ? AppColors.textSecondary 
        : widget.iconColor;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _shadowAnimation,
        builder: (context, child) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppShapes.radiusCircle),
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
            child: Center(
              child: Icon(
                widget.icon,
                color: iconColor,
                size: widget.iconSize,
              ),
            ),
          );
        },
      ),
    );
  }
}
