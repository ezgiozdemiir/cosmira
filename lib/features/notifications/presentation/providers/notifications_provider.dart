import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/di.dart';
import '../../data/models/notification_model.dart';
import '../../domain/entities/notification_item.dart';

final notificationsProvider =
    FutureProvider<List<NotificationItem>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final client = ref.watch(supabaseClientProvider);
  final data = await client
      .from('notification_log')
      .select()
      .eq('user_id', user.id)
      .order('created_at', ascending: false)
      .limit(50);

  return (data as List).map((j) => NotificationModel.fromJson(j)).toList();
});
