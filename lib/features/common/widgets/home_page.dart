import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import 'custom_scaffold.dart';
import 'neo_container.dart';

/// Temporary home page for testing app launch
///
/// This widget serves as a placeholder during foundation setup.
/// It will be replaced or expanded when features are implemented.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        title: Text('A255 App', style: AppTextStyles.titleMedium),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('🎯 Foundation Setup', style: AppTextStyles.display),
            const SizedBox(height: 8),
            Text('Complete', style: AppTextStyles.titleLarge),
            const SizedBox(height: 32),
            
            // Typography Test Section
            Text('Typography Test:', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            Text('Display - Bold 28', style: AppTextStyles.display),
            const SizedBox(height: 8),
            Text('Title Large - Bold 26', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text('Title Medium - SemiBold 20', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text('Body Large - SemiBold 16', style: AppTextStyles.bodyLarge),
            const SizedBox(height: 8),
            Text('Body Small - Regular 14', style: AppTextStyles.bodySmall),
            const SizedBox(height: 8),
            Text('Caption - Regular 12', style: AppTextStyles.caption),
            const SizedBox(height: 32),
            
            // NeoContainer Examples Section
            Text('NeoContainer Test:', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            
            // Default NeoContainer
            NeoContainer(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Default NeoContainer (white background)',
                style: AppTextStyles.bodyLarge,
              ),
            ),
            const SizedBox(height: 16),
            
            // Primary colored NeoContainer
            NeoContainer(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.all(16),
              child: Text(
                'Primary Background NeoContainer',
                style: AppTextStyles.bodyLarge,
              ),
            ),
            const SizedBox(height: 16),
            
            // Interactive NeoContainer with tap
            NeoContainer(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.all(16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('NeoContainer tapped!')),
                );
              },
              child: Column(
                children: [
                  Text(
                    'Interactive NeoContainer',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap me to see pressed state!',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Disabled NeoContainer
            NeoContainer(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.all(16),
              isDisabled: true,
              onTap: () {
                // This won't be called
              },
              child: Text(
                'Disabled NeoContainer (gray, no shadow)',
                style: AppTextStyles.bodyLarge,
              ),
            ),
            const SizedBox(height: 16),
            
            // Accent color examples
            Row(
              children: [
                Expanded(
                  child: NeoContainer(
                    backgroundColor: AppColors.accentPink,
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Text('Pink', style: AppTextStyles.bodySmall),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NeoContainer(
                    backgroundColor: AppColors.accentGreen,
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Text('Green', style: AppTextStyles.bodySmall),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NeoContainer(
                    backgroundColor: AppColors.accentPurple,
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Text('Purple', style: AppTextStyles.bodySmall),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
