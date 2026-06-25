import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../providers/astrocartography_provider.dart';

// ─── Planet line definitions ──────────────────────────────────────────────────

class _Line {
  final String emoji;
  final String translationKey; // e.g. 'sun', 'moon', 'venus' …
  final Color color;
  final double mapX;
  final double mapY;

  const _Line({
    required this.emoji,
    required this.translationKey,
    required this.color,
    required this.mapX,
    required this.mapY,
  });

  String get planet => 'astro_line_${translationKey}_planet'.tr();
  String get lineType => 'astro_line_${translationKey}_type'.tr();
  String get theme => 'astro_line_${translationKey}_theme'.tr();
  String get bestFor => 'astro_line_${translationKey}_best_for'.tr();
  String get reading => 'astro_line_${translationKey}_reading'.tr();
}

const _lines = <_Line>[
  _Line(emoji: '☀️', translationKey: 'sun',     color: AppColors.auraAmber,   mapX: 0.54, mapY: 0.32),
  _Line(emoji: '🌙', translationKey: 'moon',    color: AppColors.accentGlow,  mapX: 0.49, mapY: 0.22),
  _Line(emoji: '♀',  translationKey: 'venus',   color: AppColors.auraRose,    mapX: 0.82, mapY: 0.52),
  _Line(emoji: '♂',  translationKey: 'mars',    color: Color(0xFFEF4444),     mapX: 0.19, mapY: 0.42),
  _Line(emoji: '♃',  translationKey: 'jupiter', color: AppColors.auraEmerald, mapX: 0.60, mapY: 0.44),
  _Line(emoji: '♄',  translationKey: 'saturn',  color: AppColors.auraIndigo,  mapX: 0.32, mapY: 0.69),
  _Line(emoji: '♅',  translationKey: 'uranus',  color: AppColors.auraTeal,    mapX: 0.72, mapY: 0.36),
  _Line(emoji: '♆',  translationKey: 'neptune', color: AppColors.auraViolet,  mapX: 0.90, mapY: 0.68),
];

class _Destination {
  final String translationKey; // 'career', 'love', 'home'
  final String emoji;
  final Color color;

  const _Destination({
    required this.translationKey,
    required this.emoji,
    required this.color,
  });

  String get label  => 'astro_dest_${translationKey}_label'.tr();
  String get region => 'astro_dest_${translationKey}_region'.tr();
  String get why    => 'astro_dest_${translationKey}_why'.tr();
}

const _destinations = [
  _Destination(translationKey: 'career', emoji: '☀️', color: AppColors.auraAmber),
  _Destination(translationKey: 'love',   emoji: '♀',  color: AppColors.auraRose),
  _Destination(translationKey: 'home',   emoji: '🌙', color: AppColors.accentGlow),
];

// ─── Line type guide data ─────────────────────────────────────────────────────

class _LineTypeInfo {
  final String symbol;
  final String nameKey;
  final String descKey;
  final Color color;

  const _LineTypeInfo({
    required this.symbol,
    required this.nameKey,
    required this.descKey,
    required this.color,
  });

  String get name => nameKey.tr();
  String get desc => descKey.tr();
}

const _lineTypes = [
  _LineTypeInfo(symbol: 'AC', nameKey: 'astro_lt_ac_name', descKey: 'astro_lt_ac_desc', color: AppColors.auraAmber),
  _LineTypeInfo(symbol: 'DC', nameKey: 'astro_lt_dc_name', descKey: 'astro_lt_dc_desc', color: AppColors.auraRose),
  _LineTypeInfo(symbol: 'MC', nameKey: 'astro_lt_mc_name', descKey: 'astro_lt_mc_desc', color: AppColors.auraEmerald),
  _LineTypeInfo(symbol: 'IC', nameKey: 'astro_lt_ic_name', descKey: 'astro_lt_ic_desc', color: AppColors.accentGlow),
];

// ─── Power cities data ────────────────────────────────────────────────────────

class _City {
  final String emoji;
  final String translationKey;
  final Color color;

  const _City({
    required this.emoji,
    required this.translationKey,
    required this.color,
  });

  String get name    => 'astro_city_${translationKey}_name'.tr();
  String get country => 'astro_city_${translationKey}_country'.tr();
  String get line    => 'astro_city_${translationKey}_line'.tr();
  String get reason  => 'astro_city_${translationKey}_reason'.tr();
}

const _cities = [
  _City(emoji: '☀️', translationKey: 'athens',    color: AppColors.auraAmber),
  _City(emoji: '♀',  translationKey: 'lisbon',    color: AppColors.auraRose),
  _City(emoji: '♃',  translationKey: 'tokyo',     color: AppColors.auraEmerald),
  _City(emoji: '🌙', translationKey: 'reykjavik', color: AppColors.accentGlow),
  _City(emoji: '♅',  translationKey: 'sydney',    color: AppColors.auraTeal),
  _City(emoji: '♆',  translationKey: 'bali',      color: AppColors.auraViolet),
  _City(emoji: '♂',  translationKey: 'marrakech', color: Color(0xFFEF4444)),
  _City(emoji: '♄',  translationKey: 'edinburgh', color: AppColors.auraIndigo),
];

// ─── Parans data ──────────────────────────────────────────────────────────────

class _Paran {
  final String emoji1;
  final String emoji2;
  final String translationKey;
  final Color color1;
  final Color color2;

  const _Paran({
    required this.emoji1,
    required this.emoji2,
    required this.translationKey,
    required this.color1,
    required this.color2,
  });

  String get city    => 'astro_paran_${translationKey}_city'.tr();
  String get country => 'astro_paran_${translationKey}_country'.tr();
  String get theme   => 'astro_paran_${translationKey}_theme'.tr();
  String get meaning => 'astro_paran_${translationKey}_meaning'.tr();
}

const _parans = [
  _Paran(emoji1: '♃', emoji2: '♀',  translationKey: 'barcelona', color1: AppColors.auraEmerald, color2: AppColors.auraRose),
  _Paran(emoji1: '☀️', emoji2: '🌙', translationKey: 'capetown',  color1: AppColors.auraAmber,   color2: AppColors.accentGlow),
  _Paran(emoji1: '♅', emoji2: '♄',  translationKey: 'seoul',     color1: AppColors.auraTeal,    color2: AppColors.auraIndigo),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class AstrocartographyScreen extends ConsumerStatefulWidget {
  const AstrocartographyScreen({super.key});

  @override
  ConsumerState<AstrocartographyScreen> createState() =>
      _AstrocartographyScreenState();
}

class _AstrocartographyScreenState
    extends ConsumerState<AstrocartographyScreen> {
  bool _unlocking = false;
  int? _expandedIndex;

  Future<void> _handleUnlock() async {
    setState(() => _unlocking = true);
    HapticUtils.medium();
    final error = await ref.read(astrocartographyProvider.notifier).unlock();
    if (mounted) setState(() => _unlocking = false);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    } else if (mounted) {
      HapticUtils.selection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final balance = ref.watch(stardustBalanceProvider).valueOrNull ?? 0;
    final astroState = ref.watch(astrocartographyProvider);
    final isUnlocked = astroState.status == AstrocartographyStatus.unlocked;
    final isLoading  = astroState.status == AstrocartographyStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.textPrimary),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 4),
                      const Text('🌍', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Text('astro_title'.tr(),
                          style: AppTextStyles.headlineSmall),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SummarySection(birthCity: profile?.birthCity)
                          .animate()
                          .fadeIn(delay: 100.ms)
                          .slideY(begin: 0.06),

                      const SizedBox(height: 20),

                      if (isLoading)
                        const Center(
                            child: Padding(
                                padding: EdgeInsets.all(32),
                                child: CircularProgressIndicator()))
                      else if (!isUnlocked)
                        _UnlockGate(
                          balance: balance,
                          unlocking: _unlocking,
                          onUnlock: _handleUnlock,
                          onEarnMore: () => context.push('/stardust'),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08)
                      else ...[
                        const _LineTypesGuide()
                            .animate()
                            .fadeIn(delay: 80.ms),
                        const SizedBox(height: 20),
                        _SectionLabel(
                          title: 'astro_planetary_lines'.tr(),
                          subtitle: 'astro_planetary_lines_sub'.tr(),
                        ),
                        const SizedBox(height: 12),
                        const _PlanetLineTable()
                            .animate()
                            .fadeIn(delay: 100.ms),
                        const SizedBox(height: 20),
                        const _WorldMapSection()
                            .animate()
                            .fadeIn(delay: 150.ms),
                        const SizedBox(height: 20),
                        _SectionLabel(
                          title: 'astro_planet_by_planet'.tr(),
                          subtitle: 'astro_planet_by_planet_sub'.tr(),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(_lines.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _PlanetCard(
                              line: _lines[i],
                              expanded: _expandedIndex == i,
                              onTap: () => setState(() =>
                                  _expandedIndex =
                                      _expandedIndex == i ? null : i),
                            )
                                .animate()
                                .fadeIn(delay: (80 * i).ms)
                                .slideX(begin: -0.04),
                          );
                        }),
                        const SizedBox(height: 20),
                        const _DestinyCompass()
                            .animate()
                            .fadeIn(delay: 200.ms),
                        const SizedBox(height: 20),
                        const _TopCitiesSection()
                            .animate()
                            .fadeIn(delay: 220.ms),
                        const SizedBox(height: 20),
                        const _ParansSection()
                            .animate()
                            .fadeIn(delay: 240.ms),
                        const SizedBox(height: 20),
                        _CurrentLocationSection(birthCity: profile?.birthCity)
                            .animate()
                            .fadeIn(delay: 260.ms),
                      ],
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Summary Section ──────────────────────────────────────────────────────────

class _SummarySection extends StatelessWidget {
  final String? birthCity;
  const _SummarySection({this.birthCity});

  @override
  Widget build(BuildContext context) {
    final locationText = birthCity != null
        ? 'astro_summary_para3_city'.tr(namedArgs: {'city': birthCity!})
        : 'astro_summary_para3_no_city'.tr();

    return CosmicCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0E1B3A), Color(0xFF0B1026)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🌐', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Text(
              'astro_what_is'.tr(),
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
            ),
          ]),
          const SizedBox(height: 14),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 14),
          Text(
            'astro_summary_para1'.tr(),
            style: AppTextStyles.bodyMedium
                .copyWith(color: Colors.white.withValues(alpha: 0.82), height: 1.65),
          ),
          const SizedBox(height: 12),
          Text(
            'astro_summary_para2'.tr(),
            style: AppTextStyles.bodyMedium
                .copyWith(color: Colors.white.withValues(alpha: 0.82), height: 1.65),
          ),
          const SizedBox(height: 12),
          Text(
            locationText,
            style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.accentGlow.withValues(alpha: 0.9),
                height: 1.65),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.auraAmber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.auraAmber.withValues(alpha: 0.25)),
            ),
            child: Row(children: [
              const Icon(Icons.auto_awesome,
                  color: AppColors.auraAmber, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'astro_summary_unlock'.tr(),
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.auraAmber.withValues(alpha: 0.85),
                      height: 1.5),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─── Unlock Gate ──────────────────────────────────────────────────────────────

class _UnlockGate extends StatelessWidget {
  final int balance;
  final bool unlocking;
  final VoidCallback onUnlock;
  final VoidCallback onEarnMore;

  const _UnlockGate({
    required this.balance,
    required this.unlocking,
    required this.onUnlock,
    required this.onEarnMore,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = balance >= 100;

    final includes = [
      'astro_include_1'.tr(),
      'astro_include_2'.tr(),
      'astro_include_3'.tr(),
      'astro_include_4'.tr(),
      'astro_include_5'.tr(),
    ];

    return CosmicCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A1050), Color(0xFF0D0B22)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.auraAmber.withValues(alpha: 0.12),
                border: Border.all(
                    color: AppColors.auraAmber.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.lock_outline,
                  color: AppColors.auraAmber, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('astro_full_report'.tr(),
                      style: AppTextStyles.titleMedium
                          .copyWith(color: Colors.white)),
                  Text('astro_one_time'.tr(),
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.auraAmber.withValues(alpha: 0.85))),
                ],
              ),
            ),
          ]),

          const SizedBox(height: 20),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 16),

          Text('astro_whats_included'.tr(),
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textSecondary, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          ...includes.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✦',
                        style: TextStyle(
                            color: AppColors.auraAmber, fontSize: 10)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 20),

          Row(children: [
            const Icon(Icons.auto_awesome,
                color: AppColors.auraAmber, size: 15),
            const SizedBox(width: 6),
            Text('astro_balance'.tr(),
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary)),
            Text('$balance',
                style: AppTextStyles.bodySmall.copyWith(
                    color: canAfford ? AppColors.auraAmber : AppColors.error,
                    fontWeight: FontWeight.w600)),
            if (!canAfford) ...[
              const Spacer(),
              GestureDetector(
                onTap: onEarnMore,
                child: Text('astro_earn_more'.tr(),
                    style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.accentGlow,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.accentGlow)),
              ),
            ],
          ]),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: canAfford && !unlocking ? onUnlock : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: canAfford
                      ? const LinearGradient(
                          colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                        )
                      : null,
                  color: canAfford ? null : AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: unlocking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(
                        canAfford
                            ? 'astro_unlock_btn'.tr()
                            : 'astro_not_enough'.tr(),
                        style: AppTextStyles.titleMedium.copyWith(
                          color: canAfford
                              ? Colors.black
                              : AppColors.textTertiary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionLabel({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
        const SizedBox(height: 2),
        Text(subtitle, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

// ─── Planet Line Table ────────────────────────────────────────────────────────

class _PlanetLineTable extends StatelessWidget {
  const _PlanetLineTable();

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              const SizedBox(width: 44),
              Expanded(
                  child: Text('astro_col_planet'.tr(),
                      style: AppTextStyles.labelSmall
                          .copyWith(letterSpacing: 1.0))),
              Expanded(
                  child: Text('astro_col_line'.tr(),
                      style: AppTextStyles.labelSmall
                          .copyWith(letterSpacing: 1.0))),
              Expanded(
                flex: 2,
                child: Text('astro_col_theme'.tr(),
                    style: AppTextStyles.labelSmall
                        .copyWith(letterSpacing: 1.0)),
              ),
            ]),
          ),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 4),
          ..._lines.asMap().entries.map((e) {
            final line = e.value;
            final isLast = e.key == _lines.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 32,
                        decoration: BoxDecoration(
                          color: line.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(line.emoji,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(line.planet,
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                      ),
                      Expanded(
                        child: Text(line.lineType,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: line.color)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(line.theme,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.35)),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(color: AppColors.cardBorder, height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─── World Map Section ────────────────────────────────────────────────────────

class _WorldMapSection extends StatelessWidget {
  const _WorldMapSection();

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('astro_power_regions'.tr(),
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
          const SizedBox(height: 2),
          Text('astro_power_regions_sub'.tr(),
              style: AppTextStyles.bodySmall),
          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 180,
              child: LayoutBuilder(builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _MapGridPainter()),
                    ),

                    ..._lines.map((line) {
                      final x = line.mapX * constraints.maxWidth;
                      final y = line.mapY * 180;
                      return Positioned(
                        left: x - 6,
                        top: y - 6,
                        child: _MapDot(color: line.color),
                      );
                    }),

                    Positioned(left: 28,  top: 52,  child: _RegionLabel('astro_region_n_america'.tr())),
                    Positioned(left: 28,  top: 100, child: _RegionLabel('astro_region_s_america'.tr())),
                    Positioned(left: 160, top: 35,  child: _RegionLabel('astro_region_europe'.tr())),
                    Positioned(left: 148, top: 80,  child: _RegionLabel('astro_region_africa'.tr())),
                    Positioned(right: 68, top: 32,  child: _RegionLabel('astro_region_asia'.tr())),
                    Positioned(right: 16, top: 110, child: _RegionLabel('astro_region_oceania'.tr())),

                    Positioned(
                      left: 6,
                      top: 87,
                      child: Text('astro_equator'.tr(),
                          style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.22),
                              fontSize: 9)),
                    ),

                    Positioned(
                      bottom: 6,
                      right: 8,
                      child: Text(
                        'astro_interactive_coming'.tr(),
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary, fontSize: 9),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: _lines
                .map((l) => Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: l.color),
                      ),
                      const SizedBox(width: 5),
                      Text(l.planet,
                          style: AppTextStyles.bodySmall
                              .copyWith(fontSize: 10)),
                    ]))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF060E24),
    );

    // lon/lat → pixel
    Offset geo(double lon, double lat) => Offset(
          (lon + 180) / 360 * size.width,
          (90 - lat) / 180 * size.height,
        );

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.055)
      ..strokeWidth = 0.7;

    for (int i = 0; i <= 12; i++) {
      final x = size.width * i / 12;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (int i = 0; i <= 6; i++) {
      final y = size.height * i / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..strokeWidth = 1.0,
    );

    final fill = Paint()
      ..color = const Color(0xFF1A2A4A)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    void land(List<(double, double)> pts) {
      if (pts.length < 3) return;
      final path = Path()..moveTo(geo(pts[0].$1, pts[0].$2).dx, geo(pts[0].$1, pts[0].$2).dy);
      for (var i = 1; i < pts.length; i++) {
        path.lineTo(geo(pts[i].$1, pts[i].$2).dx, geo(pts[i].$1, pts[i].$2).dy);
      }
      path.close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
    }

    // ── North America ────────────────────────────────────────────────────────
    land([
      (-168, 66), (-141, 60), (-127, 50), (-124, 47),
      (-124, 37), (-117, 33), (-110, 23), (-104, 19),
      (-90, 15),  (-87, 14),  (-83,  9),
      (-81, 25),  (-80, 26),  (-80, 31),  (-75, 35),
      (-74, 40),  (-70, 42),  (-63, 45),  (-53, 47),
      (-56, 52),  (-68, 58),  (-79, 62),  (-85, 67),
      (-105, 72), (-135, 70), (-163, 68),
    ]);

    // ── Greenland ─────────────────────────────────────────────────────────────
    land([
      (-44, 83), (-18, 76), (-19, 68), (-27, 64),
      (-44, 60), (-55, 67), (-58, 76),
    ]);

    // ── South America ────────────────────────────────────────────────────────
    land([
      (-78,  8), (-63, 11), (-50,  5), (-35, -4),
      (-35,-10), (-39,-18), (-43,-23), (-49,-28),
      (-52,-33), (-58,-35), (-64,-42), (-68,-54),
      (-74,-50), (-72,-30), (-80, -3), (-80,  0),
    ]);

    // ── Europe ────────────────────────────────────────────────────────────────
    land([
      ( -9, 37), (  3, 36), (  7, 44), ( 15, 38),
      ( 18, 40), ( 26, 37), ( 30, 44), ( 30, 60),
      ( 28, 71), ( 15, 69), (  5, 58), (  8, 55),
      ( 10, 54), (  8, 47), (  5, 51), ( -2, 51),
      ( -4, 48), ( -2, 44),
    ]);

    // ── Africa ────────────────────────────────────────────────────────────────
    land([
      ( -5, 36), ( 10, 37), ( 14, 32), ( 25, 31),
      ( 33, 29), ( 37, 22), ( 43, 12), ( 51, 11),
      ( 45,-12), ( 40,-12), ( 35,-18), ( 35,-26),
      ( 19,-35), ( 17,-30), ( 12,-18), ( 12, -5),
      (  9, -1), ( 10,  1), (  8,  5), ( -1,  5),
      ( -5,  5), (-16,  5), (-17, 15), (-16, 21),
      (-13, 28),
    ]);

    // ── Asia (inc. Arabian peninsula & Indian subcontinent) ──────────────────
    land([
      ( 29, 41), ( 36, 36), ( 41, 42), ( 50, 43),
      ( 60, 43), ( 63, 40), ( 60, 35), ( 57, 22),
      ( 60, 22), ( 67, 25), ( 73, 20), ( 76, 10),
      ( 80,  8), ( 80, 14), ( 80, 20), ( 88, 22),
      ( 92, 22), ( 99, 14), (100,  5), (104,  1),
      (106, 10), (109, 21), (117, 24), (122, 30),
      (122, 37), (120, 40), (131, 43), (141, 46),
      (163, 52), (163, 60), (170, 66), (160, 70),
      (140, 70), (120, 72), (100, 70), ( 80, 73),
      ( 60, 68), ( 55, 55), ( 37, 47), ( 34, 46),
      ( 30, 44),
    ]);

    // ── Australia ─────────────────────────────────────────────────────────────
    land([
      (114,-22), (122,-18), (136,-12), (145,-14),
      (154,-28), (151,-34), (147,-39), (140,-38),
      (130,-34), (117,-34), (114,-34),
    ]);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapDot extends StatelessWidget {
  final Color color;
  const _MapDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.6),
              blurRadius: 6,
              spreadRadius: 1)
        ],
      ),
    );
  }
}

class _RegionLabel extends StatelessWidget {
  final String text;
  const _RegionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
          color: Colors.white.withValues(alpha: 0.28),
          fontSize: 9,
          letterSpacing: 0.4),
    );
  }
}

// ─── Planet Card (expandable) ─────────────────────────────────────────────────

class _PlanetCard extends StatelessWidget {
  final _Line line;
  final bool expanded;
  final VoidCallback onTap;

  const _PlanetCard({
    required this.line,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              line.color.withValues(alpha: expanded ? 0.16 : 0.10),
              line.color.withValues(alpha: expanded ? 0.06 : 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: line.color.withValues(alpha: expanded ? 0.45 : 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(line.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(line.planet,
                      style: AppTextStyles.titleMedium
                          .copyWith(color: Colors.white)),
                  Text(line.lineType,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: line.color, fontSize: 10)),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: line.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: line.color.withValues(alpha: 0.3)),
                ),
                child: Text(line.theme.split('&').first.trim(),
                    style: AppTextStyles.labelSmall
                        .copyWith(color: line.color, fontSize: 9)),
              ),
              const SizedBox(width: 8),
              Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textTertiary,
                  size: 18),
            ]),
            if (expanded) ...[
              const SizedBox(height: 12),
              Divider(color: line.color.withValues(alpha: 0.2), height: 1),
              const SizedBox(height: 12),
              Text(
                line.reading,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.80),
                    height: 1.65),
              ),
              const SizedBox(height: 10),
              Text('astro_best_for'.tr(),
                  style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary, letterSpacing: 0.8)),
              const SizedBox(height: 4),
              Text(line.bestFor,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: line.color, height: 1.4)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Destiny Compass ──────────────────────────────────────────────────────────

class _DestinyCompass extends StatelessWidget {
  const _DestinyCompass();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('astro_destiny_compass'.tr(),
            style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
        const SizedBox(height: 2),
        Text('astro_destiny_compass_sub'.tr(),
            style: AppTextStyles.bodySmall),
        const SizedBox(height: 12),
        ..._destinations.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DestinationCard(dest: d),
            )),
      ],
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final _Destination dest;
  const _DestinationCard({required this.dest});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            dest.color.withValues(alpha: 0.13),
            dest.color.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dest.color.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dest.color.withValues(alpha: 0.12),
              border: Border.all(color: dest.color.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Text(dest.emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dest.label,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: dest.color, letterSpacing: 0.8)),
                const SizedBox(height: 3),
                Text(dest.region,
                    style: AppTextStyles.titleMedium
                        .copyWith(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 6),
                Text(dest.why,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Line Types Guide ─────────────────────────────────────────────────────────

class _LineTypesGuide extends StatefulWidget {
  const _LineTypesGuide();

  @override
  State<_LineTypesGuide> createState() => _LineTypesGuideState();
}

class _LineTypesGuideState extends State<_LineTypesGuide> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('astro_line_types_title'.tr(),
                          style: AppTextStyles.titleMedium
                              .copyWith(color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('astro_line_types_sub'.tr(),
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.cardBorder, height: 1),
            const SizedBox(height: 14),
            ..._lineTypes.map((lt) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: lt.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: lt.color.withValues(alpha: 0.3)),
                        ),
                        alignment: Alignment.center,
                        child: Text(lt.symbol,
                            style: AppTextStyles.labelSmall.copyWith(
                                color: lt.color,
                                fontWeight: FontWeight.w800,
                                fontSize: 11)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lt.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                    color: lt.color,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(lt.desc,
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.55)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.textTertiary, size: 13),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('astro_lt_note'.tr(),
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                            height: 1.5)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Top Cities Section ───────────────────────────────────────────────────────

class _TopCitiesSection extends StatelessWidget {
  const _TopCitiesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          title: 'astro_cities_title'.tr(),
          subtitle: 'astro_cities_sub'.tr(),
        ),
        const SizedBox(height: 12),
        ..._cities.map((city) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CityCard(city: city),
            )),
      ],
    );
  }
}

class _CityCard extends StatelessWidget {
  final _City city;
  const _CityCard({required this.city});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            city.color.withValues(alpha: 0.12),
            city.color.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: city.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: city.color.withValues(alpha: 0.12),
              border: Border.all(color: city.color.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Text(city.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(city.name,
                        style: AppTextStyles.titleMedium
                            .copyWith(color: Colors.white, fontSize: 15)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('· ${city.country}',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textTertiary),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: city.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: city.color.withValues(alpha: 0.35)),
                      ),
                      child: Text(city.line,
                          style: AppTextStyles.labelSmall.copyWith(
                              color: city.color,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(city.reason,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary, height: 1.55)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Parans Section ───────────────────────────────────────────────────────────

class _ParansSection extends StatelessWidget {
  const _ParansSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          title: 'astro_parans_title'.tr(),
          subtitle: 'astro_parans_sub'.tr(),
        ),
        const SizedBox(height: 12),
        ..._parans.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ParanCard(paran: p),
            )),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.auraViolet.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.auraViolet.withValues(alpha: 0.20)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✦',
                  style: TextStyle(
                      color: AppColors.auraViolet, fontSize: 11)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('astro_parans_note'.tr(),
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.auraViolet.withValues(alpha: 0.85),
                        fontSize: 11,
                        height: 1.5)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ParanCard extends StatelessWidget {
  final _Paran paran;
  const _ParanCard({required this.paran});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            paran.color1.withValues(alpha: 0.10),
            paran.color2.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: paran.color1.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: paran.color1.withValues(alpha: 0.12),
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(20)),
                  border:
                      Border.all(color: paran.color1.withValues(alpha: 0.3)),
                ),
                child: Text(paran.emoji1,
                    style: const TextStyle(fontSize: 16)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: paran.color2.withValues(alpha: 0.12),
                  borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(20)),
                  border:
                      Border.all(color: paran.color2.withValues(alpha: 0.3)),
                ),
                child: Text(paran.emoji2,
                    style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(paran.theme,
                        style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white, fontSize: 14)),
                    Text('${paran.city} · ${paran.country}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10)),
                ),
                child: Text('PARAN',
                    style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 8,
                        letterSpacing: 1.2)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
              color: paran.color1.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 12),
          Text(paran.meaning,
              style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.80),
                  height: 1.65)),
        ],
      ),
    );
  }
}

// ─── Current Location Section ─────────────────────────────────────────────────

class _CurrentLocationSection extends StatelessWidget {
  final String? birthCity;
  const _CurrentLocationSection({this.birthCity});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          title: 'astro_current_title'.tr(),
          subtitle: 'astro_current_sub'.tr(),
        ),
        const SizedBox(height: 12),
        CosmicCard(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0E1A38), Color(0xFF0A0E20)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('🏠', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    birthCity != null
                        ? 'astro_current_born_in'
                            .tr(namedArgs: {'city': birthCity!})
                        : 'astro_current_no_city'.tr(),
                    style: AppTextStyles.titleMedium
                        .copyWith(color: Colors.white),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              const Divider(color: AppColors.cardBorder, height: 1),
              const SizedBox(height: 14),
              Text('astro_current_para1'.tr(),
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.80),
                      height: 1.65)),
              const SizedBox(height: 12),
              Text('astro_current_para2'.tr(),
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.80),
                      height: 1.65)),
              const SizedBox(height: 12),
              Text('astro_current_para3'.tr(),
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.80),
                      height: 1.65)),
              const SizedBox(height: 20),
              Text('astro_current_activation_title'.tr(),
                  style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary, letterSpacing: 1.0)),
              const SizedBox(height: 2),
              Text('astro_current_activation_sub'.tr(),
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textTertiary, fontSize: 11)),
              const SizedBox(height: 12),
              _ActivationZoneRow(
                range: 'astro_current_zone_1'.tr(),
                label: 'astro_current_zone_1_label'.tr(),
                strength: 1.0,
                color: AppColors.auraAmber,
              ),
              _ActivationZoneRow(
                range: 'astro_current_zone_2'.tr(),
                label: 'astro_current_zone_2_label'.tr(),
                strength: 0.65,
                color: AppColors.auraEmerald,
              ),
              _ActivationZoneRow(
                range: 'astro_current_zone_3'.tr(),
                label: 'astro_current_zone_3_label'.tr(),
                strength: 0.35,
                color: AppColors.accentGlow,
              ),
              _ActivationZoneRow(
                range: 'astro_current_zone_4'.tr(),
                label: 'astro_current_zone_4_label'.tr(),
                strength: 0.08,
                color: AppColors.auraViolet,
                isLast: true,
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentGlow.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.accentGlow.withValues(alpha: 0.20)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🌍', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('astro_current_tip'.tr(),
                          style: AppTextStyles.bodySmall.copyWith(
                              color:
                                  AppColors.accentGlow.withValues(alpha: 0.85),
                              height: 1.5)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivationZoneRow extends StatelessWidget {
  final String range;
  final String label;
  final double strength;
  final Color color;
  final bool isLast;

  const _ActivationZoneRow({
    required this.range,
    required this.label,
    required this.strength,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(range,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textTertiary, fontSize: 11)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: strength,
                    backgroundColor: AppColors.cardBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(label,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: color, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
