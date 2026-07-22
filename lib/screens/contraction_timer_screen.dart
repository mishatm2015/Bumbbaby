import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/contraction_session.dart';
import '../models/user_profile.dart';
import '../services/contraction_service.dart';
import '../services/user_repository.dart';

class ContractionTimerScreen extends StatefulWidget {
  const ContractionTimerScreen({super.key});

  @override
  State<ContractionTimerScreen> createState() => _ContractionTimerScreenState();
}

enum _TimerState { idle, timing }

class _ContractionTimerScreenState extends State<ContractionTimerScreen> {
  _TimerState _state = _TimerState.idle;
  int _elapsedSec = 0;
  DateTime? _contractionStart;
  Timer? _timer;

  final _userRepo = UserRepository();
  UserProfile? _profile;

  String? _sessionId;
  DateTime? _sessionStartedAt;
  final List<ContractionEntry> _log = [];

  static const _teal = Color(0xFF1A8C6A);
  static const _dark = Color(0xFF1A1A2E);
  static const _muted = Color(0xFF6B6570);
  static const _amber = Color(0xFFE8A020);

  int? get _week => _profile?.currentWeek;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final profile = await _userRepo.getProfile(uid);
    if (!mounted) return;
    setState(() => _profile = profile);
  }

  // ── Timer control ─────────────────────────────────────────────────────────
  void _start() {
    setState(() {
      _state = _TimerState.timing;
      _contractionStart = DateTime.now();
      _elapsedSec = 0;
      _sessionId ??= DateTime.now().microsecondsSinceEpoch.toString();
      _sessionStartedAt ??= DateTime.now();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _contractionStart == null) return;
      setState(() =>
          _elapsedSec = DateTime.now().difference(_contractionStart!).inSeconds);
    });
  }

  void _stop() {
    _timer?.cancel();
    final now = DateTime.now();
    final start = _contractionStart ?? now;
    final duration = now.difference(start).inSeconds;

    // Frequency = start-to-start with the previous contraction.
    int? frequencySec;
    if (_log.isNotEmpty) {
      frequencySec = start.difference(_log.first.startTime).inSeconds;
    }

    setState(() {
      _log.insert(
        0,
        ContractionEntry(
          startTime: start,
          durationSec: duration,
          frequencySec: frequencySec,
        ),
      );
      _state = _TimerState.idle;
      _elapsedSec = 0;
      _contractionStart = null;
    });
    _persistSession();
  }

  Future<void> _persistSession() async {
    if (_log.isEmpty || _sessionId == null || _sessionStartedAt == null) return;
    final session = ContractionSession(
      id: _sessionId!,
      startedAt: _sessionStartedAt!,
      entries: List.of(_log),
      week: _week,
      met511: _meets511,
    );
    try {
      await ContractionService.saveSession(session);
    } catch (_) {}
  }

  void _clear() {
    _timer?.cancel();
    _persistSession(); // keep what was timed before clearing
    setState(() {
      _log.clear();
      _state = _TimerState.idle;
      _elapsedSec = 0;
      _contractionStart = null;
      _sessionId = null;
      _sessionStartedAt = null;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Fire-and-forget save when leaving the screen.
    if (_log.isNotEmpty) {
      _persistSession();
    }
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _formatSec(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _durLabel(int sec) {
    if (sec < 60) return '${sec}s';
    return '${sec ~/ 60}m ${sec % 60}s';
  }

  String get _avgDuration {
    if (_log.isEmpty) return '—';
    final avg =
        _log.map((e) => e.durationSec).reduce((a, b) => a + b) / _log.length;
    return _durLabel(avg.round());
  }

  String get _avgFrequency {
    final withFreq = _log.where((e) => e.frequencySec != null).toList();
    if (withFreq.isEmpty) return '—';
    final avg = withFreq.map((e) => e.frequencySec!).reduce((a, b) => a + b) /
        withFreq.length;
    return _durLabel(avg.round());
  }

  /// 5-1-1: contractions ≤5 min apart, ≥1 min long, sustained ~1 hour.
  bool get _meets511 {
    if (_log.length < 3) return false;
    final newest = _log.first.startTime;
    final recent = _log
        .where((e) => newest.difference(e.startTime).inMinutes <= 60)
        .toList();
    if (recent.length < 3) return false;
    final spanMin =
        recent.first.startTime.difference(recent.last.startTime).inMinutes;
    if (spanMin < 55) return false; // roughly an hour of data
    final freqs =
        recent.where((e) => e.frequencySec != null).map((e) => e.frequencySec!);
    if (freqs.isEmpty) return false;
    final avgFreq = freqs.reduce((a, b) => a + b) / freqs.length;
    final avgDur =
        recent.map((e) => e.durationSec).reduce((a, b) => a + b) / recent.length;
    return avgFreq <= 300 && avgDur >= 55;
  }

  String _timeLabel(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    final isTiming = _state == _TimerState.timing;
    final preterm = _week != null && _week! < 37;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text('Contraction Timer',
            style: sans(fontSize: 17, fontWeight: FontWeight.w700, color: _dark)),
        actions: [
          if (_log.isNotEmpty)
            TextButton(
              onPressed: _clear,
              child: Text('Clear',
                  style: sans(
                      fontSize: 14, fontWeight: FontWeight.w600, color: _teal)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Timer card ───────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD6F5EE), Color(0xFFAAE8D6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    isTiming ? 'TIMING CONTRACTION' : 'READY TO TIME',
                    style: sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0D6B50)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatSec(_elapsedSec),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0A4A38)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isTiming
                        ? 'Press stop when the contraction ends'
                        : 'Press start when a contraction begins',
                    style: sans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A6B54)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 220,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isTiming ? _stop : _start,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isTiming
                            ? const Color(0xFFD23B3B)
                            : _teal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Text(
                        isTiming ? 'Stop contraction' : 'Start contraction',
                        style: sans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 5-1-1 alert ──────────────────────────────────────────────
            if (_meets511) _FiveOneOneAlert(sans: sans),
            if (preterm) _PretermAlert(week: _week!, sans: sans),

            // ── Stats row ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatPill(
                      value: '${_log.length}',
                      label: 'Contractions',
                      valueColor: _dark,
                      sans: sans),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatPill(
                      value: _avgDuration,
                      label: 'Avg duration',
                      valueColor: _amber,
                      sans: sans),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatPill(
                      value: _avgFrequency,
                      label: 'Avg frequency',
                      valueColor: _amber,
                      sans: sans),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── 5-1-1 rule box ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBCDED8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('The 5-1-1 rule',
                      style: sans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _teal)),
                  const SizedBox(height: 4),
                  Text(
                    'Head to the hospital when contractions are 5 minutes apart, each lasting 1 minute, for at least 1 hour. (Some hospitals use 4-1-1 — ask your provider.)',
                    style: sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2E6B5A)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Contraction log ──────────────────────────────────────────
            Text('CONTRACTION LOG',
                style: sans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: _muted)),
            const SizedBox(height: 12),
            if (_log.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text('No contractions logged yet',
                      style: sans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _muted)),
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: _LogHeader('#', sans: sans)),
                    Expanded(flex: 2, child: _LogHeader('Start', sans: sans)),
                    Expanded(child: _LogHeader('Duration', sans: sans)),
                    Expanded(child: _LogHeader('Frequency', sans: sans)),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE8E4EC)),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _log.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: Color(0xFFE8E4EC)),
                itemBuilder: (context, index) {
                  final entry = _log[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('${_log.length - index}',
                              style: sans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _dark)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(_timeLabel(entry.startTime),
                              style: sans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _muted)),
                        ),
                        Expanded(
                          child: Text(_durLabel(entry.durationSec),
                              style: sans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _teal)),
                        ),
                        Expanded(
                          child: Text(
                              entry.frequencySec != null
                                  ? _durLabel(entry.frequencySec!)
                                  : '—',
                              style: sans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _muted)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 28),

            // ── Braxton Hicks vs true labor ──────────────────────────────
            _ComparisonCard(sans: sans),
            const SizedBox(height: 20),

            // ── Call immediately box ─────────────────────────────────────
            _CallImmediatelyBox(sans: sans),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Stat pill ─────────────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.sans,
  });

  final String value;
  final String label;
  final Color valueColor;
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: sans(
                fontSize: 20, fontWeight: FontWeight.w700, color: valueColor)),
        const SizedBox(height: 2),
        Text(label,
            style: sans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B6570)),
            textAlign: TextAlign.center),
      ],
    );
  }
}

class _LogHeader extends StatelessWidget {
  const _LogHeader(this.text, {required this.sans});
  final String text;
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: sans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6B6570)));
  }
}

class _FiveOneOneAlert extends StatelessWidget {
  const _FiveOneOneAlert({required this.sans});
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE89B9B), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_hospital_rounded,
              color: Color(0xFFD23B3B), size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('5-1-1 pattern detected',
                    style: sans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFB02525))),
                const SizedBox(height: 2),
                Text(
                    'Your contractions are ~5 min apart, ~1 min long, over about an hour. Call your provider / head to the hospital.',
                    style: sans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8A2A2A))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PretermAlert extends StatelessWidget {
  const _PretermAlert({required this.week, required this.sans});
  final int week;
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              'You are at week $week. Regular contractions before 37 weeks may signal preterm labor — call your provider even if the 5-1-1 rule is not met yet.',
              style: sans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8A6A1A)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({required this.sans});
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['Pattern', 'Irregular, not closer', 'Regular, closer over time'],
      ['Intensity', 'Stays same / fades', 'Gets stronger'],
      ['Location', 'Front of abdomen', 'Back → radiates to front'],
      ['With movement', 'Often stops on walking/rest', 'Continues regardless'],
      ['Duration', "Doesn't lengthen", 'Gradually lengthens'],
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDE6EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Braxton Hicks vs. true labor',
              style: sans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E))),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(flex: 3, child: SizedBox()),
              Expanded(
                flex: 4,
                child: Text('False labor',
                    style: sans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A8C6A))),
              ),
              Expanded(
                flex: 4,
                child: Text('True labor',
                    style: sans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFD23B3B))),
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFE8E4EC)),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(r[0],
                          style: sans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6B6570))),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(r[1],
                          style: sans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF3D3A42))),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(r[2],
                          style: sans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF3D3A42))),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _CallImmediatelyBox extends StatelessWidget {
  const _CallImmediatelyBox({required this.sans});
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;

  @override
  Widget build(BuildContext context) {
    const items = [
      'Contractions before 37 weeks (possible preterm labor)',
      'Contractions with bleeding, fluid leakage, or severe pain',
      "Baby's movement decreases along with contractions",
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
          Text('Call immediately (any trimester)',
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
