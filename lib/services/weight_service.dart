import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/weight_entry.dart';
import 'firestore_user_data.dart';

/// Weight logs in Firestore: `users/{uid}/weightEntries/{id}`
class WeightService {
  static CollectionReference<Map<String, dynamic>>? get _col =>
      FirestoreUserData.sub('weightEntries');

  static Future<List<WeightEntry>> getEntries() async {
    final col = _col;
    if (col == null) return [];
    try {
      final snap = await col.orderBy('date').get();
      return snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return WeightEntry.fromMap(data);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<WeightEntry>> addEntry(WeightEntry entry) async {
    final col = _col;
    if (col == null) return [entry];
    await col.doc(entry.id).set({
      ...entry.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return getEntries();
  }

  static Future<List<WeightEntry>> removeEntry(String id) async {
    final col = _col;
    if (col == null) return [];
    await col.doc(id).delete();
    return getEntries();
  }
}
