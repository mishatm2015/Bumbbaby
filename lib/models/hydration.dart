/// Daily water intake target for pregnancy.
///
/// Base estimate uses ~32.5 ml per kg of body weight (the midpoint of the
/// common 30–35 ml/kg clinical range), with a small trimester adjustment
/// because blood volume and amniotic fluid needs rise later in pregnancy.
/// The result is clamped to a sensible 1.6–3.5 L range.
class HydrationGoal {
  const HydrationGoal(this.litres);

  final double litres;

  static const double cupLitres = 0.25; // 250 ml per glass

  int get cups => (litres / cupLitres).round();

  static HydrationGoal compute({double? weightKg, int trimester = 1}) {
    double base;
    if (weightKg != null && weightKg > 0) {
      base = weightKg * 32.5 / 1000; // litres
    } else {
      base = 2.1; // reasonable default before weight is known
    }

    double extra;
    switch (trimester) {
      case 3:
        extra = 0.5;
        break;
      case 2:
        extra = 0.3;
        break;
      default:
        extra = 0.0;
    }

    final total = (base + extra).clamp(1.6, 3.5).toDouble();
    return HydrationGoal(double.parse(total.toStringAsFixed(2)));
  }

  /// Parses a free-form weight string ("65", "65 kg", "150 lbs") to kg.
  static double? parseWeightKg(String? raw) {
    if (raw == null) return null;
    final lower = raw.toLowerCase();
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(lower);
    if (match == null) return null;
    final value = double.tryParse(match.group(1)!);
    if (value == null || value <= 0) return null;
    if (lower.contains('lb')) return value * 0.45359237;
    return value;
  }
}
