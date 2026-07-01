import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/premium_upsell_card.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final stardust = ref.watch(stardustBalanceProvider).valueOrNull ?? 0;
    final streak = ref.watch(streakProvider).valueOrNull ?? 0;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.accentGlow.withValues(alpha: 0.2),
                    child: Text(
                      profile?.sunSign?.zodiacEmoji ?? '✨',
                      style: const TextStyle(fontSize: 40),
                    ),
                  ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 16),
                  Text(
                    (profile?.fullName.isNotEmpty ?? false)
                        ? profile!.fullName
                        : profile?.displayName ?? 'Stargazer',
                    style: AppTextStyles.headlineMedium,
                  ).animate().fadeIn(delay: 200.ms),
                  if (profile?.sunSign != null)
                    Text(
                      '${profile!.sunSign!.zodiacName} ${'profile_sun'.tr()} • ${profile.moonSign?.zodiacName ?? '?'} ${'profile_moon'.tr()} • ${profile.risingSign?.zodiacName ?? '?'} ${'profile_rising'.tr()}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.accentGlow,
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatBadge(
                        icon: Icons.auto_awesome,
                        value: '$stardust',
                        label: 'profile_stardust'.tr(),
                        color: AppColors.auraAmber,
                      ),
                      const SizedBox(width: 24),
                      _StatBadge(
                        icon: Icons.local_fire_department,
                        value: '$streak',
                        label: 'profile_streak'.tr(),
                        color: AppColors.auraRose,
                      ),
                      const SizedBox(width: 24),
                      _StatBadge(
                        icon: Icons.workspace_premium,
                        value: profile?.isPremium == true
                            ? 'profile_plan_pro'.tr()
                            : 'profile_plan_free'.tr(),
                        label: 'profile_plan'.tr(),
                        color: AppColors.auraViolet,
                      ),
                    ],
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 32),
                  if (profile?.isPremium != true)
                    const PremiumUpsellCard().animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 16),
                  _ProfileMenuItem(
                    icon: Icons.edit,
                    label: 'profile_edit'.tr(),
                    onTap: () => context.push('/profile/edit'),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.auto_awesome,
                    label: 'profile_stardust_store'.tr(),
                    onTap: () => context.push('/stardust'),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    label: 'profile_notifications'.tr(),
                    onTap: () => context.push('/notifications'),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.share,
                    label: 'profile_share'.tr(),
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.settings_outlined,
                    label: 'profile_settings'.tr(),
                    onTap: () => context.push('/settings'),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.help_outline,
                    label: 'profile_help'.tr(),
                    onTap: () => context.push('/help'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        ref.read(authControllerProvider.notifier).signOut(),
                    child: Text(
                      'profile_sign_out'.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.titleMedium),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: AppTextStyles.bodyLarge),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
