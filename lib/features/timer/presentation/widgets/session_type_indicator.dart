import 'package:flutter/material.dart';
import '../cubits/timer_state.dart';
import '../../../common/themes/app_text_styles.dart';

/// Session type indicator widget displaying "WORK" or "BREAK"
/// 
/// Stateless widget that receives a [SessionType] parameter and displays
/// the corresponding label using Neo-Brutalist typography.
/// 
/// Design: Bold uppercase text, centered alignment
class SessionTypeIndicator extends StatelessWidget {
  final SessionType sessionType;

  const SessionTypeIndicator({
    super.key,
    required this.sessionType,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      sessionType == SessionType.work ? 'WORK' : 'BREAK',
      style: AppTextStyles.bodyLarge.copyWith(
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }
}
