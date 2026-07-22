import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/contraction_session.dart';
import 'firestore_user_data.dart';

/// Contraction sessions in Firestore: `users/{uid}/contractions/{id}`
class ContractionService {
  static CollectionReference<Map<String, dynamic>>? get _col =>
      FirestoreUserData.sub('contractions');

  static Future<List<ContractionSession>> getSessions() async {
    final col = _col;
    if (col == null) return [];
    try {
      final snap = await col.orderBy('startedAt', descending: true).get();
      return snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return ContractionSession.fromMap(data);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveSession(ContractionSession session) async {
    final col = _col;
    if (col == null) return;
    await col.doc(session.id).set({
      ...session.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> removeSession(String id) async {
    final col = _col;
    if (col == null) return;
    await col.doc(id).delete();
  }
}
