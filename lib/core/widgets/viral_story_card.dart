import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'star_field.dart';

/// Extracts a short, punchy hook (first sentence, capped length) from a
/// longer AI-generated (or static) paragraph, for use as a
/// [ViralStoryCard.quotableLine] — short and bold reads better on a Story
/// than a dense excerpt.
String storyHook(String text, {int maxLen = 140}) {
  if (text.isEmpty) return text;
  final idx = text.indexOf('. ');
  var sentence = idx != -1 ? text.substring(0, idx + 1) : text;
  if (sentence.length > maxLen) {
    sentence = '${sentence.substring(0, maxLen)}…';
  }
  return sentence;
}

/// One stat shown in a [ViralStoryCard]'s stat row — e.g. a zodiac sign or a
/// top power city.
class StoryStat {
  final String emoji;
  final String value;
  final String label;
  const StoryStat({required this.emoji, required this.value, required this.label});
}

/// Shared 9:16 Instagram Story export template, used by every "share this
/// report" flow in the app (Birth Map, Astrocartography, Loved Ones — both
/// self and gifted). Designed to be "viral": a big, punchy hook headline and
/// ONE short quotable line rather than a long italic paragraph excerpt —
/// short and bold reads better on a Story than dense prose.
class ViralStoryCard extends StatelessWidget {
  /// Small letter-spaced kicker above the headline, e.g. "✦ C O S M I R A ✦".
  final String eyebrow;

  /// The big hook line — should read like a headline, not a sentence.
  final String headline;

  /// Optional row of up to 3 stats (e.g. Sun/Moon/Rising, or a top city).
  final List<StoryStat> stats;

  /// One short, punchy, quotable sentence — not a paragraph.
  final String quotableLine;

  final Color accentColor;

  /// Footer branding line, defaults to the app URL.
  final String footer;

  const ViralStoryCard({
    super.key,
    required this.eyebrow,
    required this.headline,
    this.stats = const [],
    required this.quotableLine,
    this.accentColor = AppColors.auraAmber,
    this.footer = 'cosmira.app',
  });

  @override
  Widget build(BuildContext context) {
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
            const StarField(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    eyebrow,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 10,
                      letterSpacing: 4,
                      color: accentColor.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    headline,
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: Colors.white,
                      height: 1.15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (stats.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < stats.length; i++) ...[
                          if (i > 0) const SizedBox(width: 24),
                          _StatColumn(stat: stats[i]),
                        ],
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 22),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(18),
                      border:
                          Border.all(color: accentColor.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      quotableLine,
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 20,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    footer,
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

class _StatColumn extends StatelessWidget {
  final StoryStat stat;
  const _StatColumn({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(stat.emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(stat.value,
            style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500)),
        Text(stat.label,
            style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.4))),
      ],
    );
  }
}
