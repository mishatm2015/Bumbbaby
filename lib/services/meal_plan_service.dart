import '../models/food_item.dart';
import 'firestore_user_data.dart';
import 'food_repository.dart';
import 'user_repository.dart';

/// Builds deterministic daily / weekly meal plans from the food catalog.
class MealPlanService {
  MealPlanService({
    FoodRepository? foods,
    UserRepository? users,
  })  : _foods = foods ?? FoodRepository.instance,
        _users = users ?? UserRepository();

  final FoodRepository _foods;
  final UserRepository _users;

  static const slotOrder = <String>[
    'early_morning',
    'breakfast',
    'morning_snack',
    'lunch',
    'evening_snack',
    'juice',
    'dinner',
    'bedtime_snack',
  ];

  static const slotLabels = <String, String>{
    'early_morning': 'Early morning',
    'breakfast': 'Breakfast',
    'morning_snack': 'Mid-morning snack',
    'lunch': 'Lunch',
    'evening_snack': 'Evening snack',
    'juice': 'Juice',
    'dinner': 'Dinner',
    'bedtime_snack': 'Bedtime',
  };

  Future<NutritionPrefs> loadPrefs() async {
    if (FirestoreUserData.uid == null) return const NutritionPrefs();
    try {
      final snap = await FirestoreUserData.userRef()?.get();
      final data = snap?.data();
      final raw = data?['nutritionPrefs'];
      if (raw is Map<String, dynamic>) return NutritionPrefs.fromMap(raw);
      if (raw is Map) {
        return NutritionPrefs.fromMap(Map<String, dynamic>.from(raw));
      }
    } catch (_) {}
    return const NutritionPrefs();
  }

  Future<void> savePrefs(NutritionPrefs prefs) async {
    final uid = FirestoreUserData.uid;
    if (uid == null) return;
    await _users.updateProfile(uid, {'nutritionPrefs': prefs.toMap()});
  }

  Future<DailyMealPlan> planForDate({
    required DateTime date,
    required int week,
    required int trimester,
    NutritionPrefs? prefs,
  }) async {
    final p = prefs ?? await loadPrefs();
    final all = await _foods.getAll();
    final dateKey = FirestoreUserData.dateKey(date);
    final slots = <String, FoodItem>{};
    final usedIds = <String>{};

    for (final slot in slotOrder) {
      final pool = _filter(
        all,
        category: slot,
        week: week,
        trimester: trimester,
        prefs: p,
      );
      final pick = _pick(pool, '$dateKey|$slot|$week|${p.dietType}', usedIds) ??
          _pick(all.where((f) => f.category == slot).toList(), '$dateKey|$slot',
              usedIds);
      if (pick != null) {
        slots[slot] = pick;
        usedIds.add(pick.id);
      }
    }
    return DailyMealPlan(
      dateKey: dateKey,
      week: week,
      trimester: trimester,
      slots: slots,
    );
  }

  Future<List<DailyMealPlan>> weekPlans({
    required DateTime weekStart,
    required int baseWeek,
    required int trimester,
    NutritionPrefs? prefs,
  }) async {
    final p = prefs ?? await loadPrefs();
    final plans = <DailyMealPlan>[];
    for (var i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      plans.add(await planForDate(
        date: day,
        week: baseWeek,
        trimester: trimester,
        prefs: p,
      ));
    }
    return plans;
  }

  Future<List<FoodItem>> foodsForBabyWeek(int week) async {
    final all = await _foods.getAll();
    final matched = all
        .where((f) => f.suitsWeek(week) && (f.weekMin != null || f.weekMax != null))
        .toList();
    if (matched.isNotEmpty) return matched.take(12).toList();
    // Fallback tips by stage.
    return _stageFallback(all, week);
  }

  Future<List<FoodItem>> foodsForSymptom(String symptom) async {
    final all = await _foods.getAll();
    return all.where((f) => f.symptomTags.contains(symptom)).toList();
  }

  List<FoodItem> _filter(
    List<FoodItem> all, {
    required String category,
    required int week,
    required int trimester,
    required NutritionPrefs prefs,
  }) {
    var pool = all.where((f) => f.category == category).toList();
    pool = pool.where((f) => f.suitsTrimester(trimester)).toList();
    pool = pool.where((f) => f.matchesDiet(prefs.dietType)).toList();
    if (prefs.medicalTags.isNotEmpty) {
      final medical = pool.where((f) => f.matchesMedical(prefs.medicalTags)).toList();
      if (medical.isNotEmpty) pool = medical;
    }
    // Soft cuisine preference — if too few, ignore.
    final cuisineFiltered =
        pool.where((f) => f.matchesCuisine(prefs.cuisines)).toList();
    if (cuisineFiltered.length >= 3) pool = cuisineFiltered;

    // Prefer week-relevant items when available, but keep variety.
    final weekHit = pool.where((f) => f.suitsWeek(week)).toList();
    if (weekHit.length >= 2) pool = weekHit;

    // Soft boost for active symptoms: put matching items first via separate pool.
    if (prefs.activeSymptoms.isNotEmpty) {
      final symptomHit = pool
          .where((f) =>
              f.symptomTags.any((s) => prefs.activeSymptoms.contains(s)))
          .toList();
      if (symptomHit.isNotEmpty) {
        // Interleave: symptom foods get higher chance via seed offset handled in pick.
        pool = [...symptomHit, ...pool];
      }
    }
    return pool;
  }

  FoodItem? _pick(List<FoodItem> pool, String seed, Set<String> used) {
    if (pool.isEmpty) return null;
    final available = pool.where((f) => !used.contains(f.id)).toList();
    final list = available.isNotEmpty ? available : pool;
    final idx = seed.hashCode.abs() % list.length;
    return list[idx];
  }

  List<FoodItem> _stageFallback(List<FoodItem> all, int week) {
    final ids = <String>[];
    if (week <= 12) {
      ids.addAll(['bf_scram_eggs', 'ms_walnuts', 'ln_fish_curry_rice', 'ms_flax_yogurt', 'bf_chia_pudding']);
    } else if (week <= 26) {
      ids.addAll(['ms_cottage_cheese', 'bd_warm_milk', 'ms_yogurt_fruit', 'ms_sesame_ladoo', 'ln_paneer_roti']);
    } else {
      ids.addAll(['ln_chicken_curry', 'dn_grilled_fish_veg', 'ms_dates', 'ln_palak_paneer', 'ms_trail_mix']);
    }
    final map = {for (final f in all) f.id: f};
    return ids.map((id) => map[id]).whereType<FoodItem>().toList();
  }

  /// Human-readable focus line for the baby's week.
  static String babyFocus(int week) {
    if (week <= 4) return 'Early cell division — folate-rich foods matter most.';
    if (week <= 8) return 'Organs forming — focus on folate, protein, and hydration.';
    if (week <= 12) return 'Brain & neural tube — eggs, walnuts, leafy greens, legumes.';
    if (week <= 16) return 'Bones starting — calcium from dairy, ragi, sesame, greens.';
    if (week <= 20) return 'Rapid growth — iron + vitamin C pairing helps absorption.';
    if (week <= 24) return 'Bone & muscle growth — milk, paneer, yogurt, sesame seeds.';
    if (week <= 28) return 'Brain fat accumulation — omega-3 from fish/flax/walnuts.';
    if (week <= 32) return 'Weight gain phase — protein, healthy fats, iron-rich meals.';
    if (week <= 36) return 'Final growth — protein, fiber, and steady hydration.';
    return 'Ready for birth — lighter dinners, protein, and electrolyte fluids.';
  }

  static String trimesterFocus(int trimester) {
    switch (trimester) {
      case 1:
        return 'Focus: folic acid, small frequent meals, managing nausea.';
      case 2:
        return 'Focus: calcium, iron, omega-3, about +340 kcal/day.';
      default:
        return 'Focus: protein, iron, fiber, hydration, about +450 kcal/day. Keep dinners light.';
    }
  }
}
