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
  _Line(emoji: '♃',  translationKey: 'jupiter', color: AppColors.auraEmerald, mapX: 0.62, mapY: 0.45),
  _Line(emoji: '♄',  translationKey: 'saturn',  color: AppColors.auraIndigo,  mapX: 0.36, mapY: 0.28),
  _Line(emoji: '♅',  translationKey: 'uranus',  color: AppColors.auraTeal,    mapX: 0.72, mapY: 0.36),
  _Line(emoji: '♆',  translationKey: 'neptune', color: AppColors.auraViolet,  mapX: 0.27, mapY: 0.58),
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
              const Text('✦',
                  style: TextStyle(color: AppColors.auraAmber, fontSize: 13)),
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
            Text('$balance ✦',
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

    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.055)
      ..strokeWidth = 0.7;

    for (int i = 0; i <= 12; i++) {
      final x = size.width * i / 12;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (int i = 0; i <= 6; i++) {
      final y = size.height * i / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..strokeWidth = 1.0,
    );

    _drawContinent(canvas, size, _europeAfrica(size));
    _drawContinent(canvas, size, _americas(size));
    _drawContinent(canvas, size, _asia(size));
    _drawContinent(canvas, size, _oceania(size));
  }

  void _drawContinent(Canvas canvas, Size s, List<Offset> pts) {
    if (pts.isEmpty) return;
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path,
        Paint()
          ..color = const Color(0xFF1A2A4A)
          ..style = PaintingStyle.fill);
    canvas.drawPath(path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.07)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8);
  }

  List<Offset> _europeAfrica(Size s) => [
        Offset(s.width * 0.44, s.height * 0.10),
        Offset(s.width * 0.56, s.height * 0.10),
        Offset(s.width * 0.58, s.height * 0.45),
        Offset(s.width * 0.54, s.height * 0.82),
        Offset(s.width * 0.46, s.height * 0.82),
        Offset(s.width * 0.42, s.height * 0.45),
      ];

  List<Offset> _americas(Size s) => [
        Offset(s.width * 0.08, s.height * 0.12),
        Offset(s.width * 0.28, s.height * 0.12),
        Offset(s.width * 0.30, s.height * 0.55),
        Offset(s.width * 0.22, s.height * 0.90),
        Offset(s.width * 0.16, s.height * 0.90),
        Offset(s.width * 0.06, s.height * 0.55),
      ];

  List<Offset> _asia(Size s) => [
        Offset(s.width * 0.58, s.height * 0.08),
        Offset(s.width * 0.94, s.height * 0.08),
        Offset(s.width * 0.96, s.height * 0.60),
        Offset(s.width * 0.78, s.height * 0.65),
        Offset(s.width * 0.60, s.height * 0.48),
      ];

  List<Offset> _oceania(Size s) => [
        Offset(s.width * 0.76, s.height * 0.68),
        Offset(s.width * 0.92, s.height * 0.68),
        Offset(s.width * 0.94, s.height * 0.90),
        Offset(s.width * 0.74, s.height * 0.90),
      ];

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
