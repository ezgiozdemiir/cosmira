import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/language_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../notifications/presentation/providers/notification_prefs_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageCodeProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 4),
                    Text('settings_title'.tr(),
                        style: AppTextStyles.headlineLarge),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsSection(
                  title: 'settings_language'.tr(),
                  children: [
                    _LanguageTile(currentLang: currentLang),
                  ],
                ),
                const SizedBox(height: 24),
                _NotificationSettingsSection(),
                const SizedBox(height: 24),
                _SettingsSection(
                  title: 'settings_account'.tr(),
                  children: [
                    _ActionTile(
                        title: 'settings_privacy_policy'.tr(),
                        onTap: () => context.push('/privacy')),
                    _ActionTile(
                        title: 'settings_terms_of_service'.tr(),
                        onTap: () => context.push('/terms')),
                    _ActionTile(
                      title: 'settings_delete_account'.tr(),
                      onTap: () {},
                      isDestructive: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'settings_version'.tr(),
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends ConsumerWidget {
  final String currentLang;
  const _LanguageTile({required this.currentLang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.language, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text('settings_language'.tr(), style: AppTextStyles.bodyLarge),
          ),
          _LangChip(
            label: 'settings_language_en'.tr(),
            selected: currentLang == 'en',
            onTap: () async {
              if (currentLang == 'en') return;
              await context.setLocale(const Locale('en'));
              await ref.read(languageCodeProvider.notifier).setLanguage('en');
              if (context.mounted) context.go('/');
            },
          ),
          const SizedBox(width: 8),
          _LangChip(
            label: 'settings_language_tr'.tr(),
            selected: currentLang == 'tr',
            onTap: () async {
              if (currentLang == 'tr') return;
              await context.setLocale(const Locale('tr'));
              await ref.read(languageCodeProvider.notifier).setLanguage('tr');
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentGlow.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.accentGlow
                : AppColors.textTertiary.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: selected ? AppColors.accentGlow : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headlineSmall),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _NotificationSettingsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notifPrefsProvider);
    final notifier = ref.read(notifPrefsProvider.notifier);

    return _SettingsSection(
      title: 'settings_notifications'.tr(),
      children: [
        _ToggleTile(
          title: 'settings_daily_horoscope'.tr(),
          subtitle: 'settings_daily_horoscope_sub'.tr(),
          value: prefs['daily_horoscope'] ?? true,
          onChanged: (v) => notifier.toggle('daily_horoscope', v),
        ),
        _ToggleTile(
          title: 'settings_moon_alerts'.tr(),
          subtitle: 'settings_moon_alerts_sub'.tr(),
          value: prefs['moon_alerts'] ?? true,
          onChanged: (v) => notifier.toggle('moon_alerts', v),
        ),
        _ToggleTile(
          title: 'settings_cosmic_events'.tr(),
          subtitle: 'settings_cosmic_events_sub'.tr(),
          value: prefs['cosmic_events'] ?? true,
          onChanged: (v) => notifier.toggle('cosmic_events', v),
        ),
        _ToggleTile(
          title: 'settings_weekly_summary'.tr(),
          subtitle: 'settings_weekly_summary_sub'.tr(),
          value: prefs['weekly_summary'] ?? true,
          onChanged: (v) => notifier.toggle('weekly_summary', v),
        ),
        _ToggleTile(
          title: 'settings_breathwork_reminders'.tr(),
          subtitle: 'settings_breathwork_reminders_sub'.tr(),
          value: prefs['breathwork'] ?? false,
          onChanged: (v) => notifier.toggle('breathwork', v),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.accentGlow,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionTile({
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDestructive ? AppColors.error : null,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive ? AppColors.error : AppColors.textTertiary,
      ),
      onTap: onTap,
    );
  }
}
