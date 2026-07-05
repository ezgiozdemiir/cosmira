import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../features/auth/domain/entities/user_profile.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Chip-style gender picker, shared between the user's own profile forms
/// (onboarding, Edit Profile) and the Loved One form.
class GenderSelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChanged;

  const GenderSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Gender.values.map((g) {
        final selected = value == g;
        return GestureDetector(
          onTap: () => onChanged(g),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: selected ? AppColors.accentGradient : null,
              color: selected ? null : AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? Colors.transparent : AppColors.cardBorder,
              ),
            ),
            child: Text(
              'gender_$g'.tr(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
