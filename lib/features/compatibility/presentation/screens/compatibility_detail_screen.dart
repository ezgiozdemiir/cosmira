import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../../core/widgets/cosmic_button.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/compatibility_partner.dart';
import '../providers/compatibility_provider.dart';

class CompatibilityDetailScreen extends ConsumerWidget {
  final CompatibilityPartner partner;

  const CompatibilityDetailScreen({super.key, required this.partner});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.valueOrNull;
    final userSunSign = profile?.sunSign?.toLowerCase() ?? '';
    final isPremium = profile?.isPremium ?? false;

    final score = _compatibilityScore(userSunSign, partner.sunSign);
    final description = _compatibilityDescriptionKey(userSunSign, partner.sunSign).tr();

    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  _PartnerHeader(partner: partner)
                      .animate()
                      .fadeIn()
                      .slideY(begin: -0.05),

                  const SizedBox(height: 24),

                  // Birth details
                  CosmicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('compat_birth_details'.tr(),
                            style: AppTextStyles.titleMedium),
                        const SizedBox(height: 16),
                        _DetailRow(
                          icon: Icons.cake_outlined,
                          label: 'compat_birthday'.tr(),
                          value:
                              '${partner.birthDate.day} ${'month_${partner.birthDate.month}'.tr()} ${partner.birthDate.year}',
                        ),
                        if (partner.birthCity != null &&
                            partner.birthCity!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.location_on_outlined,
                            label: 'compat_birth_city'.tr(),
                            value: partner.birthCity!,
                          ),
                        ],
                        const SizedBox(height: 12),
                        _DetailRow(
                          icon: Icons.auto_awesome,
                          label: 'compat_sun_sign'.tr(),
                          value: partner.sunSign.zodiacName,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 16),

                  // Basic element compatibility card — Pro only
                  if (userSunSign.isNotEmpty && isPremium)
                    _CompatibilityCard(
                      userSunSign: userSunSign,
                      partnerSunSign: partner.sunSign,
                      score: score,
                      description: description,
                    ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 16),

                  // Deep report section
                  _DeepReportSection(
                    partner: partner,
                    isPremium: isPremium,
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 32),

                  TextButton.icon(
                    onPressed: () => _confirmDelete(context, ref),
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error, size: 18),
                    label: Text('compat_remove_partner'.tr(),
                        style: const TextStyle(color: AppColors.error)),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      backgroundColor: AppColors.midnight,
      foregroundColor: AppColors.textPrimary,
      floating: true,
      title: Text('compat_detail_title'.tr(),
          style: AppTextStyles.titleMedium),
      centerTitle: true,
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('compat_remove_partner'.tr(), style: AppTextStyles.titleMedium),
        content: Text(
          'compat_remove_confirm'.tr(namedArgs: {'name': partner.name}),
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('compat_cancel'.tr(),
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('compat_remove'.tr(),
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(compatibilityRepositoryProvider)
          .removePartner(partner.id);
      ref.invalidate(partnersProvider);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  // Simple element-based compatibility
  static int _compatibilityScore(String signA, String signB) {
    final elementA = _element(signA);
    final elementB = _element(signB);
    if (elementA == elementB) return 90;
    const pairs = {
      ('fire', 'air'), ('air', 'fire'),
      ('earth', 'water'), ('water', 'earth'),
    };
    final pair = (elementA, elementB);
    if (pairs.contains(pair)) return 80;
    const neutral = {
      ('fire', 'earth'), ('earth', 'fire'),
      ('air', 'water'), ('water', 'air'),
    };
    if (neutral.contains(pair)) return 62;
    return 50;
  }

  static String _compatibilityDescriptionKey(String signA, String signB) {
    final score = _compatibilityScore(signA, signB);
    if (score >= 90) return 'compat_desc_kindred';
    if (score >= 80) return 'compat_desc_complements';
    if (score >= 62) return 'compat_desc_tension';
    return 'compat_desc_challenge';
  }

  static String _element(String sign) {
    const fire = ['aries', 'leo', 'sagittarius'];
    const earth = ['taurus', 'virgo', 'capricorn'];
    const air = ['gemini', 'libra', 'aquarius'];
    final s = sign.toLowerCase();
    if (fire.contains(s)) return 'fire';
    if (earth.contains(s)) return 'earth';
    if (air.contains(s)) return 'air';
    return 'water';
  }

}

// ---------------------------------------------------------------------------

class _PartnerHeader extends StatelessWidget {
  final CompatibilityPartner partner;
  const _PartnerHeader({required this.partner});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.auraRose.withValues(alpha: 0.3),
                AppColors.auraRose.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Center(
            child: Text(
              partner.sunSign.zodiacEmoji,
              style: const TextStyle(fontSize: 44),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(partner.name, style: AppTextStyles.headlineMedium),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(partner.sunSign.zodiacName,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.auraRose)),
            const Text(' · ', style: AppTextStyles.bodyMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.auraRose.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'compat_${partner.relationship}'.tr(),
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.auraRose),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _CompatibilityCard extends StatelessWidget {
  final String userSunSign;
  final String partnerSunSign;
  final int score;
  final String description;

  const _CompatibilityCard({
    required this.userSunSign,
    required this.partnerSunSign,
    required this.score,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: AppColors.auraRose, size: 18),
              const SizedBox(width: 8),
              Text('compat_cosmic_compat'.tr(),
                  style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: 20),

          // Signs row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SignBubble(sign: userSunSign, label: 'compat_you'.tr()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      '$score%',
                      style: AppTextStyles.headlineLarge
                          .copyWith(color: AppColors.auraRose),
                    ),
                    Text('compat_match'.tr(), style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              _SignBubble(sign: partnerSunSign, label: 'compat_them'.tr()),
            ],
          ),

          const SizedBox(height: 20),

          // Score bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 6,
              backgroundColor: AppColors.textTertiary.withValues(alpha: 0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.auraRose),
            ),
          ),

          const SizedBox(height: 16),
          Text(description, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _SignBubble extends StatelessWidget {
  final String sign;
  final String label;
  const _SignBubble({required this.sign, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.auraRose.withValues(alpha: 0.15),
          ),
          child: Center(
            child: Text(sign.zodiacEmoji,
                style: const TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(height: 6),
        Text(sign.zodiacName, style: AppTextStyles.bodySmall),
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textTertiary)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Deep report section
// ---------------------------------------------------------------------------

class _DeepReportSection extends ConsumerWidget {
  final CompatibilityPartner partner;
  final bool isPremium;

  const _DeepReportSection({required this.partner, required this.isPremium});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isPremium) return const _LockedReportCard();

    final reportAsync = ref.watch(compatibilityReportProvider(partner.id));
    final generateState = ref.watch(generateReportProvider(partner.id));
    final isGenerating = generateState is AsyncLoading;

    return reportAsync.when(
      loading: () => const CosmicCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(color: AppColors.auraViolet),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (report) {
        if (report == null) {
          return CosmicCard(
            child: Column(
              children: [
                const Icon(Icons.auto_awesome,
                    color: AppColors.auraViolet, size: 32),
                const SizedBox(height: 12),
                Text('compat_deep_report'.tr(),
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'compat_deep_report_sub'.tr(),
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                CosmicButton(
                  label: isGenerating ? 'compat_generating'.tr() : 'compat_generate'.tr(),
                  icon: Icons.auto_awesome,
                  onPressed: isGenerating
                      ? null
                      : () => ref
                          .read(generateReportProvider(partner.id).notifier)
                          .generate(partner.id),
                ),
                if (generateState is AsyncError) ...[
                  const SizedBox(height: 12),
                  Text(
                    generateState.error.toString(),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        }

        return _ReportContent(report: report);
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _LockedReportCard extends StatelessWidget {
  const _LockedReportCard();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred preview
        CosmicCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('compat_deep_report'.tr(),
                  style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),
              _ScoreBarRow(label: 'compat_emotional'.tr(), value: 0.72),
              const SizedBox(height: 10),
              _ScoreBarRow(label: 'compat_communication'.tr(), value: 0.85),
              const SizedBox(height: 10),
              _ScoreBarRow(label: 'compat_karmic'.tr(), value: 0.61),
              const SizedBox(height: 10),
              _ScoreBarRow(label: 'compat_intimacy'.tr(), value: 0.78),
              const SizedBox(height: 16),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
        // Lock overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.midnight.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.auraViolet.withValues(alpha: 0.15),
                    border: Border.all(
                        color: AppColors.auraViolet.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.lock_outline,
                      color: AppColors.auraViolet, size: 28),
                ),
                const SizedBox(height: 14),
                Text('compat_pro_feature'.tr(),
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                Text(
                  'compat_pro_sub'.tr(),
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _ReportContent extends StatelessWidget {
  final CompatibilityReport report;
  const _ReportContent({required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score grid
        CosmicCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('compat_deep_report'.tr(),
                  style: AppTextStyles.titleMedium),
              const SizedBox(height: 4),
              Text('compat_ai_analysis'.tr(),
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.auraViolet)),
              const SizedBox(height: 20),
              _ScoreBarRow(
                  label: 'compat_emotional'.tr(),
                  value: report.emotionalAlignment / 100),
              const SizedBox(height: 10),
              _ScoreBarRow(
                  label: 'compat_communication'.tr(),
                  value: report.communicationScore / 100),
              const SizedBox(height: 10),
              _ScoreBarRow(
                  label: 'compat_karmic'.tr(), value: report.karmicBond / 100),
              const SizedBox(height: 10),
              _ScoreBarRow(
                  label: 'compat_intimacy'.tr(),
                  value: report.intimacyEnergy / 100),
              const SizedBox(height: 10),
              _ScoreBarRow(
                  label: 'compat_long_term'.tr(),
                  value: report.longTermScore / 100),
              const SizedBox(height: 10),
              _ScoreBarRow(
                  label: 'compat_soulmate'.tr(),
                  value: report.soulmateProbability / 100,
                  color: AppColors.auraRose),
            ],
          ),
        ),

        if (report.summary != null) ...[
          const SizedBox(height: 12),
          _InsightCard(
            icon: Icons.auto_awesome,
            color: AppColors.auraViolet,
            title: 'compat_summary'.tr(),
            text: report.summary!,
          ),
        ],
        if (report.emotionalInsight != null) ...[
          const SizedBox(height: 12),
          _InsightCard(
            icon: Icons.favorite_outline,
            color: AppColors.auraRose,
            title: 'compat_emotional'.tr(),
            text: report.emotionalInsight!,
          ),
        ],
        if (report.communicationInsight != null) ...[
          const SizedBox(height: 12),
          _InsightCard(
            icon: Icons.chat_bubble_outline,
            color: AppColors.auraIndigo,
            title: 'compat_communication'.tr(),
            text: report.communicationInsight!,
          ),
        ],
        if (report.karmicInsight != null) ...[
          const SizedBox(height: 12),
          _InsightCard(
            icon: Icons.loop,
            color: AppColors.auraTeal,
            title: 'compat_karmic'.tr(),
            text: report.karmicInsight!,
          ),
        ],
        if (report.intimacyInsight != null) ...[
          const SizedBox(height: 12),
          _InsightCard(
            icon: Icons.spa_outlined,
            color: AppColors.auraAmber,
            title: 'compat_intimacy'.tr(),
            text: report.intimacyInsight!,
          ),
        ],
        if (report.longTermInsight != null) ...[
          const SizedBox(height: 12),
          _InsightCard(
            icon: Icons.timeline,
            color: AppColors.auraEmerald,
            title: 'compat_long_term'.tr(),
            text: report.longTermInsight!,
          ),
        ],

        if (report.strengths.isNotEmpty) ...[
          const SizedBox(height: 12),
          CosmicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.star_outline,
                      color: AppColors.auraAmber, size: 18),
                  const SizedBox(width: 8),
                  Text('compat_strengths'.tr(), style: AppTextStyles.titleMedium),
                ]),
                const SizedBox(height: 12),
                ...report.strengths.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✦ ',
                              style: TextStyle(color: AppColors.auraAmber)),
                          Expanded(
                              child: Text(s,
                                  style: AppTextStyles.bodySmall)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],

        if (report.conflicts.isNotEmpty) ...[
          const SizedBox(height: 12),
          CosmicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.balance,
                      color: AppColors.auraIndigo, size: 18),
                  const SizedBox(width: 8),
                  Text('compat_growth_areas'.tr(),
                      style: AppTextStyles.titleMedium),
                ]),
                const SizedBox(height: 12),
                ...report.conflicts.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('◈ ',
                              style:
                                  TextStyle(color: AppColors.auraIndigo)),
                          Expanded(
                              child: Text(c,
                                  style: AppTextStyles.bodySmall)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],

        if (report.cosmicAdvice != null) ...[
          const SizedBox(height: 12),
          CosmicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.nights_stay_outlined,
                      color: AppColors.auraTeal, size: 18),
                  const SizedBox(width: 8),
                  Text('compat_advice'.tr(),
                      style: AppTextStyles.titleMedium),
                ]),
                const SizedBox(height: 12),
                Text(report.cosmicAdvice!, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _ScoreBarRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _ScoreBarRow({
    required this.label,
    required this.value,
    this.color = AppColors.auraViolet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: AppTextStyles.bodySmall),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: AppColors.textTertiary.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${(value * 100).round()}%',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String text;

  const _InsightCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.titleMedium),
          ]),
          const SizedBox(height: 10),
          Text(text, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 10),
        Text('$label  ', style: AppTextStyles.bodySmall),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
