import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../router/app_router.dart';

const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
  'cosmira_default',
  'Cosmira Notifications',
  description: 'Cosmic events, Stardust rewards, and daily updates',
  importance: Importance.high,
);

/// Wires Firebase Cloud Messaging + flutter_local_notifications so
/// notification_log rows (see NotificationService) also arrive as real
/// phone push notifications, and routes taps back into the app.
///
/// Push delivery is sent server-side by the `send-push` edge function —
/// this class only handles on-device permission/token/display/tap wiring.
/// Web is out of scope (web push needs a VAPID key + service worker, a
/// separate flow) so every entry point below no-ops under kIsWeb.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _lastToken;
  bool _initialized = false;

  Future<void> initialize() async {
    if (kIsWeb || _initialized) return;
    _initialized = true;

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (_) => _openNotifications(),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // Foreground: FCM does not auto-display a system notification while the
    // app is open, so show one ourselves via flutter_local_notifications.
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    });

    // Background/terminated: the OS already displayed the notification (the
    // send-push function always includes a `notification` payload) — this
    // just routes the tap back into the app.
    FirebaseMessaging.onMessageOpenedApp.listen((_) => _openNotifications());
    final initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) _openNotifications();

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _lastToken = token;
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        _upsertToken(Supabase.instance.client, userId, token);
      }
    });
  }

  void _openNotifications() {
    rootNavigatorKey.currentContext?.push('/notifications');
  }

  Future<void> registerDeviceToken(
      SupabaseClient client, String userId) async {
    if (kIsWeb) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    _lastToken = token;
    await _upsertToken(client, userId, token);
  }

  Future<void> _upsertToken(
      SupabaseClient client, String userId, String token) async {
    try {
      await client.from('device_tokens').upsert({
        'user_id': userId,
        'token': token,
        'platform':
            defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'token');
    } catch (_) {}
  }

  Future<void> unregisterDeviceToken(SupabaseClient client) async {
    if (kIsWeb) return;
    final token = _lastToken;
    if (token == null) return;
    try {
      await client.from('device_tokens').delete().eq('token', token);
    } catch (_) {}
  }
}
