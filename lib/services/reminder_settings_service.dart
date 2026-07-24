import 'package:shared_preferences/shared_preferences.dart';

/// Persists the Reminders screen's toggle + schedule state locally, so it
/// survives app restarts and can be turned into real scheduled notifications.
class ReminderSettingsService {
  ReminderSettingsService._();

  static const _keyPrefix = 'reminder_enabled_';
  static const _pushKey = 'notif_push';
  static const _soundKey = 'notif_sound';
  static const _vibrationKey = 'notif_vibration';
  static const _medTimesKey = 'reminder_med_times';

  static Future<Map<String, bool>> loadReminderToggles(
      Map<String, bool> defaults) async {
    final prefs = await SharedPreferences.getInstance();
    return {
      for (final entry in defaults.entries)
        entry.key: prefs.getBool('$_keyPrefix${entry.key}') ?? entry.value,
    };
  }

  static Future<void> saveReminderToggles(Map<String, bool> toggles) async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in toggles.entries) {
      await prefs.setBool('$_keyPrefix${entry.key}', entry.value);
    }
  }

  static Future<({bool push, bool sound, bool vibration})>
      loadNotificationStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      push: prefs.getBool(_pushKey) ?? true,
      sound: prefs.getBool(_soundKey) ?? true,
      vibration: prefs.getBool(_vibrationKey) ?? true,
    );
  }

  static Future<void> saveNotificationStyle({
    required bool push,
    required bool sound,
    required bool vibration,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushKey, push);
    await prefs.setBool(_soundKey, sound);
    await prefs.setBool(_vibrationKey, vibration);
  }

  static Future<List<String>> loadMedTimes(List<String> defaults) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_medTimesKey) ?? defaults;
  }

  static Future<void> saveMedTimes(List<String> times) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_medTimesKey, times);
  }
}
