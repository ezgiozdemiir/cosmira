import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

const Map<String, Color> _signColors = {
  'aries':       Color(0xFFEF4444),
  'taurus':      Color(0xFF22C55E),
  'gemini':      Color(0xFFFACC15),
  'cancer':      Color(0xFFBAE6FD),
  'leo':         Color(0xFFF97316),
  'virgo':       Color(0xFF86EFAC),
  'libra':       Color(0xFFFDA4AF),
  'scorpio':     Color(0xFF7C3AED),
  'sagittarius': Color(0xFF8B5CF6),
  'capricorn':   Color(0xFF64748B),
  'aquarius':    Color(0xFF38BDF8),
  'pisces':      Color(0xFFA5B4FC),
};

const Map<String, String> _signElement = {
  'aries': 'fire',  'leo': 'fire',  'sagittarius': 'fire',
  'taurus': 'earth', 'virgo': 'earth', 'capricorn': 'earth',
  'gemini': 'air',  'libra': 'air', 'aquarius': 'air',
  'cancer': 'water', 'scorpio': 'water', 'pisces': 'water',
};

class AuraCard extends ConsumerWidget {
  const AuraCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final sun  = profile?.sunSign?.toLowerCase();
    final moon = profile?.moonSign?.toLowerCase();

    if (sun == null) return const SizedBox.shrink();

    final primaryColor = _signColors[sun]  ?? AppColors.accentGlow;
    final moonColor    = moon != null ? _signColors[moon] : null;
    final element      = _signElement[sun] ?? 'air';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: 0.14),
            primaryColor.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header label
            Row(
              children: [
                Icon(Icons.blur_on, color: primaryColor, size: 14),
                const SizedBox(width: 6),
                Text(
                  'aura_title'.tr(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: primaryColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Orb + info row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AuraOrb(primaryColor: primaryColor, moonColor: moonColor)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(0.96, 0.96),
                      end: const Offset(1.04, 1.04),
                      duration: 2400.ms,
                      curve: Curves.easeInOut,
                    ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'aura_${sun}_color'.tr(),
                        style: AppTextStyles.titleMedium
                            .copyWith(color: Colors.white, height: 1.2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'aura_shape_$element'.tr(),
                        style: AppTextStyles.bodySmall
                            .copyWith(color: primaryColor),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'aura_${sun}_desc'.tr(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Moon accent row
            if (moonColor != null) ...[
              const SizedBox(height: 14),
              const Divider(color: AppColors.cardBorder, height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: moonColor,
                      boxShadow: [
                        BoxShadow(
                            color: moonColor.withValues(alpha: 0.4),
                            blurRadius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'aura_moon_prefix'.tr(),
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'aura_${moon}_color'.tr(),
                    style: AppTextStyles.labelSmall
                        .copyWith(color: moonColor.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AuraOrb extends StatelessWidget {
  final Color primaryColor;
  final Color? moonColor;

  const _AuraOrb({required this.primaryColor, this.moonColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer halo
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.07),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.22),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          // Mid ring
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.14),
            ),
          ),
          // Inner core
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.9),
                  primaryColor.withValues(alpha: 0.35),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          // Moon accent orb
          if (moonColor != null)
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: moonColor!.withValues(alpha: 0.85),
                  border: Border.all(
                      color: Colors.black.withValues(alpha: 0.25), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                        color: moonColor!.withValues(alpha: 0.45),
                        blurRadius: 6),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
