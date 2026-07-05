import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/breathwork_session.dart';
import '../providers/breathwork_provider.dart';
import '../widgets/breathing_circle.dart';

class BreathworkScreen extends ConsumerWidget {
  const BreathworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bState = ref.watch(breathworkStateProvider);
    final selectedPattern = ref.watch(selectedPatternProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white70, size: 20),
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: (!bState.isActive && bState.phase != BreathPhase.complete)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('breathwork_title'.tr(),
                                style: AppTextStyles.headlineLarge)
                            .animate()
                            .fadeIn(),
                        const SizedBox(height: 8),
                        Text('breathwork_subtitle'.tr(),
                            style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 20),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // 3 kart + 2 boşluk (12px) tam ekrana sığsın
                            final cardWidth =
                                (constraints.maxWidth - 12 * 2) / 3;
                            return SizedBox(
                              height: 132,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.none,
                                itemCount: BreathworkPattern.all.length,
                                itemBuilder: (context, index) {
                                  final pattern = BreathworkPattern.all[index];
                                  final isSelected =
                                      pattern.id == selectedPattern.id;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (pattern.isPremium) {
                                          final isPremium = ref.read(userProfileProvider).valueOrNull?.isPremium ?? false;
                                          if (!isPremium) {
                                            context.push('/paywall');
                                            return;
                                          }
                                        }
                                        ref.read(selectedPatternProvider.notifier).state = pattern;
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: cardWidth,
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          gradient: isSelected
                                              ? AppColors.accentGradient
                                              : null,
                                          color: isSelected
                                              ? null
                                              : AppColors.surface,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.accentGlow
                                                : AppColors.cardBorder,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'breathwork_pattern_${pattern.id}'
                                                  .tr(),
                                              style: AppTextStyles.labelLarge
                                                  .copyWith(
                                                color: Colors.white,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const Spacer(),
                                            Text(
                                              '${pattern.inhaleSeconds}-'
                                              '${pattern.holdSeconds}-'
                                              '${pattern.exhaleSeconds}',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: Colors.white70,
                                              ),
                                            ),
                                            if (pattern.isPremium)
                                              Text(
                                                'breathwork_premium'.tr(),
                                                style: AppTextStyles.labelSmall
                                                    .copyWith(
                                                  color: AppColors.auraAmber,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            const Spacer(),
            Center(
              child: BreathingCircle(
                phase: bState.phase,
                isActive: bState.isActive,
                phaseSeconds: bState.phaseSecondsRemaining,
              ),
            ),
            const SizedBox(height: 8),
            if (bState.isActive) ...[
              Center(
                child: Text(
                  _phaseLabel(bState.phase).toUpperCase(),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 3,
                  ),
                ),
              ),
              if (bState.phaseSecondsRemaining > 0) ...[
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    '${bState.phaseSecondsRemaining}',
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w200,
                      color: AppColors.accentGlow,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'breathwork_cycle'.tr(namedArgs: {
                    'current': '${bState.currentCycle}',
                    'total': '${bState.totalCycles}',
                  }),
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ] else if (bState.phase == BreathPhase.complete) ...[
              Center(
                child: Text(
                  'breathwork_complete'.tr(),
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.accentGlow,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'breathwork_well_done'
                      .tr(namedArgs: {'cycles': '${bState.totalCycles}'}),
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ] else ...[
              const SizedBox.shrink(),
            ],
            const Spacer(),
            Center(
              child: CosmicButton(
                label: bState.isActive
                    ? 'breathwork_stop'.tr()
                    : bState.phase == BreathPhase.complete
                        ? 'breathwork_start_again'.tr()
                        : 'breathwork_begin'.tr(),
                isPrimary: !bState.isActive,
                onPressed: () {
                  final notifier = ref.read(breathworkStateProvider.notifier);
                  if (bState.isActive) {
                    notifier.stop();
                  } else {
                    if (selectedPattern.isPremium) {
                      final isPremium = ref.read(userProfileProvider).valueOrNull?.isPremium ?? false;
                      if (!isPremium) {
                        context.push('/paywall');
                        return;
                      }
                    }
                    notifier.start();
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _phaseLabel(BreathPhase phase) => switch (phase) {
        BreathPhase.inhale => 'breathwork_inhale'.tr(),
        BreathPhase.hold => 'breathwork_hold'.tr(),
        BreathPhase.exhale => 'breathwork_exhale'.tr(),
        BreathPhase.holdOut => 'breathwork_hold'.tr(),
        BreathPhase.complete => '',
        BreathPhase.idle => '',
      };
}
