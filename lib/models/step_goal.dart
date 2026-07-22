/// Daily walking-step target during pregnancy.
///
/// Most guidelines suggest healthy pregnant women aim for roughly 30 minutes
/// of moderate activity a day, which is about 6,000–10,000 steps for most
/// people. Energy and comfort typically dip in the first trimester, rise in
/// the second, and taper again in the third as the bump grows, so the goal is
/// nudged slightly by trimester. The result is clamped to a sensible range.
class StepGoal {
  const StepGoal(this.steps);

  final int steps;

  /// Approximate stride length in metres, used for the distance estimate.
  static const double _strideMetres = 0.72;

  /// Rough calories burned per step while walking.
  static const double _kcalPerStep = 0.04;

  static StepGoal compute({int trimester = 1}) {
    int base;
    switch (trimester) {
      case 3:
        base = 7000; // taper as the third trimester gets heavier
        break;
      case 2:
        base = 9000; // usually the most energetic stretch
        break;
      default:
        base = 8000;
    }
    return StepGoal(base.clamp(4000, 10000));
  }

  /// Estimated distance in kilometres for a given step count.
  static double distanceKm(int steps) => steps * _strideMetres / 1000;

  /// Estimated calories burned for a given step count.
  static int calories(int steps) => (steps * _kcalPerStep).round();

  /// Fraction of the goal completed (0.0–1.0).
  double fraction(int steps) =>
      steps <= 0 ? 0 : (steps / this.steps).clamp(0.0, 1.0);
}
