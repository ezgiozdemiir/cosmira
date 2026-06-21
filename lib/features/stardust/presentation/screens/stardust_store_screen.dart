import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../providers/stardust_provider.dart';

class StardustStoreScreen extends ConsumerWidget {
  const StardustStoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(stardustBalanceProvider).valueOrNull ?? 0;
    final transactions = ref.watch(stardustTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: AppColors.textPrimary),
                            onPressed: () => context.pop(),
                          ),
                          const Spacer(),
                          Text('stardust_title'.tr(), style: AppTextStyles.titleLarge),
                          const Spacer(),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CosmicCard(
                        gradient: AppColors.premiumGradient,
                        child: Column(
                          children: [
                            const Icon(Icons.auto_awesome,
                                color: AppColors.auraAmber, size: 40),
                            const SizedBox(height: 12),
                            Text(
                              '$balance',
                              style: AppTextStyles.displayLarge.copyWith(
                                color: AppColors.auraAmber,
                                fontSize: 48,
                              ),
                            ),
                            Text(
                              'stardust_balance'.tr(),
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
                      const SizedBox(height: 24),
                      Text('stardust_earn'.tr(),
                          style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 12),
                      _EarnTile(
                        icon: Icons.play_circle,
                        title: 'stardust_watch_video'.tr(),
                        reward: '+10',
                        subtitle: 'stardust_watch_video_sub'.tr(),
                        onTap: () {},
                      ),
                      _EarnTile(
                        icon: Icons.share,
                        title: 'stardust_invite'.tr(),
                        reward: '+50',
                        subtitle: 'stardust_invite_sub'.tr(),
                        onTap: () {},
                      ),
                      _EarnTile(
                        icon: Icons.local_fire_department,
                        title: 'stardust_daily_login'.tr(),
                        reward: '+5',
                        subtitle: 'stardust_daily_login_sub'.tr(),
                        onTap: () {},
                      ),
                      const SizedBox(height: 24),
                      Text('stardust_history'.tr(), style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              transactions.when(
                data: (list) => SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tx = list[index];
                      final isPositive = tx.isPositive;
                      final txColor = isPositive ? AppColors.success : AppColors.error;
                      final txKey = 'stardust_tx_${tx.source}';
                      final txLabel = txKey.tr() == txKey ? tx.description : txKey.tr();
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: txColor.withValues(alpha: 0.2),
                          child: Icon(
                            isPositive ? Icons.add : Icons.remove,
                            color: txColor,
                            size: 16,
                          ),
                        ),
                        title: Text(txLabel,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textPrimary)),
                        subtitle: Text(
                          tx.createdAt.formatted,
                          style: AppTextStyles.bodySmall,
                        ),
                        trailing: Text(
                          '${isPositive ? '+' : '-'}${tx.amount}',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: txColor,
                          ),
                        ),
                      );
                    },
                    childCount: list.length,
                  ),
                ),
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EarnTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String reward;
  final String subtitle;
  final VoidCallback onTap;

  const _EarnTile({
    required this.icon,
    required this.title,
    required this.reward,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CosmicCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accentGlow, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.auraAmber.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                reward,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.auraAmber,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
