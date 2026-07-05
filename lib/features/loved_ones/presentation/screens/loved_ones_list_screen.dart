import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_button.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/loved_ones_provider.dart';
import 'add_loved_one_sheet.dart';

class LovedOnesScreen extends ConsumerWidget {
  const LovedOnesScreen({super.key});

  static const accentColor = Color(0xFFF472B6);
  static const _freeLimit = 2;
  static const _premiumLimit = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lovedOnes = ref.watch(lovedOnesProvider);
    final isPremium =
        ref.watch(userProfileProvider).valueOrNull?.isPremium ?? false;
    final limit = isPremium ? _premiumLimit : _freeLimit;

    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white70, size: 20),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('lo_title'.tr(),
                                    style: AppTextStyles.headlineLarge)
                                .animate()
                                .fadeIn(),
                            const SizedBox(height: 4),
                            Text('lo_subtitle'.tr(),
                                    style: AppTextStyles.bodyMedium)
                                .animate()
                                .fadeIn(delay: 200.ms),
                          ],
                        ),
                      ),
                      lovedOnes.maybeWhen(
                        data: (list) => list.isNotEmpty && list.length < limit
                            ? IconButton.filled(
                                onPressed: () => _showAddSheet(context),
                                icon: const Icon(Icons.add),
                                style: IconButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                ),
                              )
                            : const SizedBox.shrink(),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              lovedOnes.when(
                data: (list) {
                  if (list.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CosmicCard(
                          child: Column(
                            children: [
                              const Icon(Icons.card_giftcard_rounded,
                                  size: 48, color: accentColor),
                              const SizedBox(height: 16),
                              Text('lo_empty_title'.tr(),
                                  style: AppTextStyles.titleMedium),
                              const SizedBox(height: 8),
                              Text(
                                'lo_empty_sub'.tr(),
                                style: AppTextStyles.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              CosmicButton(
                                label: 'lo_add'.tr(),
                                icon: Icons.add,
                                onPressed: () => _showAddSheet(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final lovedOne = list[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 6),
                          child: CosmicCard(
                            onTap: () => context.push(
                              '/loved-ones/detail',
                              extra: lovedOne,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor:
                                      accentColor.withValues(alpha: 0.2),
                                  child: Text(
                                    lovedOne.sunSign.zodiacEmoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(lovedOne.name,
                                          style: AppTextStyles.titleMedium),
                                      Text(
                                        lovedOne.sunSign.zodiacName,
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: AppColors.textTertiary),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(delay: (index * 100).ms)
                              .slideX(begin: 0.05),
                        );
                      },
                      childCount: list.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => SliverToBoxAdapter(
                  child: Center(child: Text('lo_error'.tr())),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddLovedOneSheet(),
    );
  }
}
