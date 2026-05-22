import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../../core/widgets/cosmic_button.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../providers/compatibility_provider.dart';

class CompatibilityScreen extends ConsumerWidget {
  const CompatibilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partners = ref.watch(partnersProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Compatibility', style: AppTextStyles.headlineLarge)
                      .animate()
                      .fadeIn(),
                  const SizedBox(height: 8),
                  Text(
                    'Explore your cosmic connections',
                    style: AppTextStyles.bodyMedium,
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          partners.when(
            data: (list) {
              if (list.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CosmicCard(
                      child: Column(
                        children: [
                          const Icon(Icons.favorite_border,
                              size: 48, color: AppColors.auraRose),
                          const SizedBox(height: 16),
                          Text('No partners yet',
                              style: AppTextStyles.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            'Add someone to discover your cosmic compatibility.',
                            style: AppTextStyles.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          CosmicButton(
                            label: 'Add Partner',
                            icon: Icons.add,
                            onPressed: () {},
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
                    final partner = list[index];
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: CosmicCard(
                        onTap: () {},
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.auraRose.withOpacity(0.2),
                              child: Text(
                                partner.sunSign.zodiacEmoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(partner.name,
                                      style: AppTextStyles.titleMedium),
                                  Text(
                                    '${partner.sunSign.capitalize} • ${partner.relationship.capitalize}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: AppColors.textTertiary),
                          ],
                        ),
                      ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.05),
                    );
                  },
                  childCount: list.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SliverToBoxAdapter(
              child: Center(child: Text('Error loading partners')),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
