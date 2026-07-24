import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/food_item.dart';
import '../services/meal_plan_service.dart';

class NutritionPrefsScreen extends StatefulWidget {
  const NutritionPrefsScreen({super.key});

  @override
  State<NutritionPrefsScreen> createState() => _NutritionPrefsScreenState();
}

class _NutritionPrefsScreenState extends State<NutritionPrefsScreen> {
  static const _ink = Color(0xFF2D2A32);
  static const _muted = Color(0xFF6B6570);
  static const _accent = Color(0xFFE04B84);
  static const _bg = Color(0xFFFDF8FA);

  final _service = MealPlanService();
  bool _loading = true;
  bool _saving = false;

  String _diet = 'vegetarian';
  final Set<String> _cuisines = {
    'indian',
    'south_indian',
    'kerala',
    'north_indian',
  };
  final Set<String> _medical = {};
  final Set<String> _symptoms = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await _service.loadPrefs();
    if (!mounted) return;
    setState(() {
      _diet = prefs.dietType;
      _cuisines
        ..clear()
        ..addAll(prefs.cuisines);
      _medical
        ..clear()
        ..addAll(prefs.medicalTags);
      _symptoms
        ..clear()
        ..addAll(prefs.activeSymptoms);
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _service.savePrefs(
      NutritionPrefs(
        dietType: _diet,
        cuisines: _cuisines.toList(),
        medicalTags: _medical.toList(),
        activeSymptoms: _symptoms.toList(),
      ),
    );
    if (!mounted) return;
    Navigator.pop(context, true);
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
          'Diet preferences',
          style: serif(fontWeight: FontWeight.w800, fontSize: 18, color: _ink),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              children: [
                Text('DIET TYPE',
                    style: sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: _accent)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final opt in [
                      ('vegetarian', 'Vegetarian'),
                      ('eggetarian', 'Eggetarian'),
                      ('non_vegetarian', 'Non-vegetarian'),
                      ('vegan', 'Vegan'),
                    ])
                      ChoiceChip(
                        label: Text(opt.$2),
                        selected: _diet == opt.$1,
                        onSelected: (_) => setState(() => _diet = opt.$1),
                        selectedColor: const Color(0xFFFFE4EE),
                        labelStyle: sans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: _diet == opt.$1 ? _accent : _ink,
                        ),
                      ),
                  ],
                ),
                if (_diet == 'vegan') ...[
                  const SizedBox(height: 8),
                  Text(
                    'Vegan pregnancy diets need careful planning with your healthcare provider for B12, iron, calcium, and protein.',
                    style: sans(fontSize: 12, color: _muted, height: 1.35),
                  ),
                ],
                const SizedBox(height: 12),
                Text('CUISINE',
                    style: sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: _accent)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final c in [
                      ('indian', 'Indian'),
                      ('south_indian', 'South Indian'),
                      ('kerala', 'Kerala'),
                      ('north_indian', 'North Indian'),
                      ('international', 'International'),
                    ])
                      FilterChip(
                        label: Text(c.$2),
                        selected: _cuisines.contains(c.$1),
                        onSelected: (sel) {
                          setState(() {
                            if (sel) {
                              _cuisines.add(c.$1);
                            } else {
                              _cuisines.remove(c.$1);
                            }
                          });
                        },
                        selectedColor: const Color(0xFFFFE4EE),
                        checkmarkColor: _accent,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('MEDICAL / SPECIAL',
                    style: sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: _accent)),
                const SizedBox(height: 4),
                Text(
                  'Filters meals when tagged. Always confirm with your provider.',
                  style: sans(fontSize: 12, color: _muted),
                ),
                const SizedBox(height: 8),
                for (final m in [
                  ('gluten_free', 'Gluten-free'),
                  ('lactose_free', 'Lactose-free'),
                  ('high_protein', 'Prefer high protein'),
                ])
                  CheckboxListTile(
                    value: _medical.contains(m.$1),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _medical.add(m.$1);
                        } else {
                          _medical.remove(m.$1);
                        }
                      });
                    },
                    title: Text(m.$2,
                        style: sans(fontWeight: FontWeight.w600, fontSize: 14)),
                    activeColor: _accent,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                const SizedBox(height: 12),
                Text('CURRENT SYMPTOMS',
                    style: sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: _accent)),
                const SizedBox(height: 8),
                for (final s in [
                  ('nausea', 'Morning sickness / nausea'),
                  ('constipation', 'Constipation'),
                  ('heartburn', 'Heartburn'),
                  ('anemia', 'Anemia / low iron'),
                  ('leg_cramps', 'Leg cramps'),
                  ('swelling', 'Swelling'),
                ])
                  CheckboxListTile(
                    value: _symptoms.contains(s.$1),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _symptoms.add(s.$1);
                        } else {
                          _symptoms.remove(s.$1);
                        }
                      });
                    },
                    title: Text(s.$2,
                        style: sans(fontWeight: FontWeight.w600, fontSize: 14)),
                    activeColor: _accent,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text('Save preferences',
                            style: sans(
                                fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                ),
              ],
            ),
    );
  }
}
