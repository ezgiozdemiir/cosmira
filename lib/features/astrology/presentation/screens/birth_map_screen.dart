import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/birth_map.dart';
import '../providers/birth_map_provider.dart';

class BirthMapScreen extends ConsumerWidget {
  const BirthMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapAsync = ref.watch(birthMapProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: mapAsync.when(
          loading: () => _CosmicLoadingView(),
          error: (_, __) => _buildError(context),
          data: (map) => map == null
              ? _buildNotPurchased(context)
              : _BirthMapContent(map: map, profile: profile),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) => SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.auraRose, size: 48),
              const SizedBox(height: 16),
              const Text('Could not load your Birth Map',
                  style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      );

  Widget _buildNotPurchased(BuildContext context) => SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('✦', style: TextStyle(fontSize: 40, color: AppColors.auraAmber)),
                const SizedBox(height: 16),
                const Text('Birth Map not found',
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Return to your Natal Chart to discover your Cosmic Fingerprint.',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go back'),
                ),
              ],
            ),
          ),
        ),
      );
}

// ---------------------------------------------------------------------------
// Loading view
// ---------------------------------------------------------------------------

class _CosmicLoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const ShimmerLoading(height: 280),
            const SizedBox(height: 24),
            const ShimmerLoading(height: 20, width: 160),
            const SizedBox(height: 12),
            const ShimmerLoading(height: 140),
            const SizedBox(height: 24),
            const ShimmerLoading(height: 20, width: 200),
            const SizedBox(height: 12),
            const ShimmerLoading(height: 180),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main scrollable content
// ---------------------------------------------------------------------------

class _BirthMapContent extends ConsumerWidget {
  final BirthMap map;
  final dynamic profile;

  const _BirthMapContent({required this.map, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sunSign = profile?.sunSign ?? '';
    final moonSign = profile?.moonSign ?? '';
    final risingSign = profile?.risingSign ?? '';
    final mcSign = profile?.mcSign ?? '';

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _CosmicHeader(
            sunSign: sunSign,
            moonSign: moonSign,
            risingSign: risingSign,
            mcSign: mcSign,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cosmic Fingerprint
                if (map.cosmicFingerprint != null)
                  _FingerprintCard(text: map.cosmicFingerprint!)
                      .animate()
                      .fadeIn(delay: 200.ms),

                // Personality
                if (map.personality != null)
                  _SectionCard(
                    title: 'Personality',
                    icon: Icons.auto_awesome,
                    accentColor: AppColors.auraViolet,
                    delay: 300.ms,
                    child: _PersonalityBody(section: map.personality!,
                        lightSide: map.lightSide, shadowSide: map.shadowSide),
                  ),

                // Life Purpose
                if (map.lifePurpose != null)
                  _SectionCard(
                    title: 'Life Purpose & Soul Path',
                    icon: Icons.brightness_high_rounded,
                    accentColor: AppColors.auraIndigo,
                    delay: 400.ms,
                    child: _LifePurposeBody(section: map.lifePurpose!,
                        karmic: map.karmicLessons),
                  ),

                // Love & Relationships
                if (map.loveAndRelationships != null)
                  _SectionCard(
                    title: 'Love & Relationships',
                    icon: Icons.favorite_rounded,
                    accentColor: AppColors.auraRose,
                    delay: 500.ms,
                    child: _LoveBody(section: map.loveAndRelationships!),
                  ),

                // Career & Destiny
                if (map.careerAndDestiny != null)
                  _SectionCard(
                    title: 'Career & Destiny',
                    icon: Icons.star_rounded,
                    accentColor: AppColors.auraAmber,
                    delay: 600.ms,
                    child: _CareerBody(section: map.careerAndDestiny!,
                        talents: map.naturalTalents, paths: map.idealPaths),
                  ),

                // Strengths & Challenges
                if (map.strengthsAndChallenges != null)
                  _SectionCard(
                    title: 'Strengths & Challenges',
                    icon: Icons.bolt_rounded,
                    accentColor: AppColors.auraEmerald,
                    delay: 700.ms,
                    child: _StrengthsBody(section: map.strengthsAndChallenges!,
                        powers: map.superpowers, edges: map.growthEdges),
                  ),

                // Cosmic Timing
                if (map.cosmicTiming != null)
                  _SectionCard(
                    title: 'Cosmic Timing',
                    icon: Icons.timeline_rounded,
                    accentColor: AppColors.auraTeal,
                    delay: 800.ms,
                    child: _TimingBody(section: map.cosmicTiming!,
                        years: map.yearPredictions),
                  ),

                // Cosmic Wisdom
                if (map.cosmicWisdom != null)
                  _WisdomCard(text: map.cosmicWisdom!)
                      .animate()
                      .fadeIn(delay: 900.ms),

                // Export
                _ExportBar(map: map, profile: profile)
                    .animate()
                    .fadeIn(delay: 1000.ms),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Cosmic Header
// ---------------------------------------------------------------------------

class _CosmicHeader extends StatelessWidget {
  final String sunSign;
  final String moonSign;
  final String risingSign;
  final String mcSign;

  const _CosmicHeader({
    required this.sunSign,
    required this.moonSign,
    required this.risingSign,
    required this.mcSign,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A0A3A),
                  Color(0xFF0D0620),
                  Color(0xFF0B1026),
                ],
              ),
            ),
          ),
          // Star field
          const _StarField(),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Back button row
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white70, size: 20),
                  ),
                ),
                const Spacer(),
                Text(
                  '✦  B I R T H   M A P  ✦',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.auraAmber,
                    letterSpacing: 4,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your Cosmic Fingerprint',
                  style: AppTextStyles.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Big Three row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _HeaderSign(emoji: sunSign.zodiacEmoji, label: 'Sun',
                        sign: sunSign.capitalize),
                    _HeaderSign(emoji: moonSign.zodiacEmoji, label: 'Moon',
                        sign: moonSign.capitalize),
                    _HeaderSign(emoji: risingSign.zodiacEmoji, label: 'Rising',
                        sign: risingSign.capitalize),
                  ],
                ),
                if (mcSign.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'MC in ${mcSign.capitalize}',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: Colors.white38),
                  ),
                ],
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSign extends StatelessWidget {
  final String emoji;
  final String label;
  final String sign;

  const _HeaderSign(
      {required this.emoji, required this.label, required this.sign});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 30)),
        const SizedBox(height: 4),
        Text(sign,
            style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
        Text(label,
            style: AppTextStyles.labelSmall.copyWith(color: Colors.white38)),
      ],
    );
  }
}

/// Deterministic star field using fixed seed positions.
class _StarField extends StatelessWidget {
  const _StarField();

  @override
  Widget build(BuildContext context) {
    final rng = math.Random(42);
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: List.generate(30, (i) {
          final x = rng.nextDouble() * constraints.maxWidth;
          final y = rng.nextDouble() * constraints.maxHeight;
          final size = rng.nextDouble() * 2.5 + 0.8;
          final opacity = rng.nextDouble() * 0.5 + 0.1;
          return Positioned(
            left: x,
            top: y,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Cosmic Fingerprint card (opening statement)
// ---------------------------------------------------------------------------

class _FingerprintCard extends StatelessWidget {
  final String text;

  const _FingerprintCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7B68EE), Color(0xFF4B3F72), Color(0xFF2D1B69)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.auraViolet.withValues(alpha: 0.4), width: 1),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('✦', style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 8),
                Text(
                  'Cosmic Fingerprint',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: Colors.white70, letterSpacing: 1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              text,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
                height: 1.7,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Generic section card
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final Duration delay;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: CosmicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.titleMedium
                      .copyWith(color: accentColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay);
  }
}

// ---------------------------------------------------------------------------
// Section body widgets
// ---------------------------------------------------------------------------

class _PersonalityBody extends StatelessWidget {
  final Map<String, dynamic> section;
  final List<String> lightSide;
  final List<String> shadowSide;

  const _PersonalityBody(
      {required this.section,
      required this.lightSide,
      required this.shadowSide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section['core_essence'] != null)
          _ProseText(section['core_essence'] as String),
        if (section['unique_gifts'] != null) ...[
          const SizedBox(height: 12),
          _ProseText(section['unique_gifts'] as String,
              color: Colors.white.withValues(alpha: 0.7)),
        ],
        if (lightSide.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ChipsRow(label: 'Strengths', items: lightSide,
              color: AppColors.auraViolet),
        ],
        if (shadowSide.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ChipsRow(label: 'Growth Edges', items: shadowSide,
              color: AppColors.auraIndigo),
        ],
      ],
    );
  }
}

class _LifePurposeBody extends StatelessWidget {
  final Map<String, dynamic> section;
  final List<String> karmic;

  const _LifePurposeBody({required this.section, required this.karmic});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section['soul_mission'] != null)
          _ProseText(section['soul_mission'] as String),
        if (section['north_node_path'] != null) ...[
          const SizedBox(height: 16),
          _LabeledBlock(
            label: 'North Node Path',
            text: section['north_node_path'] as String,
            color: AppColors.auraIndigo,
          ),
        ],
        if (karmic.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ChipsRow(label: 'Karmic Lessons', items: karmic,
              color: AppColors.auraIndigo),
        ],
      ],
    );
  }
}

class _LoveBody extends StatelessWidget {
  final Map<String, dynamic> section;

  const _LoveBody({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section['love_style'] != null)
          _ProseText(section['love_style'] as String),
        if (section['what_they_seek'] != null) ...[
          const SizedBox(height: 16),
          _LabeledBlock(
            label: 'What You Seek',
            text: section['what_they_seek'] as String,
            color: AppColors.auraRose,
          ),
        ],
        if (section['relationship_patterns'] != null) ...[
          const SizedBox(height: 16),
          _LabeledBlock(
            label: 'Relationship Patterns',
            text: section['relationship_patterns'] as String,
            color: AppColors.auraRose,
          ),
        ],
        if (section['venus_wisdom'] != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.auraRose.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.auraRose.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Text('♀', style: TextStyle(color: AppColors.auraRose, fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section['venus_wisdom'] as String,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CareerBody extends StatelessWidget {
  final Map<String, dynamic> section;
  final List<String> talents;
  final List<String> paths;

  const _CareerBody(
      {required this.section, required this.talents, required this.paths});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section['purpose_and_calling'] != null)
          _ProseText(section['purpose_and_calling'] as String),
        if (talents.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ChipsRow(label: 'Natural Talents', items: talents,
              color: AppColors.auraAmber),
        ],
        if (paths.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ChipsRow(label: 'Ideal Paths', items: paths,
              color: AppColors.auraAmber),
        ],
        if (section['success_formula'] != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.auraAmber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.auraAmber.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Text('★', style: TextStyle(color: AppColors.auraAmber, fontSize: 16)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section['success_formula'] as String,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StrengthsBody extends StatelessWidget {
  final Map<String, dynamic> section;
  final List<String> powers;
  final List<String> edges;

  const _StrengthsBody(
      {required this.section, required this.powers, required this.edges});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (powers.isNotEmpty)
          _ChipsRow(label: 'Superpowers', items: powers,
              color: AppColors.auraEmerald),
        if (edges.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ChipsRow(label: 'Growth Edges', items: edges,
              color: AppColors.auraTeal),
        ],
        if (section['transformation_key'] != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.auraEmerald.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.auraEmerald.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚡', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section['transformation_key'] as String,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TimingBody extends StatelessWidget {
  final Map<String, dynamic> section;
  final List<Map<String, dynamic>> years;

  const _TimingBody({required this.section, required this.years});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section['current_chapter'] != null)
          _ProseText(section['current_chapter'] as String),
        if (years.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Year by Year',
              style: AppTextStyles.labelLarge
                  .copyWith(color: AppColors.auraTeal)),
          const SizedBox(height: 12),
          ...years.asMap().entries.map((e) => _YearCard(
                data: e.value,
                isLast: e.key == years.length - 1,
              )),
        ],
      ],
    );
  }
}

class _YearCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isLast;

  const _YearCard({required this.data, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final year = data['year']?.toString() ?? '';
    final theme = data['theme'] as String? ?? '';
    final forecast = data['forecast'] as String? ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.auraTeal.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.auraTeal.withValues(alpha: 0.4)),
              ),
              child: Center(
                child: Text(
                  year,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.auraTeal, fontSize: 10),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 1,
                height: 80,
                color: AppColors.auraTeal.withValues(alpha: 0.2),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  theme,
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.auraTeal),
                ),
                const SizedBox(height: 6),
                Text(
                  forecast,
                  style: AppTextStyles.bodySmall
                      .copyWith(height: 1.6, color: Colors.white60),
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
// Cosmic Wisdom (closing card)
// ---------------------------------------------------------------------------

class _WisdomCard extends StatelessWidget {
  final String text;

  const _WisdomCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7B68EE),
              Color(0xFF4B3F72),
              Color(0xFF2D1B69),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('✦', style: TextStyle(color: Colors.white54)),
                const SizedBox(width: 8),
                Text(
                  'A Message from the Stars',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: Colors.white54, letterSpacing: 1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              text,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
                height: 1.8,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '— Cosmira',
                style: AppTextStyles.labelSmall
                    .copyWith(color: Colors.white38, letterSpacing: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Export bar
// ---------------------------------------------------------------------------

class _ExportBar extends StatefulWidget {
  final BirthMap map;
  final dynamic profile;

  const _ExportBar({required this.map, required this.profile});

  @override
  State<_ExportBar> createState() => _ExportBarState();
}

class _ExportBarState extends State<_ExportBar> {
  bool _exportingPdf = false;
  bool _exportingStory = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Export', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ExportButton(
                  label: 'Save PDF',
                  icon: Icons.picture_as_pdf_rounded,
                  color: AppColors.auraViolet,
                  isLoading: _exportingPdf,
                  onTap: _exportPdf,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ExportButton(
                  label: 'Share Story',
                  icon: Icons.share_rounded,
                  color: AppColors.auraRose,
                  isLoading: _exportingStory,
                  onTap: _exportStory,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf() async {
    setState(() => _exportingPdf = true);
    try {
      final doc = _buildPdf();
      await Printing.layoutPdf(
        onLayout: (_) async => doc.save(),
        name: 'Cosmira_Birth_Map.pdf',
      );
    } finally {
      if (mounted) setState(() => _exportingPdf = false);
    }
  }

  pw.Document _buildPdf() {
    final doc = pw.Document();
    final map = widget.map;
    final profile = widget.profile;

    final headerStyle = pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold);
    final sectionStyle = pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold);
    final bodyStyle = pw.TextStyle(fontSize: 11);
    final accentColor = PdfColor.fromInt(0xFF7B68EE);

    pw.Widget section(String title, List<pw.Widget> children) =>
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.SizedBox(height: 20),
          pw.Text(title, style: sectionStyle.copyWith(color: accentColor)),
          pw.Divider(color: accentColor, thickness: 0.5),
          pw.SizedBox(height: 8),
          ...children,
        ]);

    pw.Widget prose(String? text) => text == null
        ? pw.SizedBox()
        : pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Text(text, style: bodyStyle));

    pw.Widget chips(String label, List<String> items) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('$label:', style: sectionStyle.copyWith(fontSize: 11)),
            pw.SizedBox(height: 4),
            pw.Wrap(
              spacing: 6,
              runSpacing: 4,
              children: items
                  .map((t) => pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: accentColor),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Text(t,
                            style:
                                bodyStyle.copyWith(color: accentColor)),
                      ))
                  .toList(),
            ),
            pw.SizedBox(height: 8),
          ],
        );

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('Generated by Cosmira',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
      ),
      build: (ctx) => [
        // Cover
        pw.Center(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('✦  BIRTH MAP  ✦',
                  style: const pw.TextStyle(
                      fontSize: 11, color: PdfColor.fromInt(0xFFFBBF24))),
              pw.SizedBox(height: 8),
              pw.Text('Your Cosmic Fingerprint', style: headerStyle),
              pw.SizedBox(height: 4),
              if (profile != null)
                pw.Text(
                    '${(profile.sunSign ?? '').toUpperCase()} ·'
                    ' ${(profile.moonSign ?? '').toUpperCase()} ·'
                    ' ${(profile.risingSign ?? '').toUpperCase()}',
                    style: const pw.TextStyle(
                        fontSize: 12, color: PdfColors.grey600)),
              pw.SizedBox(height: 24),
              pw.Divider(),
            ],
          ),
        ),
        // Cosmic Fingerprint
        if (map.cosmicFingerprint != null)
          section('Cosmic Fingerprint', [prose(map.cosmicFingerprint)]),
        // Personality
        if (map.personality != null)
          section('Personality', [
            prose(map.personality!['core_essence'] as String?),
            prose(map.personality!['unique_gifts'] as String?),
            if (map.lightSide.isNotEmpty) chips('Strengths', map.lightSide),
            if (map.shadowSide.isNotEmpty) chips('Growth Edges', map.shadowSide),
          ]),
        // Life Purpose
        if (map.lifePurpose != null)
          section('Life Purpose & Soul Path', [
            prose(map.lifePurpose!['soul_mission'] as String?),
            prose(map.lifePurpose!['north_node_path'] as String?),
            if (map.karmicLessons.isNotEmpty)
              chips('Karmic Lessons', map.karmicLessons),
          ]),
        // Love
        if (map.loveAndRelationships != null)
          section('Love & Relationships', [
            prose(map.loveAndRelationships!['love_style'] as String?),
            prose(map.loveAndRelationships!['what_they_seek'] as String?),
            prose(map.loveAndRelationships!['relationship_patterns'] as String?),
            prose(map.loveAndRelationships!['venus_wisdom'] as String?),
          ]),
        // Career
        if (map.careerAndDestiny != null)
          section('Career & Destiny', [
            prose(map.careerAndDestiny!['purpose_and_calling'] as String?),
            if (map.naturalTalents.isNotEmpty)
              chips('Natural Talents', map.naturalTalents),
            if (map.idealPaths.isNotEmpty)
              chips('Ideal Paths', map.idealPaths),
            prose(map.careerAndDestiny!['success_formula'] as String?),
          ]),
        // Strengths
        if (map.strengthsAndChallenges != null)
          section('Strengths & Challenges', [
            if (map.superpowers.isNotEmpty)
              chips('Superpowers', map.superpowers),
            if (map.growthEdges.isNotEmpty)
              chips('Growth Edges', map.growthEdges),
            prose(map.strengthsAndChallenges!['transformation_key'] as String?),
          ]),
        // Cosmic Timing
        if (map.cosmicTiming != null)
          section('Cosmic Timing', [
            prose(map.cosmicTiming!['current_chapter'] as String?),
            ...map.yearPredictions.map((y) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 12),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${y['year']} — ${y['theme'] ?? ''}',
                          style: sectionStyle.copyWith(fontSize: 11),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(y['forecast'] as String? ?? '',
                            style: bodyStyle),
                      ]),
                )),
          ]),
        // Cosmic Wisdom
        if (map.cosmicWisdom != null)
          section('A Message from the Stars', [prose(map.cosmicWisdom)]),
      ],
    ));

    return doc;
  }

  Future<void> _exportStory() async {
    setState(() => _exportingStory = true);
    try {
      final controller = ScreenshotController();
      final imageBytes = await controller.captureFromWidget(
        _StoryCard(map: widget.map, profile: widget.profile),
        pixelRatio: 3.0,
        targetSize: const Size(360, 640),
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/cosmira_story.png');
      await file.writeAsBytes(imageBytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'My Cosmic Fingerprint ✦ cosmira.app',
      );
    } finally {
      if (mounted) setState(() => _exportingStory = false);
    }
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
                  child: CircularProgressIndicator(
                      color: color, strokeWidth: 2),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 8),
                  Text(label,
                      style: AppTextStyles.labelLarge.copyWith(color: color)),
                ],
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Instagram Story card (9:16 captured off-screen)
// ---------------------------------------------------------------------------

class _StoryCard extends StatelessWidget {
  final BirthMap map;
  final dynamic profile;

  const _StoryCard({required this.map, required this.profile});

  @override
  Widget build(BuildContext context) {
    final sunSign = profile?.sunSign ?? '';
    final moonSign = profile?.moonSign ?? '';
    final risingSign = profile?.risingSign ?? '';
    final fingerprint = map.cosmicFingerprint ?? '';
    final excerpt = fingerprint.length > 220
        ? '${fingerprint.substring(0, 220)}…'
        : fingerprint;

    return SizedBox(
      width: 360,
      height: 640,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A3A), Color(0xFF0B1026), Color(0xFF000000)],
          ),
        ),
        child: Stack(
          children: [
            const _StarField(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    '✦  C O S M I R A  ✦',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 10,
                      letterSpacing: 4,
                      color: AppColors.auraAmber.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'My Cosmic Fingerprint',
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StorySign(emoji: sunSign.zodiacEmoji,
                          label: 'Sun', sign: sunSign.capitalize),
                      const SizedBox(width: 24),
                      _StorySign(emoji: moonSign.zodiacEmoji,
                          label: 'Moon', sign: moonSign.capitalize),
                      const SizedBox(width: 24),
                      _StorySign(emoji: risingSign.zodiacEmoji,
                          label: 'Rising', sign: risingSign.capitalize),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      excerpt,
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12,
                        height: 1.7,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'cosmira.app',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 11,
                      letterSpacing: 2,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorySign extends StatelessWidget {
  final String emoji;
  final String label;
  final String sign;

  const _StorySign(
      {required this.emoji, required this.label, required this.sign});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(sign,
            style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500)),
        Text(label,
            style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.4))),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable primitives
// ---------------------------------------------------------------------------

class _ProseText extends StatelessWidget {
  final String text;
  final Color? color;

  const _ProseText(this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        color: color ?? Colors.white.withValues(alpha: 0.8),
        height: 1.7,
      ),
    );
  }
}

class _LabeledBlock extends StatelessWidget {
  final String label;
  final String text;
  final Color color;

  const _LabeledBlock(
      {required this.label, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTextStyles.labelSmall.copyWith(color: color, letterSpacing: 1)),
        const SizedBox(height: 6),
        Text(
          text,
          style: AppTextStyles.bodySmall
              .copyWith(color: Colors.white60, height: 1.6),
        ),
      ],
    );
  }
}

class _ChipsRow extends StatelessWidget {
  final String label;
  final List<String> items;
  final Color color;

  const _ChipsRow(
      {required this.label, required this.items, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.labelSmall
                .copyWith(color: color, letterSpacing: 1)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((item) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      item,
                      style: AppTextStyles.labelSmall.copyWith(color: color),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
