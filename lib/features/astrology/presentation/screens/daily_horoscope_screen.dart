import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shimmer_loading.dart';
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
                  Text('Daily Horoscope', style: AppTextStyles.headlineLarge)
                      .animate()
                      .fadeIn(),
                  const SizedBox(height: 24),
                  horoscope.when(
                    data: (h) => h != null
                        ? HoroscopeCard(horoscope: h).animate().fadeIn(delay: 200.ms)
                        : Text(
                            'Complete your birth details to see your horoscope.',
                            style: AppTextStyles.bodyMedium,
                          ),
                    loading: () => const ShimmerCardLoading(),
                    error: (_, __) => const Text('Error loading horoscope'),
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
