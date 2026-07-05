import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/birth_map.dart';
import '../providers/birth_map_provider.dart';

class BirthMapHistoryScreen extends ConsumerWidget {
  const BirthMapHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(birthMapHistoryProvider);
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
                    Text('bm_history_title'.tr(), style: AppTextStyles.titleLarge),
                  ],
                ),
              ),
              Expanded(
                child: historyAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(child: Text('bm_error_load'.tr())),
                  data: (history) => history.isEmpty
                      ? Center(
                          child: Text('bm_history_empty'.tr(),
                              style: AppTextStyles.bodyMedium),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: history.length,
                          itemBuilder: (context, i) {
                            final map = history[i];
                            final isCurrent = map.birthDataVersion == currentVersion;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _HistoryTile(map: map, isCurrent: isCurrent)
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
  final BirthMap map;
  final bool isCurrent;

  const _HistoryTile({required this.map, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final date = map.createdAt;
    final dateStr = '${date.day}/${date.month}/${date.year}';

    return GestureDetector(
      onTap: () => context.push(
        '/birth-map/history/${map.birthDataVersion}',
      ),
      child: CosmicCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.auraViolet.withValues(alpha: 0.12),
                border: Border.all(color: AppColors.auraViolet.withValues(alpha: 0.3)),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.auto_awesome, color: AppColors.auraViolet, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('bm_history_item_sub'.tr(namedArgs: {'date': dateStr}),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: Colors.white)),
                  if (isCurrent) ...[
                    const SizedBox(height: 4),
                    Text('bm_history_current'.tr(),
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
