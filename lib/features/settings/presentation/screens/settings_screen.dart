import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 24),
            _SettingsSection(
              title: 'Notifications',
              children: [
                _ToggleTile(
                  title: 'Daily Horoscope',
                  subtitle: 'Get your horoscope every morning',
                  value: true,
                  onChanged: (_) {},
                ),
                _ToggleTile(
                  title: 'Moon Phase Alerts',
                  subtitle: 'New & full moon reminders',
                  value: true,
                  onChanged: (_) {},
                ),
                _ToggleTile(
                  title: 'Breathwork Reminders',
                  subtitle: 'Daily practice nudge',
                  value: false,
                  onChanged: (_) {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SettingsSection(
              title: 'Account',
              children: [
                _ActionTile(title: 'Privacy Policy', onTap: () {}),
                _ActionTile(title: 'Terms of Service', onTap: () {}),
                _ActionTile(title: 'Delete Account', onTap: () {}, isDestructive: true),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Cosmira v1.0.0',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
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
            color: AppColors.surface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(children: children),
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
      activeColor: AppColors.accentGlow,
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
