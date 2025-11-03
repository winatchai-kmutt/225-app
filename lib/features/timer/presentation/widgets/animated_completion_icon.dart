import 'package:flutter/material.dart';
import '../../../common/themes/app_colors.dart';
import '../../../common/utils/audio_service.dart';

/// Animated checkmark icon for timer completion
///
/// Draws a checkmark using CustomPaint with progressive path animation.
/// Animation duration: 400ms with easeOut curve.
/// Stroke width: 20px to match timer ring.
///
/// **Usage:**
/// ```dart
/// AnimatedCompletionIcon(
///   size: 280.0,
/// )
/// ```
class AnimatedCompletionIcon extends StatefulWidget {
  /// Size of the checkmark (width and height)
  final double size;
  
  /// Stroke width of the checkmark
  final double strokeWidth;

  const AnimatedCompletionIcon({
    super.key,
    this.size = 280.0,
    this.strokeWidth = 20.0,
  });

  @override
  State<AnimatedCompletionIcon> createState() => _AnimatedCompletionIconState();
}

class _AnimatedCompletionIconState extends State<AnimatedCompletionIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    
    // Play success sound when animation starts
    AudioService.instance.playSound('audio/success_chime.mp3');
    
    // Start animation immediately
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: CheckmarkPainter(
              progress: _animation.value,
              strokeWidth: widget.strokeWidth,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter for animated checkmark
class CheckmarkPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  CheckmarkPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    // Define checkmark path
    // Start at left-middle, go down-right to bottom, then up-right to top
    final path = Path();
    
    // Checkmark proportions (scaled to size)
    final startX = size.width * 0.25;
    final startY = size.height * 0.5;
    final middleX = size.width * 0.45;
    final middleY = size.height * 0.65;
    final endX = size.width * 0.75;
    final endY = size.height * 0.35;
    
    path.moveTo(startX, startY);
    path.lineTo(middleX, middleY);
    path.lineTo(endX, endY);
    
    // Calculate path length and draw partial path based on progress
    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) return;
    
    final totalLength = pathMetrics.fold<double>(
      0.0,
      (sum, metric) => sum + metric.length,
    );
    
    final targetLength = totalLength * progress;
    
    final drawPath = Path();
    var currentLength = 0.0;
    
    for (final metric in pathMetrics) {
      if (currentLength + metric.length <= targetLength) {
        // Draw entire segment
        drawPath.addPath(
          metric.extractPath(0.0, metric.length),
          Offset.zero,
        );
        currentLength += metric.length;
      } else {
        // Draw partial segment
        final remainingLength = targetLength - currentLength;
        drawPath.addPath(
          metric.extractPath(0.0, remainingLength),
          Offset.zero,
        );
        break;
      }
    }
    
    canvas.drawPath(drawPath, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
