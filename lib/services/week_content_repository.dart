import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trimester_info.dart';
import '../models/week_content.dart';

/// Loads weekly size-chart content and trimester charts from Firestore,
/// falling back to the bundled local dataset.
class WeekContentRepository {
  WeekContentRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final Map<int, WeekContent> _weekCache = {};
  final Map<int, TrimesterInfo> _triCache = {};

  CollectionReference<Map<String, dynamic>> get _weeks =>
      _db.collection('weeklyContent');

  CollectionReference<Map<String, dynamic>> get _trimesters =>
      _db.collection('trimesterInfo');

  Future<WeekContent> getWeek(int week) async {
    final w = week.clamp(1, 40);
    if (_weekCache.containsKey(w)) return _weekCache[w]!;

    WeekContent content = WeekContent.forWeek(w);
    try {
      final snap = await _weeks.doc('$w').get();
      final data = snap.data();
      if (snap.exists && data != null) {
        content = WeekContent.fromMap(w, data);
      }
    } catch (_) {
      // Offline or rules blocking — use local content.
    }
    _weekCache[w] = content;
    return content;
  }

  Future<TrimesterInfo> getTrimester(int trimester) async {
    final t = trimester.clamp(1, 3);
    if (_triCache.containsKey(t)) return _triCache[t]!;

    TrimesterInfo info = TrimesterInfo.bundled(t);
    try {
      final snap = await _trimesters.doc('$t').get();
      final data = snap.data();
      if (snap.exists && data != null) {
        info = TrimesterInfo.fromMap(t, data);
      }
    } catch (_) {}
    _triCache[t] = info;
    return info;
  }
}
