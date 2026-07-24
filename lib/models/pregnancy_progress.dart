/// Pregnancy timeline math derived from the last menstrual period (LMP).
///
/// A full-term pregnancy is measured as 280 days (40 weeks) from the LMP
/// using Naegele's rule.
///
/// Two related numbers are exposed:
/// - [weeks] + [dayOfWeek] → obstetric age, e.g. "24 weeks + 3 days"
/// - [contentWeek] → which week you are *in* (1–40), matching common apps:
///   `days ~/ 7 + 1` (days 0–6 = week 1, days 7–13 = week 2, …)
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
  int get weeks => daysElapsed ~/ 7;

  /// Extra days into the current week (0–6).
  int get dayOfWeek => daysElapsed % 7;

  /// Week number you are currently in (1–40).
  /// Days 0–6 → week 1, days 7–13 → week 2, … matches [UserProfile.currentWeek].
  int get contentWeek => ((daysElapsed ~/ 7) + 1).clamp(1, totalWeeks);

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

  /// Trimester from completed gestational weeks.
  /// 1st: < 13 weeks, 2nd: 13–26, 3rd: 27+.
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

  /// Clear obstetric age, e.g. "24 weeks + 3 days".
  String get weekDayLabel {
    final w = weeks;
    final d = dayOfWeek;
    final weekPart = w == 1 ? '1 week' : '$w weeks';
    final dayPart = d == 1 ? '1 day' : '$d days';
    return '$weekPart + $dayPart';
  }

  /// Short badge, e.g. "Week 25".
  String get weekBadge => 'Week $contentWeek';

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
