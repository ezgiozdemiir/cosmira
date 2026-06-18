import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'cosmic_card.dart';

class PremiumUpsellCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const PremiumUpsellCard({
    super.key,
    this.title = 'Upgrade to Premium',
    this.subtitle = 'Unlock all features & unlimited insights',
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
                Text(title, style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
                Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white54),
        ],
      ),
    );
  }
}
