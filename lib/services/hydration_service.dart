import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_user_data.dart';

/// Daily water cups in Firestore: `users/{uid}/hydration/{YYYY-MM-DD}`
class HydrationService {
  static DocumentReference<Map<String, dynamic>>? _doc([DateTime? date]) {
    final col = FirestoreUserData.sub('hydration');
    if (col == null) return null;
    return col.doc(FirestoreUserData.dateKey(date));
  }

  static Future<int> getTodayCups() async {
    final doc = _doc();
    if (doc == null) return 0;
    try {
      final snap = await doc.get();
      return (snap.data()?['cups'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> setTodayCups(int cups) async {
    final doc = _doc();
    if (doc == null) return;
    await doc.set({
      'cups': cups < 0 ? 0 : cups,
      'date': FirestoreUserData.dateKey(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
