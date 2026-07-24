import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/food_item.dart';

class FoodDetailScreen extends StatelessWidget {
  const FoodDetailScreen({super.key, required this.food});

  final FoodItem food;

  static const _ink = Color(0xFF2D2A32);
  static const _muted = Color(0xFF6B6570);
  static const _accent = Color(0xFFE04B84);
  static const _bg = Color(0xFFFDF8FA);

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
          food.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: sans(fontWeight: FontWeight.w700, fontSize: 16, color: _ink),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE4EE), Color(0xFFF5C6DC)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(food.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 10),
                Text(
                  food.name,
                  textAlign: TextAlign.center,
                  style: serif(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${food.category.replaceAll('_', ' ')} · ${food.cuisine.replaceAll('_', ' ')}',
                  style: sans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (food.nutrients.isNotEmpty)
            _InfoCard(
              title: 'Nutrients',
              body: food.nutrients,
              sans: sans,
            ),
          if (food.benefits.isNotEmpty)
            _InfoCard(
              title: 'Benefits',
              body: food.benefits,
              sans: sans,
            ),
          _InfoCard(
            title: 'Best trimester',
            body: food.trimester.map(_triLabel).join(', '),
            sans: sans,
          ),
          if (food.servingSize.isNotEmpty)
            _InfoCard(
              title: 'Serving size',
              body: food.servingSize,
              sans: sans,
            ),
          if (food.weekMin != null || food.weekMax != null)
            _InfoCard(
              title: 'Helpful around weeks',
              body: '${food.weekMin ?? 1}–${food.weekMax ?? 40}',
              sans: sans,
            ),
          if (food.symptomTags.isNotEmpty)
            _InfoCard(
              title: 'May help with',
              body: food.symptomTags.map(_symptomLabel).join(', '),
              sans: sans,
            ),
          if (food.cookingTips != null && food.cookingTips!.isNotEmpty)
            _InfoCard(
              title: 'Cooking tips',
              body: food.cookingTips!,
              sans: sans,
            ),
          if (food.avoidIf != null && food.avoidIf!.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF5C2C2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AVOID / CAUTION',
                    style: sans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: const Color(0xFFD23B3B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    food.avoidIf!,
                    style: sans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8B2E2E),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in food.dietTags)
                Chip(
                  label: Text(tag.replaceAll('_', ' '),
                      style: sans(fontSize: 11, fontWeight: FontWeight.w600)),
                  backgroundColor: const Color(0xFFFFE4EE),
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _triLabel(int t) {
    switch (t) {
      case 1:
        return '1st';
      case 2:
        return '2nd';
      default:
        return '3rd';
    }
  }

  static String _symptomLabel(String s) {
    switch (s) {
      case 'nausea':
        return 'Morning sickness';
      case 'constipation':
        return 'Constipation';
      case 'heartburn':
        return 'Heartburn';
      case 'anemia':
        return 'Anemia';
      case 'leg_cramps':
        return 'Leg cramps';
      case 'swelling':
        return 'Swelling';
      default:
        return s;
    }
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.sans,
  });

  final String title;
  final String body;
  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
    double? height,
    double? letterSpacing,
  }) sans;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0E6EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: sans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: FoodDetailScreen._accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: sans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: FoodDetailScreen._ink,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
