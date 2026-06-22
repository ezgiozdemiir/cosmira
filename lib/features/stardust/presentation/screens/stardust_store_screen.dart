import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../config/di.dart' show currentUserProvider;
import '../../../home/presentation/providers/home_provider.dart';
import '../providers/stardust_provider.dart';

String _referralCode(String userId) =>
    userId.replaceAll('-', '').substring(0, 8).toUpperCase();

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
                      const _InviteTile(),
                      const SizedBox(height: 24),
                      Text('stardust_history'.tr(),
                          style: AppTextStyles.headlineSmall),
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
                ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('stardust_daily_success'.tr()),
              backgroundColor: AppColors.success,
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

// ── Invite tile ────────────────────────────────────────────────────────────────

class _InviteTile extends ConsumerWidget {
  const _InviteTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider)?.id;
    if (userId == null) return const SizedBox.shrink();

    final code = _referralCode(userId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CosmicCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.share, color: AppColors.accentGlow, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('stardust_invite'.tr(),
                          style: AppTextStyles.titleMedium),
                      Text('stardust_invite_sub'.tr(),
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.auraAmber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+10',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.auraAmber),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Referral code display
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accentGlow.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.accentGlow.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      color: AppColors.accentGlow, size: 16),
                  const SizedBox(width: 10),
                  Text(
                    'stardust_referral_code'.tr(),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    code,
                    style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white, letterSpacing: 2),
                  ),
                  const Spacer(),
                  // Copy button
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('stardust_code_copied'.tr()),
                            duration: const Duration(seconds: 1)),
                      );
                    },
                    child: const Icon(Icons.copy,
                        color: AppColors.textSecondary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  // Share button
                  GestureDetector(
                    onTap: () {
                      Share.share(
                        'stardust_share_text'.tr(namedArgs: {'code': code}),
                      );
                    },
                    child: const Icon(Icons.ios_share,
                        color: AppColors.accentGlow, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
