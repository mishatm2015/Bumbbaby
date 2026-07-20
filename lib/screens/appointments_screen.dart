import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _AppointmentEntry {
  _AppointmentEntry({
    required this.title,
    required this.detail,
    required this.dotColor,
  });

  final String title;
  final String detail;
  final Color dotColor;
}

class _RecommendedItem {
  const _RecommendedItem(this.weeks, this.description);

  final String weeks;
  final String description;
}

/// Appointments hub: summary, editable upcoming list, recommended checkups.
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  static const _plum = Color(0xFF4A2C4A);
  static const _cardPink = Color(0xFFFFE4EE);
  static const _accentPink = Color(0xFFFF5C9D);

  final List<_AppointmentEntry> _upcoming = [
    _AppointmentEntry(
      title: 'Anomaly scan',
      detail: 'Dr. Priya Nair · Amrita Hospital · 28 Mar, 10:30 AM',
      dotColor: const Color(0xFFE04B84),
    ),
    _AppointmentEntry(
      title: 'OB-GYN checkup',
      detail: 'Dr. Smitha Rajan · Aster · 4 Apr, 11:00 AM',
      dotColor: const Color(0xFF4A9FE8),
    ),
    _AppointmentEntry(
      title: 'Glucose tolerance test',
      detail: 'Amrita Lab · 10 Apr, 9:00 AM',
      dotColor: const Color(0xFF4CAF6A),
    ),
    _AppointmentEntry(
      title: 'Dental checkup',
      detail: 'Dr. Anitha · Smile Clinic · 15 Apr, 3:00 PM',
      dotColor: const Color(0xFFB88A6A),
    ),
  ];

  static const _recommended = [
    _RecommendedItem('Week 8–10', 'First prenatal visit, blood tests, dating scan'),
    _RecommendedItem('Week 11–14', 'NT scan, Down syndrome screening'),
    _RecommendedItem('Week 18–22', 'Anomaly scan (morphology)'),
    _RecommendedItem('Week 24–28', 'Glucose tolerance test, iron levels'),
    _RecommendedItem('Week 32–34', 'Growth scan, GBS test'),
    _RecommendedItem('Week 36–40', 'Weekly visits, birth position check'),
  ];

  final List<bool> _checked = [true, true, true, false, false, false];

  void _removeAt(int i) {
    setState(() => _upcoming.removeAt(i));
  }

  void _toggleRecommended(int i) {
    setState(() => _checked[i] = !_checked[i]);
  }

  Future<void> _showAddSheet() async {
    final sans = GoogleFonts.plusJakartaSans;
    final nameCtrl = TextEditingController();
    final placeCtrl = TextEditingController();
    DateTime? date;
    TimeOfDay? time;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add new appointment',
                    style: sans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: _fieldDec(sans, 'Appointment name'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: placeCtrl,
                          decoration: _fieldDec(sans, 'Doctor / hospital'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: ctx,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2035),
                            );
                            if (d != null) setModal(() => date = d);
                          },
                          child: Text(
                            date == null
                                ? 'dd-mm-yyyy'
                                : '${date!.day.toString().padLeft(2, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.year}',
                            style: sans(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final t = await showTimePicker(
                              context: ctx,
                              initialTime: TimeOfDay.now(),
                            );
                            if (t != null) setModal(() => time = t);
                          },
                          child: Text(
                            time == null ? '--:-- --' : time!.format(context),
                            style: sans(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {
                          if (nameCtrl.text.trim().isEmpty) return;
                          final dStr = date != null
                              ? '${date!.day} ${_month(date!.month)}'
                              : 'TBD';
                          final tStr = time?.format(context) ?? '';
                          setState(() {
                            _upcoming.add(
                              _AppointmentEntry(
                                title: nameCtrl.text.trim(),
                                detail:
                                    '${placeCtrl.text.trim().isEmpty ? 'Location TBD' : placeCtrl.text.trim()} · $dStr${tStr.isEmpty ? '' : ', $tStr'}',
                                dotColor: const Color(0xFF9B7ED9),
                              ),
                            );
                          });
                          Navigator.pop(ctx);
                        },
                        style: FilledButton.styleFrom(backgroundColor: _accentPink),
                        child: Text('Add', style: sans(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    nameCtrl.dispose();
    placeCtrl.dispose();
  }

  static InputDecoration _fieldDec(TextStyle Function({Color? color, double? fontSize, FontWeight? fontWeight}) sans, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: sans(color: Colors.black38, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  static String _month(int m) {
    const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[m];
  }

  @override
  Widget build(BuildContext context) {
    final serif = GoogleFonts.fraunces;
    final sans = GoogleFonts.plusJakartaSans;

    final next = _upcoming.isNotEmpty ? _upcoming.first : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Appointments',
          style: serif(fontWeight: FontWeight.w700, fontSize: 18, color: _plum),
        ),
        actions: [
          IconButton(
            onPressed: _showAddSheet,
            icon: Icon(Icons.add_rounded, color: _accentPink, size: 28),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            decoration: BoxDecoration(
              color: _cardPink,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UPCOMING',
                  style: sans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: _plum,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_upcoming.length} appointments',
                  style: serif(fontSize: 26, fontWeight: FontWeight.w800, color: _plum),
                ),
                const SizedBox(height: 8),
                Text(
                  next == null
                      ? 'Add your next visit'
                      : 'Next: ${next.title} on ${next.detail.split('·').last.trim()}',
                  style: serif(fontSize: 14, fontWeight: FontWeight.w500, color: _plum, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'UPCOMING APPOINTMENTS',
            style: serif(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: _plum,
            ),
          ),
          const SizedBox(height: 14),
          if (_upcoming.isEmpty)
            Text('No appointments yet.', style: serif(fontSize: 15, color: _plum))
          else
            ...List.generate(_upcoming.length, (i) {
              final a = _upcoming[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(color: a.dotColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.title,
                            style: serif(fontSize: 16, fontWeight: FontWeight.w700, color: _plum),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            a.detail,
                            style: serif(fontSize: 13, fontWeight: FontWeight.w400, color: _plum, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeAt(i),
                      icon: Icon(Icons.close_rounded, size: 20, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 20),
          Text(
            'RECOMMENDED CHECKUPS',
            style: serif(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: _plum,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(_recommended.length, (i) {
            final r = _recommended[i];
            final on = _checked[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _toggleRecommended(i),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: on ? const Color(0xFF2E7D32) : Colors.transparent,
                        border: Border.all(
                          color: on ? const Color(0xFF2E7D32) : Colors.black54,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: on ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${r.weeks} — ',
                              style: serif(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                height: 1.35,
                              ),
                            ),
                            TextSpan(
                              text: r.description,
                              style: serif(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

}
