import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sleep duration log, quality picker, weekly chart, and pregnancy tips.
class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  static const _purple = Color(0xFF706FD3);
  static const _purpleDeep = Color(0xFF574B90);
  static const _trackBlue = Color(0xFF4A9FE8);

  double _hours = 7.5;
  int _quality = 1;
  static const _qualities = ['Deep', 'Good', 'Fair', 'Poor', 'Restless'];
  static const _qualityEmoji = ['😴', '😊', '😐', '🙁', '😰'];

  static const _week = [7.0, 8.0, 5.0, 7.5, 9.0, 6.0, 7.3];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final serif = GoogleFonts.fraunces;
    final sans = GoogleFonts.plusJakartaSans;
    const goal = 9.0;
    final lastNightH = 7 + 20 / 60.0;
    final ringProgress = (lastNightH / goal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Sleep Tracker',
          style: serif(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sleep history coming soon')),
              );
            },
            child: Text(
              'Log',
              style: sans(fontWeight: FontWeight.w700, fontSize: 14, color: _purpleDeep),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            decoration: BoxDecoration(
              color: _purple,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LAST NIGHT',
                  style: sans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '7h 20m',
                  style: serif(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Recommended: 8–9 hours in pregnancy',
                  style: sans(fontSize: 13, color: Colors.white.withValues(alpha: 0.95), height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CustomPaint(
                    painter: _RingPainter(progress: ringProgress, color: _purple, track: const Color(0xFFE8E4FA)),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${lastNightH.toStringAsFixed(1)}h',
                      style: serif(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black),
                    ),
                    Text(
                      'of ${goal.toStringAsFixed(0)}h goal',
                      style: serif(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Hours slept last night',
                  style: serif(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ),
              Text(
                '${_hours.toStringAsFixed(1)} hrs',
                style: serif(fontSize: 15, fontWeight: FontWeight.w700, color: _purpleDeep),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _trackBlue,
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: _trackBlue,
              overlayColor: _trackBlue.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: _hours,
              min: 3,
              max: 12,
              divisions: 18,
              onChanged: (v) => setState(() => _hours = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('3h', style: sans(fontSize: 12, color: Colors.black45)),
              Text('12h', style: sans(fontSize: 12, color: Colors.black45)),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'SLEEP QUALITY',
            style: serif(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_qualities.length, (i) {
              final sel = i == _quality;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _quality = i),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFFE8E4FA) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_qualityEmoji[i], style: const TextStyle(fontSize: 26)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _qualities[i],
                          textAlign: TextAlign.center,
                          style: serif(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: sel ? _purpleDeep : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
          Text(
            'THIS WEEK',
            style: serif(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(7, (i) {
            final h = _week[i];
            final maxH = _week.reduce(math.max);
            final frac = maxH == 0 ? 0.0 : h / maxH;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(_days[i], style: serif(fontSize: 13, color: Colors.black87)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: frac,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        color: _purple,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '${h.toStringAsFixed(1)}h',
                      textAlign: TextAlign.right,
                      style: sans(fontSize: 13, fontWeight: FontWeight.w700, color: _trackBlue),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF90CAF9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Color(0xFF1976D2), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Sleep tips for pregnancy',
                      style: sans(fontWeight: FontWeight.w800, fontSize: 14, color: const Color(0xFF1565C0)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Sleep on your left side · Use a pregnancy pillow between knees · '
                  'Avoid screens 1 hr before bed · Eat a light snack if hungry at night · '
                  'Keep room cool and dark',
                  style: serif(fontSize: 13, height: 1.4, color: const Color(0xFF1565C0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color, required this.track});

  final double progress;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 14.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - stroke) / 2;

    final bg = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2,
      false,
      bg,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
