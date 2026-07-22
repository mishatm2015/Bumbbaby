/// Pregnancy timeline math derived from the last menstrual period (LMP).
///
/// A full-term pregnancy is measured as 280 days (40 weeks) from the LMP
/// using Naegele's rule. Gestational age is expressed as completed
/// weeks + days (e.g. "24 weeks 3 days").
class PregnancyProgress {
  const PregnancyProgress({
    required this.lmp,
    required this.reference,
  });

  final DateTime lmp;

  /// The "today" used for the calculation (defaults to now via [fromLmp]).
  final DateTime reference;

  static const int totalDays = 280;
  static const int totalWeeks = 40;

  /// Builds progress from an LMP string in `DD/MM/YYYY` (or `DD-MM-YYYY`).
  /// Returns null when the LMP cannot be parsed.
  static PregnancyProgress? fromLmp(String? lmpText, {DateTime? now}) {
    final lmp = _parse(lmpText);
    if (lmp == null) return null;
    final ref = now ?? DateTime.now();
    return PregnancyProgress(
      lmp: DateTime(lmp.year, lmp.month, lmp.day),
      reference: DateTime(ref.year, ref.month, ref.day),
    );
  }

  int get _rawDays => reference.difference(lmp).inDays;

  /// Days since LMP, clamped to a valid pregnancy range.
  int get daysElapsed => _rawDays.clamp(0, totalDays + 14);

  /// Completed weeks of gestation ("N weeks pregnant").
  int get weeks => (daysElapsed ~/ 7);

  /// Days into the current week (0–6).
  int get dayOfWeek => daysElapsed % 7;

  /// Week number used to look up weekly content (1–40).
  int get contentWeek {
    final w = weeks == 0 ? 1 : weeks;
    return w.clamp(1, totalWeeks);
  }

  /// Days remaining until the estimated due date (0–280).
  int get daysLeft => (totalDays - daysElapsed).clamp(0, totalDays);

  /// Percent of the pregnancy completed (0–100).
  double get percent =>
      (daysElapsed / totalDays * 100).clamp(0, 100).toDouble();

  /// Fraction complete (0.0–1.0) for progress bars.
  double get fraction => (daysElapsed / totalDays).clamp(0.0, 1.0);

  /// Estimated due date (LMP + 280 days).
  DateTime get edd => lmp.add(const Duration(days: totalDays));

  bool get isFullTerm => weeks >= totalWeeks;

  int get trimester {
    if (weeks < 13) return 1;
    if (weeks < 27) return 2;
    return 3;
  }

  String get trimesterLabel {
    switch (trimester) {
      case 1:
        return 'First Trimester';
      case 2:
        return 'Second Trimester';
      default:
        return 'Third Trimester';
    }
  }

  String get trimesterShort {
    switch (trimester) {
      case 1:
        return '1st Trimester';
      case 2:
        return '2nd Trimester';
      default:
        return '3rd Trimester';
    }
  }

  /// "WEEK 24 · DAY 3" style label.
  String get weekDayLabel => 'WEEK $weeks · DAY $dayOfWeek';

  /// "168 days down, 112 to go".
  String get countdownLabel => '$daysElapsed days down, $daysLeft to go';

  static DateTime? _parse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.trim().split(RegExp(r'[/-]'));
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    try {
      final d = DateTime(year, month, day);
      if (d.day != day || d.month != month || d.year != year) return null;
      return d;
    } catch (_) {
      return null;
    }
  }
}
