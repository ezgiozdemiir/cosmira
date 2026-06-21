import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/horoscope_card.dart';
import '../widgets/stardust_header.dart';
import '../widgets/aura_card.dart';
import '../widgets/quick_action_grid.dart';

String _dailyText() {
  final dayOfYear =
      DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
  final index = dayOfYear % 30;
  return 'daily_text_$index'.tr();
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StardustHeader().animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 24),
                  Text(
                    'home_hello'.tr(namedArgs: {
                      'name': profile?.firstName ??
                          profile?.displayName ??
                          'Stargazer',
                    }),
                    style: AppTextStyles.headlineLarge,
                  ).animate().fadeIn(delay: 200.ms),
                  if (profile?.sunSign != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${profile!.sunSign!.zodiacName} ${profile.sunSign!.zodiacEmoji}',
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
              child: _buildMainCard(context, ref, profile),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AuraCard(),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.08),
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

  Widget _buildMainCard(
    BuildContext context,
    WidgetRef ref,
    UserProfile? profile,
  ) {
    if (!(profile?.onboardingComplete ?? false)) {
      return CosmicCard(
        onTap: () => context.push('/onboarding'),
        child: Column(
          children: [
            const Icon(Icons.stars, color: AppColors.accentGlow, size: 40),
            const SizedBox(height: 12),
            Text(
              'home_complete_birth_details'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    final horoscope = ref.watch(todayHoroscopeProvider);
    return horoscope.when(
      data: (h) => h != null
          ? HoroscopeCard(horoscope: h)
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.1)
          : _DailyTextCard()
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.08),
      loading: () => const ShimmerCardLoading(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _DailyTextCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A1240), Color(0xFF0D0B22)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌙', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 8),
              Text(
                'home_message_title'.tr(),
                style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 12),
          Text(
            _dailyText(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
