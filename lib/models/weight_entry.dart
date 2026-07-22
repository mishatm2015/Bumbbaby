/// A single weight log recorded by the user during pregnancy.
class WeightEntry {
  const WeightEntry({
    required this.id,
    required this.date,
    required this.weightKg,
    this.week,
  });

  final String id;
  final DateTime date;
  final double weightKg;

  /// Gestational week at the time of logging (nullable if LMP unknown).
  final int? week;

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'weightKg': weightKg,
        'week': week,
      };

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      id: map['id'] as String,
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0,
      week: (map['week'] as num?)?.toInt(),
    );
  }
}
