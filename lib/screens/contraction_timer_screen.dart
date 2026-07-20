import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContractionTimerScreen extends StatefulWidget {
  const ContractionTimerScreen({super.key});

  @override
  State<ContractionTimerScreen> createState() => _ContractionTimerScreenState();
}

enum _TimerState { idle, timing }

class _ContractionEntry {
  _ContractionEntry({
    required this.startTime,
    required this.durationSec,
    this.intervalSec,
  });

  final DateTime startTime;
  final int durationSec;
  final int? intervalSec;
}

class _ContractionTimerScreenState extends State<ContractionTimerScreen> {
  _TimerState _state = _TimerState.idle;
  int _elapsedSec = 0;
  DateTime? _contractionStart;
  Timer? _timer;

  final List<_ContractionEntry> _log = [];

  static const _teal    = Color(0xFF1A8C6A);
  static const _dark    = Color(0xFF1A1A2E);
  static const _muted   = Color(0xFF6B6570);
  static const _amber   = Color(0xFFE8A020);

  // ── Timer control ─────────────────────────────────────────────────────────
  void _start() {
    setState(() {
      _state = _TimerState.timing;
      _contractionStart = DateTime.now();
      _elapsedSec = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSec++);
    });
  }

  void _stop() {
    _timer?.cancel();
    final duration = _elapsedSec;
    final now = DateTime.now();

    int? intervalSec;
    if (_log.isNotEmpty) {
      intervalSec = now.difference(_log.first.startTime).inSeconds - _log.first.durationSec;
    }

    setState(() {
      _log.insert(
        0,
        _ContractionEntry(
          startTime: _contractionStart ?? now,
          durationSec: duration,
          intervalSec: intervalSec,
        ),
      );
      _state = _TimerState.idle;
      _elapsedSec = 0;
      _contractionStart = null;
    });
  }

  void _clear() {
    _timer?.cancel();
    setState(() {
      _log.clear();
      _state = _TimerState.idle;
      _elapsedSec = 0;
      _contractionStart = null;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    final avg = _log.map((e) => e.durationSec).reduce((a, b) => a + b) / _log.length;
    return _durLabel(avg.round());
  }

  String get _avgInterval {
    final withInterval = _log.where((e) => e.intervalSec != null).toList();
    if (withInterval.isEmpty) return '—';
    final avg = withInterval.map((e) => e.intervalSec!).reduce((a, b) => a + b) /
        withInterval.length;
    return _durLabel(avg.round());
  }

  String _timeLabel(DateTime dt) {
    final h  = dt.hour.toString().padLeft(2, '0');
    final m  = dt.minute.toString().padLeft(2, '0');
    final s  = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    final isTiming = _state == _TimerState.timing;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Contraction Timer',
          style: sans(fontSize: 17, fontWeight: FontWeight.w700, color: _dark),
        ),
        actions: [
          TextButton(
            onPressed: _clear,
            child: Text(
              'Clear',
              style: sans(fontSize: 14, fontWeight: FontWeight.w600, color: _teal),
            ),
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
                      color: const Color(0xFF0D6B50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatSec(_elapsedSec),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0A4A38),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isTiming
                        ? 'Press stop when contraction ends'
                        : 'Press start when a contraction begins',
                    style: sans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A6B54),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isTiming ? _stop : _start,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Text(
                        isTiming ? 'Stop contraction' : 'Start contraction',
                        style: sans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Stats row ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatPill(
                    value: '${_log.length}',
                    label: 'Contractions',
                    valueColor: _dark,
                    sans: sans,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatPill(
                    value: _avgDuration,
                    label: 'Avg duration',
                    valueColor: _amber,
                    sans: sans,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatPill(
                    value: _avgInterval,
                    label: 'Avg interval',
                    valueColor: _amber,
                    sans: sans,
                  ),
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
                  Text(
                    '511 rule reminder',
                    style: sans(fontSize: 12, fontWeight: FontWeight.w700, color: _teal),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Go to hospital when contractions are 5 min apart, last 1 minute each, for 1 hour.',
                    style: sans(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF2E6B5A)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Contraction log ──────────────────────────────────────────
            Text(
              'CONTRACTION LOG',
              style: sans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: _muted,
              ),
            ),
            const SizedBox(height: 12),

            if (_log.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'No contractions logged yet',
                    style: sans(fontSize: 13, fontWeight: FontWeight.w500, color: _muted),
                  ),
                ),
              )
            else ...[
              // header
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: _LogHeader('#', sans: sans)),
                    Expanded(flex: 2, child: _LogHeader('Time', sans: sans)),
                    Expanded(child: _LogHeader('Duration', sans: sans)),
                    Expanded(child: _LogHeader('Interval', sans: sans)),
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
                          child: Text(
                            '${_log.length - index}',
                            style: sans(fontSize: 13, fontWeight: FontWeight.w700, color: _dark),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            _timeLabel(entry.startTime),
                            style: sans(fontSize: 12, fontWeight: FontWeight.w500, color: _muted),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _durLabel(entry.durationSec),
                            style: sans(fontSize: 12, fontWeight: FontWeight.w600, color: _teal),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.intervalSec != null ? _durLabel(entry.intervalSec!) : '—',
                            style: sans(fontSize: 12, fontWeight: FontWeight.w500, color: _muted),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
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
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color}) sans;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: sans(fontSize: 20, fontWeight: FontWeight.w700, color: valueColor),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: sans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF6B6570)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LogHeader extends StatelessWidget {
  const _LogHeader(this.text, {required this.sans});
  final String text;
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color}) sans;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: sans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF6B6570)),
    );
  }
}
