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
        Text('Explore', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _ActionTile(
              icon: Icons.stars,
              label: 'Natal Chart',
              color: AppColors.auraViolet,
              onTap: () => context.go('/astrology'),
            ),
            _ActionTile(
              icon: Icons.favorite_border,
              label: 'Compatibility',
              color: AppColors.auraRose,
              onTap: () => context.go('/compatibility'),
            ),
            _ActionTile(
              icon: Icons.air,
              label: 'Breathwork',
              color: AppColors.auraTeal,
              onTap: () => context.go('/breathwork'),
            ),
            _ActionTile(
              icon: Icons.nightlight_round,
              label: 'Moon Rituals',
              color: AppColors.auraIndigo,
              onTap: () => context.go('/moon'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
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
            colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
