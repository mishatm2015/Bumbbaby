import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/trimester_info.dart';
import '../models/week_content.dart';
import 'firestore_user_data.dart';

/// One-time upload of the size chart (weeks 1–40) and trimester chart
/// into Firestore so the app and Console share the same content.
///
/// Collections:
/// - `weeklyContent/{1..40}`  — baby size / fruit / development
/// - `trimesterInfo/{1|2|3}`  — trimester overview charts
class ContentSeedService {
  static const _flagKey = 'firestore_content_seeded_v1';

  /// Seeds missing documents. Safe to call on every login.
  static Future<void> seedIfNeeded() async {
    if (FirestoreUserData.uid == null) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_flagKey) == true) {
      final tri = await FirestoreUserData.db
          .collection('trimesterInfo')
          .doc('1')
          .get();
      if (tri.exists) return;
    }

    try {
      await _seedWeeklyContent();
      await _seedTrimesterInfo();
      await prefs.setBool(_flagKey, true);
    } catch (e) {
      assert(() {
        // ignore: avoid_print
        print('ContentSeedService: $e');
        return true;
      }());
    }
  }

  static Future<void> _seedWeeklyContent() async {
    final col = FirestoreUserData.db.collection('weeklyContent');
    final existing = await col.limit(1).get();
    if (existing.docs.isNotEmpty) {
      // Collection already has data — fill any missing week docs.
      WriteBatch? batch;
      var ops = 0;
      for (var w = 1; w <= 40; w++) {
        final ref = col.doc('$w');
        final snap = await ref.get();
        if (snap.exists) continue;
        batch ??= FirestoreUserData.db.batch();
        batch.set(ref, {
          ...WeekContent.forWeek(w).toMap(),
          'seededAt': FieldValue.serverTimestamp(),
        });
        ops++;
      }
      if (ops > 0) await batch!.commit();
      return;
    }

    final batch = FirestoreUserData.db.batch();
    for (var w = 1; w <= 40; w++) {
      batch.set(col.doc('$w'), {
        ...WeekContent.forWeek(w).toMap(),
        'seededAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  static Future<void> _seedTrimesterInfo() async {
    final col = FirestoreUserData.db.collection('trimesterInfo');
    WriteBatch? batch;
    var ops = 0;
    for (var t = 1; t <= 3; t++) {
      final ref = col.doc('$t');
      final snap = await ref.get();
      if (snap.exists) continue;
      batch ??= FirestoreUserData.db.batch();
      batch.set(ref, {
        ...TrimesterInfo.bundled(t).toMap(),
        'seededAt': FieldValue.serverTimestamp(),
      });
      ops++;
    }
    if (ops > 0) await batch!.commit();
  }
}
