import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cosmic_button.dart';
import '../../../astrology/presentation/providers/astrology_provider.dart';
import '../../../auth/data/models/user_profile_model.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../onboarding/presentation/widgets/birth_data_form.dart';
import '../../../onboarding/presentation/widgets/personal_info_form.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  bool _isSaving = false;

  String _firstName = '';
  String _lastName = '';
  String? _gender;

  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  String _birthCity = '';

  static String _sunSignFromDate(DateTime date) {
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

  static String? _normalizedTime(String? t) {
    if (t == null) return null;
    final parts = t.split(':');
    if (parts.length < 2) return t;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  static bool _isSameDate(DateTime? a, DateTime? b) {
    if (a == null || b == null) return a == b;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<bool?> _showBirthChangeConfirmDialog({required int remaining, required int limit}) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('edit_profile_birth_change_confirm_title'.tr(), style: AppTextStyles.titleMedium),
        content: Text(
          'edit_profile_birth_change_confirm_body'
              .tr(namedArgs: {'remaining': '$remaining', 'limit': '$limit'}),
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('edit_profile_birth_change_cancel'.tr(),
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('edit_profile_birth_change_continue'.tr(),
                style: const TextStyle(color: AppColors.auraAmber)),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showBirthChangeLimitDialog({required int limit, required bool isFree}) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('edit_profile_birth_change_limit_title'.tr(), style: AppTextStyles.titleMedium),
        content: Text(
          'edit_profile_birth_change_limit_body'.tr(namedArgs: {'limit': '$limit'}),
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          if (isFree)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('edit_profile_birth_change_limit_upgrade'.tr(),
                  style: const TextStyle(color: AppColors.auraAmber)),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('edit_profile_birth_change_limit_ok'.tr(),
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Future<void> _persist({
    required String userId,
    required UserProfile? profile,
    required DateTime? birthDate,
    required String? birthTime,
    required String birthCity,
    required double? birthLat,
    required double? birthLng,
    required String? sunSign,
    required String? moonSign,
    required String? risingSign,
    required String? mcSign,
  }) async {
    final updated = UserProfileModel(
      id: userId,
      displayName: profile?.displayName,
      firstName: _firstName.trim(),
      lastName: _lastName.trim(),
      gender: _gender,
      avatarUrl: profile?.avatarUrl,
      birthDate: birthDate,
      birthTime: birthTime,
      birthCity: birthCity,
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
      success: (_) {
        ref.invalidate(userProfileProvider);
        context.pop();
      },
      failure: (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('edit_profile_save_error'.tr(namedArgs: {'error': f.message}))),
      ),
    );
  }

  Future<void> _save() async {
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

    final profile = ref.read(userProfileProvider).valueOrNull;
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    final birthTimeStr =
        '${_birthTime!.hour.toString().padLeft(2, '0')}:${_birthTime!.minute.toString().padLeft(2, '0')}';
    final birthCityTrimmed = _birthCity.trim();

    final birthChanged = profile != null &&
        (!_isSameDate(profile.birthDate, _birthDate) ||
            _normalizedTime(profile.birthTime) != birthTimeStr ||
            profile.birthCity?.trim() != birthCityTrimmed);

    if (!birthChanged) {
      // Only name/gender/etc. changed — no recalculation needed, no edit consumed.
      setState(() => _isSaving = true);
      await _persist(
        userId: userId,
        profile: profile,
        birthDate: profile?.birthDate ?? _birthDate,
        birthTime: profile?.birthTime ?? birthTimeStr,
        birthCity: profile?.birthCity ?? birthCityTrimmed,
        birthLat: profile?.birthLat,
        birthLng: profile?.birthLng,
        sunSign: profile?.sunSign,
        moonSign: profile?.moonSign,
        risingSign: profile?.risingSign,
        mcSign: profile?.mcSign,
      );
      return;
    }

    final remaining = profile.birthDataEditsRemaining;
    if (remaining <= 0) {
      final wantsUpgrade = await _showBirthChangeLimitDialog(
        limit: profile.birthDataEditLimit,
        isFree: !profile.isPremium,
      );
      if (wantsUpgrade == true && mounted) {
        context.push('/paywall');
        return;
      }
      // Save the non-birth-field changes, keeping birth data at its current value.
      setState(() => _isSaving = true);
      await _persist(
        userId: userId,
        profile: profile,
        birthDate: profile.birthDate,
        birthTime: profile.birthTime,
        birthCity: profile.birthCity ?? birthCityTrimmed,
        birthLat: profile.birthLat,
        birthLng: profile.birthLng,
        sunSign: profile.sunSign,
        moonSign: profile.moonSign,
        risingSign: profile.risingSign,
        mcSign: profile.mcSign,
      );
      return;
    }

    final confirmed = await _showBirthChangeConfirmDialog(
      remaining: remaining,
      limit: profile.birthDataEditLimit,
    );
    if (confirmed != true) return;

    setState(() => _isSaving = true);

    var sunSign = _sunSignFromDate(_birthDate!);
    var moonSign = profile.moonSign;
    var risingSign = profile.risingSign;
    var mcSign = profile.mcSign;
    var birthLat = profile.birthLat;
    var birthLng = profile.birthLng;

    final bigThree = await ref.read(astrologyRepositoryProvider).calculateBigThree(
          birthDate: _birthDate!,
          birthTime: birthTimeStr,
          birthCity: birthCityTrimmed,
        );
    bool bigThreeFailed = false;
    bigThree.when(
      success: (r) {
        sunSign = r.sunSign;
        moonSign = r.moonSign;
        risingSign = r.risingSign;
        mcSign = r.mcSign;
        birthLat = r.birthLat;
        birthLng = r.birthLng;
      },
      failure: (f) {
        bigThreeFailed = true;
        debugPrint('calculateBigThree failed: ${f.message}');
      },
    );

    if (bigThreeFailed) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('edit_profile_birth_calc_error'.tr()),
          backgroundColor: Colors.red[700],
        ),
      );
      return;
    }

    final editResult = await ref.read(authRepositoryProvider).editBirthData(
          birthDate: _birthDate!,
          birthTime: birthTimeStr,
          birthCity: birthCityTrimmed,
          birthLat: birthLat,
          birthLng: birthLng,
          sunSign: sunSign,
          moonSign: moonSign,
          risingSign: risingSign,
          mcSign: mcSign,
        );

    if (!mounted) return;

    final editOk = editResult.when(
      success: (_) => true,
      failure: (f) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('edit_profile_save_error'.tr(namedArgs: {'error': f.message}))),
        );
        return false;
      },
    );
    if (!editOk) return;

    await _persist(
      userId: userId,
      profile: profile,
      birthDate: _birthDate,
      birthTime: birthTimeStr,
      birthCity: birthCityTrimmed,
      birthLat: birthLat,
      birthLng: birthLng,
      sunSign: sunSign,
      moonSign: moonSign,
      risingSign: risingSign,
      mcSign: mcSign,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final initialTime = profile?.birthTime != null
        ? TimeOfDay(
            hour: int.parse(profile!.birthTime!.split(':')[0]),
            minute: int.parse(profile.birthTime!.split(':')[1]),
          )
        : null;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Text('edit_profile_title'.tr(), style: AppTextStyles.titleLarge),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PersonalInfoForm(
                        key: ValueKey(profile?.id),
                        initialFirstName: profile?.firstName,
                        initialLastName: profile?.lastName,
                        initialGender: profile?.gender,
                        onDataChanged: (firstName, lastName, gender) {
                          _firstName = firstName;
                          _lastName = lastName;
                          _gender = gender;
                        },
                      ),
                      const SizedBox(height: 24),
                      BirthDataForm(
                        initialDate: profile?.birthDate,
                        initialTime: initialTime,
                        initialCity: profile?.birthCity,
                        onDataChanged: (date, time, city) {
                          _birthDate = date;
                          _birthTime = time;
                          _birthCity = city;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: CosmicButton(
                    label: 'edit_profile_save'.tr(),
                    isLoading: _isSaving,
                    onPressed: _save,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
