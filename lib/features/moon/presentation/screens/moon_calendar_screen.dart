import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../providers/moon_provider.dart';

class MoonCalendarScreen extends ConsumerWidget {
  const MoonCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPhase = ref.watch(currentMoonPhaseProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Moon Calendar', style: AppTextStyles.headlineLarge)
                      .animate()
                      .fadeIn(),
                  const SizedBox(height: 24),
                  currentPhase.when(
                    data: (phase) {
                      if (phase == null) return const SizedBox.shrink();

                      return CosmicCard(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1a1a3e),
                            Color(0xFF0d0d2b),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              phase.phaseEmoji,
                              style: const TextStyle(fontSize: 64),
                            ).animate().fadeIn(delay: 200.ms).scale(
                                  begin: const Offset(0.5, 0.5),
                                  duration: 800.ms,
                                  curve: Curves.elasticOut,
                                ),
                            const SizedBox(height: 16),
                            Text(
                              phase.phaseName.replaceAll('_', ' ').capitalize,
                              style: AppTextStyles.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'in ${phase.zodiacSign.capitalize} ${phase.zodiacSign.zodiacEmoji}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.accentGlow,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(phase.illumination * 100).toStringAsFixed(0)}% illuminated',
                              style: AppTextStyles.bodySmall,
                            ),
                            if (phase.ritualTitle.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              const Divider(color: AppColors.cardBorder),
                              const SizedBox(height: 16),
                              Text(
                                phase.ritualTitle,
                                style: AppTextStyles.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                phase.ritualDescription,
                                style: AppTextStyles.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                            if (phase.intentions.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: phase.intentions.map((intention) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.auraIndigo.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: AppColors.auraIndigo.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      intention,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.auraIndigo,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            if (phase.crystalRecommendation != null) ...[
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.diamond,
                                      color: AppColors.auraTeal, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Crystal: ${phase.crystalRecommendation}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.auraTeal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
                    },
                    loading: () => const ShimmerCardLoading(),
                    error: (_, __) => const Text('Error loading moon data'),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
