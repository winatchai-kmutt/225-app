import 'package:flutter/material.dart';
import '../../../common/themes/app_colors.dart';
import '../../../common/themes/app_text_styles.dart';

/// Placeholder break screen
///
/// Temporary screen for break time navigation until US 3.1 implements
/// the full break screen functionality.
class BreakPlaceholderPage extends StatelessWidget {
  const BreakPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Break Time!',
              style: AppTextStyles.display,
            ),
            const SizedBox(height: 16),
            Text(
              'Full break screen coming in US 3.1',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
