import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_button.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../astrology/presentation/providers/astrology_provider.dart';
import '../../../auth/data/models/user_profile_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../stardust/presentation/providers/stardust_provider.dart';
import '../widgets/birth_data_form.dart';
import '../widgets/personal_info_form.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isSaving = false;

  String _firstName = '';
  String _lastName = '';
  String? _gender;

  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  String _birthCity = '';
  String _referralCode = '';
  final _referralCtrl = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _referralCtrl.dispose();
    super.dispose();
  }

  static String? _sunSignFromDate(DateTime date) {
    final m = date.month;
    final d = date.day;
    if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) return 'aries';
    if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) return 'taurus';
    if ((m == 5 && d >= 21) || (m == 6 && d <= 20)) return 'gemini';
    if ((m == 6 && d >= 21) || (m == 7 && d <= 22)) return 'cancer';
    if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) return 'leo';
    if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) return 'virgo';
    if ((m == 9 && d >= 23) || (m == 10 && d <= 22)) return 'libra';
    if ((m == 10 && d >= 23) || (m == 11 && d <= 21)) return 'scorpio';
    if ((m == 11 && d >= 22) || (m == 12 && d <= 21)) return 'sagittarius';
    if ((m == 12 && d >= 22) || (m == 1 && d <= 19)) return 'capricorn';
    if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) return 'aquarius';
    return 'pisces';
  }

  Future<void> _saveAndContinue() async {
    if (_firstName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('validate_first_name'.tr())),
      );
      return;
    }

    if (_lastName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('validate_last_name'.tr())),
      );
      return;
    }

    if (_gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('validate_gender'.tr())),
      );
      return;
    }

    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('validate_birth_date'.tr())),
      );
      return;
    }

    if (_birthTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('validate_birth_time'.tr())),
      );
      return;
    }

    if (_birthCity.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('validate_birth_city'.tr())),
      );
      return;
    }

    setState(() => _isSaving = true);

    final profile = ref.read(userProfileProvider).valueOrNull;
    final userId = ref.read(currentUserProvider)?.id;

    if (userId == null) {
      setState(() => _isSaving = false);
      return;
    }

    final birthTimeStr =
        '${_birthTime!.hour.toString().padLeft(2, '0')}:${_birthTime!.minute.toString().padLeft(2, '0')}';

    var sunSign = _sunSignFromDate(_birthDate!);
    var moonSign = profile?.moonSign;
    var risingSign = profile?.risingSign;
    var mcSign = profile?.mcSign;
    var birthLat = profile?.birthLat;
    var birthLng = profile?.birthLng;

    final bigThree = await ref.read(astrologyRepositoryProvider).calculateBigThree(
          birthDate: _birthDate!,
          birthTime: birthTimeStr,
          birthCity: _birthCity.trim(),
        );
    bigThree.when(
      success: (r) {
        sunSign = r.sunSign;
        moonSign = r.moonSign;
        risingSign = r.risingSign;
        mcSign = r.mcSign;
        birthLat = r.birthLat;
        birthLng = r.birthLng;
      },
      // Network hiccup or unrecognized city: keep the date-based sun sign
      // and leave moon/rising/mc as-is. User can retry from Edit Profile.
      failure: (_) {},
    );

    final updated = UserProfileModel(
      id: profile?.id ?? userId,
      displayName: profile?.displayName,
      firstName: _firstName.trim(),
      lastName: _lastName.trim(),
      gender: _gender,
      avatarUrl: profile?.avatarUrl,
      birthDate: _birthDate,
      birthTime: birthTimeStr,
      birthCity: _birthCity.trim(),
      birthLat: birthLat,
      birthLng: birthLng,
      sunSign: sunSign,
      moonSign: moonSign,
      risingSign: risingSign,
      mcSign: mcSign,
      subscriptionTier: profile?.subscriptionTier ?? 'free',
      onboardingComplete: true,
      createdAt: profile?.createdAt ?? DateTime.now(),
    );

    final result = await ref.read(authRepositoryProvider).updateProfile(updated);

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.when(
      success: (_) async {
        // Claim referral reward if a code was entered
        final code = _referralCode.trim().toUpperCase();
        if (code.isNotEmpty) {
          await ref.read(stardustRepositoryProvider).claimReferral(
                referralCode: code,
                newUserId: userId,
              );
        }

        ref.invalidate(userProfileProvider);
        if (mounted) context.go('/');
      },
      failure: (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: ${f.message}')),
      ),
    );
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
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Text('Your Details', style: AppTextStyles.headlineLarge),
                        const SizedBox(height: 8),
                        Text(
                          'This information is used to personalize your experience '
                          'and calculate your unique natal chart.',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 32),
                        PersonalInfoForm(
                          onDataChanged: (firstName, lastName, gender) {
                            _firstName = firstName;
                            _lastName = lastName;
                            _gender = gender;
                          },
                        ),
                        const SizedBox(height: 24),
                        BirthDataForm(
                          onDataChanged: (date, time, city) {
                            _birthDate = date;
                            _birthTime = time;
                            _birthCity = city;
                          },
                        ),
                        const SizedBox(height: 32),
                        Text('onboarding_referral_label'.tr(),
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _referralCtrl,
                          textCapitalization: TextCapitalization.characters,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white, letterSpacing: 2),
                          decoration: InputDecoration(
                            hintText: 'onboarding_referral_hint'.tr(),
                            hintStyle: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textTertiary),
                            prefixIcon: const Icon(Icons.auto_awesome,
                                color: AppColors.accentGlow, size: 18),
                            filled: true,
                            fillColor:
                                AppColors.accentGlow.withValues(alpha: 0.06),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: AppColors.accentGlow
                                      .withValues(alpha: 0.25)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: AppColors.accentGlow
                                      .withValues(alpha: 0.2)),
                            ),
                          ),
                          onChanged: (v) => _referralCode = v,
                        ),
                      ],
                    ),
                  ),
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
                    isLoading: _isSaving,
                    onPressed: () {
                      if (_currentPage < 2) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _saveAndContinue();
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
