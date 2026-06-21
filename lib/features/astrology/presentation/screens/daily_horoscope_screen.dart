import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../home/presentation/widgets/horoscope_card.dart';

class DailyHoroscopeScreen extends ConsumerWidget {
  const DailyHoroscopeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horoscope = ref.watch(todayHoroscopeProvider);

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
                  horoscope.when(
                    loading: () => const ShimmerCardLoading(),
                    error: (_, __) => Text('horoscope_error'.tr()),
                    data: (h) {
                      if (h != null) {
                        return HoroscopeCard(horoscope: h)
                            .animate()
                            .fadeIn(delay: 200.ms);
                      }
                      // Show shimmer while profile is still loading
                      final profileLoading =
                          ref.watch(userProfileProvider).isLoading;
                      if (profileLoading) return const ShimmerCardLoading();
                      return Text(
                        'horoscope_empty'.tr(),
                        style: AppTextStyles.bodyMedium,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
