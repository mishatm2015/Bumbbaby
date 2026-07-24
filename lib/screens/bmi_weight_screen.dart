import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/hydration.dart';
import '../models/user_profile.dart';
import '../models/weight_entry.dart';
import '../services/user_repository.dart';
import '../services/weight_service.dart';

/// BMI & weight tracker. Height and pre-pregnancy weight come from the user's
/// profile; the user logs their current weight over time and sees the trend.
class BmiWeightScreen extends StatefulWidget {
  const BmiWeightScreen({super.key});

  @override
  State<BmiWeightScreen> createState() => _BmiWeightScreenState();
}

class _BmiWeightScreenState extends State<BmiWeightScreen> {
  static const _dark = Color(0xFF1A1A2E);
  static const _barLo = Color(0xFFE8BF7A);
  static const _barHi = Color(0xFFB87A20);

  final _userRepo = UserRepository();

  UserProfile? _profile;
  List<WeightEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final profile = uid == null ? null : await _userRepo.getProfile(uid);
    final entries = await WeightService.getEntries();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _entries = entries;
      _loading = false;
    });
  }

  // ── derived values ────────────────────────────────────────────────────────
  double? get _heightCm => _parseHeightCm(_profile?.height);
  double? get _preWeightKg => HydrationGoal.parseWeightKg(_profile?.prePregnancyWeight);
  int? get _currentWeek => _profile?.currentWeek;

  double? get _currentWeightKg =>
      _entries.isNotEmpty ? _entries.last.weightKg : _preWeightKg;

  double? get _gainedKg {
    final cur = _currentWeightKg;
    final pre = _preWeightKg;
    if (cur == null || pre == null) return null;
    return cur - pre;
  }

  double? _bmiFromWeight(double? weightKg) {
    final h = _heightCm;
    final w = weightKg;
    if (h == null || w == null || h <= 0) return null;
    final m = h / 100;
    return w / (m * m);
  }

  /// BMI from the latest logged weight (updates when you add/change weight).
  double? get _bmi => _bmiFromWeight(_currentWeightKg);

  /// Pre-pregnancy BMI — used for IOM recommended gain ranges.
  double? get _prePregnancyBmi => _bmiFromWeight(_preWeightKg);

  String _categoryFor(double? bmi) {
    if (bmi == null) return 'Add height & weight';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal weight';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  String get _bmiCategory => _categoryFor(_bmi);

  /// Recommended total gain range (kg) per IOM guidelines by pre-preg BMI.
  String get _recommendation {
    final bmi = _prePregnancyBmi;
    if (bmi == null) {
      return 'Add your height and pre-pregnancy weight in your profile to see a personalized recommendation.';
    }
    String range;
    if (bmi < 18.5) {
      range = '12.5–18 kg';
    } else if (bmi < 25.0) {
      range = '11.5–16 kg';
    } else if (bmi < 30.0) {
      range = '7–11.5 kg';
    } else {
      range = '5–9 kg';
    }
    final wk = _currentWeek != null ? ' (currently week $_currentWeek)' : '';
    final preCat = _categoryFor(bmi);
    return 'Based on your pre-pregnancy BMI ($preCat, ${bmi.toStringAsFixed(1)}), a total gain of $range across pregnancy is recommended$wk.';
  }

  Future<void> _addWeight() async {
    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _WeightEntrySheet(
        initial: _currentWeightKg,
        week: _currentWeek,
      ),
    );
    if (result == null) return;

    final now = DateTime.now();
    final entry = WeightEntry(
      id: now.microsecondsSinceEpoch.toString(),
      date: DateTime(now.year, now.month, now.day),
      weightKg: result,
      week: _currentWeek,
    );
    final updated = await WeightService.addEntry(entry);
    if (!mounted) return;
    setState(() => _entries = updated);
  }

  Future<void> _deleteEntry(WeightEntry e) async {
    final updated = await WeightService.removeEntry(e.id);
    if (!mounted) return;
    setState(() => _entries = updated);
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: _dark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text('BMI & Weight',
            style: sans(fontSize: 17, fontWeight: FontWeight.w700, color: _dark)),
      ),
      floatingActionButton: _loading
          ? null
          : FloatingActionButton.extended(
              onPressed: _addWeight,
              backgroundColor: _barHi,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text('Add weight',
                  style: sans(fontWeight: FontWeight.w700, color: Colors.white)),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BmiCard(
                    bmi: _bmi,
                    category: _bmiCategory,
                    prePregnancyBmi: _prePregnancyBmi,
                    sans: sans,
                  ),
                  const SizedBox(height: 24),
                  _StatsGrid(
                    sans: sans,
                    heightCm: _heightCm,
                    preWeightKg: _preWeightKg,
                    currentWeightKg: _currentWeightKg,
                    gainedKg: _gainedKg,
                  ),
                  const SizedBox(height: 20),
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
                        Text('Recommended weight gain',
                            style: sans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2E6B2E))),
                        const SizedBox(height: 4),
                        Text(_recommendation,
                            style: sans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF3D7A3D))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Text('Weight this pregnancy (kg)',
                          style: sans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _dark)),
                      const Spacer(),
                      if (_entries.isNotEmpty)
                        Text('${_entries.length} logs',
                            style: sans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B6570))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_entries.isEmpty)
                    _EmptyChart(sans: sans, onAdd: _addWeight)
                  else
                    _WeightChart(
                        history: _entries, barLo: _barLo, barHi: _barHi, sans: sans),
                  if (_entries.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('History',
                        style: sans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _dark)),
                    const SizedBox(height: 8),
                    ..._entries.reversed.map(
                      (e) => _HistoryTile(
                        entry: e,
                        sans: sans,
                        onDelete: () => _deleteEntry(e),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  static double? _parseHeightCm(String? raw) {
    if (raw == null) return null;
    final lower = raw.toLowerCase();
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(lower);
    if (match == null) return null;
    final v = double.tryParse(match.group(1)!);
    if (v == null || v <= 0) return null;
    if (lower.contains('ft') || lower.contains('feet') || lower.contains("'")) {
      return v * 30.48; // feet → cm
    }
    if (v < 3) return v * 100; // metres → cm
    return v; // already cm
  }
}

// ── BMI Card ──────────────────────────────────────────────────────────────────

class _BmiCard extends StatelessWidget {
  const _BmiCard({
    required this.bmi,
    required this.category,
    required this.sans,
    this.prePregnancyBmi,
  });

  final double? bmi;
  final String category;
  final double? prePregnancyBmi;
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;

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
          Text('CURRENT BMI',
              style: sans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF7A5200))),
          const SizedBox(height: 8),
          Text(bmi == null ? '—' : bmi!.toStringAsFixed(1),
              style: sans(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4A3000))),
          Text(category,
              style: sans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7A5200))),
          if (prePregnancyBmi != null) ...[
            const SizedBox(height: 6),
            Text(
              'Pre-pregnancy BMI: ${prePregnancyBmi!.toStringAsFixed(1)}',
              style: sans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF7A5200),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _BmiSlider(bmi: bmi ?? 21.5),
        ],
      ),
    );
  }
}

class _BmiSlider extends StatelessWidget {
  const _BmiSlider({required this.bmi});

  final double bmi;

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
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF5EC4EF),
                          Color(0xFF7DDA85),
                          Color(0xFFFFB347),
                          Color(0xFFEF5350),
                        ],
                        stops: [0.0, 0.26, 0.60, 1.0],
                      ),
                    ),
                  ),
                ),
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
          children: const [
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
  const _StatsGrid({
    required this.sans,
    required this.heightCm,
    required this.preWeightKg,
    required this.currentWeightKg,
    required this.gainedKg,
  });

  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;
  final double? heightCm;
  final double? preWeightKg;
  final double? currentWeightKg;
  final double? gainedKg;

  String _fmt(double? v, {String suffix = ''}) =>
      v == null ? '—' : '${v.toStringAsFixed(1)}$suffix';

  @override
  Widget build(BuildContext context) {
    final gained = gainedKg;
    final gainedStr = gained == null
        ? '—'
        : '${gained >= 0 ? '+' : ''}${gained.toStringAsFixed(1)} kg';
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _StatCell(
                    label: 'Height (cm)', value: _fmt(heightCm), sans: sans)),
            const SizedBox(width: 16),
            Expanded(
                child: _StatCell(
                    label: 'Pre-preg. weight (kg)',
                    value: _fmt(preWeightKg),
                    sans: sans)),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: Color(0xFFE8E4EC), height: 1),
        ),
        Row(
          children: [
            Expanded(
                child: _StatCell(
                    label: 'Current weight (kg)',
                    value: _fmt(currentWeightKg),
                    sans: sans)),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCell(
                label: 'Weight gained',
                value: gainedStr,
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
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: sans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B6570))),
        const SizedBox(height: 4),
        Text(value,
            style: sans(
                fontSize: 22, fontWeight: FontWeight.w700, color: valueColor)),
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

  final List<WeightEntry> history;
  final Color barLo;
  final Color barHi;
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;

  @override
  Widget build(BuildContext context) {
    final maxW = history.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b);
    final minW =
        history.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b) - 2;
    const chartHeight = 100.0;
    final last = history.length - 1;
    final range = (maxW - minW).abs() < 0.1 ? 1.0 : (maxW - minW);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < history.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            SizedBox(
              width: 46,
              child: Column(
                children: [
                  Text(
                    history[i].weightKg.toStringAsFixed(1),
                    style: sans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: i == last ? barHi : const Color(0xFF6B6570),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: chartHeight *
                        ((history[i].weightKg - minW) / range).clamp(0.15, 1.0),
                    decoration: BoxDecoration(
                      color: i == last ? barHi : barLo,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    history[i].week != null
                        ? 'Wk ${history[i].week}'
                        : _shortDate(history[i].date),
                    style: sans(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: i == last ? barHi : const Color(0xFF6B6570),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _shortDate(DateTime d) =>
      '${d.day}/${d.month}';
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.sans, required this.onAdd});

  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE6EA)),
      ),
      child: Column(
        children: [
          const Icon(Icons.monitor_weight_outlined,
              size: 40, color: Color(0xFFCBB98E)),
          const SizedBox(height: 12),
          Text(
            'No weight logged yet.\nTap “Add weight” to record your first entry.',
            textAlign: TextAlign.center,
            style: sans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B6570)),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.entry,
    required this.sans,
    required this.onDelete,
  });

  final WeightEntry entry;
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final d = entry.date;
    final dateStr = '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
    final sub = entry.week != null ? 'Week ${entry.week} · $dateStr' : dateStr;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDE6EA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.monitor_weight_outlined,
              size: 20, color: Color(0xFFB87A20)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${entry.weightKg.toStringAsFixed(1)} kg',
                  style: sans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E))),
              Text(sub,
                  style: sans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B6570))),
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

// ── Add-weight bottom sheet ─────────────────────────────────────────────────

class _WeightEntrySheet extends StatefulWidget {
  const _WeightEntrySheet({this.initial, this.week});

  final double? initial;
  final int? week;

  @override
  State<_WeightEntrySheet> createState() => _WeightEntrySheetState();
}

class _WeightEntrySheetState extends State<_WeightEntrySheet> {
  late final TextEditingController _ctrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.initial != null ? widget.initial!.toStringAsFixed(1) : '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final v = double.tryParse(_ctrl.text.trim().replaceAll(',', '.'));
    if (v == null || v < 20 || v > 250) {
      setState(() => _error = 'Enter a weight between 20 and 250 kg');
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    const gold = Color(0xFFB87A20);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Log today\'s weight',
              style: sans(fontSize: 18, fontWeight: FontWeight.w800)),
          if (widget.week != null) ...[
            const SizedBox(height: 4),
            Text('Week ${widget.week}',
                style: sans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B6570))),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: InputDecoration(
              labelText: 'Weight',
              suffixText: 'kg',
              errorText: _error,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text('Save',
                  style: sans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
