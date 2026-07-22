/// One timed contraction within a session.
class ContractionEntry {
  const ContractionEntry({
    required this.startTime,
    required this.durationSec,
    this.frequencySec,
  });

  final DateTime startTime;
  final int durationSec;
  final int? frequencySec;

  Map<String, dynamic> toMap() => {
        'startTime': startTime.toIso8601String(),
        'durationSec': durationSec,
        'frequencySec': frequencySec,
      };

  factory ContractionEntry.fromMap(Map<String, dynamic> map) {
    return ContractionEntry(
      startTime:
          DateTime.tryParse(map['startTime'] as String? ?? '') ?? DateTime.now(),
      durationSec: (map['durationSec'] as num?)?.toInt() ?? 0,
      frequencySec: (map['frequencySec'] as num?)?.toInt(),
    );
  }
}

/// A saved contraction timing session.
class ContractionSession {
  const ContractionSession({
    required this.id,
    required this.startedAt,
    required this.entries,
    this.week,
    this.met511 = false,
  });

  final String id;
  final DateTime startedAt;
  final List<ContractionEntry> entries;
  final int? week;
  final bool met511;

  Map<String, dynamic> toMap() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'entries': entries.map((e) => e.toMap()).toList(),
        'week': week,
        'met511': met511,
        'count': entries.length,
      };

  factory ContractionSession.fromMap(Map<String, dynamic> map) {
    final raw = map['entries'];
    final list = <ContractionEntry>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          list.add(ContractionEntry.fromMap(Map<String, dynamic>.from(e)));
        }
      }
    }
    return ContractionSession(
      id: map['id'] as String? ?? '',
      startedAt:
          DateTime.tryParse(map['startedAt'] as String? ?? '') ?? DateTime.now(),
      entries: list,
      week: (map['week'] as num?)?.toInt(),
      met511: map['met511'] as bool? ?? false,
    );
  }
}
