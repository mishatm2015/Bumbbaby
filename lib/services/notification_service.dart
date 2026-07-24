import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Wraps `flutter_local_notifications` so the Reminders screen can turn its
/// toggles into real, sound-capable local notifications.
///
/// Android channels are created up front for every sound/vibration
/// combination (channel settings can't be changed after creation), and the
/// right channel is picked at schedule time based on the user's current
/// Notification Style preferences.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Reminder id ranges — kept stable so re-scheduling replaces, not stacks.
  static const int medicineBaseId = 100; // 100..149
  static const int waterBaseId = 200; // 200..229
  static const int kickCountId = 300;
  static const int weightCheckId = 301;
  static const int sleepReminderId = 302;
  static const int dailyTipId = 303;
  static const int appointmentDayBeforeBaseId = 400; // 400..499 (per appt)
  static const int appointmentHourBeforeBaseId = 500; // 500..599 (per appt)
  static const int testNotificationId = 999;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('NotificationService: could not resolve local timezone: $e');
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      ),
    );

    await _createAndroidChannels();
  }

  static Future<void> _createAndroidChannels() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    for (final sound in [true, false]) {
      for (final vibration in [true, false]) {
        await android.createNotificationChannel(
          AndroidNotificationChannel(
            _channelId(sound: sound, vibration: vibration),
            'Reminders',
            description: 'MamaBloom reminder alerts',
            importance: Importance.max,
            playSound: sound,
            enableVibration: vibration,
          ),
        );
      }
    }
  }

  static String _channelId({required bool sound, required bool vibration}) {
    final s = sound ? 's1' : 's0';
    final v = vibration ? 'v1' : 'v0';
    return 'reminders_${s}_$v';
  }

  /// Requests the OS-level permission needed to show notifications at all
  /// (Android 13+ runtime permission, iOS alert/badge/sound prompt).
  static Future<bool> requestPermission() async {
    await init();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? true;
    }

    return true;
  }

  static NotificationDetails _details({
    required bool sound,
    required bool vibration,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId(sound: sound, vibration: vibration),
        'Reminders',
        channelDescription: 'MamaBloom reminder alerts',
        importance: Importance.max,
        priority: Priority.high,
        playSound: sound,
        enableVibration: vibration,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: sound,
      ),
    );
  }

  /// Fires an immediate notification — used by the "Test reminder" action so
  /// the user can hear how it sounds right away.
  static Future<void> showNow({
    required String title,
    required String body,
    required bool sound,
    required bool vibration,
  }) async {
    await init();
    await _plugin.show(
      id: testNotificationId,
      title: title,
      body: body,
      notificationDetails: _details(sound: sound, vibration: vibration),
    );
  }

  /// Schedules (or replaces) a notification that repeats every day at
  /// [hour]:[minute] local time.
  static Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required bool sound,
    required bool vibration,
  }) async {
    await init();
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfTime(hour, minute),
      notificationDetails: _details(sound: sound, vibration: vibration),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedules (or replaces) a notification that repeats every week on
  /// [weekday] (1 = Monday .. 7 = Sunday) at [hour]:[minute] local time.
  static Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
    required bool sound,
    required bool vibration,
  }) async {
    await init();
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfWeekday(weekday, hour, minute),
      notificationDetails: _details(sound: sound, vibration: vibration),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Schedules hourly notifications between [startHour] and [endHour]
  /// (inclusive), one id per hour starting at [baseId].
  static Future<void> scheduleHourlyRange({
    required int baseId,
    required int startHour,
    required int endHour,
    required String title,
    required String body,
    required bool sound,
    required bool vibration,
  }) async {
    await init();
    var slot = 0;
    for (var h = startHour; h <= endHour; h++) {
      await scheduleDaily(
        id: baseId + slot,
        title: title,
        body: body,
        hour: h,
        minute: 0,
        sound: sound,
        vibration: vibration,
      );
      slot++;
    }
    // Clear any previously-used slots beyond the current range.
    for (var extra = slot; extra < 30; extra++) {
      await cancel(baseId + extra);
    }
  }

  /// Schedules a one-off reminder at an exact future [dateTime]. Silently
  /// skipped if that moment has already passed.
  static Future<void> scheduleOneOff({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    required bool sound,
    required bool vibration,
  }) async {
    await init();
    if (dateTime.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(dateTime, tz.local),
      notificationDetails: _details(sound: sound, vibration: vibration),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancel(int id) async {
    await init();
    await _plugin.cancel(id: id);
  }

  static Future<void> cancelRange(int baseId, int count) async {
    for (var i = 0; i < count; i++) {
      await cancel(baseId + i);
    }
  }

  static Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static tz.TZDateTime _nextInstanceOfWeekday(
      int weekday, int hour, int minute) {
    var scheduled = _nextInstanceOfTime(hour, minute);
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
