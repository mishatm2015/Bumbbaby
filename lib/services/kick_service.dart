import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/kick_session.dart';
import 'firestore_user_data.dart';

/// Kick sessions in Firestore: `users/{uid}/kickSessions/{id}`
class KickService {
  static CollectionReference<Map<String, dynamic>>? get _col =>
      FirestoreUserData.sub('kickSessions');

  static Future<List<KickSession>> getSessions() async {
    final col = _col;
    if (col == null) return [];
    try {
      final snap = await col.orderBy('start', descending: true).get();
      return snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return KickSession.fromMap(data);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<KickSession>> addSession(KickSession session) async {
    final col = _col;
    if (col == null) return [session];
    await col.doc(session.id).set({
      ...session.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return getSessions();
  }

  static Future<List<KickSession>> removeSession(String id) async {
    final col = _col;
    if (col == null) return [];
    await col.doc(id).delete();
    return getSessions();
  }
}
