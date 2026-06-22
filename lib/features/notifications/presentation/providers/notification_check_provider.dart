import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/di.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../domain/services/notification_service.dart';
import 'notification_prefs_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.watch(supabaseClientProvider));
});

/// Fires once per unique combination of (user, balance, prefs, language).
/// The service deduplicates by event_key, so re-runs are always safe.
final notificationCheckProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return;

  final balance = await ref.watch(stardustBalanceProvider.future);
  final profile = ref.watch(userProfileProvider).valueOrNull;
  final prefs = ref.watch(notifPrefsProvider);
  final lang = ref.watch(languageCodeProvider);
  final service = ref.watch(notificationServiceProvider);

  await service.checkAndCreate(
    userId: user.id,
    balance: balance,
    sunSign: profile?.sunSign,
    breathworkEnabled: prefs['breathwork'] ?? false,
    cosmicEventsEnabled: prefs['cosmic_events'] ?? true,
    weeklySummaryEnabled: prefs['weekly_summary'] ?? true,
    languageCode: lang,
  );
});
