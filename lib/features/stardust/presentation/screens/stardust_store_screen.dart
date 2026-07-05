import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../config/di.dart' show currentUserProvider;
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
                          Text('stardust_title'.tr(),
                              style: AppTextStyles.titleLarge),
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
                      ).animate().fadeIn().scale(
                          begin: const Offset(0.95, 0.95)),
                      const SizedBox(height: 24),
                      Text('stardust_earn'.tr(),
                          style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 12),
                      const _DailyCheckInTile(),
                      const SizedBox(height: 24),
                      Text('stardust_buy'.tr(),
                          style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 12),
                      const _BundleGrid(),
                      const SizedBox(height: 24),
                      Text('stardust_history'.tr(),
                          style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              transactions.when(
                data: (list) {
                  if (list.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        child: Center(
                          child: Text(
                            'stardust_no_transactions'.tr(),
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                      final tx = list[index];
                      final isPositive = tx.isPositive;
                      final txColor =
                          isPositive ? AppColors.success : AppColors.error;
                      final txKey = 'stardust_tx_${tx.source}';
                      final txLabel =
                          txKey.tr() == txKey ? tx.description : txKey.tr();
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
                );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) =>
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Daily check-in tile ────────────────────────────────────────────────────────

class _DailyCheckInTile extends ConsumerStatefulWidget {
  const _DailyCheckInTile();

  @override
  ConsumerState<_DailyCheckInTile> createState() => _DailyCheckInTileState();
}

class _DailyCheckInTileState extends ConsumerState<_DailyCheckInTile> {
  bool _claiming = false;

  Future<void> _claim() async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    setState(() => _claiming = true);

    final result = await ref
        .read(stardustRepositoryProvider)
        .claimDailyCheckIn(userId: userId);

    if (!mounted) return;
    setState(() => _claiming = false);

    result.when(
      success: (claimed) {
        if (claimed) {
          ref.invalidate(stardustTransactionsProvider);
          ref.invalidate(stardustBalanceProvider);
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                'stardust_daily_popup_title'.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome,
                      color: AppColors.auraAmber, size: 52),
                  const SizedBox(height: 12),
                  Text(
                    'stardust_daily_popup_body'.tr(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'stardust_daily_popup_cta'.tr(),
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.accentGlow),
                  ),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('stardust_daily_already'.tr())),
          );
        }
      },
      failure: (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final alreadyClaimed =
        ref.watch(hasCheckedInTodayProvider).valueOrNull ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CosmicCard(
        onTap: (!alreadyClaimed && !_claiming) ? _claim : null,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              alreadyClaimed
                  ? Icons.check_circle
                  : Icons.local_fire_department,
              color: alreadyClaimed
                  ? AppColors.success
                  : AppColors.accentGlow,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('stardust_daily_login'.tr(),
                      style: AppTextStyles.titleMedium),
                  Text(
                    alreadyClaimed
                        ? 'stardust_daily_claimed'.tr()
                        : 'stardust_daily_login_sub'.tr(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: alreadyClaimed
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (_claiming)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.auraAmber),
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: (alreadyClaimed ? AppColors.success : AppColors.auraAmber)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  alreadyClaimed ? '✓' : '+1',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: alreadyClaimed
                        ? AppColors.success
                        : AppColors.auraAmber,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Stardust bundle grid ───────────────────────────────────────────────────────

class _BundleGrid extends StatelessWidget {
  const _BundleGrid();

  static const _bundles = [
    (amount: 100, price: '₺79',  label: 'Starter'),
    (amount: 200, price: '₺149', label: 'Explorer'),
    (amount: 300, price: '₺199', label: 'Seeker'),
    (amount: 600, price: '₺349', label: 'Cosmic'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: _bundles
          .map((b) => _BundleTile(amount: b.amount, price: b.price, label: b.label))
          .toList(),
    );
  }
}

class _BundleTile extends StatelessWidget {
  final int amount;
  final String price;
  final String label;

  const _BundleTile({required this.amount, required this.price, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('stardust_bundle_soon_title'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge),
          content: Text('stardust_bundle_soon_body'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.accentGlow)),
            ),
          ],
        ),
      ),
      child: CosmicCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome,
                    color: AppColors.auraAmber, size: 18),
                const SizedBox(width: 6),
                Text(
                  '$amount',
                  style: AppTextStyles.displayMedium
                      .copyWith(color: AppColors.auraAmber, fontSize: 24),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(label,
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.premiumGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(price,
                  style: AppTextStyles.labelLarge
                      .copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
