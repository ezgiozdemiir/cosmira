import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_button.dart';
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
            if (!bState.isActive) ...[
              Text('Breathwork', style: AppTextStyles.headlineLarge)
                  .animate()
                  .fadeIn(),
              const SizedBox(height: 8),
              Text(
                'Find your inner peace',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: BreathworkPattern.all.length,
                  itemBuilder: (context, index) {
                    final pattern = BreathworkPattern.all[index];
                    final isSelected = pattern.id == selectedPattern.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => ref
                            .read(selectedPatternProvider.notifier)
                            .state = pattern,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 140,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? AppColors.accentGradient
                                : null,
                            color: isSelected ? null : AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accentGlow
                                  : AppColors.cardBorder,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pattern.name,
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Text(
                                '${pattern.inhaleSeconds}-${pattern.holdSeconds}-${pattern.exhaleSeconds}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              if (pattern.isPremium)
                                Text(
                                  'Premium',
                                  style: AppTextStyles.labelSmall.copyWith(
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
              ),
            ],
            const Spacer(),
            Center(
              child: BreathingCircle(
                phase: bState.phase,
                isActive: bState.isActive,
              ),
            ),
            if (bState.isActive) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _phaseLabel(bState.phase),
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.accentGlow,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Cycle ${bState.currentCycle} of ${bState.totalCycles}',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
            const Spacer(),
            Center(
              child: CosmicButton(
                label: bState.isActive ? 'Stop' : 'Begin Session',
                isPrimary: !bState.isActive,
                onPressed: () {
                  final notifier = ref.read(breathworkStateProvider.notifier);
                  if (bState.isActive) {
                    notifier.stop();
                  } else {
                    notifier.start();
                  }
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _phaseLabel(BreathPhase phase) {
    switch (phase) {
      case BreathPhase.inhale:
        return 'Inhale';
      case BreathPhase.hold:
        return 'Hold';
      case BreathPhase.exhale:
        return 'Exhale';
      case BreathPhase.holdOut:
        return 'Hold';
      case BreathPhase.complete:
        return 'Complete';
      case BreathPhase.idle:
        return '';
    }
  }
}
