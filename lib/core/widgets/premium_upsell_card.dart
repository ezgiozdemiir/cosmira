import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'cosmic_card.dart';

class PremiumUpsellCard extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const PremiumUpsellCard({
    super.key,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      gradient: AppColors.premiumGradient,
      onTap: () => context.push('/paywall'),
      child: Row(
        children: [
          const Icon(Icons.stars, color: AppColors.auraAmber, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title ?? 'premium_upsell_title'.tr(),
                    style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
                Text(subtitle ?? 'premium_upsell_subtitle'.tr(),
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white54),
        ],
      ),
    );
  }
}
