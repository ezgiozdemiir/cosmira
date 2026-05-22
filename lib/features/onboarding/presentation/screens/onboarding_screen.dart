import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_button.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../widgets/birth_data_form.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _WelcomePage(),
                  _CosmicProfilePage(),
                  const BirthDataForm(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      3,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.accentGlow
                              : AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  CosmicButton(
                    label: _currentPage == 2 ? 'Begin' : 'Next',
                    onPressed: () {
                      if (_currentPage < 2) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 80,
            color: AppColors.accentGlow,
          ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.5, 0.5)),
          const SizedBox(height: 32),
          Text(
            'Welcome to\nCosmira',
            textAlign: TextAlign.center,
            style: AppTextStyles.displayLarge,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 16),
          Text(
            'Your personal cosmic companion for\nself-discovery, growth & inner peace.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}

class _CosmicProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.stars,
            size: 80,
            color: AppColors.auraViolet,
          ).animate().fadeIn(duration: 600.ms),
          const SizedBox(height: 32),
          Text(
            'Your Cosmic\nProfile',
            textAlign: TextAlign.center,
            style: AppTextStyles.displayMedium,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 16),
          Text(
            'We need your birth details to calculate\nyour natal chart and unlock personalized insights.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}
