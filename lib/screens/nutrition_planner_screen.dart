import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/food_item.dart';
import '../models/pregnancy_progress.dart';
import '../services/auth_service.dart';
import '../services/meal_plan_service.dart';
import '../services/user_repository.dart';
import 'food_detail_screen.dart';
import 'food_library_screen.dart';
import 'nutrition_prefs_screen.dart';

class NutritionPlannerScreen extends StatefulWidget {
  const NutritionPlannerScreen({super.key});

  @override
  State<NutritionPlannerScreen> createState() => _NutritionPlannerScreenState();
}

class _NutritionPlannerScreenState extends State<NutritionPlannerScreen>
    with SingleTickerProviderStateMixin {
  static const _ink = Color(0xFF2D2A32);
  static const _muted = Color(0xFF6B6570);
  static const _accent = Color(0xFFE04B84);
  static const _bg = Color(0xFFFDF8FA);

  final _mealService = MealPlanService();
  final _userRepo = UserRepository();

  late final TabController _tabs;
  bool _loading = true;
  NutritionPrefs _prefs = const NutritionPrefs();
  DailyMealPlan? _today;
  List<DailyMealPlan> _week = [];
  List<FoodItem> _weekFoods = [];
  List<FoodItem> _symptomFoods = [];
  int _weekNum = 1;
  int _trimester = 1;
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final uid = AuthService().currentUser?.uid;
    var week = 1;
    var trimester = 1;
    if (uid != null) {
      final profile = await _userRepo.getProfile(uid);
      final progress = PregnancyProgress.fromLmp(profile?.lmp);
      week = progress?.contentWeek ?? 1;
      trimester = progress?.trimester ?? 1;
    }
    final prefs = await _mealService.loadPrefs();
    final today = await _mealService.planForDate(
      date: _selectedDay,
      week: week,
      trimester: trimester,
      prefs: prefs,
    );
    final monday = _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
    final weekPlans = await _mealService.weekPlans(
      weekStart: monday,
      baseWeek: week,
      trimester: trimester,
      prefs: prefs,
    );
    final babyFoods = await _mealService.foodsForBabyWeek(week);
    List<FoodItem> symptomFoods = [];
    if (prefs.activeSymptoms.isNotEmpty) {
      for (final s in prefs.activeSymptoms) {
        symptomFoods.addAll(await _mealService.foodsForSymptom(s));
      }
      final seen = <String>{};
      symptomFoods = symptomFoods.where((f) => seen.add(f.id)).toList();
    }

    if (!mounted) return;
    setState(() {
      _prefs = prefs;
      _weekNum = week;
      _trimester = trimester;
      _today = today;
      _week = weekPlans;
      _weekFoods = babyFoods;
      _symptomFoods = symptomFoods;
      _loading = false;
    });
  }

  Future<void> _pickDay(DateTime day) async {
    setState(() {
      _selectedDay = day;
      _loading = true;
    });
    final plan = await _mealService.planForDate(
      date: day,
      week: _weekNum,
      trimester: _trimester,
      prefs: _prefs,
    );
    if (!mounted) return;
    setState(() {
      _today = plan;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    final serif = GoogleFonts.fraunces;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Nutrition Planner',
          style: serif(fontWeight: FontWeight.w800, fontSize: 18, color: _ink),
        ),
        actions: [
          IconButton(
            tooltip: 'Diet preferences',
            onPressed: () async {
              final updated = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const NutritionPrefsScreen()),
              );
              if (updated == true) _load();
            },
            icon: const Icon(Icons.tune_rounded, color: _accent),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: _accent,
          unselectedLabelColor: _muted,
          indicatorColor: _accent,
          labelStyle: sans(fontSize: 13, fontWeight: FontWeight.w800),
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Week'),
            Tab(text: 'Baby'),
            Tab(text: 'Browse'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : TabBarView(
              controller: _tabs,
              children: [
                _TodayTab(
                  plan: _today,
                  week: _weekNum,
                  trimester: _trimester,
                  selectedDay: _selectedDay,
                  prefs: _prefs,
                  symptomFoods: _symptomFoods,
                  sans: sans,
                  serif: serif,
                  onPickDay: _pickDay,
                  onOpenFood: _openFood,
                ),
                _WeekTab(
                  plans: _week,
                  selectedDay: _selectedDay,
                  sans: sans,
                  onSelect: _pickDay,
                  onOpenFood: _openFood,
                ),
                _BabyTab(
                  week: _weekNum,
                  foods: _weekFoods,
                  sans: sans,
                  serif: serif,
                  onOpenFood: _openFood,
                ),
                _BrowseTab(sans: sans),
              ],
            ),
    );
  }

  void _openFood(FoodItem food) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FoodDetailScreen(food: food)),
    );
  }
}

class _TodayTab extends StatelessWidget {
  const _TodayTab({
    required this.plan,
    required this.week,
    required this.trimester,
    required this.selectedDay,
    required this.prefs,
    required this.symptomFoods,
    required this.sans,
    required this.serif,
    required this.onPickDay,
    required this.onOpenFood,
  });

  final DailyMealPlan? plan;
  final int week;
  final int trimester;
  final DateTime selectedDay;
  final NutritionPrefs prefs;
  final List<FoodItem> symptomFoods;
  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
    double? height,
    double? letterSpacing,
  }) sans;
  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
    double? height,
  }) serif;
  final ValueChanged<DateTime> onPickDay;
  final ValueChanged<FoodItem> onOpenFood;

  @override
  Widget build(BuildContext context) {
    final triName = trimester == 1
        ? 'First'
        : trimester == 2
            ? 'Second'
            : 'Third';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE4EE), Color(0xFFF5C6DC)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$triName trimester · Week $week',
                style: sans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: const Color(0xFF6B6570),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'A different plan every day',
                style: serif(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D2A32),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                MealPlanService.trimesterFocus(trimester),
                style: sans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B6570),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              _dayLabel(selectedDay),
              style: sans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D2A32),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: selectedDay,
                  firstDate: DateTime.now().subtract(const Duration(days: 7)),
                  lastDate: DateTime.now().add(const Duration(days: 40)),
                );
                if (d != null) onPickDay(d);
              },
              icon: const Icon(Icons.calendar_today_rounded, size: 16),
              label: Text('Change day',
                  style: sans(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ],
        ),
        Text(
          'Diet: ${_dietLabel(prefs.dietType)}',
          style: sans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B6570),
          ),
        ),
        const SizedBox(height: 12),
        if (plan == null)
          Text('No plan available', style: sans(color: const Color(0xFF6B6570)))
        else
          ...MealPlanService.slotOrder.map((slot) {
            final food = plan!.slots[slot];
            if (food == null) return const SizedBox.shrink();
            return _MealSlotCard(
              label: MealPlanService.slotLabels[slot] ?? slot,
              food: food,
              sans: sans,
              onTap: () => onOpenFood(food),
            );
          }),
        if (symptomFoods.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'FOR YOUR SYMPTOMS',
            style: sans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: const Color(0xFFE04B84),
            ),
          ),
          const SizedBox(height: 8),
          ...symptomFoods.take(6).map(
                (f) => _MealSlotCard(
                  label: f.symptomTags.join(' · '),
                  food: f,
                  sans: sans,
                  onTap: () => onOpenFood(f),
                ),
              ),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFE0A3)),
          ),
          child: Text(
            'General guidance only. Personalize with your doctor or dietitian if you have gestational diabetes, hypertension, kidney disease, food allergies, or other conditions.',
            style: sans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B5A30),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  static String _dayLabel(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month]}';
  }

  static String _dietLabel(String d) {
    switch (d) {
      case 'non_vegetarian':
        return 'Non-vegetarian';
      case 'eggetarian':
        return 'Eggetarian';
      case 'vegan':
        return 'Vegan';
      default:
        return 'Vegetarian';
    }
  }
}

class _MealSlotCard extends StatelessWidget {
  const _MealSlotCard({
    required this.label,
    required this.food,
    required this.sans,
    required this.onTap,
  });

  final String label;
  final FoodItem food;
  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
    double? height,
    double? letterSpacing,
  }) sans;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF0E6EA)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4EE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(food.emoji, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: sans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: const Color(0xFFE04B84),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        food.name,
                        style: sans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D2A32),
                        ),
                      ),
                      if (food.servingSize.isNotEmpty)
                        Text(
                          food.servingSize,
                          style: sans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B6570),
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF9A939E)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekTab extends StatelessWidget {
  const _WeekTab({
    required this.plans,
    required this.selectedDay,
    required this.sans,
    required this.onSelect,
    required this.onOpenFood,
  });

  final List<DailyMealPlan> plans;
  final DateTime selectedDay;
  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
    double? height,
    double? letterSpacing,
  }) sans;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<FoodItem> onOpenFood;

  @override
  Widget build(BuildContext context) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: plans.length,
      itemBuilder: (context, i) {
        final plan = plans[i];
        final parts = plan.dateKey.split('-');
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        final selected = plan.dateKey ==
            '${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}';
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: selected ? const Color(0xFFFFE4EE) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                onSelect(date);
                // Also jump visual — parent reloads today tab data.
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFE04B84)
                        : const Color(0xFFF0E6EA),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dayNames[i]} · ${date.day}/${date.month}',
                      style: sans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2D2A32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      [
                        plan.breakfast?.name,
                        plan.lunch?.name,
                        plan.dinner?.name,
                      ].whereType<String>().join(' · '),
                      style: sans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B6570),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final slot in [
                          plan.breakfast,
                          plan.lunch,
                          plan.dinner
                        ])
                          if (slot != null)
                            ActionChip(
                              avatar: Text(slot.emoji,
                                  style: const TextStyle(fontSize: 14)),
                              label: Text(slot.name,
                                  style: sans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                              onPressed: () => onOpenFood(slot),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFFF0E6EA)),
                              visualDensity: VisualDensity.compact,
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BabyTab extends StatelessWidget {
  const _BabyTab({
    required this.week,
    required this.foods,
    required this.sans,
    required this.serif,
    required this.onOpenFood,
  });

  final int week;
  final List<FoodItem> foods;
  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
    double? height,
    double? letterSpacing,
  }) sans;
  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
    double? height,
  }) serif;
  final ValueChanged<FoodItem> onOpenFood;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF0FC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Week $week · baby growth foods',
                style: serif(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D2A32),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                MealPlanService.babyFocus(week),
                style: sans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B6570),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...foods.map(
          (f) => _MealSlotCard(
            label: f.category.replaceAll('_', ' '),
            food: f,
            sans: sans,
            onTap: () => onOpenFood(f),
          ),
        ),
      ],
    );
  }
}

class _BrowseTab extends StatelessWidget {
  const _BrowseTab({required this.sans});

  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
    double? height,
    double? letterSpacing,
  }) sans;

  static const _libs = [
    ('breakfast', 'Breakfast library', '🥣', Color(0xFFFFE4EE)),
    ('lunch', 'Lunch library', '🍛', Color(0xFFE8F5E9)),
    ('dinner', 'Dinner library', '🍲', Color(0xFFE3F2FD)),
    ('morning_snack', 'Snack library', '🍎', Color(0xFFFFF3E0)),
    ('evening_snack', 'Evening snacks', '🌱', Color(0xFFE0F2F1)),
    ('juice', 'Juice library', '🧃', Color(0xFFFCE4EC)),
    ('fruit', 'Fruit library', '🍇', Color(0xFFF3E5F5)),
    ('vegetable', 'Vegetable library', '🥬', Color(0xFFE8F5E9)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      children: [
        for (final lib in _libs)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FoodLibraryScreen(
                        category: lib.$1,
                        title: lib.$2,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF0E6EA)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: lib.$4,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child:
                            Text(lib.$3, style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          lib.$2,
                          style: sans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2A32),
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: Color(0xFF9A939E)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
