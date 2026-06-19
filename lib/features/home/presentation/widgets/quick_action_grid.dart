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
        _AstrocartographyBanner(
          onTap: () => context.push('/astrocartography'),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _ExploreTile(
              emoji: '✨',
              label: 'Natal Chart',
              description: 'Your horoscope for today is being prepared',
              buttonLabel: 'Explore your chart',
              color: AppColors.auraViolet,
              onTap: () => context.go('/astrology'),
            ),
            _ExploreTile(
              iconData: Icons.favorite_border,
              label: 'Compatibility',
              description: 'Discover your cosmic connection with others',
              buttonLabel: 'Check compatibility',
              color: AppColors.auraRose,
              onTap: () => context.go('/compatibility'),
            ),
            _ExploreTile(
              iconData: Icons.air,
              label: 'Breathwork',
              description: 'Balance your energy with guided breathing',
              buttonLabel: 'Begin session',
              color: AppColors.auraTeal,
              onTap: () => context.go('/breathwork'),
            ),
            _ExploreTile(
              iconData: Icons.nightlight_round,
              label: 'Moon Rituals',
              description: 'Align your intentions with the lunar cycle',
              buttonLabel: 'View calendar',
              color: AppColors.auraIndigo,
              onTap: () => context.go('/moon'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExploreTile extends StatelessWidget {
  final String? emoji;
  final IconData? iconData;
  final String label;
  final String description;
  final String buttonLabel;
  final Color color;
  final VoidCallback onTap;

  const _ExploreTile({
    this.emoji,
    this.iconData,
    required this.label,
    required this.description,
    required this.buttonLabel,
    required this.color,
    required this.onTap,
  }) : assert(emoji != null || iconData != null);

  Widget _icon() {
    if (emoji != null) return Text(emoji!, style: const TextStyle(fontSize: 26));
    return Icon(iconData!, color: color, size: 26);
  }

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
            _icon(),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
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

class _AstrocartographyBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _AstrocartographyBanner({required this.onTap});

  static const _color = Color(0xFF0EA5E9);

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
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x360EA5E9), Color(0x148B5CF6)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _color.withValues(alpha: 0.30)),
        ),
        child: Row(
          children: [
            const Text('🌍', style: TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Astrocartography',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover where your cosmic power lines flow across the world',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.auraAmber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.auraAmber.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '100 ✦  to unlock full report',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.auraAmber,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _color.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Explore',
                style: AppTextStyles.labelSmall.copyWith(
                  color: _color,
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
