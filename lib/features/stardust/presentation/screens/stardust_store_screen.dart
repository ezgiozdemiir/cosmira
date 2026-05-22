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
                          Text('Stardust', style: AppTextStyles.titleLarge),
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
                              'Stardust Balance',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
                      const SizedBox(height: 24),
                      Text('Earn Stardust',
                          style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 12),
                      _EarnTile(
                        icon: Icons.play_circle,
                        title: 'Watch a Video',
                        reward: '+10',
                        subtitle: 'Watch a short ad',
                        onTap: () {},
                      ),
                      _EarnTile(
                        icon: Icons.share,
                        title: 'Invite a Friend',
                        reward: '+50',
                        subtitle: 'Share your referral link',
                        onTap: () {},
                      ),
                      _EarnTile(
                        icon: Icons.local_fire_department,
                        title: 'Daily Login',
                        reward: '+5',
                        subtitle: 'Come back every day',
                        onTap: () {},
                      ),
                      const SizedBox(height: 24),
                      Text('History', style: AppTextStyles.headlineSmall),
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
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: tx.isEarning
                              ? AppColors.success.withOpacity(0.2)
                              : AppColors.error.withOpacity(0.2),
                          child: Icon(
                            tx.isEarning ? Icons.add : Icons.remove,
                            color: tx.isEarning
                                ? AppColors.success
                                : AppColors.error,
                            size: 16,
                          ),
                        ),
                        title: Text(tx.description,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textPrimary)),
                        subtitle: Text(
                          tx.createdAt.formatted,
                          style: AppTextStyles.bodySmall,
                        ),
                        trailing: Text(
                          '${tx.isEarning ? '+' : '-'}${tx.amount}',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: tx.isEarning
                                ? AppColors.success
                                : AppColors.error,
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
                color: AppColors.auraAmber.withOpacity(0.2),
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
