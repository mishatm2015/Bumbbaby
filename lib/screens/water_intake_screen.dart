import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/hydration.dart';
import '../services/hydration_service.dart';

/// Full water tracker: add / remove glasses, enter an exact count, and see the
/// personalized daily goal. Intake persists per day via [HydrationService].
class WaterIntakeScreen extends StatefulWidget {
  const WaterIntakeScreen({super.key, required this.goal});

  final HydrationGoal goal;

  @override
  State<WaterIntakeScreen> createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends State<WaterIntakeScreen> {
  static const _blue = Color(0xFF4A9FE8);
  static const _ink = Color(0xFF2D2A32);
  static const _muted = Color(0xFF6B6570);

  int _cups = 0;
  bool _loading = true;

  int get _goalCups => widget.goal.cups;
  int get _maxCups => math.max(_goalCups + 4, _goalCups); // allow going over goal

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cups = await HydrationService.getTodayCups();
    if (!mounted) return;
    setState(() {
      _cups = cups.clamp(0, _maxCups);
      _loading = false;
    });
  }

  Future<void> _setCups(int value) async {
    final v = value.clamp(0, _maxCups);
    setState(() => _cups = v);
    await HydrationService.setTodayCups(v);
  }

  Future<void> _enterExact() async {
    final controller = TextEditingController(text: '$_cups');
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Enter glasses',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Number of 250 ml glasses',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final n = int.tryParse(controller.text.trim()) ?? _cups;
                Navigator.pop(context, n);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (result != null) await _setCups(result);
  }

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    final litres = _cups * HydrationGoal.cupLitres;
    final goalL = widget.goal.litres;
    final frac = goalL == 0 ? 0.0 : (litres / goalL);
    final reached = _cups >= _goalCups;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FC),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Water Intake',
            style: sans(fontWeight: FontWeight.w700, fontSize: 17)),
        actions: [
          IconButton(
            tooltip: 'Enter exact glasses',
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: _loading ? null : _enterExact,
          ),
        ],
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
                        width: 180,
                        height: 180,
                        child: CustomPaint(
                          painter: _RingPainter(
                            progress: frac.clamp(0.0, 1.0),
                            trackColor: const Color(0xFFE8F4FE),
                            fillColor: _blue,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${litres.toStringAsFixed(2)}L',
                                  style: sans(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: _ink,
                                  ),
                                ),
                                Text(
                                  'of ${goalL.toStringAsFixed(1)}L',
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
                                    color: _blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$_cups of $_goalCups glasses',
                        style: sans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reached
                            ? 'Great! You reached today\'s goal 🎉'
                            : 'Each glass is 250 ml',
                        style: sans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Add / remove controls ────────────────────────
                Row(
                  children: [
                    _RoundBtn(
                      icon: Icons.remove,
                      onTap: _cups > 0 ? () => _setCups(_cups - 1) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () => _setCups(_cups + 1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _blue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.water_drop_rounded),
                          label: Text(
                            'Add a glass (250 ml)',
                            style: sans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _RoundBtn(
                      icon: Icons.add,
                      onTap: () => _setCups(_cups + 1),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Cup grid ─────────────────────────────────────
                Text(
                  'TAP TO LOG',
                  style: sans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(_goalCups, (i) {
                    final filled = i < _cups;
                    return GestureDetector(
                      onTap: () => _setCups(i + 1 == _cups ? i : i + 1),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: filled
                              ? _blue.withValues(alpha: 0.15)
                              : const Color(0xFFEFF4F8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.water_drop,
                          size: 22,
                          color: filled ? _blue : const Color(0xFFC6D6E4),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // ── Goal explanation ─────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FD),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: _blue, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your goal of ${goalL.toStringAsFixed(1)} L ($_goalCups glasses) is based on '
                          'your body weight and trimester. Drink more in hot weather, '
                          'while exercising, or if your urine is dark yellow.',
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
                Center(
                  child: TextButton.icon(
                    onPressed: _cups == 0 ? null : () => _setCups(0),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset today'),
                  ),
                ),
              ],
            ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: enabled ? const Color(0xFF4A9FE8) : const Color(0xFFDCE4EC),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: enabled ? const Color(0xFF4A9FE8) : const Color(0xFFC6D0DA),
          ),
        ),
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
