import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Shared Firestore helpers for per-user data under `users/{uid}/…`.
class FirestoreUserData {
  FirestoreUserData._();

  static FirebaseFirestore get db => FirebaseFirestore.instance;

  static String? get uid => FirebaseAuth.instance.currentUser?.uid;

  static DocumentReference<Map<String, dynamic>>? userRef() {
    final id = uid;
    if (id == null) return null;
    return db.collection('users').doc(id);
  }

  static CollectionReference<Map<String, dynamic>>? sub(String name) {
    final user = userRef();
    if (user == null) return null;
    return user.collection(name);
  }

  static String dateKey([DateTime? date]) {
    final d = date ?? DateTime.now();
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }
}
