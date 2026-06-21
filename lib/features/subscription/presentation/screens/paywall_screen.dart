import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_button.dart';
import '../../domain/entities/subscription.dart';
import '../providers/subscription_provider.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPlan = ref.watch(selectedPlanProvider);
    final isLoading = ref.watch(subscriptionLoadingProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => context.pop(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Icon(Icons.stars, size: 64, color: AppColors.auraAmber)
                          .animate()
                          .fadeIn()
                          .scale(begin: const Offset(0.5, 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'paywall_title'.tr(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayMedium,
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 8),
                      Text(
                        'paywall_subtitle'.tr(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.accentGlow,
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 32),
                      ...SubscriptionPlan.premium.features.map(
                        (feature) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: AppColors.success, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(feature,
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(color: AppColors.textPrimary)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: _PlanOption(
                              label: 'paywall_monthly'.tr(),
                              price: 'paywall_price_monthly'.tr(),
                              isSelected: selectedPlan == 'monthly',
                              onTap: () => ref
                                  .read(selectedPlanProvider.notifier)
                                  .state = 'monthly',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PlanOption(
                              label: 'paywall_yearly'.tr(),
                              price: 'paywall_price_yearly'.tr(),
                              badge: 'paywall_save'.tr(),
                              isSelected: selectedPlan == 'yearly',
                              onTap: () => ref
                                  .read(selectedPlanProvider.notifier)
                                  .state = 'yearly',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: CosmicButton(
                          label: 'paywall_trial'.tr(),
                          isLoading: isLoading,
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'paywall_trial_sub'.tr(),
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text('paywall_restore'.tr(),
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textSecondary)),
                          ),
                          Text(' • ',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textTertiary)),
                          TextButton(
                            onPressed: () {},
                            child: Text('paywall_terms'.tr(),
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textSecondary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanOption extends StatelessWidget {
  final String label;
  final String price;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanOption({
    required this.label,
    required this.price,
    this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.accentGradient : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accentGlow : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.auraAmber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.auraAmber,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(label, style: AppTextStyles.titleMedium),
            const SizedBox(height: 4),
            Text(
              price,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
