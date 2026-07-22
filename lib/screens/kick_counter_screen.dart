import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/kick_session.dart';
import '../models/user_profile.dart';
import '../services/kick_service.dart';
import '../services/user_repository.dart';

class KickCounterScreen extends StatefulWidget {
  const KickCounterScreen({super.key});

  @override
  State<KickCounterScreen> createState() => _KickCounterScreenState();
}

class _KickCounterScreenState extends State<KickCounterScreen> {
  static const int _goal = 10;
  static const _pink = Color(0xFFE04B84);
  static const _pinkBg = Color(0xFFFFF0F5);
  static const _dark = Color(0xFF1A1A2E);
  static const _muted = Color(0xFF6B6570);

  static const _positions = ['Left side', 'Right side', 'Sitting', 'Reclined'];

  final _userRepo = UserRepository();
  final _notesCtrl = TextEditingController();

  UserProfile? _profile;
  List<KickSession> _history = [];
  bool _loading = true;

  bool _active = false;
  bool _completed = false;
  DateTime? _start;
  int _count = 0;
  int _elapsedSec = 0;
  final List<DateTime> _kicks = [];
  String _position = 'Left side';
  Timer? _ticker;

  int? get _week => _profile?.currentWeek;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final profile = uid == null ? null : await _userRepo.getProfile(uid);
    final history = await KickService.getSessions();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _history = history;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _active = true;
      _completed = false;
      _start = DateTime.now();
      _count = 0;
      _elapsedSec = 0;
      _kicks.clear();
      _notesCtrl.clear();
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _start == null) return;
      setState(() => _elapsedSec = DateTime.now().difference(_start!).inSeconds);
    });
  }

  void _logKick() {
    if (!_active || _completed) return;
    setState(() {
      _count++;
      _kicks.insert(0, DateTime.now());
      if (_count >= _goal) {
        _completed = true;
        _ticker?.cancel();
      }
    });
  }

  Future<void> _saveSession() async {
    if (_start == null || _count == 0) {
      _discard();
      return;
    }
    final session = KickSession(
      id: _start!.microsecondsSinceEpoch.toString(),
      start: _start!,
      count: _count,
      durationSec: _elapsedSec,
      reachedGoal: _count >= _goal,
      position: _position,
      week: _week,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    final history = await KickService.addSession(session);
    if (!mounted) return;
    _ticker?.cancel();
    setState(() {
      _history = history;
      _active = false;
      _completed = false;
      _start = null;
      _count = 0;
      _elapsedSec = 0;
      _kicks.clear();
      _notesCtrl.clear();
    });
  }

  void _discard() {
    _ticker?.cancel();
    setState(() {
      _active = false;
      _completed = false;
      _start = null;
      _count = 0;
      _elapsedSec = 0;
      _kicks.clear();
      _notesCtrl.clear();
    });
  }

  Future<void> _deleteHistory(KickSession s) async {
    final history = await KickService.removeSession(s.id);
    if (!mounted) return;
    setState(() => _history = history);
  }

  // ── helpers ─────────────────────────────────────────────────────────────
  static String _formatClock(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  static String _formatElapsed(int sec) {
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    final s = sec % 60;
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  bool get _overTwoHoursLow => _active && !_completed && _elapsedSec >= 7200;

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: _dark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text('Kick Counter',
            style: sans(fontSize: 17, fontWeight: FontWeight.w700, color: _dark)),
        actions: [
          if (_active)
            TextButton(
              onPressed: _discard,
              child: Text('Cancel',
                  style: sans(
                      fontSize: 14, fontWeight: FontWeight.w600, color: _pink)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_week != null && _week! < 28) _StartWeekNote(sans: sans),
                  _CounterCard(
                    count: _count,
                    goal: _goal,
                    active: _active,
                    completed: _completed,
                    elapsedLabel: _formatElapsed(_elapsedSec),
                    onTapBaby: _logKick,
                    onStart: _startSession,
                    sans: sans,
                  ),
                  const SizedBox(height: 20),
                  if (_overTwoHoursLow) _DoctorAlert(sans: sans),
                  if (_active) ...[
                    _InfoRow(
                      label: 'Movements',
                      value: '$_count / $_goal',
                      sans: sans,
                    ),
                    const Divider(height: 24, color: Color(0xFFE8E4EC)),
                    _InfoRow(
                      label: 'Started',
                      value: _start != null ? _formatClock(_start!) : '—',
                      sans: sans,
                    ),
                    const Divider(height: 24, color: Color(0xFFE8E4EC)),
                    _InfoRow(
                      label: 'Time elapsed',
                      value: _formatElapsed(_elapsedSec),
                      sans: sans,
                    ),
                    const SizedBox(height: 20),
                    Text('POSITION',
                        style: sans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: _muted)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _positions.map((p) {
                        final selected = _position == p;
                        return ChoiceChip(
                          label: Text(p == 'Left side' ? '$p ★' : p),
                          selected: selected,
                          selectedColor: _pink.withValues(alpha: 0.18),
                          onSelected: (_) => setState(() => _position = p),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesCtrl,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'e.g. after dinner, very active',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saveSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _pink,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          _completed ? 'Save session' : 'Save & finish early',
                          style: sans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_kicks.isNotEmpty) ...[
                      Text('THIS SESSION',
                          style: sans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: _muted)),
                      const SizedBox(height: 8),
                      ..._kicks.asMap().entries.map((e) {
                        final number = _kicks.length - e.key;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                    color: _pinkBg, shape: BoxShape.circle),
                                child: Center(
                                  child: Text('$number',
                                      style: sans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: _pink)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text('Movement #$number',
                                  style: sans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _dark)),
                              const Spacer(),
                              Text(_formatClock(e.value),
                                  style: sans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: _muted)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                  const SizedBox(height: 8),
                  _DoctorInfoBox(sans: sans),
                  const SizedBox(height: 20),
                  _MethodBox(sans: sans),
                  if (_history.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('PAST SESSIONS',
                        style: sans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: _muted)),
                    const SizedBox(height: 8),
                    ..._history.map((s) => _HistoryTile(
                          session: s,
                          sans: sans,
                          onDelete: () => _deleteHistory(s),
                        )),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

// ── Counter card ────────────────────────────────────────────────────────────
class _CounterCard extends StatelessWidget {
  const _CounterCard({
    required this.count,
    required this.goal,
    required this.active,
    required this.completed,
    required this.elapsedLabel,
    required this.onTapBaby,
    required this.onStart,
    required this.sans,
  });

  final int count;
  final int goal;
  final bool active;
  final bool completed;
  final String elapsedLabel;
  final VoidCallback onTapBaby;
  final VoidCallback onStart;
  final TextStyle Function(
      {FontWeight? fontWeight,
      double? fontSize,
      Color? color,
      double? letterSpacing}) sans;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFDE8F2), Color(0xFFFFC8E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            completed ? 'GOAL REACHED 🎉' : 'MOVEMENTS',
            style: sans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: const Color(0xFF9A2A5A)),
          ),
          const SizedBox(height: 8),
          Text('$count',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF6A0030))),
          Text(
            completed
                ? '$goal movements in $elapsedLabel'
                : active
                    ? '$elapsedLabel elapsed · goal $goal'
                    : 'Goal: $goal movements within 2 hours',
            style: sans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9A2A5A)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          if (!active)
            SizedBox(
              width: 200,
              height: 52,
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE04B84),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text('Start session',
                    style: sans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            )
          else ...[
            GestureDetector(
              onTap: onTapBaby,
              child: AnimatedOpacity(
                opacity: completed ? 0.5 : 1,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB8D4),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE04B84).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                      child: Text('👶', style: TextStyle(fontSize: 44))),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              completed ? 'Save your session below' : 'Tap the baby for each movement',
              style: sans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9A2A5A)),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Small pieces ────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, required this.sans});

  final String label;
  final String value;
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: sans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E))),
        Text(value,
            style: sans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B6570))),
      ],
    );
  }
}

class _StartWeekNote extends StatelessWidget {
  const _StartWeekNote({required this.sans});
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF2DFB0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFB07300), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Kick counting is usually started around 28 weeks (some doctors say 26), once movements become regular. You can still practice now.',
              style: sans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8A6A1A)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorAlert extends StatelessWidget {
  const _DoctorAlert({required this.sans});
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3B4B4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFD23B3B), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Fewer than 10 movements in 2 hours. Contact your doctor or maternity unit now.',
              style: sans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB02525)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorInfoBox extends StatelessWidget {
  const _DoctorInfoBox({required this.sans});
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;

  @override
  Widget build(BuildContext context) {
    const items = [
      'Fewer than 10 movements in 2 hours',
      'A noticeable decrease in baby\'s usual pattern',
      'No movement felt at all during an active period',
      'Any sudden change from baby\'s normal activity',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3B4B4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('When to contact a doctor',
              style: sans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFB02525))),
          const SizedBox(height: 8),
          ...items.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  ',
                        style: TextStyle(
                            color: Color(0xFFB02525),
                            fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(t,
                          style: sans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF8A2A2A))),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _MethodBox extends StatelessWidget {
  const _MethodBox({required this.sans});
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Choose a time baby is usually active (after meals or evening).',
      'Sit or lie on your left side for best blood flow.',
      'Tap the baby for each distinct movement — kicks, rolls, jabs (hiccups don\'t count).',
      'Stop once you reach 10 movements and note how long it took.',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF6CFE0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('The "Count to 10" method',
              style: sans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF9A2A5A))),
          const SizedBox(height: 8),
          ...steps.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${e.key + 1}.  ',
                        style: sans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFC94F7D))),
                    Expanded(
                      child: Text(e.value,
                          style: sans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF7A3554))),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 4),
          Text('Normal: 10 movements within 2 hours (often felt within 30–60 min).',
              style: sans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF9A2A5A))),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.session,
    required this.sans,
    required this.onDelete,
  });

  final KickSession session;
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final d = session.start;
    final dateStr = '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')} · '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    final normal = session.isNormal;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDE6EA)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: normal
                  ? const Color(0xFFE6F6EC)
                  : const Color(0xFFFDECEC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              normal ? 'Normal' : 'Check',
              style: sans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: normal
                      ? const Color(0xFF1F8A4C)
                      : const Color(0xFFB02525)),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${session.count} movements · ${_KickCounterScreenState._formatElapsed(session.durationSec)}',
                style: sans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E)),
              ),
              Text(
                '$dateStr · ${session.position}'
                '${session.week != null ? ' · wk ${session.week}' : ''}',
                style: sans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B6570)),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 20, color: Color(0xFF9A939E)),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
