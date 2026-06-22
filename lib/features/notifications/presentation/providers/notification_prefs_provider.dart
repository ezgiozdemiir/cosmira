import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotifPrefsNotifier extends StateNotifier<Map<String, bool>> {
  NotifPrefsNotifier()
      : super({
          'daily_horoscope': true,
          'moon_alerts': true,
          'breathwork': false,
          'cosmic_events': true,
          'weekly_summary': true,
        }) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = {
      'daily_horoscope': prefs.getBool('notif_daily_horoscope') ?? true,
      'moon_alerts': prefs.getBool('notif_moon_alerts') ?? true,
      'breathwork': prefs.getBool('notif_breathwork') ?? false,
      'cosmic_events': prefs.getBool('notif_cosmic_events') ?? true,
      'weekly_summary': prefs.getBool('notif_weekly_summary') ?? true,
    };
  }

  Future<void> toggle(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_$key', value);
    state = {...state, key: value};
  }
}

final notifPrefsProvider =
    StateNotifierProvider<NotifPrefsNotifier, Map<String, bool>>(
  (ref) => NotifPrefsNotifier(),
);
