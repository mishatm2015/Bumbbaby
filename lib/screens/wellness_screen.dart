import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/hydration.dart';
import '../models/pregnancy_progress.dart';
import '../services/auth_service.dart';
import '../services/hydration_service.dart';
import '../services/meal_plan_service.dart';
import '../services/user_repository.dart';
import 'nutrition_planner_screen.dart';
import 'medicine_screen.dart';

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  final _userRepo = UserRepository();

  HydrationGoal _goal = const HydrationGoal(2.4); // sensible default
  int _loggedCups = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final cups = await HydrationService.getTodayCups();

    HydrationGoal goal = _goal;
    final uid = AuthService().currentUser?.uid;
    if (uid != null) {
      final profile = await _userRepo.getProfile(uid);
      final weightKg =
          HydrationGoal.parseWeightKg(profile?.prePregnancyWeight);
      final trimester = PregnancyProgress.fromLmp(profile?.lmp)?.trimester ?? 1;
      goal = HydrationGoal.compute(weightKg: weightKg, trimester: trimester);
    }

    if (!mounted) return;
    setState(() {
      _goal = goal;
      _loggedCups = cups.clamp(0, goal.cups);
      _loading = false;
    });
  }

  Future<void> _logCup(int index) async {
    final newCount = index < _loggedCups ? index : index + 1;
    setState(() => _loggedCups = newCount);
    await HydrationService.setTodayCups(newCount);
  }

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    final totalCups = _goal.cups;
    final double litres = _loggedCups * HydrationGoal.cupLitres;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FC),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {},
        ),
        title: Text('Wellness',
            style: sans(fontWeight: FontWeight.w700, fontSize: 17)),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        children: [
          // ── Wellness score card ──────────────────────────────
          _ScoreCard(sans: sans),
          const SizedBox(height: 22),

          // ── Hydration tracker ────────────────────────────────
          _SectionHeader('HYDRATION TRACKER', sans),
          const SizedBox(height: 12),
          _HydrationCard(
            loggedCups: _loggedCups,
            totalCups: totalCups,
            litres: litres,
            goalLitres: _goal.litres,
            loading: _loading,
            onTap: _logCup,
          ),
          const SizedBox(height: 22),

          // ── Today's meal plan ────────────────────────────────
          Row(
            children: [
              Expanded(child: _SectionHeader("TODAY'S MEAL PLAN", sans)),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NutritionPlannerScreen(),
                    ),
                  );
                },
                child: Text(
                  'Full planner',
                  style: sans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE04B84),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _TodaysMealPreview(onOpenPlanner: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NutritionPlannerScreen(),
              ),
            );
          }),
          const SizedBox(height: 22),

          // ── Medicines today ──────────────────────────────────
          _SectionHeader('MEDICINES TODAY', sans),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MedicineScreen()),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: const _MedicineTile(
              name: 'Open medicine tracker',
              subtitle: 'Log folic acid, iron & more',
              dotColor: Color(0xFF4CAF6A),
              icon: Icons.medication_rounded,
              iconColor: Color(0xFFE85A5A),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wellness score card ───────────────────────────────────────────────────────

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.sans});
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color}) sans;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3EC88C), Color(0xFF2BAF77)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S WELLNESS SCORE",
            style: sans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: sans(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              children: [
                const TextSpan(text: '72'),
                TextSpan(
                  text: ' / 100',
                  style: sans(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Drink more water & take your evening iron tablet',
            style: sans(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, this.sans);
  final String title;
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color, double? letterSpacing}) sans;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: sans(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: const Color(0xFF2D2A32),
      ),
    );
  }
}

// ── Hydration card ────────────────────────────────────────────────────────────

class _HydrationCard extends StatelessWidget {
  const _HydrationCard({
    required this.loggedCups,
    required this.totalCups,
    required this.litres,
    required this.goalLitres,
    required this.loading,
    required this.onTap,
  });

  final int loggedCups;
  final int totalCups;
  final double litres;
  final double goalLitres;
  final bool loading;
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    const perRow = 6;
    final rows = (totalCups / perRow).ceil();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 80,
            height: 80,
            child: CustomPaint(
              painter: _RingPainter(
                progress: totalCups == 0 ? 0 : loggedCups / totalCups,
                trackColor: const Color(0xFFE8F4FE),
                fillColor: const Color(0xFF4A9FE8),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${litres.toStringAsFixed(1)}L',
                      style: sans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2D2A32),
                      ),
                    ),
                    Text(
                      'of ${goalLitres.toStringAsFixed(1)}L',
                      style: sans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF9A939E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log a glass of water',
                  style: sans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2A32),
                  ),
                ),
                const SizedBox(height: 10),
                for (int row = 0; row < rows; row++) ...[
                  if (row > 0) const SizedBox(height: 6),
                  Row(
                    children: List.generate(perRow, (col) {
                      final idx = row * perRow + col;
                      if (idx >= totalCups) {
                        return const SizedBox(width: 26);
                      }
                      final filled = idx < loggedCups;
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: GestureDetector(
                          onTap: () => onTap(idx),
                          child: Icon(
                            Icons.water_drop,
                            size: 22,
                            color: filled
                                ? const Color(0xFF4A9FE8)
                                : const Color(0xFFD4E9F7),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  loading
                      ? 'Calculating your goal…'
                      : 'Goal: $totalCups cups (${goalLitres.toStringAsFixed(1)} litres) daily',
                  style: sans(
                    fontSize: 11,
                    color: const Color(0xFF9A939E),
                    fontWeight: FontWeight.w500,
                  ),
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
    final radius = (size.width - 10) / 2;
    const strokeWidth = 8.0;
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

// ── Meal plan preview (live from Nutrition Planner) ───────────────────────────

class _TodaysMealPreview extends StatefulWidget {
  const _TodaysMealPreview({required this.onOpenPlanner});
  final VoidCallback onOpenPlanner;

  @override
  State<_TodaysMealPreview> createState() => _TodaysMealPreviewState();
}

class _TodaysMealPreviewState extends State<_TodaysMealPreview> {
  final _mealService = MealPlanService();
  final _userRepo = UserRepository();
  bool _loading = true;
  List<_MealItem> _meals = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    var week = 1;
    var trimester = 1;
    final uid = AuthService().currentUser?.uid;
    if (uid != null) {
      final profile = await _userRepo.getProfile(uid);
      final progress = PregnancyProgress.fromLmp(profile?.lmp);
      week = progress?.contentWeek ?? 1;
      trimester = progress?.trimester ?? 1;
    }
    final prefs = await _mealService.loadPrefs();
    final plan = await _mealService.planForDate(
      date: DateTime.now(),
      week: week,
      trimester: trimester,
      prefs: prefs,
    );
    if (!mounted) return;
    setState(() {
      _meals = [
        _MealItem(
          plan.breakfast?.emoji ?? '🌄',
          'Breakfast',
          plan.breakfast?.name ?? 'Open planner',
          'Today',
          const Color(0xFFFFF3E0),
        ),
        _MealItem(
          plan.lunch?.emoji ?? '☀️',
          'Lunch',
          plan.lunch?.name ?? 'Open planner',
          'Today',
          const Color(0xFFE8F5E9),
        ),
        _MealItem(
          plan.dinner?.emoji ?? '🌙',
          'Dinner',
          plan.dinner?.name ?? 'Open planner',
          'Today',
          const Color(0xFFE3F2FD),
        ),
        _MealItem(
          plan.morningSnack?.emoji ?? '🍎',
          'Snack',
          plan.morningSnack?.name ?? 'Open planner',
          'Today',
          const Color(0xFFFCE4EC),
        ),
      ];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.05,
      children: _meals
          .map((m) => _MealCard(meal: m, onTap: widget.onOpenPlanner))
          .toList(),
    );
  }
}

class _MealItem {
  const _MealItem(this.emoji, this.label, this.meal, this.tag, this.tagColor);
  final String emoji;
  final String label;
  final String meal;
  final String tag;
  final Color tagColor;
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, this.onTap});
  final _MealItem meal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0E6EA)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(meal.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                meal.label,
                style: sans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF9A939E),
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Text(
                  meal.meal,
                  style: sans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2A32),
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: meal.tagColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  meal.tag,
                  style: sans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4A4550),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Medicine tile ─────────────────────────────────────────────────────────────

class _MedicineTile extends StatelessWidget {
  const _MedicineTile({
    required this.name,
    required this.subtitle,
    required this.dotColor,
    required this.icon,
    required this.iconColor,
  });

  final String name;
  final String subtitle;
  final Color dotColor;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: sans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2A32),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: sans(
                    fontSize: 12,
                    color: const Color(0xFF9A939E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
