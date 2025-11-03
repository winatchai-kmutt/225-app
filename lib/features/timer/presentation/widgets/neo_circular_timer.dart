import 'package:flutter/material.dart';
import '../../../common/themes/app_colors.dart';

/// Circular timer display with Neo-Brutalist design
///
/// Uses CustomPaint to draw a circular progress ring with:
/// - Background track (full ring in light gray)
/// - Foreground progress arc (partial ring in primary color)
/// - 280px diameter, 20px stroke width, rounded caps
///
/// **Usage:**
/// ```dart
/// NeoCircularTimer(
///   progress: 0.75, // 75% remaining
/// )
/// ```
class NeoCircularTimer extends StatelessWidget {
  /// Progress value from 0.0 (empty) to 1.0 (full)
  final double progress;
  
  /// Diameter of the circular timer
  final double size;
  
  /// Width of the progress ring stroke
  final double strokeWidth;

  const NeoCircularTimer({
    super.key,
    required this.progress,
    this.size = 280.0,
    this.strokeWidth = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CircularTimerPainter(
          progress: progress,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

/// Custom painter for circular timer ring
class CircularTimerPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  CircularTimerPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    // Draw background track (full circle in light gray)
    final backgroundPaint = Paint()
      ..color = AppColors.surfaceDisabled
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Draw foreground progress arc (partial circle in primary color)
    final foregroundPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Calculate sweep angle (full circle = 2π, start from top = -π/2)
    const startAngle = -3.14159 / 2; // Start at top (-90 degrees)
    final sweepAngle = 2 * 3.14159 * progress; // Sweep clockwise
    
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, sweepAngle, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(CircularTimerPainter oldDelegate) {
    // Only repaint if progress changes
    return oldDelegate.progress != progress;
  }
}
