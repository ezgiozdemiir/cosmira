import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:go_router/go_router.dart';

import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/moon_phase.dart';
import '../providers/moon_provider.dart';

String _monthName(int month) => 'month_$month'.tr();

class MoonCalendarScreen extends ConsumerWidget {
  const MoonCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(localCurrentMoonPhaseProvider);
    final selectedDay = ref.watch(selectedDayProvider);
    final selectedPhase = ref.watch(selectedDayMoonPhaseProvider);
    final monthPhases = ref.watch(localMonthlyPhasesProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final isPremium =
        ref.watch(userProfileProvider).valueOrNull?.isPremium ?? false;

    final isToday = _isSameDay(selectedDay, DateTime.now());
    final displayPhase = isToday ? today : selectedPhase;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('moon_title'.tr(), style: AppTextStyles.headlineLarge)
                      .animate()
                      .fadeIn(),
                  const SizedBox(height: 4),
                  Text(
                    isToday
                        ? 'moon_today_energy'.tr()
                        : _formatDate(selectedDay),
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  _MoonHeroCard(phase: displayPhase),
                  const SizedBox(height: 24),
                  _MonthHeader(month: selectedMonth, ref: ref),
                  const SizedBox(height: 12),
                  _CalendarGrid(
                    year: selectedMonth.year,
                    month: selectedMonth.month,
                    phases: monthPhases,
                    selectedDay: selectedDay,
                  ),
                  const SizedBox(height: 24),
                  _RitualCard(phase: displayPhase),
                  const SizedBox(height: 16),
                  if (displayPhase.intentions.isNotEmpty) ...[
                    Text('moon_set_intentions'.tr(),
                        style: AppTextStyles.titleMedium),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: displayPhase.intentions.map((intention) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.auraIndigo.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.auraIndigo.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            intention.tr(),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.auraIndigo,
                              letterSpacing: 0.4,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (displayPhase.crystalRecommendation != null)
                    CosmicCard(
                      child: Row(
                        children: [
                          const Icon(Icons.diamond_outlined,
                              color: AppColors.auraTeal, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('moon_crystal_ally'.tr(),
                                    style: AppTextStyles.labelSmall),
                                const SizedBox(height: 2),
                                Text(
                                  displayPhase.crystalRecommendation!.tr(),
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.auraTeal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (!isPremium)
                    const _MoonImpactProCard()
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.06),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate(DateTime d) =>
      '${_monthName(d.month)} ${d.day}, ${d.year}';
}

class _MoonHeroCard extends StatelessWidget {
  final MoonPhase phase;
  const _MoonHeroCard({required this.phase});

  @override
  Widget build(BuildContext context) {
    final illumPct =
        '${(phase.illumination * 100).toStringAsFixed(0)}%';

    return CosmicCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1a1440), Color(0xFF0d0d28)],
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGlow.withValues(alpha: 0.25),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Text(
                phase.phaseEmoji,
                style: const TextStyle(fontSize: 52),
              ),
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.6, 0.6),
                duration: 700.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 400.ms),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'moon_phase_${phase.phaseName}'.tr(),
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'moon_zodiac_in'.tr(namedArgs: {
                    'sign': phase.zodiacSign.zodiacName,
                    'emoji': phase.zodiacSign.zodiacEmoji,
                  }),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.accentGlow,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: phase.illumination,
                          minHeight: 6,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accentGlow,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      illumPct,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'moon_illuminated'.tr(),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, duration: 400.ms);
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime month;
  final WidgetRef ref;
  const _MonthHeader({required this.month, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            final prev = DateTime(month.year, month.month - 1);
            ref.read(selectedMonthProvider.notifier).state = prev;
            ref.read(selectedDayProvider.notifier).state = prev;
          },
          icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: Center(
            child: Text(
              '${_monthName(month.month)} ${month.year}',
              style: AppTextStyles.titleMedium,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            final next = DateTime(month.year, month.month + 1);
            ref.read(selectedMonthProvider.notifier).state = next;
            ref.read(selectedDayProvider.notifier).state = next;
          },
          icon:
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _CalendarGrid extends ConsumerWidget {
  final int year;
  final int month;
  final List<MoonPhase> phases;
  final DateTime selectedDay;

  const _CalendarGrid({
    required this.year,
    required this.month,
    required this.phases,
    required this.selectedDay,
  });

  static List<String> get _dayHeaders => [
    'moon_day_mon'.tr(), 'moon_day_tue'.tr(), 'moon_day_wed'.tr(),
    'moon_day_thu'.tr(), 'moon_day_fri'.tr(), 'moon_day_sat'.tr(),
    'moon_day_sun'.tr(),
  ];

  static const _majorPhases = {
    'new_moon', 'first_quarter', 'full_moon', 'last_quarter'
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final firstWeekday = DateTime(year, month, 1).weekday - 1;

    return Column(
      children: [
        Row(
          children: _dayHeaders.map((d) {
            return Expanded(
              child: Center(
                child: Text(
                  d,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (context, constraints) {
          final cellSize = constraints.maxWidth / 7;
          return Wrap(
            children: [
              ...List.generate(
                firstWeekday,
                (_) => SizedBox(width: cellSize, height: cellSize),
              ),
              ...phases.asMap().entries.map((e) {
                final dayIndex = e.key;
                final phase = e.value;
                final day = DateTime(year, month, dayIndex + 1);
                final isToday = _isSameDay(day, today);
                final isSelected = _isSameDay(day, selectedDay);
                final isMajor = _majorPhases.contains(phase.phaseName);

                return GestureDetector(
                  onTap: () {
                    ref.read(selectedDayProvider.notifier).state = day;
                  },
                  child: SizedBox(
                    width: cellSize,
                    height: cellSize,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isMajor)
                          Text(
                            phase.phaseEmoji,
                            style: const TextStyle(fontSize: 11),
                          )
                        else
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(
                                alpha: 0.08 + 0.55 * phase.illumination,
                              ),
                            ),
                          ),
                        const SizedBox(height: 3),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected && !isToday
                                ? AppColors.auraViolet.withValues(alpha: 0.25)
                                : isToday
                                    ? AppColors.accentGlow.withValues(
                                        alpha: 0.2)
                                    : null,
                            border: isToday
                                ? Border.all(
                                    color: AppColors.accentGlow,
                                    width: 1.5,
                                  )
                                : isSelected
                                    ? Border.all(
                                        color: AppColors.auraViolet,
                                        width: 1.0,
                                      )
                                    : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${dayIndex + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isToday || isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isToday
                                  ? AppColors.accentGlow
                                  : isSelected
                                      ? AppColors.auraViolet
                                      : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        }),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(emoji: '🌑', label: 'moon_new'.tr()),
            const SizedBox(width: 16),
            _LegendItem(emoji: '🌓', label: 'moon_first_qtr'.tr()),
            const SizedBox(width: 16),
            _LegendItem(emoji: '🌕', label: 'moon_full'.tr()),
            const SizedBox(width: 16),
            _LegendItem(emoji: '🌗', label: 'moon_last_qtr'.tr()),
          ],
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _LegendItem extends StatelessWidget {
  final String emoji;
  final String label;
  const _LegendItem({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 3),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _RitualCard extends StatelessWidget {
  final MoonPhase phase;
  const _RitualCard({required this.phase});

  @override
  Widget build(BuildContext context) {
    if (phase.ritualTitle.isEmpty) return const SizedBox.shrink();

    return CosmicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(phase.phaseEmoji,
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  phase.ritualTitle.tr(),
                  style: AppTextStyles.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            phase.ritualDescription.tr(),
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.06, duration: 350.ms);
  }
}

// ---------------------------------------------------------------------------
// Moon Impact Analysis — Pro locked card
// ---------------------------------------------------------------------------

class _MoonImpactProCard extends StatelessWidget {
  const _MoonImpactProCard();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 270),
      child: Stack(
      children: [
        // Blurred preview of the pro content
        CosmicCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('moon_pro_title'.tr(), style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: 220,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: 180,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _fakeChip('🏠  3. Ev'),
                  const SizedBox(width: 8),
                  _fakeChip('♄  Satürn'),
                  const SizedBox(width: 8),
                  _fakeChip('💜  Duygu'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _fakeChip('🌙  Ay Etkisi'),
                  const SizedBox(width: 8),
                  _fakeChip('✨  Enerji'),
                ],
              ),
            ],
          ),
        ),
        // Frosted overlay + lock
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.midnight.withValues(alpha: 0.80),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.auraIndigo.withValues(alpha: 0.15),
                    border: Border.all(
                        color: AppColors.auraIndigo.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.lock_outline,
                      color: AppColors.auraIndigo, size: 28),
                ),
                const SizedBox(height: 14),
                Text('moon_pro_feature'.tr(),
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 4),
                Text('moon_pro_title'.tr(),
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.auraIndigo)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'moon_pro_sub'.tr(),
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => context.push('/paywall'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppColors.premiumGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('moon_pro_cta'.tr(),
                        style: AppTextStyles.labelLarge
                            .copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _fakeChip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.auraIndigo.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.auraIndigo.withValues(alpha: 0.2)),
        ),
        child: Text(label,
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.auraIndigo)),
      );
}
