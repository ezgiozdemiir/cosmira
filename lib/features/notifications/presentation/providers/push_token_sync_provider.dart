import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/di.dart';
import '../../domain/services/push_notification_service.dart';

/// Registers this device's FCM token against the signed-in user as soon as
/// they log in — watched once from the app root (see main.dart) so it stays
/// alive for the whole session and re-registers on every account switch.
final pushTokenSyncProvider = Provider<void>((ref) {
  ref.listen<User?>(currentUserProvider, (previous, next) {
    if (next != null) {
      PushNotificationService.instance
          .registerDeviceToken(ref.read(supabaseClientProvider), next.id);
    }
  }, fireImmediately: true);
});
