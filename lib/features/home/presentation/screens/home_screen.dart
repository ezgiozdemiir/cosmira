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
import '../widgets/quick_action_grid.dart';

// 30 daily spiritual messages — cycles by day of year.
const _dailyTexts = [
  'Your natal chart is a map of the sky at the exact moment you took your first breath. It holds every answer you seek.',
  'The planets that watched over your birth are still speaking. Your chart is the language they left you.',
  'You were born at the perfect cosmic moment. Every placement in your chart was chosen by the universe for you.',
  'Your rising sign shapes how the world sees you. Your moon sign reveals what your soul craves in the dark.',
  'The stars did not place you here by accident. Your natal chart is proof of your divine design.',
  'Sun, Moon, and Rising — your cosmic trinity — together they paint the full portrait of who you are.',
  'You are a living astrology. Every breath carries the energy of the sky on the day you were born.',
  'Your chart does not define your fate. It reveals your gifts so you can choose your destiny freely.',
  'The universe encrypted your purpose in the positions of ten celestial bodies the moment you arrived.',
  'Your north node points to where you are going. Trust the direction the cosmos has always intended for you.',
  'Every planet in your chart is a teacher. Some lessons are gentle, some are fierce — all are sacred.',
  'You are not lost. You are exactly at the coordinate the stars marked out for this chapter of your story.',
  'Your Venus sign knows what your heart truly longs for, long before your mind finds the words.',
  'Your Mars placement is the fire inside you — the drive that no one else on Earth has in quite the same way.',
  'The universe does not make mistakes. Your birth chart is its most personal letter, written for you alone.',
  'Your 12th house holds the wisdom of past lives. The universe never wastes a single experience.',
  'When you feel lost, look up. The same sky that presided over your birth is still holding space for you.',
  'Your natal Mercury shows how your mind was built to receive truth. Trust your unique way of knowing.',
  'Every challenge in your chart is a doorway, not a wall. You were given exactly the lessons you can handle.',
  'Your Jupiter sign marks where abundance flows most naturally for you. Lean into that energy today.',
  'The cosmos put a specific kind of magic in your hands when you were born. Your chart is the instruction manual.',
  'You carry stardust from planets billions of miles away. There is nothing ordinary about your existence.',
  'Your Ascendant is the mask that becomes the face. In time, the role you play becomes who you truly are.',
  'The sky at your birth was a unique configuration that will never exist again. You are genuinely one of a kind.',
  'Your Saturn placement shows where your soul agreed to do the deepest work. Honor that sacred contract.',
  'In the silence between the stars, the universe composed a song. Your natal chart is the sheet music.',
  'The moon was in a particular sign when you arrived. That sign still rules the tides of your emotional world.',
  'Your south node shows where you came from. Your north node points to who you are becoming. Walk forward.',
  'You are the universe experiencing itself through this body, in this lifetime, with this chart. That is enough.',
  'Every transit is a conversation between the sky and your birth chart. The stars are always speaking to you.',
];

String _dailyText() {
  final dayOfYear =
      DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
  return _dailyTexts[dayOfYear % _dailyTexts.length];
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
                    'Hello, ${profile?.firstName ?? profile?.displayName ?? 'Stargazer'}',
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
              child: _buildMainCard(context, ref, profile),
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

  Widget _buildMainCard(
    BuildContext context,
    WidgetRef ref,
    UserProfile? profile,
  ) {
    // New signups: prompt to complete birth data (unchanged)
    if (!(profile?.onboardingComplete ?? false)) {
      return CosmicCard(
        onTap: () => context.push('/onboarding'),
        child: const Column(
          children: [
            Icon(Icons.stars, color: AppColors.accentGlow, size: 40),
            SizedBox(height: 12),
            Text(
              'Complete your birth details\nto unlock your daily horoscope',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    // Onboarded: daily horoscope if available, otherwise daily motivational text
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

/// Shows today's rotating spiritual motivational text with no navigation CTA.
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
                'Message from the Universe',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                ),
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
