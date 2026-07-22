import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/step_goal.dart';
import '../services/step_ai_service.dart';
import '../services/step_service.dart';

/// Live step tracker backed by the device pedometer, with an AI coaching card
/// that gives pregnancy-safe activity guidance based on the day's steps.
class StepCounterScreen extends StatefulWidget {
  const StepCounterScreen({
    super.key,
    required this.goal,
    required this.trimester,
  });

  final StepGoal goal;
  final int trimester;

  @override
  State<StepCounterScreen> createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  static const _orange = Color(0xFFFF9B50);
  static const _ink = Color(0xFF2D2A32);
  static const _muted = Color(0xFF6B6570);

  final _ai = StepAiService();

  StreamSubscription<int>? _sub;
  int _steps = 0;
  bool _loading = true;
  String? _sensorError;

  StepInsight? _insight;
  bool _insightLoading = false;

  int get _goal => widget.goal.steps;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    _steps = await StepService.getTodaySteps();

    if (!StepService.isSupported) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _sensorError = 'Step counting needs a phone with a motion sensor.';
      });
      unawaited(_refreshInsight());
      return;
    }

    final granted = await StepService.ensurePermission();
    if (!granted) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _sensorError =
            'Allow physical-activity access to count your steps automatically.';
      });
      unawaited(_refreshInsight());
      return;
    }

    _sub = StepService.todayStepStream().listen(
      (steps) {
        if (!mounted) return;
        setState(() {
          _steps = steps;
          _loading = false;
        });
      },
      onError: (Object e) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _sensorError = 'Could not read the step sensor on this device.';
        });
      },
    );

    if (!mounted) return;
    setState(() => _loading = false);
    unawaited(_refreshInsight());
  }

  Future<void> _refreshInsight() async {
    if (_insightLoading) return;
    setState(() => _insightLoading = true);
    final insight = await _ai.insight(
      steps: _steps,
      goal: _goal,
      trimester: widget.trimester,
      distanceKm: StepGoal.distanceKm(_steps),
    );
    if (!mounted) return;
    setState(() {
      _insight = insight;
      _insightLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    final distance = StepGoal.distanceKm(_steps);
    final calories = StepGoal.calories(_steps);
    final frac = _goal == 0 ? 0.0 : (_steps / _goal);
    final reached = _steps >= _goal;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8FA),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Step Counter',
            style: sans(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              children: [
                // ── Ring summary ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
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
                      SizedBox(
                        width: 190,
                        height: 190,
                        child: CustomPaint(
                          painter: _RingPainter(
                            progress: frac.clamp(0.0, 1.0),
                            trackColor: const Color(0xFFFDEBDC),
                            fillColor: _orange,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.directions_walk_rounded,
                                    color: _orange, size: 26),
                                const SizedBox(height: 4),
                                Text(
                                  _formatSteps(_steps),
                                  style: sans(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: _ink,
                                  ),
                                ),
                                Text(
                                  'of ${_formatSteps(_goal)} steps',
                                  style: sans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _muted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(frac * 100).clamp(0, 100).round()}%',
                                  style: sans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        reached
                            ? 'Goal reached — great going! 🎉'
                            : 'Keep moving at your own pace',
                        style: sans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Distance / calories stats ────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        sans: sans,
                        icon: Icons.route_rounded,
                        iconColor: const Color(0xFF4A9FE8),
                        value: '${distance.toStringAsFixed(2)} km',
                        label: 'Distance',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        sans: sans,
                        icon: Icons.local_fire_department_rounded,
                        iconColor: const Color(0xFFE85A5A),
                        value: '$calories kcal',
                        label: 'Burned',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── AI coach card ────────────────────────────────
                _AiCoachCard(
                  sans: sans,
                  insight: _insight,
                  loading: _insightLoading,
                  onRefresh: _refreshInsight,
                ),
                const SizedBox(height: 16),

                if (_sensorError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: _orange, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _sensorError!,
                            style: sans(
                              fontSize: 12,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                              color: _muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Goal explanation ─────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDEFE2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.directions_walk_rounded,
                          color: _orange, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your goal of ${_formatSteps(_goal)} steps is tuned to your '
                          'trimester. Moderate walking supports circulation, sleep and '
                          'mood in pregnancy — always pace yourself and stop if you feel unwell.',
                          style: sans(
                            fontSize: 12,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            color: _muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _formatSteps(int steps) {
    final s = steps.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.sans,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: sans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D2A32),
                ),
              ),
              Text(
                label,
                style: sans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B6570),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiCoachCard extends StatelessWidget {
  const _AiCoachCard({
    required this.sans,
    required this.insight,
    required this.loading,
    required this.onRefresh,
  });

  final TextStyle Function(
      {FontWeight? fontWeight, double? fontSize, Color? color}) sans;
  final StepInsight? insight;
  final bool loading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C5CFF), Color(0xFF9B7ED9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'AI ACTIVITY COACH',
                style: sans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: loading ? null : onRefresh,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: Colors.white.withValues(alpha: loading ? 0.4 : 0.9),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (loading)
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Thinking about your day…',
                  style: sans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            )
          else
            Text(
              insight?.message ??
                  'Tap refresh for a personalized activity tip based on your steps.',
              style: sans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ).copyWith(height: 1.5),
            ),
          if (insight != null && !loading) ...[
            const SizedBox(height: 10),
            Text(
              insight!.fromAi ? 'Powered by Gemini' : 'On-device coach',
              style: sans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });

  final double progress;
  final Color trackColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;
    const strokeWidth = 14.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
