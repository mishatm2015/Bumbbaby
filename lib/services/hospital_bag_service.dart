import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/hospital_bag_item.dart';

/// Local hospital-bag checklist: defaults + packed state + custom items.
class HospitalBagService {
  HospitalBagService._();

  static const _prefsKey = 'hospital_bag_items_v1';

  static const categories = <HospitalBagCategory>[
    HospitalBagCategory(id: 'documents', emoji: '📄', name: 'Important documents'),
    HospitalBagCategory(id: 'mom', emoji: '👩', name: 'For mom'),
    HospitalBagCategory(id: 'recovery', emoji: '🩹', name: 'Recovery supplies'),
    HospitalBagCategory(id: 'baby', emoji: '👶', name: 'For baby'),
    HospitalBagCategory(id: 'breastfeeding', emoji: '🌸', name: 'Breastfeeding'),
    HospitalBagCategory(id: 'partner', emoji: '👨', name: 'For partner'),
    HospitalBagCategory(id: 'travel', emoji: '🚗', name: 'Travel'),
    HospitalBagCategory(id: 'medicines', emoji: '💊', name: 'Medicines'),
    HospitalBagCategory(id: 'comfort', emoji: '🩺', name: 'Comfort & optional'),
    HospitalBagCategory(id: 'hygiene', emoji: '🧹', name: 'Hygiene'),
    HospitalBagCategory(id: 'leaving', emoji: '🏥', name: 'Before leaving home'),
  ];

  static List<HospitalBagItem> defaults() {
    final items = <HospitalBagItem>[];

    void add(String cat, String label, {String? sub}) {
      final id = '$cat|${sub ?? ''}|$label'.toLowerCase();
      items.add(HospitalBagItem(
        id: id,
        label: label,
        categoryId: cat,
        subcategory: sub,
      ));
    }

    // Documents
    for (final label in const [
      'Hospital ID card',
      'Government ID / Passport',
      'Insurance card',
      'Hospital registration papers',
      "Doctor's referral letter",
      'Pregnancy records / antenatal file',
      'Ultrasound reports',
      'Blood test reports',
      'Blood group card',
      'Birth plan (if prepared)',
      'Emergency contact list',
      'List of allergies',
      'Current medications list',
    ]) {
      add('documents', label);
    }

    // Mom — clothing
    for (final label in const [
      'Comfortable nightgowns (2–3)',
      'Front-open nursing gowns',
      'Going-home dress',
      'Nursing bras (2–3)',
      'Nursing camisoles',
      'Cotton panties',
      'Disposable maternity underwear',
      'Warm sweater / jacket',
      'Socks',
      'Slippers',
      'Shower slippers',
    ]) {
      add('mom', label, sub: 'Clothing');
    }

    // Mom — toiletries
    for (final label in const [
      'Toothbrush',
      'Toothpaste',
      'Face wash',
      'Soap',
      'Shampoo',
      'Conditioner',
      'Hair brush',
      'Hair ties',
      'Comb',
      'Lip balm',
      'Moisturizer',
      'Deodorant',
      'Towel',
      'Face towel',
      'Wet wipes',
      'Tissues',
      'Hand sanitizer',
    ]) {
      add('mom', label, sub: 'Toiletries');
    }

    // Mom — electronics
    for (final label in const [
      'Mobile phone',
      'Charger',
      'Long charging cable',
      'Power bank',
      'Earphones',
    ]) {
      add('mom', label, sub: 'Electronics');
    }

    // Mom — food & drinks
    for (final label in const [
      'Water bottle',
      'Electrolyte drink',
      'Dry fruits',
      'Biscuits',
      'Healthy snacks',
      'Fruits (if allowed)',
      'Juice (if permitted)',
    ]) {
      add('mom', label, sub: 'Food & drinks');
    }

    // Recovery — vaginal
    for (final label in const [
      'Peri bottle',
      'Witch hazel pads',
      'Postpartum pads',
      'Disposable underwear',
      'Sitz bath supplies (if needed)',
      'Cooling pads',
      'Numbing spray (if prescribed)',
      'Stool softener (if advised)',
    ]) {
      add('recovery', label, sub: 'Vaginal birth');
    }

    // Recovery — C-section
    for (final label in const [
      'High-waisted underwear',
      'Belly binder (if recommended)',
      'Loose dresses',
      'Soft pillow for incision support',
    ]) {
      add('recovery', label, sub: 'C-section');
    }

    // Baby — clothing
    for (final label in const [
      'Newborn outfit',
      '0–3 month outfit',
      'Vests (4–6)',
      'Sleepsuits',
      'Mittens',
      'Socks',
      'Hat',
      'Booties',
      'Blanket',
      'Swaddle blanket',
      'Receiving blanket',
      'Warm blanket (if needed)',
    ]) {
      add('baby', label, sub: 'Clothing');
    }

    // Baby — diapering
    for (final label in const [
      'Newborn diapers',
      'Baby wipes',
      'Cotton balls',
      'Baby diaper cream',
      'Changing mat',
    ]) {
      add('baby', label, sub: 'Diapering');
    }

    // Baby — bath
    for (final label in const [
      'Baby towel',
      'Soft washcloth',
    ]) {
      add('baby', label, sub: 'Bath');
    }

    // Baby — feeding
    for (final label in const [
      'Nursing cover (optional)',
      'Burp cloths',
      'Nursing pillow',
      'Baby bottles',
      'Formula (if advised)',
      'Bottle brush',
      'Sterilized bottles',
    ]) {
      add('baby', label, sub: 'Feeding');
    }

    // Breastfeeding
    for (final label in const [
      'Nursing pads',
      'Nipple cream',
      'Breast pump (if recommended)',
      'Milk storage bags',
      'Breast shells (optional)',
    ]) {
      add('breastfeeding', label);
    }

    // Partner
    for (final label in const [
      'Clothes',
      'Toiletries',
      'Phone charger',
      'Wallet',
      'Snacks',
      'Water bottle',
      'Pillow',
      'Blanket',
      'Medications (if needed)',
    ]) {
      add('partner', label);
    }

    // Travel
    for (final label in const [
      'Infant car seat',
      'Car seat base',
      'Car seat blanket (weather dependent)',
    ]) {
      add('travel', label);
    }

    // Medicines
    for (final label in const [
      'Prenatal vitamins',
      'Iron tablets',
      'Calcium tablets',
      'Prescription medicines',
      'Inhaler (if used)',
      'Insulin (if prescribed)',
    ]) {
      add('medicines', label);
    }

    // Comfort & optional
    for (final label in const [
      'Eye mask',
      'Neck pillow',
      'Favorite blanket',
      'Music playlist',
      'Book',
      'Journal',
      'Pen',
      'Stress ball',
      'Camera',
      'Tripod',
      'Baby memory book',
      'Baby announcement outfit',
      'Name board for photos',
      'Warm cap (winter)',
      'Baby jacket (winter)',
      'Gloves (winter)',
      'Light cotton clothes (summer)',
      'Portable fan (summer)',
      'Cooling wipes (summer)',
    ]) {
      add('comfort', label);
    }

    // Hygiene
    for (final label in const [
      'Hand sanitizer',
      'Surface wipes',
      'Face masks (if required)',
      'Extra tissues',
      'Small trash bags',
    ]) {
      add('hygiene', label);
    }

    // Before leaving home
    for (final label in const [
      'Hospital bag packed',
      'Phone fully charged',
      'Car seat installed',
      'Important documents ready',
      'House keys',
      'Wallet',
      'Emergency contacts informed',
      'Hospital route checked',
      'Fuel in vehicle',
      'Childcare arranged (if needed)',
      'Pet care arranged (if applicable)',
    ]) {
      add('leaving', label);
    }

    return items;
  }

  static Future<List<HospitalBagItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return defaults();

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final saved = decoded
          .whereType<Map>()
          .map((e) => HospitalBagItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // Merge: keep checked + custom from saved; refresh default labels/order.
      final byId = {for (final i in saved) i.id: i};
      final merged = <HospitalBagItem>[];

      for (final d in defaults()) {
        final existing = byId.remove(d.id);
        merged.add(HospitalBagItem(
          id: d.id,
          label: d.label,
          categoryId: d.categoryId,
          subcategory: d.subcategory,
          checked: existing?.checked ?? false,
        ));
      }

      // Custom items (and any removed-from-defaults that user still has as custom)
      for (final leftover in byId.values) {
        if (leftover.isCustom) merged.add(leftover);
      }

      return merged;
    } catch (_) {
      return defaults();
    }
  }

  static Future<void> save(List<HospitalBagItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }
}
