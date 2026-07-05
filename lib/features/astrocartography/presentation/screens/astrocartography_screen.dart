import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../../core/widgets/viral_story_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../domain/entities/astrocartography_lines.dart';
import '../../domain/entities/power_city.dart';
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
  final String translationKey; // fallback static-content key
  final Color color1;
  final Color color2;
  final String planetKeyA; // real _Line.translationKey, e.g. 'jupiter'
  final String planetKeyB;

  const _Paran({
    required this.emoji1,
    required this.emoji2,
    required this.translationKey,
    required this.color1,
    required this.color2,
    required this.planetKeyA,
    required this.planetKeyB,
  });

  String get city    => 'astro_paran_${translationKey}_city'.tr();
  String get country => 'astro_paran_${translationKey}_country'.tr();
  String get theme   => 'astro_paran_${translationKey}_theme'.tr();
  String get meaning => 'astro_paran_${translationKey}_meaning'.tr();
}

const _parans = [
  _Paran(emoji1: '♃', emoji2: '♀',  translationKey: 'barcelona', color1: AppColors.auraEmerald, color2: AppColors.auraRose,   planetKeyA: 'jupiter', planetKeyB: 'venus'),
  _Paran(emoji1: '☀️', emoji2: '🌙', translationKey: 'capetown',  color1: AppColors.auraAmber,   color2: AppColors.accentGlow, planetKeyA: 'sun',     planetKeyB: 'moon'),
  _Paran(emoji1: '♅', emoji2: '♄',  translationKey: 'seoul',     color1: AppColors.auraTeal,    color2: AppColors.auraIndigo, planetKeyA: 'uranus',  planetKeyB: 'saturn'),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class AstrocartographyScreen extends ConsumerStatefulWidget {
  /// When set, shows the report as it was for a past unlocked birth-data
  /// version instead of the current one — reached from the Unlock History
  /// screen. Read-only: bypasses the unlock gate entirely.
  final String? historicalBirthCity;
  final bool isHistorical;

  /// When set, this screen unlocks/renders Astrocartography for a saved
  /// Loved One instead of the current user — [lovedOneName] is used for
  /// personalized copy (PDF/story headline), and [lovedOneBirthDate]/
  /// [lovedOneBirthTime] feed the real astrocartography line calculation
  /// (their birth city comes via [historicalBirthCity]).
  final String? lovedOneId;
  final String? lovedOneName;
  final DateTime? lovedOneBirthDate;
  final String? lovedOneBirthTime;
  final double? lovedOneBirthLat;
  final double? lovedOneBirthLng;

  const AstrocartographyScreen({
    super.key,
    this.historicalBirthCity,
    this.isHistorical = false,
    this.lovedOneId,
    this.lovedOneName,
    this.lovedOneBirthDate,
    this.lovedOneBirthTime,
    this.lovedOneBirthLat,
    this.lovedOneBirthLng,
  });

  @override
  ConsumerState<AstrocartographyScreen> createState() =>
      _AstrocartographyScreenState();
}

class _AstrocartographyScreenState
    extends ConsumerState<AstrocartographyScreen> {
  bool _unlocking = false;
  bool _exportingPdf = false;
  bool _exportingStory = false;
  int? _expandedIndex;

  Future<void> _handleUnlock() async {
    setState(() => _unlocking = true);
    HapticUtils.medium();
    final error = await ref
        .read(astrocartographyProvider(widget.lovedOneId).notifier)
        .unlock();
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

  Future<void> _exportPdf(String? birthCity, AstrocartographyLines? lines) async {
    setState(() => _exportingPdf = true);
    try {
      final regular = await PdfGoogleFonts.nunitoRegular();
      final bold = await PdfGoogleFonts.nunitoBold();
      final doc = _buildPdf(regular: regular, bold: bold, birthCity: birthCity, lines: lines);
      final bytes = await doc.save();
      await Printing.sharePdf(bytes: bytes, filename: 'Cosmira_Astrocartography.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('astro_pdf_error'.tr())),
        );
      }
    } finally {
      if (mounted) setState(() => _exportingPdf = false);
    }
  }

  Widget _buildStoryCard(String? birthCity, AstrocartographyLines? lines) {
    final computedTop = lines != null ? topCitiesFor(lines, count: 3) : null;
    final headline = widget.lovedOneName != null
        ? 'astro_story_title_gift'.tr(namedArgs: {'name': widget.lovedOneName!})
        : 'astro_story_title'.tr();

    List<StoryStat> stats;
    String quotable;
    if (computedTop != null && computedTop.isNotEmpty) {
      stats = [
        for (final m in computedTop)
          StoryStat(
            emoji: _lineFor(m.planetKey)?.emoji ?? '✦',
            value: m.match.city.name,
            label: m.match.city.country,
          ),
      ];
      final top = computedTop.first;
      final topLine = _lineFor(top.planetKey);
      quotable = storyHook(topLine != null
          ? 'astro_city_match_reason'.tr(namedArgs: {
              'city': top.match.city.name,
              'country': top.match.city.country,
              'planet': topLine.planet,
              'symbol': _lineTypeSymbol(top.match.lineType),
              'theme': topLine.theme,
              'bestFor': topLine.bestFor,
            })
          : top.match.city.name);
    } else {
      final topCities = _cities.take(3).toList();
      stats = [
        for (final c in topCities)
          StoryStat(emoji: c.emoji, value: c.name, label: c.country),
      ];
      quotable = storyHook(_cities.first.reason);
    }

    return ViralStoryCard(
      eyebrow: '✦  C O S M I R A  ✦',
      headline: headline,
      accentColor: const Color(0xFF0EA5E9),
      stats: stats,
      quotableLine: quotable,
    );
  }

  Future<void> _exportStory(String? birthCity, AstrocartographyLines? lines) async {
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      _showStoryPreview(birthCity, lines);
      return;
    }
    setState(() => _exportingStory = true);
    try {
      final controller = ScreenshotController();
      final imageBytes = await controller.captureFromWidget(
        _buildStoryCard(birthCity, lines),
        pixelRatio: 3.0,
        targetSize: const Size(360, 640),
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/cosmira_astro_story.png');
      await file.writeAsBytes(imageBytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'My Power Places ✦ cosmira.app',
      );
    } finally {
      if (mounted) setState(() => _exportingStory = false);
    }
  }

  void _showStoryPreview(String? birthCity, AstrocartographyLines? lines) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _buildStoryCard(birthCity, lines),
            ),
            Positioned(
              top: -14,
              right: -14,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Document _buildPdf({
    required pw.Font regular,
    required pw.Font bold,
    required String? birthCity,
    required AstrocartographyLines? lines,
  }) {
    final doc = pw.Document();
    final headerStyle = pw.TextStyle(font: bold, fontSize: 22);
    final sectionStyle = pw.TextStyle(font: bold, fontSize: 14);
    final bodyStyle = pw.TextStyle(font: regular, fontSize: 11);
    final accentColor = PdfColor.fromInt(0xFFFBBF24);

    pw.Widget section(String title, List<pw.Widget> children) =>
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.SizedBox(height: 18),
          pw.Text(title, style: sectionStyle.copyWith(color: accentColor)),
          pw.Divider(color: accentColor, thickness: 0.5),
          pw.SizedBox(height: 8),
          ...children,
        ]);

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('Generated by Cosmira',
            style: pw.TextStyle(font: regular, fontSize: 9, color: PdfColors.grey)),
      ),
      build: (ctx) => [
        pw.Center(
          child: pw.Column(children: [
            pw.Text('COSMIRA',
                style: pw.TextStyle(font: bold, fontSize: 11, color: accentColor)),
            pw.SizedBox(height: 8),
            pw.Text('astro_title'.tr(), style: headerStyle),
            if (birthCity != null) ...[
              pw.SizedBox(height: 4),
              pw.Text(birthCity,
                  style: pw.TextStyle(font: regular, fontSize: 12, color: PdfColors.grey600)),
            ],
            pw.SizedBox(height: 20),
            pw.Divider(),
          ]),
        ),
        section('astro_planetary_lines'.tr(), [
          ..._lines.map((l) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Text('${l.planet} — ${l.lineType}: ${l.theme}', style: bodyStyle),
              )),
        ]),
        section('astro_cities_title'.tr(), [
          if (lines != null)
            for (final m in topCitiesFor(lines))
              if (_lineFor(m.planetKey) case final line?)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Text(
                      '${m.match.city.name}, ${m.match.city.country} (${line.planet} ${_lineTypeSymbol(m.match.lineType)}) — '
                      '${'astro_city_match_reason'.tr(namedArgs: {
                        'city': m.match.city.name,
                        'country': m.match.city.country,
                        'planet': line.planet,
                        'symbol': _lineTypeSymbol(m.match.lineType),
                        'theme': line.theme,
                        'bestFor': line.bestFor,
                      })}',
                      style: bodyStyle),
                )
          else
            ..._cities.map((c) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Text('${c.name}, ${c.country} (${c.line}) — ${c.reason}', style: bodyStyle),
                )),
        ]),
        section('astro_parans_title'.tr(), [
          ..._parans.map((p) {
            final match = lines != null
                ? paranMatchFor(lines, planetKeyA: p.planetKeyA, planetKeyB: p.planetKeyB)
                : null;
            final lineA = _lineFor(p.planetKeyA);
            final lineB = _lineFor(p.planetKeyB);
            if (match != null && lineA != null && lineB != null) {
              final theme = 'astro_paran_match_theme'.tr(namedArgs: {
                'themeA': lineA.theme,
                'themeB': lineB.theme,
              });
              final meaning = 'astro_paran_match_meaning'.tr(namedArgs: {
                'planetA': lineA.planet,
                'symbolA': _lineTypeSymbol(match.lineTypeA),
                'planetB': lineB.planet,
                'symbolB': _lineTypeSymbol(match.lineTypeB),
                'city': match.city.city.name,
                'country': match.city.city.country,
              });
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Text(
                    '${match.city.city.name}, ${match.city.city.country} — $theme: $meaning',
                    style: bodyStyle),
              );
            }
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Text('${p.city}, ${p.country} — ${p.theme}: ${p.meaning}', style: bodyStyle),
            );
          }),
        ]),
        section('astro_destiny_compass'.tr(), [
          ..._destinations.map((d) {
            final match = lines != null
                ? destinyMatchFor(lines,
                    planetKeys: _destinyPlanetKeys[d.translationKey] ?? const [])
                : null;
            final line = match != null ? _lineFor(match.planetKey) : null;
            if (match != null && line != null) {
              final why = 'astro_dest_match_reason'.tr(namedArgs: {
                'planet': line.planet,
                'symbol': _lineTypeSymbol(match.match.lineType),
                'city': match.match.city.name,
                'country': match.match.city.country,
                'theme': line.theme,
              });
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Text(
                    '${d.label} — ${match.match.city.name}, ${match.match.city.country}: $why',
                    style: bodyStyle),
              );
            }
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Text('${d.label} — ${d.region}: ${d.why}', style: bodyStyle),
            );
          }),
        ]),
      ],
    ));

    return doc;
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final balance = ref.watch(stardustBalanceProvider).valueOrNull ?? 0;
    final astroState = ref.watch(astrocartographyProvider(widget.lovedOneId));
    final isUnlocked =
        widget.isHistorical || astroState.status == AstrocartographyStatus.unlocked;
    final isLoading =
        !widget.isHistorical && astroState.status == AstrocartographyStatus.loading;
    // For a Loved One, the caller passes their birth city via
    // historicalBirthCity too (it's already "an explicit city override"
    // regardless of whether the reason is history or a different person).
    final birthCity = widget.historicalBirthCity ?? profile?.birthCity;
    final birthDate = widget.lovedOneId != null ? widget.lovedOneBirthDate : profile?.birthDate;
    final birthTime = widget.lovedOneId != null ? widget.lovedOneBirthTime : profile?.birthTime;
    final subjectLat = widget.lovedOneId != null ? widget.lovedOneBirthLat : profile?.birthLat;
    final subjectLng = widget.lovedOneId != null ? widget.lovedOneBirthLng : profile?.birthLng;

    // Only fetch once unlocked — no need to compute real lines for a locked
    // paywall view.
    final linesAsync = isUnlocked
        ? ref.watch(astrocartographyLinesProvider((
            lovedOneId: widget.lovedOneId,
            birthDate: birthDate,
            birthTime: birthTime,
            birthCity: birthCity,
          )))
        : const AsyncValue<AstrocartographyLines?>.data(null);
    final lines = linesAsync.valueOrNull;

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
                      Expanded(
                        child: Text('astro_title'.tr(),
                            style: AppTextStyles.headlineSmall),
                      ),
                      if (!widget.isHistorical && widget.lovedOneId == null)
                        IconButton(
                          icon: const Icon(Icons.history_rounded,
                              color: AppColors.textPrimary),
                          tooltip: 'astro_history'.tr(),
                          onPressed: () =>
                              context.push('/astrocartography/history'),
                        ),
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
                      if (widget.isHistorical)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.auraAmber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.auraAmber.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.history_rounded,
                                    color: AppColors.auraAmber, size: 16),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    birthCity != null
                                        ? 'astro_history_city'.tr(namedArgs: {'city': birthCity})
                                        : 'astro_history_city_unknown'.tr(),
                                    style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.auraAmber.withValues(alpha: 0.9)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      _SummarySection(birthCity: birthCity)
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
                          isRecharge: widget.lovedOneId == null &&
                              (profile?.birthDataVersion ?? 0) > 0,
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
                        _WorldMapSection(lines: lines)
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
                              closestLineTypeKey: closestLineTypeKey(
                                lines?.forPlanet(_lines[i].translationKey),
                                subjectLat: subjectLat,
                                subjectLng: subjectLng,
                              ),
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
                        _DestinyCompass(lines: lines)
                            .animate()
                            .fadeIn(delay: 200.ms),
                        const SizedBox(height: 20),
                        _TopCitiesSection(lines: lines)
                            .animate()
                            .fadeIn(delay: 220.ms),
                        const SizedBox(height: 20),
                        _ParansSection(lines: lines)
                            .animate()
                            .fadeIn(delay: 240.ms),
                        const SizedBox(height: 20),
                        _CurrentLocationSection(birthCity: birthCity)
                            .animate()
                            .fadeIn(delay: 260.ms),
                        const SizedBox(height: 24),
                        _ExportBar(
                          exportingPdf: _exportingPdf,
                          exportingStory: _exportingStory,
                          onPdf: () => _exportPdf(birthCity, lines),
                          onStory: () => _exportStory(birthCity, lines),
                        ).animate().fadeIn(delay: 280.ms),
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

// ─── Save as PDF button ───────────────────────────────────────────────────────

class _ExportBar extends StatelessWidget {
  final bool exportingPdf;
  final bool exportingStory;
  final VoidCallback onPdf;
  final VoidCallback onStory;

  const _ExportBar({
    required this.exportingPdf,
    required this.exportingStory,
    required this.onPdf,
    required this.onStory,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ExportButton(
            label: 'astro_save_pdf'.tr(),
            icon: Icons.picture_as_pdf_rounded,
            color: AppColors.auraViolet,
            isLoading: exportingPdf,
            onTap: onPdf,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ExportButton(
            label: 'astro_share_story'.tr(),
            icon: Icons.share_rounded,
            color: const Color(0xFF0EA5E9),
            isLoading: exportingStory,
            onTap: onStory,
          ),
        ),
      ],
    );
  }
}

class _ExportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ExportButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: color, strokeWidth: 2),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      style: AppTextStyles.labelLarge.copyWith(color: color),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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
  final bool isRecharge;
  final VoidCallback onUnlock;
  final VoidCallback onEarnMore;

  const _UnlockGate({
    required this.balance,
    required this.unlocking,
    required this.isRecharge,
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('astro_one_time'.tr(),
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.auraAmber.withValues(alpha: 0.85))),
                      const SizedBox(width: 3),
                      Icon(Icons.auto_awesome,
                          color: AppColors.auraAmber.withValues(alpha: 0.85),
                          size: 11),
                    ],
                  ),
                ],
              ),
            ),
          ]),

          if (isRecharge) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.auraAmber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.auraAmber.withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.auraAmber, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'astro_recharge_notice'.tr(),
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.auraAmber.withValues(alpha: 0.85),
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],

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
            Text('astro_balance'.tr(),
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary)),
            Text('$balance',
                style: AppTextStyles.bodySmall.copyWith(
                    color: canAfford ? AppColors.auraAmber : AppColors.error,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Icon(Icons.auto_awesome,
                color: canAfford ? AppColors.auraAmber : AppColors.error,
                size: 12),
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
                    : canAfford
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'astro_unlock_btn'.tr(),
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.auto_awesome,
                                  color: Colors.black, size: 14),
                            ],
                          )
                        : Text(
                            'astro_not_enough'.tr(),
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.textTertiary,
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
  final AstrocartographyLines? lines;
  const _WorldMapSection({required this.lines});

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
                      child: CustomPaint(painter: _MapGridPainter(lines: lines)),
                    ),

                    // Fallback placeholder dots while real lines are still
                    // loading (first-ever unlock, before the cache is warm).
                    if (lines == null)
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
                        lines == null
                            ? 'astro_interactive_coming'.tr()
                            : 'astro_lines_computed'.tr(),
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

/// Converts a longitude normalized to [0, 360) (the edge function's
/// canonical output) to the signed [-180, 180) form the hand-drawn
/// continent outlines and pixel projection below use.
double _signedLon(double lon) {
  var n = lon % 360;
  if (n < 0) n += 360;
  return n > 180 ? n - 360 : n;
}

/// Shortest angular distance between two longitudes, in degrees.
double _lonDiff(double a, double b) {
  final d = (_signedLon(a) - _signedLon(b)).abs();
  return d > 180 ? 360 - d : d;
}

/// Determines which of a planet's 4 real line types (AC/DC/MC/IC) passes
/// closest to the subject's own birth coordinates — this is what makes the
/// planet card's badge genuinely different between two different people,
/// without needing new per-line-type copy (see migration 019 / plan notes).
String? closestLineTypeKey(
  PlanetLine? line, {
  required double? subjectLat,
  required double? subjectLng,
}) {
  if (line == null || subjectLat == null || subjectLng == null) return null;

  var bestKey = 'mc';
  var bestDiff = _lonDiff(line.mcLon, subjectLng);

  final icDiff = _lonDiff(line.icLon, subjectLng);
  if (icDiff < bestDiff) {
    bestKey = 'ic';
    bestDiff = icDiff;
  }

  (double, double)? nearestByLat(List<(double, double)> pts) {
    if (pts.isEmpty) return null;
    return pts.reduce(
        (a, b) => (a.$1 - subjectLat).abs() < (b.$1 - subjectLat).abs() ? a : b);
  }

  final ac = nearestByLat(line.ac);
  if (ac != null) {
    final d = _lonDiff(ac.$2, subjectLng);
    if (d < bestDiff) {
      bestKey = 'ac';
      bestDiff = d;
    }
  }
  final dc = nearestByLat(line.dc);
  if (dc != null) {
    final d = _lonDiff(dc.$2, subjectLng);
    if (d < bestDiff) {
      bestKey = 'dc';
      bestDiff = d;
    }
  }

  return bestKey;
}

class _MapGridPainter extends CustomPainter {
  final AstrocartographyLines? lines;
  const _MapGridPainter({this.lines});

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

    // ── Real, computed planet lines (MC/IC meridians + AC/DC curves) ────────
    final computedLines = lines;
    if (computedLines != null) {
      Offset signedGeo(double lon, double lat) => geo(_signedLon(lon), lat);

      void drawMeridian(double lonDeg, Color color) {
        final x = signedGeo(lonDeg, 0).dx;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          Paint()
            ..color = color.withValues(alpha: 0.5)
            ..strokeWidth = 1.2,
        );
      }

      void drawCurve(List<(double, double)> points, Color color) {
        if (points.isEmpty) return;
        final path = Path();
        double? lastSignedLon;
        for (final (lat, lon) in points) {
          final signed = _signedLon(lon);
          final pt = signedGeo(lon, lat);
          if (lastSignedLon == null || (signed - lastSignedLon).abs() > 180) {
            path.moveTo(pt.dx, pt.dy);
          } else {
            path.lineTo(pt.dx, pt.dy);
          }
          lastSignedLon = signed;
        }
        canvas.drawPath(
          path,
          Paint()
            ..color = color.withValues(alpha: 0.8)
            ..strokeWidth = 1.4
            ..style = PaintingStyle.stroke,
        );
      }

      for (final line in _lines) {
        final planetLine = computedLines.forPlanet(line.translationKey);
        if (planetLine == null) continue;
        drawMeridian(planetLine.mcLon, line.color);
        drawMeridian(planetLine.icLon, line.color);
        drawCurve(planetLine.ac, line.color);
        drawCurve(planetLine.dc, line.color);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) => oldDelegate.lines != lines;
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

  /// Which of this planet's 4 real line types (ac/dc/mc/ic) passes closest
  /// to the subject's own birth coordinates — null while lines are still
  /// loading, in which case we fall back to [_Line.lineType]'s static copy.
  final String? closestLineTypeKey;

  const _PlanetCard({
    required this.line,
    required this.expanded,
    required this.onTap,
    this.closestLineTypeKey,
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
                  Text(
                      closestLineTypeKey != null
                          ? 'astro_lt_${closestLineTypeKey!}_name'.tr()
                          : line.lineType,
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

/// Traditional astrocartography significators per Destiny Compass theme —
/// career favors public-achievement planets on their MC; love/home favor
/// the relationship/roots planets. See power_city.dart for the matching.
const _destinyPlanetKeys = {
  'career': ['sun', 'saturn', 'jupiter', 'mars'],
  'love': ['venus', 'moon'],
  'home': ['moon', 'venus'],
};

class _DestinyCompass extends StatelessWidget {
  final AstrocartographyLines? lines;
  const _DestinyCompass({required this.lines});

  @override
  Widget build(BuildContext context) {
    final computedLines = lines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('astro_destiny_compass'.tr(),
            style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
        const SizedBox(height: 2),
        Text('astro_destiny_compass_sub'.tr(),
            style: AppTextStyles.bodySmall),
        const SizedBox(height: 12),
        ..._destinations.map((d) {
          final match = computedLines != null
              ? destinyMatchFor(computedLines,
                  planetKeys: _destinyPlanetKeys[d.translationKey] ?? const [])
              : null;
          final line = match != null ? _lineFor(match.planetKey) : null;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: (match != null && line != null)
                ? _DestinationCard(
                    label: d.label,
                    emoji: d.emoji,
                    color: d.color,
                    region: '${match.match.city.name}, ${match.match.city.country}',
                    why: 'astro_dest_match_reason'.tr(namedArgs: {
                      'planet': line.planet,
                      'symbol': _lineTypeSymbol(match.match.lineType),
                      'city': match.match.city.name,
                      'country': match.match.city.country,
                      'theme': line.theme,
                    }),
                  )
                : _DestinationCard(
                    label: d.label,
                    emoji: d.emoji,
                    color: d.color,
                    region: d.region,
                    why: d.why,
                  ),
          );
        }),
      ],
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final String region;
  final String why;

  const _DestinationCard({
    required this.label,
    required this.emoji,
    required this.color,
    required this.region,
    required this.why,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.13),
            color.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: color, letterSpacing: 0.8)),
                const SizedBox(height: 3),
                Text(region,
                    style: AppTextStyles.titleMedium
                        .copyWith(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 6),
                Text(why,
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

String _lineTypeSymbol(LineTypeKey key) => switch (key) {
      LineTypeKey.ac => 'AC',
      LineTypeKey.dc => 'DC',
      LineTypeKey.mc => 'MC',
      LineTypeKey.ic => 'IC',
    };

_Line? _lineFor(String planetKey) {
  for (final l in _lines) {
    if (l.translationKey == planetKey) return l;
  }
  return null;
}

class _TopCitiesSection extends StatelessWidget {
  final AstrocartographyLines? lines;
  const _TopCitiesSection({required this.lines});

  @override
  Widget build(BuildContext context) {
    final computedLines = lines;
    final matches = computedLines != null ? topCitiesFor(computedLines) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          title: 'astro_cities_title'.tr(),
          subtitle: 'astro_cities_sub'.tr(),
        ),
        const SizedBox(height: 12),
        if (matches != null)
          ...matches.map((m) {
            final line = _lineFor(m.planetKey);
            if (line == null) return const SizedBox.shrink();
            final symbol = _lineTypeSymbol(m.match.lineType);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CityCard(
                emoji: line.emoji,
                color: line.color,
                name: m.match.city.name,
                country: m.match.city.country,
                badge: '${line.planet} $symbol',
                reason: 'astro_city_match_reason'.tr(namedArgs: {
                  'city': m.match.city.name,
                  'country': m.match.city.country,
                  'planet': line.planet,
                  'symbol': symbol,
                  'theme': line.theme,
                  'bestFor': line.bestFor,
                }),
              ),
            );
          })
        else
          ..._cities.map((city) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _CityCard(
                  emoji: city.emoji,
                  color: city.color,
                  name: city.name,
                  country: city.country,
                  badge: city.line,
                  reason: city.reason,
                ),
              )),
      ],
    );
  }
}

class _CityCard extends StatelessWidget {
  final String emoji;
  final Color color;
  final String name;
  final String country;
  final String badge;
  final String reason;

  const _CityCard({
    required this.emoji,
    required this.color,
    required this.name,
    required this.country,
    required this.badge,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name,
                        style: AppTextStyles.titleMedium
                            .copyWith(color: Colors.white, fontSize: 15)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('· $country',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textTertiary),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: color.withValues(alpha: 0.35)),
                      ),
                      child: Text(badge,
                          style: AppTextStyles.labelSmall.copyWith(
                              color: color,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(reason,
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
  final AstrocartographyLines? lines;
  const _ParansSection({required this.lines});

  @override
  Widget build(BuildContext context) {
    final computedLines = lines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          title: 'astro_parans_title'.tr(),
          subtitle: 'astro_parans_sub'.tr(),
        ),
        const SizedBox(height: 12),
        ..._parans.map((p) {
          final match = computedLines != null
              ? paranMatchFor(computedLines,
                  planetKeyA: p.planetKeyA, planetKeyB: p.planetKeyB)
              : null;
          final lineA = _lineFor(p.planetKeyA);
          final lineB = _lineFor(p.planetKeyB);

          final card = (match != null && lineA != null && lineB != null)
              ? _ParanCard(
                  emoji1: p.emoji1,
                  emoji2: p.emoji2,
                  color1: p.color1,
                  color2: p.color2,
                  theme: 'astro_paran_match_theme'.tr(namedArgs: {
                    'themeA': lineA.theme,
                    'themeB': lineB.theme,
                  }),
                  city: match.city.city.name,
                  country: match.city.city.country,
                  meaning: 'astro_paran_match_meaning'.tr(namedArgs: {
                    'planetA': lineA.planet,
                    'symbolA': _lineTypeSymbol(match.lineTypeA),
                    'planetB': lineB.planet,
                    'symbolB': _lineTypeSymbol(match.lineTypeB),
                    'city': match.city.city.name,
                    'country': match.city.city.country,
                  }),
                )
              : _ParanCard(
                  emoji1: p.emoji1,
                  emoji2: p.emoji2,
                  color1: p.color1,
                  color2: p.color2,
                  theme: p.theme,
                  city: p.city,
                  country: p.country,
                  meaning: p.meaning,
                );

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: card,
          );
        }),
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
  final String emoji1;
  final String emoji2;
  final Color color1;
  final Color color2;
  final String theme;
  final String city;
  final String country;
  final String meaning;

  const _ParanCard({
    required this.emoji1,
    required this.emoji2,
    required this.color1,
    required this.color2,
    required this.theme,
    required this.city,
    required this.country,
    required this.meaning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color1.withValues(alpha: 0.10),
            color2.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color1.withValues(alpha: 0.28)),
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
                  color: color1.withValues(alpha: 0.12),
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(20)),
                  border:
                      Border.all(color: color1.withValues(alpha: 0.3)),
                ),
                child: Text(emoji1,
                    style: const TextStyle(fontSize: 16)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color2.withValues(alpha: 0.12),
                  borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(20)),
                  border:
                      Border.all(color: color2.withValues(alpha: 0.3)),
                ),
                child: Text(emoji2,
                    style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(theme,
                        style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white, fontSize: 14)),
                    Text('$city · $country',
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
              color: color1.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 12),
          Text(meaning,
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
