import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../home/presentation/widgets/horoscope_card.dart';
import '../providers/astrology_provider.dart';

class DailyHoroscopeScreen extends ConsumerWidget {
  const DailyHoroscopeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sunHoroscope = ref.watch(todayHoroscopeProvider);
    final moonHoroscope = ref.watch(moonHoroscopeProvider);
    final risingHoroscope = ref.watch(risingHoroscopeProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('horoscope_title'.tr(), style: AppTextStyles.headlineLarge)
                      .animate()
                      .fadeIn(),
                  const SizedBox(height: 24),

                  // Sun horoscope
                  _HoroscopeSection(
                    icon: '☀️',
                    label: 'horoscope_sun'.tr(),
                    child: sunHoroscope.when(
                      loading: () => const ShimmerCardLoading(),
                      error: (_, __) => Text('horoscope_error'.tr()),
                      data: (h) {
                        if (h != null) {
                          return HoroscopeCard(horoscope: h)
                              .animate()
                              .fadeIn(delay: 200.ms);
                        }
                        if (ref.watch(userProfileProvider).isLoading) {
                          return const ShimmerCardLoading();
                        }
                        return Text('horoscope_empty'.tr(),
                            style: AppTextStyles.bodyMedium);
                      },
                    ),
                  ),

                  // Moon horoscope (only if moon sign is set)
                  if (profile?.moonSign != null) ...[
                    const SizedBox(height: 28),
                    _HoroscopeSection(
                      icon: '🌙',
                      label: 'horoscope_moon'.tr(),
                      child: moonHoroscope.when(
                        loading: () => const ShimmerCardLoading(),
                        error: (_, __) => Text('horoscope_error'.tr()),
                        data: (h) => h != null
                            ? HoroscopeCard(horoscope: h)
                                .animate()
                                .fadeIn(delay: 300.ms)
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],

                  // Rising horoscope (only if rising sign is set)
                  if (profile?.risingSign != null) ...[
                    const SizedBox(height: 28),
                    _HoroscopeSection(
                      icon: '⬆️',
                      label: 'horoscope_rising'.tr(),
                      child: risingHoroscope.when(
                        loading: () => const ShimmerCardLoading(),
                        error: (_, __) => Text('horoscope_error'.tr()),
                        data: (h) => h != null
                            ? HoroscopeCard(horoscope: h)
                                .animate()
                                .fadeIn(delay: 400.ms)
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _HoroscopeSection extends StatelessWidget {
  final String icon;
  final String label;
  final Widget child;

  const _HoroscopeSection({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelLarge
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
