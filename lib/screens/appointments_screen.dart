import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/appointment.dart';
import '../services/appointment_service.dart';

class _RecommendedItem {
  const _RecommendedItem(this.weeks, this.description);

  final String weeks;
  final String description;
}

/// Appointments hub: loads only this user's appointments from Firestore.
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  static const _plum = Color(0xFF4A2C4A);
  static const _cardPink = Color(0xFFFFE4EE);
  static const _accentPink = Color(0xFFFF5C9D);

  List<Appointment> _upcoming = [];
  bool _loading = true;

  static const _recommended = [
    _RecommendedItem('Week 8–10', 'First prenatal visit, blood tests, dating scan'),
    _RecommendedItem('Week 11–14', 'NT scan, Down syndrome screening'),
    _RecommendedItem('Week 18–22', 'Anomaly scan (morphology)'),
    _RecommendedItem('Week 24–28', 'Glucose tolerance test, iron levels'),
    _RecommendedItem('Week 32–34', 'Growth scan, GBS test'),
    _RecommendedItem('Week 36–40', 'Weekly visits, birth position check'),
  ];

  final List<bool> _checked = List<bool>.filled(6, false);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await AppointmentService.getUpcoming();
    if (!mounted) return;
    setState(() {
      _upcoming = list;
      _loading = false;
    });
  }

  Future<void> _removeAt(int i) async {
    final id = _upcoming[i].id;
    setState(() => _upcoming.removeAt(i));
    await AppointmentService.removeAppointment(id);
  }

  void _toggleRecommended(int i) {
    setState(() => _checked[i] = !_checked[i]);
  }

  Future<void> _showAddSheet() async {
    final appointment = await showModalBottomSheet<Appointment>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _AddAppointmentSheet(),
    );
    if (appointment == null || !mounted) return;
    await AppointmentService.addAppointment(appointment);
    await _load();
  }

  static String _month(int m) {
    const names = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return names[m];
  }

  static String _formatDetail(Appointment a) {
    final d =
        '${a.dateTime.day} ${_month(a.dateTime.month)}, ${a.dateTime.year}';
    final h = a.dateTime.hour;
    final m = a.dateTime.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${a.place} · $d, $hour12:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final serif = GoogleFonts.fraunces;
    final sans = GoogleFonts.plusJakartaSans;

    final next = _upcoming.isNotEmpty ? _upcoming.first : null;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8FA),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Colors.black),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                        '${_upcoming.length} appointment${_upcoming.length == 1 ? '' : 's'}',
                        style: serif(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: _plum),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        next == null
                            ? 'Add your next visit'
                            : 'Next: ${next.title} · ${_month(next.dateTime.month)} ${next.dateTime.day}',
                        style: serif(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _plum,
                            height: 1.3),
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
                  Text('No appointments yet. Tap + to add one.',
                      style: serif(fontSize: 15, color: _plum))
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
                            decoration: BoxDecoration(
                              color: Color(a.dotColorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.title,
                                  style: serif(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: _plum),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDetail(a),
                                  style: serif(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: _plum,
                                      height: 1.35),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeAt(i),
                            icon: Icon(Icons.close_rounded,
                                size: 20, color: Colors.grey.shade500),
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
                              color: on
                                  ? const Color(0xFF2E7D32)
                                  : Colors.transparent,
                              border: Border.all(
                                color: on
                                    ? const Color(0xFF2E7D32)
                                    : Colors.black54,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: on
                                ? const Icon(Icons.check,
                                    size: 16, color: Colors.white)
                                : null,
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

/// Owns its own text controllers so they are never disposed while still mounted.
class _AddAppointmentSheet extends StatefulWidget {
  const _AddAppointmentSheet();

  @override
  State<_AddAppointmentSheet> createState() => _AddAppointmentSheetState();
}

class _AddAppointmentSheetState extends State<_AddAppointmentSheet> {
  static const _accentPink = Color(0xFFFF5C9D);

  final _nameCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _placeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _nameCtrl.text.trim();
    if (title.isEmpty) return;
    final day = _date ?? DateTime.now();
    final tod = _time ?? TimeOfDay.now();
    final when = DateTime(day.year, day.month, day.day, tod.hour, tod.minute);
    Navigator.pop(
      context,
      Appointment(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        place: _placeCtrl.text.trim().isEmpty
            ? 'Location TBD'
            : _placeCtrl.text.trim(),
        dateTime: when,
      ),
    );
  }

  InputDecoration _fieldDec(String hint, TextStyle Function({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) sans) {
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

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add new appointment',
              style: sans(
                  fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: _fieldDec('Appointment name', sans),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _placeCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _fieldDec('Doctor / hospital', sans),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _date ?? DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2035),
                      );
                      if (d != null) setState(() => _date = d);
                    },
                    child: Text(
                      _date == null
                          ? 'dd-mm-yyyy'
                          : '${_date!.day.toString().padLeft(2, '0')}-${_date!.month.toString().padLeft(2, '0')}-${_date!.year}',
                      style: sans(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: _time ?? TimeOfDay.now(),
                      );
                      if (t != null) setState(() => _time = t);
                    },
                    child: Text(
                      _time == null ? '--:-- --' : _time!.format(context),
                      style: sans(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(backgroundColor: _accentPink),
                child: Text('Add', style: sans(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
