import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/haptic_utils.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Explore', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 16),
        // Row 1: Natal Chart (featured) + Compatibility
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _NatalChartTile(
                  onTap: () {
                    HapticUtils.light();
                    context.go('/astrology');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionTile(
                  icon: Icons.favorite_border,
                  label: 'Compatibility',
                  description: 'Discover your cosmic connection with others',
                  buttonLabel: 'Check compatibility',
                  color: AppColors.auraRose,
                  onTap: () => context.go('/compatibility'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Row 2: Breathwork + Moon Rituals
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.air,
                  label: 'Breathwork',
                  description: 'Balance your energy with guided breathing',
                  buttonLabel: 'Begin session',
                  color: AppColors.auraTeal,
                  onTap: () => context.go('/breathwork'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionTile(
                  icon: Icons.nightlight_round,
                  label: 'Moon Rituals',
                  description: 'Align your intentions with the lunar cycle',
                  buttonLabel: 'View calendar',
                  color: AppColors.auraIndigo,
                  onTap: () => context.go('/moon'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Featured Natal Chart tile with description + CTA button
class _NatalChartTile extends StatelessWidget {
  final VoidCallback onTap;
  const _NatalChartTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const color = AppColors.auraViolet;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.22),
              color.withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✨ icon instead of a Material icon
            const Text('✨', style: TextStyle(fontSize: 26)),
            const SizedBox(height: 8),
            Text(
              'Natal Chart',
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              'Your horoscope for today\nis being prepared',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            // "Explore your chart" button
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Explore your chart',
                style: AppTextStyles.labelSmall.copyWith(
                  color: color,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final String buttonLabel;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.buttonLabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticUtils.light();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.22),
              color.withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Text(
                buttonLabel,
                style: AppTextStyles.labelSmall.copyWith(
                  color: color,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
