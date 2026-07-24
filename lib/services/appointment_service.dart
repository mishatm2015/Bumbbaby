import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/appointment.dart';
import 'firestore_user_data.dart';

/// Appointments in Firestore: `users/{uid}/appointments/{id}`
/// Only the signed-in user's own appointments are stored and returned.
class AppointmentService {
  static CollectionReference<Map<String, dynamic>>? get _col =>
      FirestoreUserData.sub('appointments');

  static Future<List<Appointment>> getAppointments() async {
    final col = _col;
    if (col == null) return [];
    try {
      final snap = await col.orderBy('dateTime').get();
      return snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return Appointment.fromMap(data);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Upcoming only (from start of today onward), soonest first.
  static Future<List<Appointment>> getUpcoming({int limit = 20}) async {
    final all = await getAppointments();
    final startOfToday = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return all
        .where((a) => !a.dateTime.isBefore(startOfToday))
        .take(limit)
        .toList();
  }

  static Future<Appointment> addAppointment(Appointment appointment) async {
    final col = _col;
    if (col == null) return appointment;
    await col.doc(appointment.id).set({
      ...appointment.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return appointment;
  }

  static Future<void> removeAppointment(String id) async {
    final col = _col;
    if (col == null) return;
    await col.doc(id).delete();
  }
}
