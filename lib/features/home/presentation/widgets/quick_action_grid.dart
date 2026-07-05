import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../astrocartography/presentation/providers/astrocartography_provider.dart';

class QuickActionGrid extends ConsumerWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final astroUnlocked =
        ref.watch(astrocartographyUnlockedProvider).valueOrNull ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('explore_title'.tr(), style: AppTextStyles.headlineSmall),
        const SizedBox(height: 16),
        _AstrocartographyBanner(
          unlocked: astroUnlocked,
          onTap: () => context.push('/astrocartography'),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _ExploreTile(
              emoji: '✨',
              label: 'explore_natal_chart'.tr(),
              description: 'explore_natal_chart_desc'.tr(),
              buttonLabel: 'explore_natal_chart_btn'.tr(),
              color: AppColors.auraViolet,
              onTap: () => context.go('/astrology'),
            ),
            _ExploreTile(
              iconData: Icons.favorite_border,
              label: 'explore_compatibility'.tr(),
              description: 'explore_compatibility_desc'.tr(),
              buttonLabel: 'explore_compatibility_btn'.tr(),
              color: AppColors.auraRose,
              onTap: () => context.push('/compatibility'),
            ),
            _ExploreTile(
              iconData: Icons.air,
              label: 'explore_breathwork'.tr(),
              description: 'explore_breathwork_desc'.tr(),
              buttonLabel: 'explore_breathwork_btn'.tr(),
              color: AppColors.auraTeal,
              onTap: () => context.go('/breathwork'),
            ),
            _ExploreTile(
              iconData: Icons.nightlight_round,
              label: 'explore_moon_rituals'.tr(),
              description: 'explore_moon_rituals_desc'.tr(),
              buttonLabel: 'explore_moon_rituals_btn'.tr(),
              color: AppColors.auraIndigo,
              onTap: () => context.go('/moon'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _NumerologyBanner(
          onTap: () => context.push('/numerology'),
        ),
        const SizedBox(height: 12),
        _LovedOnesBanner(
          onTap: () => context.push('/loved-ones'),
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
            SizedBox(height: 32, child: _icon()),
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

class _NumerologyBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _NumerologyBanner({required this.onTap});

  static const _color = Color(0xFFE879F9);

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
            colors: [Color(0x36E879F9), Color(0x148B5CF6)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _color.withValues(alpha: 0.30)),
        ),
        child: Row(
          children: [
            const Text('🔢', style: TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'explore_numerology'.tr(),
                    style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'explore_numerology_desc'.tr(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _color.withValues(alpha: 0.4)),
              ),
              child: Text(
                'explore_numerology_btn'.tr(),
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

class _LovedOnesBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _LovedOnesBanner({required this.onTap});

  static const _color = Color(0xFFF472B6);

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
            colors: [Color(0x36F472B6), Color(0x148B5CF6)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _color.withValues(alpha: 0.30)),
        ),
        child: Row(
          children: [
            const Text('🎁', style: TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'explore_loved_ones'.tr(),
                    style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'explore_loved_ones_desc'.tr(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _color.withValues(alpha: 0.4)),
              ),
              child: Text(
                'explore_loved_ones_btn'.tr(),
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

class _AstrocartographyBanner extends StatelessWidget {
  final VoidCallback onTap;
  final bool unlocked;
  const _AstrocartographyBanner({required this.onTap, this.unlocked = false});

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
                    'explore_astrocartography'.tr(),
                    style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'explore_astrocartography_desc'.tr(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  if (!unlocked) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.auraAmber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.auraAmber.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'explore_astrocartography_cost'.tr(),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.auraAmber,
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(Icons.auto_awesome,
                              color: AppColors.auraAmber, size: 9),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _color.withValues(alpha: 0.4)),
              ),
              child: Text(
                unlocked
                    ? 'explore_astrocartography_view'.tr()
                    : 'explore_astrocartography_btn'.tr(),
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
