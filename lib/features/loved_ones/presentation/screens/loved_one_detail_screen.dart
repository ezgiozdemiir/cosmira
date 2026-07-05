import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../domain/entities/loved_one.dart';
import '../providers/loved_one_reports_provider.dart';
import 'loved_ones_list_screen.dart';

class LovedOneDetailScreen extends ConsumerWidget {
  final LovedOne lovedOne;
  const LovedOneDetailScreen({super.key, required this.lovedOne});

  static const _birthMapCost = 200;
  static const _astroCost = 100;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasBirthMap =
        ref.watch(lovedOneBirthMapExistsProvider(lovedOne.id)).valueOrNull ??
            false;
    final hasAstro =
        ref.watch(lovedOneAstroUnlockedProvider(lovedOne.id)).valueOrNull ??
            false;

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
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: LovedOnesScreen.accentColor
                                  .withValues(alpha: 0.2),
                              child: Text(
                                lovedOne.sunSign.zodiacEmoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(lovedOne.name,
                                style: AppTextStyles.headlineMedium),
                            const SizedBox(height: 4),
                            Text(
                              '${lovedOne.sunSign.zodiacName} • ${lovedOne.moonSign.zodiacName} • ${lovedOne.risingSign.zodiacName}',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(),
                      const SizedBox(height: 32),
                      Text('lo_detail_actions'.tr(),
                          style: AppTextStyles.titleMedium),
                      const SizedBox(height: 12),
                      _ActionTile(
                        icon: Icons.auto_awesome,
                        color: AppColors.auraViolet,
                        title: 'lo_generate_birth_map'.tr(),
                        subtitle: hasBirthMap
                            ? 'lo_action_ready'.tr()
                            : 'lo_action_cost'.tr(namedArgs: {'cost': '$_birthMapCost'}),
                        done: hasBirthMap,
                        onTap: () => context.push(
                          '/loved-ones/birth-map',
                          extra: lovedOne,
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 12),
                      _ActionTile(
                        icon: Icons.public,
                        color: const Color(0xFF0EA5E9),
                        title: 'lo_unlock_astro'.tr(),
                        subtitle: hasAstro
                            ? 'lo_action_ready'.tr()
                            : 'lo_action_cost'.tr(namedArgs: {'cost': '$_astroCost'}),
                        done: hasAstro,
                        onTap: () => context.push(
                          '/loved-ones/astrocartography',
                          extra: lovedOne,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool done;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(subtitle, style: AppTextStyles.bodySmall),
                    if (!done) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.auto_awesome,
                          color: AppColors.auraAmber, size: 12),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Icon(
            done ? Icons.chevron_right : Icons.lock_outline,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
