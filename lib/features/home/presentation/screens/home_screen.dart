import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/horoscope_card.dart';
import '../widgets/stardust_header.dart';
import '../widgets/quick_action_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final horoscope = ref.watch(todayHoroscopeProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StardustHeader()
                      .animate()
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 24),
                  Text(
                    'Hello, ${profile?.displayName ?? 'Stargazer'}',
                    style: AppTextStyles.headlineLarge,
                  ).animate().fadeIn(delay: 200.ms),
                  if (profile?.sunSign != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${profile!.sunSign!.capitalize} ${profile.sunSign!.zodiacEmoji}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.accentGlow,
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: horoscope.when(
                data: (h) => h != null
                    ? HoroscopeCard(horoscope: h)
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.1)
                    : CosmicCard(
                        child: Column(
                          children: [
                            const Icon(Icons.stars, color: AppColors.accentGlow, size: 40),
                            const SizedBox(height: 12),
                            Text(
                              'Complete your birth details\nto unlock your daily horoscope',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                        onTap: () => context.push('/onboarding'),
                      ),
                loading: () => const ShimmerCardLoading(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: QuickActionGrid(),
            ).animate().fadeIn(delay: 500.ms),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
