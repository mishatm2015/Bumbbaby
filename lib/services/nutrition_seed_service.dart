import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/food_catalog.dart';
import 'firestore_user_data.dart';

/// Seeds the global `foods/{id}` nutrition catalog into Firestore.
class NutritionSeedService {
  static const _flagKey = 'firestore_foods_seeded_v1';
  static const _batchSize = 400;

  /// Safe to call on every login. Fills missing food docs only.
  static Future<void> seedIfNeeded() async {
    if (FirestoreUserData.uid == null) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_flagKey) == true) {
      final sample = await FirestoreUserData.db.collection('foods').limit(1).get();
      if (sample.docs.isNotEmpty) return;
    }

    try {
      await _seedFoods();
      await prefs.setBool(_flagKey, true);
    } catch (e) {
      assert(() {
        // ignore: avoid_print
        print('NutritionSeedService: $e');
        return true;
      }());
    }
  }

  static Future<void> _seedFoods() async {
    final col = FirestoreUserData.db.collection('foods');
    final all = FoodCatalog.all();

    // If collection already has most items, only fill gaps.
    final existing = await col.limit(1).get();
    final hasAny = existing.docs.isNotEmpty;

    WriteBatch batch = FirestoreUserData.db.batch();
    var ops = 0;

    Future<void> flush() async {
      if (ops == 0) return;
      await batch.commit();
      batch = FirestoreUserData.db.batch();
      ops = 0;
    }

    for (final food in all) {
      final ref = col.doc(food.id);
      if (hasAny) {
        final snap = await ref.get();
        if (snap.exists) continue;
      }
      batch.set(ref, {
        ...food.toMap(),
        'seededAt': FieldValue.serverTimestamp(),
      });
      ops++;
      if (ops >= _batchSize) await flush();
    }
    await flush();
  }
}
