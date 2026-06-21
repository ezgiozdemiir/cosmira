import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/utils/zodiac_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../domain/entities/big_three_insight.dart';
import '../../domain/entities/house_insight.dart';
import '../providers/astrology_provider.dart';
import '../providers/birth_map_provider.dart';

class NatalChartScreen extends ConsumerWidget {
  const NatalChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return SafeArea(
      child: profileAsync.when(
        data: (profile) {
          if (profile == null || profile.birthDate == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: CosmicCard(
                  onTap: () => context.push('/onboarding'),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars,
                          size: 48, color: AppColors.auraViolet),
                      const SizedBox(height: 16),
                      Text('natal_not_calculated'.tr(),
                          style: AppTextStyles.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        'natal_complete_details'.tr(),
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final bd = profile.birthDate!;
          final birthDateStr =
              '${bd.day} ${'month_${bd.month}'.tr()} ${bd.year}';
          final sunSign = profile.sunSign ?? '';

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('natal_title'.tr(),
                              style: AppTextStyles.headlineLarge)
                          .animate()
                          .fadeIn(),
                      const SizedBox(height: 4),
                      Text(
                        'natal_subtitle'.tr(),
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 24),

                      CosmicCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 16, color: AppColors.accentGlow),
                                const SizedBox(width: 8),
                                Text(
                                  'natal_birth_details'.tr(),
                                  style: AppTextStyles.labelLarge
                                      .copyWith(color: AppColors.accentGlow),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _DetailRow(
                                label: 'natal_date'.tr(),
                                value: birthDateStr),
                            if (profile.birthTime != null) ...[
                              const SizedBox(height: 10),
                              _DetailRow(
                                  label: 'natal_time'.tr(),
                                  value: profile.birthTime!),
                            ],
                            if (profile.birthCity != null) ...[
                              const SizedBox(height: 10),
                              _DetailRow(
                                  label: 'natal_city'.tr(),
                                  value: profile.birthCity!),
                            ],
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 16),

                      CosmicCard(
                        gradient: AppColors.premiumGradient,
                        child: Column(
                          children: [
                            Text(
                              'natal_big_three'.tr(),
                              style: AppTextStyles.labelLarge
                                  .copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _BigThree(
                                  label: 'natal_sun'.tr(),
                                  sign: sunSign,
                                  isCalculated: sunSign.isNotEmpty,
                                ),
                                _BigThree(
                                  label: 'natal_moon'.tr(),
                                  sign: profile.moonSign ?? '',
                                  isCalculated: profile.moonSign != null,
                                ),
                                _BigThree(
                                  label: 'natal_rising'.tr(),
                                  sign: profile.risingSign ?? '',
                                  isCalculated: profile.risingSign != null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms),

                      if (profile.risingSign != null) ...[
                        const SizedBox(height: 16),
                        CosmicCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'natal_houses'.tr(),
                                style: AppTextStyles.labelLarge
                                    .copyWith(color: AppColors.accentGlow),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    for (final entry in wholeSignHouses(
                                            profile.risingSign!)
                                        .asMap()
                                        .entries)
                                      _HouseTile(
                                          houseNumber: entry.key + 1,
                                          sign: entry.value),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 470.ms),
                      ],

                      if (profile.isPremium)
                        _HouseInsightsSection(delay: 520.ms),

                      _InsightSection(
                        title: 'natal_today'.tr(),
                        provider: dailyInsightProvider,
                        delay: 570.ms,
                      ),
                      _InsightSection(
                        title: 'natal_this_month'.tr(),
                        provider: monthlyInsightProvider,
                        delay: 620.ms,
                      ),
                      _InsightSection(
                        title: 'natal_this_year'.tr(),
                        provider: yearlyInsightProvider,
                        delay: 670.ms,
                      ),

                      const _BirthMapEntryCard()
                          .animate()
                          .fadeIn(delay: 720.ms),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
        loading: () => const Center(child: ShimmerCardLoading()),
        error: (_, __) =>
            Center(child: Text('natal_error_profile'.tr())),
      ),
    );
  }
}

class _HouseTile extends StatelessWidget {
  final int houseNumber;
  final String sign;

  const _HouseTile({required this.houseNumber, required this.sign});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Text(
            'natal_house_n'.tr(namedArgs: {'n': '$houseNumber'}),
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(sign.zodiacEmoji, style: const TextStyle(fontSize: 18)),
          Text(sign.zodiacName, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _InsightSection extends StatelessWidget {
  final String title;
  final ProviderListenable<AsyncValue<BigThreeInsight?>> provider;
  final Duration delay;

  const _InsightSection({
    required this.title,
    required this.provider,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(provider);
        return state.when(
          loading: () => Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                const ShimmerLoading(height: 120),
              ],
            ),
          ),
          data: (insight) {
            if (insight == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  _InsightCard(content: insight.content),
                ],
              ),
            );
          },
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    ).animate().fadeIn(delay: delay);
  }
}

class _InsightCard extends StatelessWidget {
  final Map<String, dynamic> content;

  const _InsightCard({required this.content});

  @override
  Widget build(BuildContext context) {
    final mainText =
        (content['summary'] ?? content['insight'] ?? content['forecast'])
            as String?;
    final theme = (content['theme'] ?? content['focus_area']) as String?;
    final secondary =
        (content['advice'] ?? content['cosmic_advice'] ?? content['opportunities'])
            as String?;
    final bullets = [
      ...?(content['strengths'] as List?)?.cast<String>(),
      ...?(content['growth_areas'] as List?)?.cast<String>(),
      ...?(content['quarterly_highlights'] as List?)?.cast<String>(),
    ];

    return CosmicCard(
      gradient: AppColors.premiumGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (theme != null) ...[
            Text(
              theme,
              style: AppTextStyles.labelLarge.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
          ],
          if (mainText != null)
            Text(
              mainText,
              style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.9), height: 1.6),
            ),
          if (bullets.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: bullets
                  .map((b) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          b,
                          style: AppTextStyles.labelSmall
                              .copyWith(color: Colors.white),
                        ),
                      ))
                  .toList(),
            ),
          ],
          if (secondary != null) ...[
            const SizedBox(height: 12),
            Text(
              secondary,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BigThree extends StatelessWidget {
  final String label;
  final String sign;
  final bool isCalculated;

  const _BigThree({
    required this.label,
    required this.sign,
    required this.isCalculated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          isCalculated ? sign.zodiacEmoji : '✨',
          style: const TextStyle(fontSize: 28),
        ),
        const SizedBox(height: 4),
        Text(
          isCalculated ? sign.zodiacName : '—',
          style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

class _HouseInsightsSection extends ConsumerWidget {
  final Duration delay;

  const _HouseInsightsSection({required this.delay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(houseInsightsProvider);
    return state.when(
      loading: () => Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('natal_house_interpretations'.tr(),
                style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            const ShimmerLoading(height: 120),
            const SizedBox(height: 12),
            const ShimmerLoading(height: 120),
          ],
        ),
      ).animate().fadeIn(delay: delay),
      data: (insight) {
        if (insight == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('natal_house_interpretations'.tr(),
                  style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              ...insight.houses.map((h) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HouseInsightCard(detail: h),
                  )),
            ],
          ),
        ).animate().fadeIn(delay: delay);
      },
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _HouseInsightCard extends StatelessWidget {
  final HouseDetail detail;

  const _HouseInsightCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                detail.sign.zodiacEmoji,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 4),
              Text(
                'H${detail.house}',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.accentGlow),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        detail.theme,
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.accentGlow),
                      ),
                    ),
                    Text(
                      detail.sign.zodiacName,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  detail.interpretation,
                  style: AppTextStyles.bodySmall.copyWith(height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Birth Map entry card
// ---------------------------------------------------------------------------

class _BirthMapEntryCard extends ConsumerWidget {
  const _BirthMapEntryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alreadyPurchased =
        ref.watch(birthMapExistsProvider).valueOrNull ?? false;

    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: GestureDetector(
        onTap: () => alreadyPurchased
            ? context.push('/birth-map')
            : _showPurchaseSheet(context),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A0A3A), Color(0xFF0D0620), Color(0xFF12102A)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.auraViolet.withValues(alpha: 0.4),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('✦',
                      style: TextStyle(
                          color: AppColors.auraAmber.withValues(alpha: 0.8),
                          fontSize: 12)),
                  const SizedBox(width: 8),
                  Text('✦',
                      style: TextStyle(
                          color: AppColors.auraViolet.withValues(alpha: 0.6),
                          fontSize: 8)),
                  const SizedBox(width: 8),
                  Text('✦',
                      style: TextStyle(
                          color: AppColors.auraAmber.withValues(alpha: 0.8),
                          fontSize: 12)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'natal_birth_map_title'.tr(),
                style: AppTextStyles.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'natal_birth_map_name'.tr(),
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.auraViolet,
                  letterSpacing: 3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                'natal_birth_map_desc'.tr(),
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (alreadyPurchased)
                _buildViewBadge(context)
              else
                _buildCostBadge(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewBadge(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppColors.premiumGradient,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text('natal_birth_map_view'.tr(),
                style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
          ],
        ),
      );

  Widget _buildCostBadge(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✨', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text('natal_birth_map_cost'.tr(),
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.auraAmber)),
          ],
        ),
      );

  void _showPurchaseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _PurchaseBottomSheet(),
    );
  }
}

// ---------------------------------------------------------------------------
// Purchase bottom sheet
// ---------------------------------------------------------------------------

class _PurchaseBottomSheet extends ConsumerStatefulWidget {
  const _PurchaseBottomSheet();

  @override
  ConsumerState<_PurchaseBottomSheet> createState() =>
      _PurchaseBottomSheetState();
}

class _PurchaseBottomSheetState extends ConsumerState<_PurchaseBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(birthMapPurchaseProvider);
    final balance = ref.watch(stardustBalanceProvider).valueOrNull ?? 0;
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final canAfford = balance >= 50;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D0620),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0x33FFFFFF), width: 0.5),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'natal_birth_map_sheet_title'.tr(),
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'natal_birth_map_sheet_subtitle'.tr(),
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white38),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _BulletRow('natal_birth_map_bullet_1'.tr()),
          _BulletRow('natal_birth_map_bullet_2'.tr()),
          _BulletRow('natal_birth_map_bullet_3'.tr()),
          _BulletRow('natal_birth_map_bullet_4'.tr()),
          _BulletRow('natal_birth_map_bullet_5'.tr()),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('natal_your_stardust'.tr(),
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.white60)),
                Row(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text('$balance',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.auraAmber)),
                  ],
                ),
              ],
            ),
          ),
          if (purchaseState.error != null) ...[
            const SizedBox(height: 12),
            Text(
              purchaseState.error!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.auraRose),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
          GestureDetector(
            onTap: (purchaseState.isLoading || !canAfford || profile == null)
                ? null
                : () => _purchase(context, profile),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: canAfford
                    ? AppColors.premiumGradient
                    : const LinearGradient(
                        colors: [Colors.grey, Colors.grey]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: purchaseState.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        canAfford
                            ? 'natal_unlock_btn'.tr()
                            : 'natal_not_enough'.tr(),
                        style: AppTextStyles.labelLarge
                            .copyWith(color: Colors.white),
                      ),
              ),
            ),
          ),
          if (!canAfford) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                context.push('/stardust');
              },
              child: Text(
                'natal_get_more'.tr(),
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.auraAmber),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _purchase(BuildContext context, dynamic profile) async {
    final notifier = ref.read(birthMapPurchaseProvider.notifier);
    final success = await notifier.purchase(
      sunSign: profile.sunSign ?? '',
      moonSign: profile.moonSign ?? '',
      risingSign: profile.risingSign ?? '',
      mcSign: profile.mcSign ?? '',
      birthDate:
          profile.birthDate?.toIso8601String().split('T').first ?? '',
      birthCity: profile.birthCity ?? '',
    );
    if (success && context.mounted) {
      Navigator.of(context).pop();
      context.push('/birth-map');
    }
  }
}

class _BulletRow extends StatelessWidget {
  final String text;

  const _BulletRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✦ ',
              style: TextStyle(color: AppColors.auraViolet, fontSize: 11)),
          Expanded(
            child: Text(text,
                style: AppTextStyles.bodySmall
                    .copyWith(color: Colors.white60)),
          ),
        ],
      ),
    );
  }
}
