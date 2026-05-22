import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../providers/astrology_provider.dart';
import '../widgets/planet_position_tile.dart';
import '../widgets/zodiac_wheel.dart';

class NatalChartScreen extends ConsumerWidget {
  const NatalChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chart = ref.watch(natalChartProvider);

    return SafeArea(
      child: chart.when(
        data: (c) {
          if (c == null) {
            return Center(
              child: CosmicCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, size: 48, color: AppColors.auraViolet),
                    const SizedBox(height: 16),
                    Text('Chart not calculated yet', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Complete your birth details to see your natal chart.',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Natal Chart', style: AppTextStyles.headlineLarge)
                          .animate()
                          .fadeIn(),
                      const SizedBox(height: 24),
                      ZodiacWheel(chart: c).animate().fadeIn(delay: 200.ms).scale(
                            begin: const Offset(0.8, 0.8),
                            duration: 600.ms,
                          ),
                      const SizedBox(height: 24),
                      CosmicCard(
                        gradient: AppColors.premiumGradient,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _BigThree(
                              label: 'Sun',
                              sign: c.sunSign,
                              emoji: c.sunSign.zodiacEmoji,
                            ),
                            _BigThree(
                              label: 'Moon',
                              sign: c.moonSign,
                              emoji: c.moonSign.zodiacEmoji,
                            ),
                            _BigThree(
                              label: 'Rising',
                              sign: c.risingSign,
                              emoji: c.risingSign.zodiacEmoji,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 24),
                      Text('Planetary Positions', style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = c.planets.entries.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: PlanetPositionTile(position: entry.value)
                          .animate()
                          .fadeIn(delay: (500 + index * 100).ms)
                          .slideX(begin: 0.1),
                    );
                  },
                  childCount: c.planets.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
        loading: () => const Center(child: ShimmerCardLoading()),
        error: (_, __) => const Center(child: Text('Error loading chart')),
      ),
    );
  }
}

class _BigThree extends StatelessWidget {
  final String label;
  final String sign;
  final String emoji;

  const _BigThree({
    required this.label,
    required this.sign,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(sign.capitalize, style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
      ],
    );
  }
}
