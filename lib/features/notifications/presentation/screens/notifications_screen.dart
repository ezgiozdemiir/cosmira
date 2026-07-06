import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../providers/notifications_provider.dart';
import '../providers/unread_notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Clears the bell badge — fire-and-forget, the badge (a separate
    // realtime stream) updates itself once the rows flip to read.
    ref.read(markNotificationsReadProvider)();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);

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
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.textPrimary),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Text('notif_title'.tr(), style: AppTextStyles.titleLarge),
                  ],
                ),
              ),
              Expanded(
                child: notifications.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_none,
                                size: 48,
                                color: AppColors.textTertiary),
                            const SizedBox(height: 12),
                            Text('notif_empty'.tr(),
                                style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: item.isRead
                                ? Colors.transparent
                                : AppColors.accentGlow.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _iconForType(item.type),
                                color: _colorForType(item.type),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.title,
                                        style: AppTextStyles.titleMedium),
                                    const SizedBox(height: 4),
                                    Text(item.body,
                                        style: AppTextStyles.bodySmall),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.createdAt.formatted,
                                      style: AppTextStyles.labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                              if (!item.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.accentGlow,
                                  ),
                                ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (index * 50).ms);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) =>
                      Center(child: Text('notif_error'.tr())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'horoscope':
        return Icons.stars;
      case 'moon':
        return Icons.nightlight_round;
      case 'stardust':
      case 'stardust_milestone':
        return Icons.auto_awesome;
      case 'streak':
        return Icons.local_fire_department;
      case 'cosmic_event':
        return Icons.flare;
      case 'weekly_summary':
        return Icons.calendar_today;
      case 'breathwork':
        return Icons.air;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'horoscope':
        return AppColors.auraViolet;
      case 'moon':
        return AppColors.auraIndigo;
      case 'stardust':
      case 'stardust_milestone':
        return AppColors.auraAmber;
      case 'streak':
        return AppColors.auraRose;
      case 'cosmic_event':
        return AppColors.accentGlow;
      case 'weekly_summary':
        return AppColors.auraViolet;
      case 'breathwork':
        return AppColors.auraTeal;
      default:
        return AppColors.accentGlow;
    }
  }
}
