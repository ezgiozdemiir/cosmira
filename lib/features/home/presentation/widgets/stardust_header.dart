import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/home_provider.dart';

class StardustHeader extends ConsumerWidget {
  const StardustHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(stardustBalanceProvider).valueOrNull ?? 0;
    final streak = ref.watch(streakProvider).valueOrNull ?? 0;

    return Row(
      children: [
        Text('Cosmira', style: AppTextStyles.titleLarge),
        const Spacer(),
        if (streak > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.auraAmber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department,
                    color: AppColors.auraAmber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$streak',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.auraAmber,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
        GestureDetector(
          onTap: () => context.push('/stardust'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  '$balance',
                  style: AppTextStyles.stardustBalance.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppColors.textSecondary),
          onPressed: () => context.push('/notifications'),
        ),
      ],
    );
  }
}
