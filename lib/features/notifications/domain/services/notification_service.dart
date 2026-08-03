import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../notification_catalog.dart';

class NotificationService {
  final SupabaseClient _client;
  static const _uuid = Uuid();

  NotificationService(this._client);

  Future<void> checkAndCreate({
    required String userId,
    required int balance,
    String? sunSign,
    bool breathworkEnabled = false,
    bool cosmicEventsEnabled = true,
    bool weeklySummaryEnabled = true,
    String languageCode = 'tr',
  }) async {
    final now = DateTime.now().toUtc();
    Set<String> existingKeys;
    try {
      existingKeys = await _getExistingEventKeys(userId);
    } catch (_) {
      return;
    }

    // Welcome notification — fires once for every new user.
    if (!existingKeys.contains('welcome')) {
      await _insert(userId: userId, type: 'welcome', eventKey: 'welcome', languageCode: languageCode);
      existingKeys.add('welcome');
    }

    // Daily login hint — fires once to teach the user about the daily check-in reward.
    if (!existingKeys.contains('daily_login_hint')) {
      await _insert(userId: userId, type: 'stardust', eventKey: 'daily_login_hint', languageCode: languageCode);
      existingKeys.add('daily_login_hint');
    }

    if (cosmicEventsEnabled) {
      for (final event in NotificationCatalog.events) {
        if (existingKeys.contains(event.key)) continue;
        final windowStart = event.date.subtract(const Duration(days: 3));
        final windowEnd = event.date.add(const Duration(days: 1));
        if (now.isAfter(windowStart) && now.isBefore(windowEnd)) {
          await _insert(userId: userId, type: 'cosmic_event', eventKey: event.key, languageCode: languageCode);
          existingKeys.add(event.key);
        }
      }
    }

    // Stardust milestones (always on)
    for (final threshold in NotificationCatalog.milestoneUnlockKeys.keys) {
      if (balance < threshold) continue;
      final key = 'stardust_milestone_$threshold';
      if (existingKeys.contains(key)) continue;
      await _insert(userId: userId, type: 'stardust_milestone', eventKey: key, languageCode: languageCode);
      existingKeys.add(key);
    }

    // Weekly summary
    if (weeklySummaryEnabled) {
      final weekKey = 'weekly_${now.year}_${NotificationCatalog.isoWeek(now)}';
      if (!existingKeys.contains(weekKey)) {
        await _insert(userId: userId, type: 'weekly_summary', eventKey: weekKey, languageCode: languageCode);
        existingKeys.add(weekKey);
      }
    }

    // Breathwork reminder (daily)
    if (breathworkEnabled) {
      final dayKey = 'breathwork_${now.year}_${now.month}_${now.day}';
      if (!existingKeys.contains(dayKey)) {
        await _insert(userId: userId, type: 'breathwork', eventKey: dayKey, languageCode: languageCode);
        existingKeys.add(dayKey);
      }
    }
  }

  Future<Set<String>> _getExistingEventKeys(String userId) async {
    final data = await _client
        .from('notification_log')
        .select('event_key')
        .eq('user_id', userId);
    final keys = <String>{};
    for (final row in (data as List)) {
      final eventKey = row['event_key'] as String?;
      if (eventKey != null) keys.add(eventKey);
    }
    return keys;
  }

  Future<void> _insert({
    required String userId,
    required String type,
    required String eventKey,
    required String languageCode,
  }) async {
    final now = DateTime.now().toUtc();
    final rendered = NotificationCatalog.render(
      type: type,
      eventKey: eventKey,
      createdAt: now,
      lang: languageCode,
    );
    // Every notification type this service creates has a catalog entry —
    // `rendered` is only null for a type/key mismatch, which would be a bug.
    if (rendered == null) return;

    try {
      // Upsert on (user_id, event_key) rather than a plain insert: the
      // caller's existingKeys check is a read-then-write race under
      // concurrent invocations (e.g. two rebuilds firing close together), so
      // the DB-level unique constraint + ignoreDuplicates is what actually
      // guarantees a given event is only ever stored once per user.
      await _client.from('notification_log').upsert(
        {
          'id': _uuid.v4(),
          'user_id': userId,
          'type': type,
          'event_key': eventKey,
          'title': rendered.title,
          'body': rendered.body,
          'is_read': false,
          'data': {'event_key': eventKey},
          'created_at': now.toIso8601String(),
        },
        onConflict: 'user_id,event_key',
        ignoreDuplicates: true,
      );
    } catch (_) {
      return;
    }

    // Best-effort — a push failure should never affect the in-app
    // notification, which has already been saved above.
    try {
      await _client.functions.invoke('send-push', body: {
        'user_id': userId,
        'title': rendered.title,
        'body': rendered.body,
        'data': {'type': type, 'event_key': eventKey},
      });
    } catch (_) {}
  }
}
