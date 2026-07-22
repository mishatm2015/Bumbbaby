import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medicine.dart';
import 'firestore_user_data.dart';

/// Medicines + daily "taken" ticks stored in Firestore:
/// `users/{uid}/medicines/{id}`
/// `users/{uid}/medicineTaken/{YYYY-MM-DD}`
class MedicineService {
  static CollectionReference<Map<String, dynamic>>? get _meds =>
      FirestoreUserData.sub('medicines');

  static DocumentReference<Map<String, dynamic>>? _takenDoc([DateTime? date]) {
    final col = FirestoreUserData.sub('medicineTaken');
    if (col == null) return null;
    return col.doc(FirestoreUserData.dateKey(date));
  }

  static Future<List<Medicine>> getMedicines() async {
    final col = _meds;
    if (col == null) return _defaults();
    try {
      final snap = await col.get();
      if (snap.docs.isEmpty) {
        // First time: seed common pregnancy supplements.
        final defaults = _defaults();
        final batch = FirestoreUserData.db.batch();
        for (final m in defaults) {
          batch.set(col.doc(m.id), {
            ...m.toMap(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
        return defaults;
      }
      final list = snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return Medicine.fromMap(data);
      }).toList();
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
    } catch (_) {
      return _defaults();
    }
  }

  static Future<void> saveMedicines(List<Medicine> meds) async {
    final col = _meds;
    if (col == null) return;
    final existing = await col.get();
    final batch = FirestoreUserData.db.batch();
    final keep = meds.map((m) => m.id).toSet();
    for (final doc in existing.docs) {
      if (!keep.contains(doc.id)) batch.delete(doc.reference);
    }
    for (final m in meds) {
      batch.set(col.doc(m.id), {
        ...m.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  static Future<Set<String>> getTodayTaken() async {
    final doc = _takenDoc();
    if (doc == null) return {};
    try {
      final snap = await doc.get();
      final list = (snap.data()?['takenIds'] as List?)?.whereType<String>();
      return list?.toSet() ?? {};
    } catch (_) {
      return {};
    }
  }

  static Future<void> setTodayTaken(Set<String> ids) async {
    final doc = _takenDoc();
    if (doc == null) return;
    await doc.set({
      'takenIds': ids.toList(),
      'date': FirestoreUserData.dateKey(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static List<Medicine> _defaults() => const [
        Medicine(
            id: 'folic', name: 'Folic acid', dose: '400 mcg', time: 'Morning'),
        Medicine(
            id: 'iron', name: 'Iron', dose: '1 tablet', time: 'Afternoon'),
        Medicine(
            id: 'calcium', name: 'Calcium', dose: '500 mg', time: 'Night'),
      ];
}
