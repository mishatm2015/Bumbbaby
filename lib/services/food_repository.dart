import '../data/food_catalog.dart';
import '../models/food_item.dart';
import 'firestore_user_data.dart';

/// Loads foods from Firestore with bundled catalog fallback + memory cache.
class FoodRepository {
  FoodRepository._();
  static final FoodRepository instance = FoodRepository._();

  List<FoodItem>? _cache;

  Future<List<FoodItem>> getAll({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _cache!;

    try {
      final snap = await FirestoreUserData.db.collection('foods').get();
      if (snap.docs.isNotEmpty) {
        _cache = snap.docs
            .map((d) => FoodItem.fromMap(d.id, d.data()))
            .toList(growable: false);
        return _cache!;
      }
    } catch (_) {
      // Fall through to bundled catalog.
    }

    _cache = FoodCatalog.all();
    return _cache!;
  }

  Future<FoodItem?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<FoodItem>> byCategory(String category) async {
    final all = await getAll();
    return all.where((f) => f.category == category).toList();
  }
}
