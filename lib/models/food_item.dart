/// Shared nutrition catalog item stored at `foods/{id}` in Firestore.
class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.cuisine,
    required this.dietTags,
    required this.trimester,
    this.symptomTags = const [],
    this.weekMin,
    this.weekMax,
    this.nutrients = '',
    this.benefits = '',
    this.servingSize = '',
    this.avoidIf,
    this.cookingTips,
    this.emoji = '🍽️',
    this.imageUrl,
  });

  final String id;
  final String name;

  /// breakfast | lunch | dinner | morning_snack | evening_snack |
  /// bedtime_snack | juice | fruit | vegetable | early_morning
  final String category;
  final String cuisine;
  final List<String> dietTags;
  final List<int> trimester;
  final List<String> symptomTags;
  final int? weekMin;
  final int? weekMax;
  final String nutrients;
  final String benefits;
  final String servingSize;
  final String? avoidIf;
  final String? cookingTips;
  final String emoji;
  final String? imageUrl;

  bool suitsTrimester(int t) => trimester.contains(t);

  bool suitsWeek(int week) {
    if (weekMin == null && weekMax == null) return true;
    final min = weekMin ?? 1;
    final max = weekMax ?? 40;
    return week >= min && week <= max;
  }

  bool matchesDiet(String dietType) {
    switch (dietType) {
      case 'vegan':
        return dietTags.contains('vegan');
      case 'vegetarian':
        return dietTags.contains('vegetarian') || dietTags.contains('vegan');
      case 'eggetarian':
        return dietTags.contains('vegetarian') ||
            dietTags.contains('vegan') ||
            dietTags.contains('eggetarian');
      case 'non_vegetarian':
        return true;
      default:
        return true;
    }
  }

  bool matchesCuisine(List<String> prefs) {
    if (prefs.isEmpty) return true;
    return prefs.contains(cuisine) || cuisine == 'indian';
  }

  bool matchesMedical(List<String> medical) {
    if (medical.isEmpty) return true;
    for (final tag in medical) {
      if (!dietTags.contains(tag)) return false;
    }
    return true;
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'cuisine': cuisine,
        'dietTags': dietTags,
        'trimester': trimester,
        'symptomTags': symptomTags,
        'weekRelevance': weekMin == null && weekMax == null
            ? null
            : [weekMin ?? 1, weekMax ?? 40],
        'nutrients': nutrients,
        'benefits': benefits,
        'servingSize': servingSize,
        'avoidIf': avoidIf,
        'cookingTips': cookingTips,
        'emoji': emoji,
        'imageUrl': imageUrl,
      };

  factory FoodItem.fromMap(String id, Map<String, dynamic> data) {
    final weekRel = data['weekRelevance'];
    int? wMin;
    int? wMax;
    if (weekRel is List && weekRel.length >= 2) {
      wMin = (weekRel[0] as num?)?.toInt();
      wMax = (weekRel[1] as num?)?.toInt();
    }
    return FoodItem(
      id: id,
      name: data['name'] as String? ?? id,
      category: data['category'] as String? ?? 'lunch',
      cuisine: data['cuisine'] as String? ?? 'indian',
      dietTags: _strList(data['dietTags']),
      trimester: _intList(data['trimester'], fallback: const [1, 2, 3]),
      symptomTags: _strList(data['symptomTags']),
      weekMin: wMin,
      weekMax: wMax,
      nutrients: data['nutrients'] as String? ?? '',
      benefits: data['benefits'] as String? ?? '',
      servingSize: data['servingSize'] as String? ?? '',
      avoidIf: data['avoidIf'] as String?,
      cookingTips: data['cookingTips'] as String?,
      emoji: data['emoji'] as String? ?? '🍽️',
      imageUrl: data['imageUrl'] as String?,
    );
  }

  static List<String> _strList(dynamic v) {
    if (v is! List) return const [];
    return v.map((e) => e.toString()).toList();
  }

  static List<int> _intList(dynamic v, {required List<int> fallback}) {
    if (v is! List || v.isEmpty) return fallback;
    return v.map((e) => (e as num).toInt()).toList();
  }
}

/// One day's generated meals (deterministic from date + prefs).
class DailyMealPlan {
  const DailyMealPlan({
    required this.dateKey,
    required this.week,
    required this.trimester,
    required this.slots,
  });

  final String dateKey;
  final int week;
  final int trimester;
  final Map<String, FoodItem> slots;

  FoodItem? get earlyMorning => slots['early_morning'];
  FoodItem? get breakfast => slots['breakfast'];
  FoodItem? get morningSnack => slots['morning_snack'];
  FoodItem? get lunch => slots['lunch'];
  FoodItem? get eveningSnack => slots['evening_snack'];
  FoodItem? get juice => slots['juice'];
  FoodItem? get dinner => slots['dinner'];
  FoodItem? get bedtime => slots['bedtime_snack'];
}

/// User nutrition preferences (stored on `users/{uid}.nutritionPrefs`).
class NutritionPrefs {
  const NutritionPrefs({
    this.dietType = 'vegetarian',
    this.cuisines = const ['indian', 'south_indian', 'kerala', 'north_indian'],
    this.medicalTags = const [],
    this.activeSymptoms = const [],
  });

  final String dietType;
  final List<String> cuisines;
  final List<String> medicalTags;
  final List<String> activeSymptoms;

  Map<String, dynamic> toMap() => {
        'dietType': dietType,
        'cuisines': cuisines,
        'medicalTags': medicalTags,
        'activeSymptoms': activeSymptoms,
      };

  factory NutritionPrefs.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const NutritionPrefs();
    return NutritionPrefs(
      dietType: data['dietType'] as String? ?? 'vegetarian',
      cuisines: FoodItem._strList(data['cuisines']).isEmpty
          ? const ['indian', 'south_indian', 'kerala', 'north_indian']
          : FoodItem._strList(data['cuisines']),
      medicalTags: FoodItem._strList(data['medicalTags']),
      activeSymptoms: FoodItem._strList(data['activeSymptoms']),
    );
  }

  NutritionPrefs copyWith({
    String? dietType,
    List<String>? cuisines,
    List<String>? medicalTags,
    List<String>? activeSymptoms,
  }) {
    return NutritionPrefs(
      dietType: dietType ?? this.dietType,
      cuisines: cuisines ?? this.cuisines,
      medicalTags: medicalTags ?? this.medicalTags,
      activeSymptoms: activeSymptoms ?? this.activeSymptoms,
    );
  }
}
