/// A completed fetal-movement counting session ("Count to 10" method).
class KickSession {
  const KickSession({
    required this.id,
    required this.start,
    required this.count,
    required this.durationSec,
    required this.reachedGoal,
    required this.position,
    this.week,
    this.notes,
  });

  final String id;
  final DateTime start;

  /// Number of movements recorded.
  final int count;

  /// Seconds from session start to reaching the goal (or when stopped).
  final int durationSec;

  /// Whether the 10-movement goal was reached.
  final bool reachedGoal;

  /// Mother's position during the count (Left side recommended).
  final String position;

  /// Gestational week at time of session (nullable).
  final int? week;

  final String? notes;

  /// A session is "normal" when 10 movements are felt within 2 hours.
  bool get isNormal => reachedGoal && durationSec <= 2 * 60 * 60;

  Map<String, dynamic> toMap() => {
        'id': id,
        'start': start.toIso8601String(),
        'count': count,
        'durationSec': durationSec,
        'reachedGoal': reachedGoal,
        'position': position,
        'week': week,
        'notes': notes,
      };

  factory KickSession.fromMap(Map<String, dynamic> map) {
    return KickSession(
      id: map['id'] as String,
      start: DateTime.tryParse(map['start'] as String? ?? '') ?? DateTime.now(),
      count: (map['count'] as num?)?.toInt() ?? 0,
      durationSec: (map['durationSec'] as num?)?.toInt() ?? 0,
      reachedGoal: map['reachedGoal'] as bool? ?? false,
      position: map['position'] as String? ?? 'Left side',
      week: (map['week'] as num?)?.toInt(),
      notes: map['notes'] as String?,
    );
  }
}
