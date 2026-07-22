import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firestore_user_data.dart';

/// Pedometer baseline stays on-device (sensor is device-specific).
/// Daily totals sync to Firestore: `users/{uid}/steps/{YYYY-MM-DD}`
class StepService {
  static String _dateKey(DateTime date) => FirestoreUserData.dateKey(date);

  static String _baselineKey(DateTime date) =>
      'steps_baseline_${_dateKey(date)}';

  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static Future<bool> ensurePermission() async {
    if (!isSupported) return false;
    final status = await Permission.activityRecognition.request();
    return status.isGranted || status.isLimited;
  }

  static Future<int> getTodaySteps() async {
    final doc = FirestoreUserData.sub('steps')
        ?.doc(FirestoreUserData.dateKey());
    if (doc != null) {
      try {
        final snap = await doc.get();
        final cloud = (snap.data()?['steps'] as num?)?.toInt();
        if (cloud != null) return cloud;
      } catch (_) {}
    }
    // Fallback to last local cache if offline.
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('steps_today_${_dateKey(DateTime.now())}') ?? 0;
  }

  static Future<void> _persistTodaySteps(int steps) async {
    final safe = steps < 0 ? 0 : steps;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('steps_today_${_dateKey(DateTime.now())}', safe);

    final doc =
        FirestoreUserData.sub('steps')?.doc(FirestoreUserData.dateKey());
    if (doc == null) return;
    try {
      await doc.set({
        'steps': safe,
        'date': FirestoreUserData.dateKey(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Offline — local cache still holds the value.
    }
  }

  static Stream<int> todayStepStream() {
    return Pedometer.stepCountStream.asyncMap((event) async {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final baselineKey = _baselineKey(now);
      final cumulative = event.steps;

      int? baseline = prefs.getInt(baselineKey);
      if (baseline == null || cumulative < baseline) {
        baseline = cumulative;
        await prefs.setInt(baselineKey, baseline);
      }

      final today = (cumulative - baseline).clamp(0, 1 << 31);
      await _persistTodaySteps(today);
      return today;
    });
  }
}
