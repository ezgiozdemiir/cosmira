import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/di.dart';

/// Live unread-notification count for the current user, used to drive the
/// badge dot on the notifications bell. Backed by Supabase realtime so it
/// updates the moment a row is inserted or marked read — no polling.
final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(0);

  final client = ref.watch(supabaseClientProvider);
  return client
      .from('notification_log')
      .stream(primaryKey: ['id'])
      .eq('user_id', user.id)
      .map((rows) => rows.where((row) => row['is_read'] == false).length);
});

/// Marks all of the current user's notifications as read. Used when the
/// notifications screen is opened so the bell badge clears.
final markNotificationsReadProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final client = ref.read(supabaseClientProvider);
    await client
        .from('notification_log')
        .update({'is_read': true})
        .eq('user_id', user.id)
        .eq('is_read', false);
  };
});
