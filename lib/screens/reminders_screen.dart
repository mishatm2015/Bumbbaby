import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  static const _ink = Color(0xFF2D2A32);
  static const _accent = Color(0xFF5B6EE8);

  final List<_ReminderItem> _reminders = [
    _ReminderItem(
      emoji: '💊',
      emojiColor: Color(0xFFE85A5A),
      title: 'Medicine reminders',
      subtitle: 'Folic acid, Iron, Calcium alerts',
      enabled: true,
    ),
    _ReminderItem(
      emoji: '💧',
      emojiColor: Color(0xFF4A9FE8),
      title: 'Water intake',
      subtitle: 'Hourly hydration nudges',
      enabled: true,
    ),
    _ReminderItem(
      emoji: '📅',
      emojiColor: Color(0xFF4CAF6A),
      title: 'Appointment alerts',
      subtitle: '1 day and 1 hour before',
      enabled: true,
    ),
    _ReminderItem(
      emoji: '👶',
      emojiColor: Color(0xFFFF9B50),
      title: 'Kick count reminder',
      subtitle: 'Daily at 8 PM if not logged',
      enabled: true,
    ),
    _ReminderItem(
      emoji: '⚖️',
      emojiColor: Color(0xFFB88A6A),
      title: 'Weekly weight check',
      subtitle: 'Every Monday morning',
      enabled: true,
    ),
    _ReminderItem(
      emoji: '🌙',
      emojiColor: Color(0xFF9B7ED9),
      title: 'Sleep reminder',
      subtitle: 'Bedtime nudge at 10 PM',
      enabled: false,
    ),
    _ReminderItem(
      emoji: '📋',
      emojiColor: Color(0xFF6B6570),
      title: 'Daily pregnancy tip',
      subtitle: 'Morning tip for your week',
      enabled: false,
    ),
  ];

  final List<_MedItem> _meds = [
    _MedItem(
      emoji: '💊',
      emojiColor: Color(0xFFE85A5A),
      name: 'Folic Acid 5mg',
      note: 'Morning with food',
      time: '8:00 AM',
    ),
    _MedItem(
      emoji: '🟡',
      emojiColor: Color(0xFFFF9B50),
      name: 'Iron 100mg',
      note: 'Afternoon, empty stomach',
      time: '2:00 PM',
    ),
    _MedItem(
      emoji: '🔵',
      emojiColor: Color(0xFF4A9FE8),
      name: 'Calcium 500mg',
      note: 'Night after dinner',
      time: '9:30 PM',
    ),
  ];

  int get _activeCount =>
      _reminders.where((r) => r.enabled).length;

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
            onPressed: () {},
            child: Text(
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
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
          _NotifStyleCard(sans: sans),
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, int idx) async {
    final parts = _meds[idx].time.split(':');
    final hourMin = parts[0];
    final minAmPm = parts[1].split(' ');
    var hour = int.parse(hourMin);
    final min = int.parse(minAmPm[0]);
    final isPm = minAmPm[1] == 'PM';
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: min),
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

class _NotifStyleCard extends StatefulWidget {
  const _NotifStyleCard({required this.sans});

  final dynamic sans;

  @override
  State<_NotifStyleCard> createState() => _NotifStyleCardState();
}

class _NotifStyleCardState extends State<_NotifStyleCard> {
  bool _push = true;
  bool _vibration = true;

  @override
  Widget build(BuildContext context) {
    final sans = widget.sans;

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
                          color: value
                              ? emojiColor
                              : const Color(0xFF6B6570),
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
            subtitle: 'Banner alerts on your phone',
            value: _push,
            onChanged: (v) => setState(() => _push = v),
            isLast: false,
          ),
          row(
            emoji: '📳',
            emojiColor: const Color(0xFF5B6EE8),
            title: 'Vibration',
            subtitle: 'Silent vibrate for reminders',
            value: _vibration,
            onChanged: (v) => setState(() => _vibration = v),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ReminderItem {
  _ReminderItem({
    required this.emoji,
    required this.emojiColor,
    required this.title,
    required this.subtitle,
    required this.enabled,
  });

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
