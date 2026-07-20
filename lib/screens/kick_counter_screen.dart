import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KickCounterScreen extends StatefulWidget {
  const KickCounterScreen({super.key});

  @override
  State<KickCounterScreen> createState() => _KickCounterScreenState();
}

class _KickCounterScreenState extends State<KickCounterScreen> {
  static const int _goal = 10;

  int _count = 0;
  DateTime? _sessionStart;
  final List<DateTime> _log = [];

  static const _pink     = Color(0xFFE04B84);
  static const _pinkBg   = Color(0xFFFFF0F5);
  static const _dark     = Color(0xFF1A1A2E);
  static const _muted    = Color(0xFF6B6570);

  void _logKick() {
    setState(() {
      _sessionStart ??= DateTime.now();
      _count++;
      _log.insert(0, DateTime.now());
    });
  }

  void _reset() {
    setState(() {
      _count = 0;
      _sessionStart = null;
      _log.clear();
    });
  }

  String _formatTime(DateTime dt) {
    final h  = dt.hour.toString().padLeft(2, '0');
    final m  = dt.minute.toString().padLeft(2, '0');
    final s  = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;

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
          'Kick Counter',
          style: sans(fontSize: 17, fontWeight: FontWeight.w700, color: _dark),
        ),
        actions: [
          TextButton(
            onPressed: _reset,
            child: Text(
              'Reset',
              style: sans(fontSize: 14, fontWeight: FontWeight.w600, color: _pink),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main counter card ────────────────────────────────────────
            _CounterCard(
              count: _count,
              goal: _goal,
              onTap: _logKick,
              sans: sans,
            ),
            const SizedBox(height: 28),

            // ── Progress row ─────────────────────────────────────────────
            _InfoRow(
              label: 'Progress to goal',
              value: '$_count / $_goal',
              sans: sans,
            ),
            const Divider(height: 24, color: Color(0xFFE8E4EC)),

            _InfoRow(
              label: 'Session started',
              value: _sessionStart != null ? _formatTime(_sessionStart!) : '—',
              sans: sans,
            ),
            const SizedBox(height: 28),

            // ── Progress bar ─────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_count / _goal).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: const Color(0xFFFFD6E8),
                valueColor: const AlwaysStoppedAnimation(_pink),
              ),
            ),
            const SizedBox(height: 28),

            // ── Kick log ─────────────────────────────────────────────────
            Text(
              'KICK LOG',
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
                    'No kicks logged yet. Tap the baby above!',
                    style: sans(fontSize: 13, fontWeight: FontWeight.w500, color: _muted),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _log.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE8E4EC)),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _pinkBg,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${_log.length - index}',
                              style: sans(fontSize: 12, fontWeight: FontWeight.w700, color: _pink),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Kick #${_log.length - index}',
                          style: sans(fontSize: 14, fontWeight: FontWeight.w600, color: _dark),
                        ),
                        const Spacer(),
                        Text(
                          _formatTime(_log[index]),
                          style: sans(fontSize: 13, fontWeight: FontWeight.w500, color: _muted),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ── Counter card ───────────────────────────────────────────────────────────────

class _CounterCard extends StatelessWidget {
  const _CounterCard({
    required this.count,
    required this.goal,
    required this.onTap,
    required this.sans,
  });

  final int count;
  final int goal;
  final VoidCallback onTap;
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color, double? letterSpacing}) sans;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
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
            'TODAY\'S KICKS',
            style: sans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: const Color(0xFF9A2A5A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 64,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF6A0030),
            ),
          ),
          Text(
            'Goal: $goal kicks in 2 hours',
            style: sans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF9A2A5A)),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 90,
              height: 90,
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
                child: Text('👶', style: TextStyle(fontSize: 42)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap the baby to log a kick',
            style: sans(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF9A2A5A)),
          ),
        ],
      ),
    );
  }
}

// ── Info row ───────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, required this.sans});

  final String label;
  final String value;
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color}) sans;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: sans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E)),
        ),
        Text(
          value,
          style: sans(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF6B6570)),
        ),
      ],
    );
  }
}
