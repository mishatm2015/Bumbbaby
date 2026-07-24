import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/appointment_service.dart';
import '../services/notification_service.dart';
import '../services/reminder_settings_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  static const _ink = Color(0xFF2D2A32);
  static const _accent = Color(0xFF5B6EE8);

  bool _loading = true;
  bool _saving = false;

  final List<_ReminderItem> _reminders = [
    _ReminderItem(
      key: 'medicine',
      emoji: '💊',
      emojiColor: const Color(0xFFE85A5A),
      title: 'Medicine reminders',
      subtitle: 'Folic acid, Iron, Calcium alerts',
      enabled: true,
    ),
    _ReminderItem(
      key: 'water',
      emoji: '💧',
      emojiColor: const Color(0xFF4A9FE8),
      title: 'Water intake',
      subtitle: 'Hourly hydration nudges, 9 AM–9 PM',
      enabled: true,
    ),
    _ReminderItem(
      key: 'appointments',
      emoji: '📅',
      emojiColor: const Color(0xFF4CAF6A),
      title: 'Appointment alerts',
      subtitle: '1 day and 1 hour before',
      enabled: true,
    ),
    _ReminderItem(
      key: 'kicks',
      emoji: '👶',
      emojiColor: const Color(0xFFFF9B50),
      title: 'Kick count reminder',
      subtitle: 'Daily at 8 PM',
      enabled: true,
    ),
    _ReminderItem(
      key: 'weight',
      emoji: '⚖️',
      emojiColor: const Color(0xFFB88A6A),
      title: 'Weekly weight check',
      subtitle: 'Every Monday, 9 AM',
      enabled: true,
    ),
    _ReminderItem(
      key: 'sleep',
      emoji: '🌙',
      emojiColor: const Color(0xFF9B7ED9),
      title: 'Sleep reminder',
      subtitle: 'Bedtime nudge at 10 PM',
      enabled: false,
    ),
    _ReminderItem(
      key: 'tips',
      emoji: '📋',
      emojiColor: const Color(0xFF6B6570),
      title: 'Daily pregnancy tip',
      subtitle: 'Morning tip at 9 AM',
      enabled: false,
    ),
  ];

  final List<_MedItem> _meds = [
    _MedItem(
      emoji: '💊',
      emojiColor: const Color(0xFFE85A5A),
      name: 'Folic Acid 5mg',
      note: 'Morning with food',
      time: '8:00 AM',
    ),
    _MedItem(
      emoji: '🟡',
      emojiColor: const Color(0xFFFF9B50),
      name: 'Iron 100mg',
      note: 'Afternoon, empty stomach',
      time: '2:00 PM',
    ),
    _MedItem(
      emoji: '🔵',
      emojiColor: const Color(0xFF4A9FE8),
      name: 'Calcium 500mg',
      note: 'Night after dinner',
      time: '9:30 PM',
    ),
  ];

  bool _push = true;
  bool _sound = true;
  bool _vibration = true;

  int get _activeCount => _reminders.where((r) => r.enabled).length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final toggles = await ReminderSettingsService.loadReminderToggles(
      {for (final r in _reminders) r.key: r.enabled},
    );
    final style = await ReminderSettingsService.loadNotificationStyle();
    final medTimes = await ReminderSettingsService.loadMedTimes(
      _meds.map((m) => m.time).toList(),
    );

    if (!mounted) return;
    setState(() {
      for (final r in _reminders) {
        r.enabled = toggles[r.key] ?? r.enabled;
      }
      for (var i = 0; i < _meds.length && i < medTimes.length; i++) {
        _meds[i].time = medTimes[i];
      }
      _push = style.push;
      _sound = style.sound;
      _vibration = style.vibration;
      _loading = false;
    });
  }

  bool _enabled(String key) =>
      _reminders.firstWhere((r) => r.key == key).enabled;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ReminderSettingsService.saveReminderToggles(
        {for (final r in _reminders) r.key: r.enabled},
      );
      await ReminderSettingsService.saveNotificationStyle(
        push: _push,
        sound: _sound,
        vibration: _vibration,
      );
      await ReminderSettingsService.saveMedTimes(
        _meds.map((m) => m.time).toList(),
      );

      if (!_push) {
        await NotificationService.cancelAll();
      } else {
        final granted = await NotificationService.requestPermission();
        if (!granted) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Notifications are blocked — enable them in system settings to get reminders.'),
            ),
          );
          setState(() => _saving = false);
          return;
        }
        await _applySchedule();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_push
              ? 'Reminders saved — you\'ll get alerts with sound'
              : 'Reminders saved — notifications are off'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _applySchedule() async {
    // Medicine reminders
    if (_enabled('medicine')) {
      for (var i = 0; i < _meds.length; i++) {
        final t = _parseTime(_meds[i].time);
        await NotificationService.scheduleDaily(
          id: NotificationService.medicineBaseId + i,
          title: '💊 ${_meds[i].name}',
          body: _meds[i].note,
          hour: t.hour,
          minute: t.minute,
          sound: _sound,
          vibration: _vibration,
        );
      }
      await NotificationService.cancelRange(
        NotificationService.medicineBaseId + _meds.length,
        50 - _meds.length,
      );
    } else {
      await NotificationService.cancelRange(NotificationService.medicineBaseId, 50);
    }

    // Water intake — hourly 9 AM to 9 PM
    if (_enabled('water')) {
      await NotificationService.scheduleHourlyRange(
        baseId: NotificationService.waterBaseId,
        startHour: 9,
        endHour: 21,
        title: '💧 Time to hydrate',
        body: 'Have a glass of water for you and baby.',
        sound: _sound,
        vibration: _vibration,
      );
    } else {
      await NotificationService.cancelRange(NotificationService.waterBaseId, 30);
    }

    // Appointment alerts — real upcoming appointments, 1 day + 1 hour before
    if (_enabled('appointments')) {
      final appts = await AppointmentService.getUpcoming(limit: 50);
      for (var i = 0; i < appts.length; i++) {
        final a = appts[i];
        await NotificationService.scheduleOneOff(
          id: NotificationService.appointmentDayBeforeBaseId + i,
          title: '📅 Appointment tomorrow',
          body: '${a.title} at ${a.place}',
          dateTime: a.dateTime.subtract(const Duration(days: 1)),
          sound: _sound,
          vibration: _vibration,
        );
        await NotificationService.scheduleOneOff(
          id: NotificationService.appointmentHourBeforeBaseId + i,
          title: '📅 Appointment in 1 hour',
          body: '${a.title} at ${a.place}',
          dateTime: a.dateTime.subtract(const Duration(hours: 1)),
          sound: _sound,
          vibration: _vibration,
        );
      }
      await NotificationService.cancelRange(
        NotificationService.appointmentDayBeforeBaseId + appts.length,
        100 - appts.length,
      );
      await NotificationService.cancelRange(
        NotificationService.appointmentHourBeforeBaseId + appts.length,
        100 - appts.length,
      );
    } else {
      await NotificationService.cancelRange(
          NotificationService.appointmentDayBeforeBaseId, 100);
      await NotificationService.cancelRange(
          NotificationService.appointmentHourBeforeBaseId, 100);
    }

    // Kick count
    if (_enabled('kicks')) {
      await NotificationService.scheduleDaily(
        id: NotificationService.kickCountId,
        title: '👶 Kick count check-in',
        body: 'Take a few minutes to count baby\'s kicks today.',
        hour: 20,
        minute: 0,
        sound: _sound,
        vibration: _vibration,
      );
    } else {
      await NotificationService.cancel(NotificationService.kickCountId);
    }

    // Weekly weight check
    if (_enabled('weight')) {
      await NotificationService.scheduleWeekly(
        id: NotificationService.weightCheckId,
        title: '⚖️ Weekly weight check',
        body: 'Log this week\'s weight to track your progress.',
        weekday: DateTime.monday,
        hour: 9,
        minute: 0,
        sound: _sound,
        vibration: _vibration,
      );
    } else {
      await NotificationService.cancel(NotificationService.weightCheckId);
    }

    // Sleep reminder
    if (_enabled('sleep')) {
      await NotificationService.scheduleDaily(
        id: NotificationService.sleepReminderId,
        title: '🌙 Time to wind down',
        body: 'A good night\'s sleep helps you and baby recover.',
        hour: 22,
        minute: 0,
        sound: _sound,
        vibration: _vibration,
      );
    } else {
      await NotificationService.cancel(NotificationService.sleepReminderId);
    }

    // Daily pregnancy tip
    if (_enabled('tips')) {
      await NotificationService.scheduleDaily(
        id: NotificationService.dailyTipId,
        title: '📋 Today\'s pregnancy tip',
        body: 'Open MamaBloom for a fresh tip for your week.',
        hour: 9,
        minute: 0,
        sound: _sound,
        vibration: _vibration,
      );
    } else {
      await NotificationService.cancel(NotificationService.dailyTipId);
    }
  }

  ({int hour, int minute}) _parseTime(String time) {
    final parts = time.split(':');
    final hourMin = parts[0];
    final minAmPm = parts[1].split(' ');
    var hour = int.parse(hourMin);
    final minute = int.parse(minAmPm[0]);
    final isPm = minAmPm[1] == 'PM';
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;
    return (hour: hour, minute: minute);
  }

  Future<void> _sendTest() async {
    final granted = await NotificationService.requestPermission();
    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Notifications are blocked — enable them in system settings first.'),
        ),
      );
      return;
    }
    await NotificationService.showNow(
      title: '🔔 Test reminder',
      body: _sound
          ? 'This is how your reminders will sound.'
          : 'This is how your silent reminders will look.',
      sound: _sound,
      vibration: _vibration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    final serif = GoogleFonts.fraunces;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8FA),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Reminders',
          style: sans(fontWeight: FontWeight.w700, fontSize: 17.0, color: _ink),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: sans(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              children: [
                // ── Header card ────────────────────────────────────────
                _HeaderCard(
                  activeCount: _activeCount,
                  totalCount: _reminders.length,
                  sans: sans,
                  serif: serif,
                ),
                const SizedBox(height: 24),

                // ── Reminders list ─────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: _reminders.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      final isLast = idx == _reminders.length - 1;
                      return _ReminderRow(
                        item: item,
                        isLast: isLast,
                        sans: sans,
                        onToggle: (val) =>
                            setState(() => _reminders[idx].enabled = val),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Medicine schedule ──────────────────────────────────
                Text(
                  'MEDICINE SCHEDULE',
                  style: sans(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: _meds.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final med = entry.value;
                      final isLast = idx == _meds.length - 1;
                      return _MedRow(
                        med: med,
                        isLast: isLast,
                        sans: sans,
                        onTimeTap: () => _pickTime(context, idx),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Notification style ─────────────────────────────────
                Text(
                  'NOTIFICATION STYLE',
                  style: sans(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 12),
                _NotifStyleCard(
                  sans: sans,
                  push: _push,
                  sound: _sound,
                  vibration: _vibration,
                  onPushChanged: (v) => setState(() => _push = v),
                  onSoundChanged: (v) => setState(() => _sound = v),
                  onVibrationChanged: (v) => setState(() => _vibration = v),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _sendTest,
                  icon: const Icon(Icons.notifications_active_outlined,
                      color: _accent),
                  label: Text(
                    'Send test reminder',
                    style: sans(fontWeight: FontWeight.w700, color: _accent),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: _accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap "Save" to turn your active reminders into real alerts. Use "Send test reminder" to hear how they sound.',
                  textAlign: TextAlign.center,
                  style: sans(
                    fontSize: 12.0,
                    color: const Color(0xFF9A94A0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _pickTime(BuildContext context, int idx) async {
    final t = _parseTime(_meds[idx].time);

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: t.hour, minute: t.minute),
    );
    if (picked != null) {
      setState(() {
        _meds[idx].time = picked.format(context);
      });
    }
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.activeCount,
    required this.totalCount,
    required this.sans,
    required this.serif,
  });

  final int activeCount;
  final int totalCount;
  final dynamic sans;
  final dynamic serif;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B8FE8), Color(0xFF5B6EE8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B6EE8).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIVE REMINDERS',
            style: sans(
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$activeCount of $totalCount on',
            style: serif(
              fontSize: 28.0,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Keeping you and baby on track',
            style: sans(
              fontSize: 13.0,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.item,
    required this.isLast,
    required this.sans,
    required this.onToggle,
  });

  final _ReminderItem item;
  final bool isLast;
  final dynamic sans;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.emojiColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    item.emoji,
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: sans(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D2A32),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: sans(
                        fontSize: 12.0,
                        color: item.enabled
                            ? item.emojiColor
                            : const Color(0xFF6B6570),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: item.enabled,
                onChanged: onToggle,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF5B6EE8),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFE0D8E4),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: 70,
            endIndent: 0,
            color: Color(0xFFF0E8EC),
          ),
      ],
    );
  }
}

class _MedRow extends StatelessWidget {
  const _MedRow({
    required this.med,
    required this.isLast,
    required this.sans,
    required this.onTimeTap,
  });

  final _MedItem med;
  final bool isLast;
  final dynamic sans;
  final VoidCallback onTimeTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: med.emojiColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    med.emoji,
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.name,
                      style: sans(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D2A32),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      med.note,
                      style: sans(
                        fontSize: 12.0,
                        color: const Color(0xFF6B6570),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onTimeTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF0FC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    med.time,
                    style: sans(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5B6EE8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: 70,
            endIndent: 0,
            color: Color(0xFFF0E8EC),
          ),
      ],
    );
  }
}

class _NotifStyleCard extends StatelessWidget {
  const _NotifStyleCard({
    required this.sans,
    required this.push,
    required this.sound,
    required this.vibration,
    required this.onPushChanged,
    required this.onSoundChanged,
    required this.onVibrationChanged,
  });

  final dynamic sans;
  final bool push;
  final bool sound;
  final bool vibration;
  final ValueChanged<bool> onPushChanged;
  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onVibrationChanged;

  @override
  Widget build(BuildContext context) {
    Widget row({
      required String emoji,
      required Color emojiColor,
      required String title,
      required String subtitle,
      required bool value,
      required ValueChanged<bool> onChanged,
      required bool isLast,
    }) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: emojiColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: sans(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D2A32),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: sans(
                          fontSize: 12.0,
                          color:
                              value ? emojiColor : const Color(0xFF6B6570),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF5B6EE8),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFE0D8E4),
                ),
              ],
            ),
          ),
          if (!isLast)
            const Divider(
              height: 1,
              indent: 70,
              endIndent: 0,
              color: Color(0xFFF0E8EC),
            ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          row(
            emoji: '🔔',
            emojiColor: const Color(0xFFFF9B50),
            title: 'Push notifications',
            subtitle: push
                ? 'Banner alerts on your phone'
                : 'All reminder alerts are off',
            value: push,
            onChanged: onPushChanged,
            isLast: false,
          ),
          row(
            emoji: '🔊',
            emojiColor: const Color(0xFF4CAF6A),
            title: 'Sound',
            subtitle: sound
                ? 'Play a sound with each reminder'
                : 'Reminders arrive silently',
            value: sound,
            onChanged: onSoundChanged,
            isLast: false,
          ),
          row(
            emoji: '📳',
            emojiColor: const Color(0xFF5B6EE8),
            title: 'Vibration',
            subtitle: 'Silent vibrate for reminders',
            value: vibration,
            onChanged: onVibrationChanged,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ReminderItem {
  _ReminderItem({
    required this.key,
    required this.emoji,
    required this.emojiColor,
    required this.title,
    required this.subtitle,
    required this.enabled,
  });

  final String key;
  final String emoji;
  final Color emojiColor;
  final String title;
  final String subtitle;
  bool enabled;
}

class _MedItem {
  _MedItem({
    required this.emoji,
    required this.emojiColor,
    required this.name,
    required this.note,
    required this.time,
  });

  final String emoji;
  final Color emojiColor;
  final String name;
  final String note;
  String time;
}
