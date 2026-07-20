import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Birth preferences editor styled like the MamaBloom birth-plan mockups.
class BirthPlanScreen extends StatefulWidget {
  const BirthPlanScreen({super.key});

  @override
  State<BirthPlanScreen> createState() => _BirthPlanScreenState();
}

class _BirthPlanScreenState extends State<BirthPlanScreen> {
  static const _ink = Color(0xFF1A1A1A);
  static const _burgundy = Color(0xFF5C2438);
  static const _bg = Color(0xFFFFFFFF);

  final _notesCtrl = TextEditingController();

  final Set<String> _labour = {};
  final Set<String> _pain = {};
  final Set<String> _during = {};
  final Set<String> _after = {};

  static const _labourOpts = [
    'Dim lighting',
    'Quiet',
    'Soft music',
    'Partner present',
    'Family allowed',
  ];
  static const _painOpts = [
    'Epidural okay',
    'Water therapy',
    'Natural birth',
    'Breathing techniques',
    'Massage',
  ];
  static const _duringOpts = [
    'Avoid episiotomy if possible',
    'Skin-to-skin immediately',
    'Delayed cord cutting',
    'Partner cut cord',
  ];
  static const _afterOpts = [
    'Breastfeed immediately',
    'Rooming-in with baby',
    'Formula supplement okay',
    'Pacifier okay',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notesCtrl.text = p.getString('birth_plan_notes') ?? '';
      _labour
        ..clear()
        ..addAll(p.getStringList('birth_plan_labour') ?? const ['Dim lighting', 'Quiet']);
      _pain
        ..clear()
        ..addAll(p.getStringList('birth_plan_pain') ?? const ['Epidural okay', 'Water therapy']);
      _during
        ..clear()
        ..addAll(p.getStringList('birth_plan_during') ??
            const ['Avoid episiotomy if possible', 'Skin-to-skin immediately']);
      _after
        ..clear()
        ..addAll(p.getStringList('birth_plan_after') ??
            const ['Breastfeed immediately', 'Rooming-in with baby']);
    });
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _toggle(Set<String> target, String key) {
    setState(() {
      if (target.contains(key)) {
        target.remove(key);
      } else {
        target.add(key);
      }
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('birth_plan_notes', _notesCtrl.text);
    await p.setStringList('birth_plan_labour', _labour.toList());
    await p.setStringList('birth_plan_pain', _pain.toList());
    await p.setStringList('birth_plan_during', _during.toList());
    await p.setStringList('birth_plan_after', _after.toList());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Birth plan saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serif = GoogleFonts.fraunces;
    final sans = GoogleFonts.plusJakartaSans;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _ink),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Birth Plan',
          style: serif(fontWeight: FontWeight.w700, fontSize: 18, color: _burgundy),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, color: _ink),
          ),
          TextButton(
            onPressed: _save,
            child: Text(
              'Save',
              style: sans(fontWeight: FontWeight.w700, fontSize: 14, color: _burgundy),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _HeroBanner(serif: serif, sans: sans),
          const SizedBox(height: 28),
          _SectionHeading(text: 'LABOUR ENVIRONMENT', serif: serif),
          const SizedBox(height: 8),
          Text(
            'I prefer the room to be:',
            style: serif(fontSize: 15, color: _ink, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 14),
          _OptionWrap(
            options: _labourOpts,
            selected: _labour,
            onTap: (o) => _toggle(_labour, o),
            serif: serif,
          ),
          const SizedBox(height: 28),
          _SectionHeading(text: 'PAIN RELIEF PREFERENCES', serif: serif),
          const SizedBox(height: 14),
          _OptionWrap(
            options: _painOpts,
            selected: _pain,
            onTap: (o) => _toggle(_pain, o),
            serif: serif,
          ),
          const SizedBox(height: 28),
          _SectionHeading(text: 'DURING DELIVERY', serif: serif),
          const SizedBox(height: 14),
          _OptionGrid(
            options: _duringOpts,
            selected: _during,
            onTap: (o) => _toggle(_during, o),
            serif: serif,
          ),
          const SizedBox(height: 28),
          _SectionHeading(text: 'AFTER DELIVERY', serif: serif),
          const SizedBox(height: 14),
          _OptionGrid(
            options: _afterOpts,
            selected: _after,
            onTap: (o) => _toggle(_after, o),
            serif: serif,
          ),
          const SizedBox(height: 28),
          _SectionHeading(text: 'SPECIAL REQUESTS / ALLERGIES', serif: serif),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            maxLines: 5,
            style: sans(fontSize: 14, color: _ink),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              hintText:
                  'e.g. I am allergic to penicillin. Please avoid latex gloves. I would like to play Malayalam devotional songs during labour...',
              hintStyle: sans(fontSize: 13, color: Colors.black38),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: _burgundy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.save_outlined, size: 20),
              label: Text(
                'Save my birth plan',
                style: sans(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.text, required this.serif});

  final String text;
  final TextStyle Function({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
  })
  serif;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: serif(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
        color: const Color(0xFF1A1A1A),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.serif, required this.sans});

  final TextStyle Function({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    double? height,
  })
  serif;
  final TextStyle Function({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
  })
  sans;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFE8B4BC), Color(0xFF5C2438)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR PREFERENCES',
            style: sans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: const Color(0xFF3D1524),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Birth Plan',
            style: serif(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF3D1524),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share this with your doctor and hospital team',
            style: serif(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.35,
              color: const Color(0xFF3D1524),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionWrap extends StatelessWidget {
  const _OptionWrap({
    required this.options,
    required this.selected,
    required this.onTap,
    required this.serif,
  });

  final List<String> options;
  final Set<String> selected;
  final void Function(String) onTap;
  final TextStyle Function({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  })
  serif;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options
          .map(
            (o) => _ChipPill(
              label: o,
              selected: selected.contains(o),
              onTap: () => onTap(o),
              serif: serif,
            ),
          )
          .toList(),
    );
  }
}

class _OptionGrid extends StatelessWidget {
  const _OptionGrid({
    required this.options,
    required this.selected,
    required this.onTap,
    required this.serif,
  });

  final List<String> options;
  final Set<String> selected;
  final void Function(String) onTap;
  final TextStyle Function({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  })
  serif;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: options
          .map(
            (o) => _ChipPill(
              label: o,
              selected: selected.contains(o),
              onTap: () => onTap(o),
              serif: serif,
              alignCenter: true,
            ),
          )
          .toList(),
    );
  }
}

class _ChipPill extends StatelessWidget {
  const _ChipPill({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.serif,
    this.alignCenter = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle Function({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  })
  serif;
  final bool alignCenter;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          alignment: alignCenter ? Alignment.center : null,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFE4EE) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            textAlign: alignCenter ? TextAlign.center : TextAlign.start,
            style: serif(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? const Color(0xFF5C2438) : const Color(0xFF1A1A1A),
            ),
          ),
        ),
      ),
    );
  }
}
