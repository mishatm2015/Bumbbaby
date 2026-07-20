import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BmiWeightScreen extends StatelessWidget {
  const BmiWeightScreen({super.key});

  // ── static sample data ────────────────────────────────────────────────────
  static const double _heightCm  = 162;
  static const double _preWeight = 58;

  static const List<_WeekWeight> _history = [
    _WeekWeight(week: 8,  weight: 58.2),
    _WeekWeight(week: 12, weight: 59.1),
    _WeekWeight(week: 16, weight: 60.5),
    _WeekWeight(week: 20, weight: 62.8),
    _WeekWeight(week: 24, weight: 65.2),
  ];

  // ── colours ───────────────────────────────────────────────────────────────
  static const _dark   = Color(0xFF1A1A2E);
  static const _barLo  = Color(0xFFE8BF7A);
  static const _barHi  = Color(0xFFB87A20);

  double get _bmi => _preWeight / ((_heightCm / 100) * (_heightCm / 100));

  String get _bmiCategory {
    if (_bmi < 18.5) return 'Underweight';
    if (_bmi < 25.0) return 'Normal weight';
    if (_bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    final bmi = _bmi;

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
          'BMI & Weight',
          style: sans(fontSize: 17, fontWeight: FontWeight.w700, color: _dark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── BMI card ─────────────────────────────────────────────────
            _BmiCard(bmi: bmi, category: _bmiCategory, sans: sans),
            const SizedBox(height: 24),

            // ── Stats grid ───────────────────────────────────────────────
            _StatsGrid(sans: sans),
            const SizedBox(height: 20),

            // ── Recommended gain ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9F0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBCDEBC)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended weight gain',
                    style: sans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E6B2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'For normal BMI: recommended gain is 11–16 kg total. You\'re on track at week 24.',
                    style: sans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF3D7A3D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Weight chart ─────────────────────────────────────────────
            Text(
              'Weight this pregnancy (kg)',
              style: sans(fontSize: 14, fontWeight: FontWeight.w700, color: _dark),
            ),
            const SizedBox(height: 16),
            _WeightChart(history: _history, barLo: _barLo, barHi: _barHi, sans: sans),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── BMI Card ──────────────────────────────────────────────────────────────────

class _BmiCard extends StatelessWidget {
  const _BmiCard({required this.bmi, required this.category, required this.sans});

  final double bmi;
  final String category;
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color}) sans;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0C8), Color(0xFFFFD87A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRE-PREGNANCY BMI',
            style: sans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF7A5200),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bmi.toStringAsFixed(1),
            style: sans(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4A3000),
            ),
          ),
          Text(
            category,
            style: sans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF7A5200),
            ),
          ),
          const SizedBox(height: 16),
          // Gradient slider bar
          _BmiSlider(bmi: bmi),
        ],
      ),
    );
  }
}

class _BmiSlider extends StatelessWidget {
  const _BmiSlider({required this.bmi});

  final double bmi;

  /// Maps BMI (roughly 14–35) to 0..1 for the indicator position.
  double get _fraction => ((bmi - 14.0) / (35.0 - 14.0)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final pos = _fraction * (w - 14);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Gradient track
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF5EC4EF), // underweight – blue
                          Color(0xFF7DDA85), // normal – green
                          Color(0xFFFFB347), // overweight – orange
                          Color(0xFFEF5350), // obese – red
                        ],
                        stops: [0.0, 0.26, 0.60, 1.0],
                      ),
                    ),
                  ),
                ),
                // Indicator dot
                Positioned(
                  left: pos,
                  top: -3,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A3000),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SliderLabel('Underweight <18.5'),
            _SliderLabel('Normal 18.5–24.9'),
            _SliderLabel('Overweight 25+'),
          ],
        ),
      ],
    );
  }
}

class _SliderLabel extends StatelessWidget {
  const _SliderLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 9,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF9A7A3A),
      ),
    );
  }
}

// ── Stats Grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.sans});

  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color}) sans;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCell(label: 'Height (cm)', value: '162', sans: sans)),
            const SizedBox(width: 16),
            Expanded(child: _StatCell(label: 'Pre-preg. weight (kg)', value: '58', sans: sans)),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: Color(0xFFE8E4EC), height: 1),
        ),
        Row(
          children: [
            Expanded(child: _StatCell(label: 'Current weight (kg)', value: '65.2', sans: sans)),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCell(
                label: 'Weight gained',
                value: '+7.2 kg',
                valueColor: const Color(0xFFE8A020),
                sans: sans,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF1A1A2E),
    required this.sans,
  });

  final String label;
  final String value;
  final Color valueColor;
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color}) sans;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: sans(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF6B6570)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: sans(fontSize: 22, fontWeight: FontWeight.w700, color: valueColor),
        ),
      ],
    );
  }
}

// ── Weight Chart ──────────────────────────────────────────────────────────────

class _WeightChart extends StatelessWidget {
  const _WeightChart({
    required this.history,
    required this.barLo,
    required this.barHi,
    required this.sans,
  });

  final List<_WeekWeight> history;
  final Color barLo;
  final Color barHi;
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color}) sans;

  @override
  Widget build(BuildContext context) {
    final maxW = history.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
    final minW = history.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 2;
    const chartHeight = 100.0;
    final isLast = history.length - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < history.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                Text(
                  history[i].weight.toString(),
                  style: sans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: i == isLast ? barHi : const Color(0xFF6B6570),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: chartHeight * ((history[i].weight - minW) / (maxW - minW)).clamp(0.15, 1.0),
                  decoration: BoxDecoration(
                    color: i == isLast ? barHi : barLo,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Wk ${history[i].week}',
                  style: sans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: i == isLast ? barHi : const Color(0xFF6B6570),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _WeekWeight {
  const _WeekWeight({required this.week, required this.weight});
  final int week;
  final double weight;
}
