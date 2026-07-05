import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/astrocartography_unlock.dart';
import '../providers/astrocartography_provider.dart';

class AstrocartographyHistoryScreen extends ConsumerWidget {
  const AstrocartographyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(astrocartographyHistoryProvider);
    final currentVersion =
        ref.watch(userProfileProvider).valueOrNull?.birthDataVersion ?? 0;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Text('astro_history_title'.tr(), style: AppTextStyles.titleLarge),
                  ],
                ),
              ),
              Expanded(
                child: historyAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (history) => history.isEmpty
                      ? Center(
                          child: Text('astro_history_empty'.tr(),
                              style: AppTextStyles.bodyMedium),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: history.length,
                          itemBuilder: (context, i) {
                            final unlock = history[i];
                            final isCurrent = unlock.birthDataVersion == currentVersion;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _HistoryTile(unlock: unlock, isCurrent: isCurrent)
                                  .animate()
                                  .fadeIn(delay: (60 * i).ms),
                            );
                          },
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

class _HistoryTile extends StatelessWidget {
  final AstrocartographyUnlock unlock;
  final bool isCurrent;

  const _HistoryTile({required this.unlock, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final date = unlock.unlockedAt;
    final dateStr = '${date.day}/${date.month}/${date.year}';

    return GestureDetector(
      onTap: () => context.push('/astrocartography/history/entry', extra: unlock),
      child: CosmicCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.auraAmber.withValues(alpha: 0.12),
                border: Border.all(color: AppColors.auraAmber.withValues(alpha: 0.3)),
              ),
              alignment: Alignment.center,
              child: const Text('🌍', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('astro_history_item_sub'.tr(namedArgs: {'date': dateStr}),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    unlock.birthCity != null
                        ? 'astro_history_city'.tr(namedArgs: {'city': unlock.birthCity!})
                        : 'astro_history_city_unknown'.tr(),
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(height: 4),
                    Text('astro_history_current'.tr(),
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.auraAmber)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
