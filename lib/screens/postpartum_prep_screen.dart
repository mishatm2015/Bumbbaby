import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'hospital_bag_screen.dart';

/// Postpartum journey: all main headings visible on one screen.
class PostpartumPrepScreen extends StatelessWidget {
  const PostpartumPrepScreen({super.key});

  static const _ink = Color(0xFF2D2A32);
  static const _muted = Color(0xFF6B6570);
  static const _accent = Color(0xFFE04B84);
  static const _bg = Color(0xFFFDF8FA);

  static const _topics = <_Topic>[
    _Topic(1, 'Hospital bag checklist', 'Mom · Baby · Partner packing list', Icons.luggage_outlined, Color(0xFFE0F2F1)),
    _Topic(2, 'Physical recovery', 'Vaginal & C-section healing timelines', Icons.healing_outlined, Color(0xFFE8F5E9)),
    _Topic(3, 'Bleeding (lochia)', 'Normal stages & when to call', Icons.water_drop_outlined, Color(0xFFFFEBEE)),
    _Topic(4, 'Breast recovery', 'Breastfeeding & formula care', Icons.favorite_outline, Color(0xFFFCE4EC)),
    _Topic(5, 'Pelvic floor recovery', 'Kegels, symptoms & when to seek help', Icons.fitness_center_outlined, Color(0xFFE8EAF6)),
    _Topic(6, 'Emotional & mental health', 'Baby blues, PPD, anxiety, psychosis', Icons.psychology_outlined, Color(0xFFF3E5F5)),
    _Topic(7, 'Sleep & fatigue', 'What’s normal and tips to cope', Icons.bedtime_outlined, Color(0xFFE3F2FD)),
    _Topic(8, 'Nutrition after delivery', 'Healing foods & hydration', Icons.restaurant_outlined, Color(0xFFFFF3E0)),
    _Topic(9, 'Exercise timeline', 'Week-by-week safe activity', Icons.directions_walk_outlined, Color(0xFFE0F7FA)),
    _Topic(10, 'Sexual health & birth control', 'Intimacy timing & contraception', Icons.favorite_border, Color(0xFFFCE4EC)),
    _Topic(11, 'Home setup before baby', 'Nursery, feeding & changing stations', Icons.home_outlined, Color(0xFFEFEBE9)),
    _Topic(12, 'Postpartum recovery kit', 'Pads, peri bottle, pain relief & more', Icons.medical_services_outlined, Color(0xFFE8F5E9)),
    _Topic(13, 'Feeding preparation', 'Breast, formula & combination feeding', Icons.child_care_outlined, Color(0xFFFFF8E1)),
    _Topic(14, 'First 6 weeks timeline', 'Week-by-week focus & normal vs call', Icons.timeline_outlined, Color(0xFFE0F2F1)),
    _Topic(15, 'Year-one emotional journey', 'Month-by-month adjustment', Icons.calendar_month_outlined, Color(0xFFE8EAF6)),
    _Topic(16, 'Mother self-care checklist', 'Daily habits for recovery', Icons.check_circle_outline, Color(0xFFE8F5E9)),
    _Topic(17, 'Follow-up visits', 'Typical postpartum appointment schedule', Icons.event_available_outlined, Color(0xFFE3F2FD)),
    _Topic(18, 'Support system planning', 'Meals, visitors, partner roles', Icons.groups_outlined, Color(0xFFF3E5F5)),
    _Topic(19, 'Admin / legal prep', 'Insurance, leave, pediatrician, papers', Icons.description_outlined, Color(0xFFFFF3E0)),
    _Topic(20, 'Warning & emergency signs', 'When to call doctor or go to ED', Icons.warning_amber_outlined, Color(0xFFFFEBEE)),
  ];

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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Postpartum prep',
          style: serif(fontWeight: FontWeight.w800, fontSize: 18, color: _ink),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFE4EE), Color(0xFFF5C6DC)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.14),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From hospital bag to year one',
                  style: serif(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap any topic for full details. Recovery is not linear — follow your midwife or doctor.',
                  style: sans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _EmergencyBanner(sans: sans),
          const SizedBox(height: 20),
          Text(
            'ALL TOPICS',
            style: sans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: _accent,
            ),
          ),
          const SizedBox(height: 12),
          ..._topics.map((t) => _TopicHeadingCard(
                topic: t,
                sans: sans,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _TopicDetailScreen(topic: t),
                    ),
                  );
                },
              )),
        ],
      ),
    );
  }
}

class _Topic {
  const _Topic(this.id, this.title, this.subtitle, this.icon, this.bg);
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bg;
}

typedef _Sans = TextStyle Function({
  FontWeight? fontWeight,
  double? fontSize,
  Color? color,
  double? height,
  double? letterSpacing,
});
typedef _Serif = TextStyle Function({
  FontWeight? fontWeight,
  double? fontSize,
  Color? color,
  double? height,
});

class _EmergencyBanner extends StatelessWidget {
  const _EmergencyBanner({required this.sans});
  final _Sans sans;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFDECEC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          await Clipboard.setData(const ClipboardData(text: '112'));
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Emergency number 112 copied')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.emergency_outlined, color: Color(0xFFD23B3B)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Emergency: heavy bleeding, chest pain, seizures, thoughts of harm — tap to copy 112',
                  style: sans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB02525),
                      height: 1.35),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicHeadingCard extends StatelessWidget {
  const _TopicHeadingCard({
    required this.topic,
    required this.sans,
    required this.onTap,
  });

  final _Topic topic;
  final _Sans sans;
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: topic.bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(topic.icon,
                      color: PostpartumPrepScreen._accent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: sans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: PostpartumPrepScreen._ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        topic.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: sans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: PostpartumPrepScreen._muted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF9A939E)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Detail screen ───────────────────────────────────────────────────────────

class _TopicDetailScreen extends StatelessWidget {
  const _TopicDetailScreen({required this.topic});
  final _Topic topic;

  @override
  Widget build(BuildContext context) {
    final serif = GoogleFonts.fraunces;
    final sans = GoogleFonts.plusJakartaSans;

    return Scaffold(
      backgroundColor: PostpartumPrepScreen._bg,
      appBar: AppBar(
        backgroundColor: PostpartumPrepScreen._bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          topic.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: sans(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: PostpartumPrepScreen._ink,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: topic.bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF0E6EA)),
            ),
            child: Row(
              children: [
                Icon(topic.icon, color: PostpartumPrepScreen._accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    topic.subtitle,
                    style: sans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: PostpartumPrepScreen._ink,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._contentFor(topic.id, serif, sans, context),
        ],
      ),
    );
  }
}

// ── Shared content widgets ──────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child, this.color = Colors.white, this.border});
  final Widget child;
  final Color color;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border ?? const Color(0xFFE8EEEC)),
      ),
      child: child,
    );
  }
}

class _SubH extends StatelessWidget {
  const _SubH(this.text, this.sans, {this.color = const Color(0xFF00897B)});
  final String text;
  final _Sans sans;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: sans(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
    );
  }
}

class _P extends StatelessWidget {
  const _P(this.text, this.sans);
  final String text;
  final _Sans sans;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text,
          style: sans(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B6570),
              height: 1.4)),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets(this.items, this.sans, {this.color = const Color(0xFF00897B)});
  final List<String> items;
  final _Sans sans;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final line in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Icon(Icons.circle, size: 6, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(line,
                      style: sans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D2A32),
                          height: 1.4)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RowT extends StatelessWidget {
  const _RowT(this.when, this.what, this.sans, {this.color = const Color(0xFF00897B)});
  final String when;
  final String what;
  final _Sans sans;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(when,
                  textAlign: TextAlign.center,
                  style: sans(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(what,
                style: sans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2A32),
                    height: 1.35)),
          ),
        ],
      ),
    );
  }
}

class _Checks extends StatefulWidget {
  const _Checks({required this.title, required this.items, required this.sans});
  final String title;
  final List<String> items;
  final _Sans sans;

  @override
  State<_Checks> createState() => _ChecksState();
}

class _ChecksState extends State<_Checks> {
  late final List<bool> _done = List<bool>.filled(widget.items.length, false);

  @override
  Widget build(BuildContext context) {
    final n = _done.where((e) => e).length;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(widget.title,
                    style: widget.sans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2D2A32))),
              ),
              Text('$n/${widget.items.length}',
                  style: widget.sans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00897B))),
            ],
          ),
          const SizedBox(height: 6),
          ...List.generate(widget.items.length, (i) {
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              value: _done[i],
              activeColor: const Color(0xFF00897B),
              title: Text(widget.items[i],
                  style: widget.sans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _done[i]
                        ? const Color(0xFF9A939E)
                        : const Color(0xFF2D2A32),
                  )),
              onChanged: (v) => setState(() => _done[i] = v ?? false),
            );
          }),
        ],
      ),
    );
  }
}

class _Compare extends StatelessWidget {
  const _Compare({
    required this.left,
    required this.right,
    required this.rows,
    required this.sans,
  });
  final String left;
  final String right;
  final List<(String, String)> rows;
  final _Sans sans;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(left,
                    style: sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2E7D32))),
              ),
              Expanded(
                child: Text(right,
                    style: sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFD23B3B))),
              ),
            ],
          ),
          const Divider(height: 16),
          for (final r in rows) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(r.$1,
                      style: sans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D2A32),
                          height: 1.35)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(r.$2,
                      style: sans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D2A32),
                          height: 1.35)),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

List<Widget> _contentFor(
    int id, _Serif serif, _Sans sans, BuildContext context) {
  switch (id) {
    case 1:
      return [
        _P('Pack by ~36 weeks. Use the interactive checklist to track what you’ve packed.',
            sans),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HospitalBagScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PostpartumPrepScreen._accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.luggage_outlined),
              label: Text(
                'Open hospital bag checklist',
                style: sans(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ),
        _Checks(title: 'For mom', sans: sans, items: const [
          'ID, insurance card, hospital paperwork / birth plan',
          'Comfortable going-home outfit (loose, ~6-month pregnant size)',
          'Nursing bras / tank tops (2–3)',
          'Maternity / postpartum underwear (high-waisted, several)',
          'Toiletries (toothbrush, deodorant, hair ties, lip balm)',
          'Phone charger (long cord)',
          'Robe or comfortable cardigan',
          'Slip-on slippers / grip socks',
          'Flip-flops for shower',
          'Snacks for after delivery',
        ]),
        _Checks(title: 'For baby', sans: sans, items: const [
          'Going-home outfit (newborn + 0–3 months)',
          'Swaddle blanket',
          'Car seat (installed & inspected beforehand)',
          'Hat, mittens (optional)',
        ]),
        _Checks(title: 'For partner / support person', sans: sans, items: const [
          'Change of clothes, toiletries',
          'Snacks, phone / charger',
          'Pillow for hospital chairs / pull-out beds',
        ]),
      ];
    case 2:
      return [
        _P('Healing depends on delivery type. Follow your provider’s clearance.', sans),
        _Card(
          color: const Color(0xFFE8F5E9),
          border: const Color(0xFFA5D6A7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubH('Vaginal delivery', sans, color: const Color(0xFF2E7D32)),
              _RowT('Days 1–3', 'Soreness, swelling, possible stitches; heavy lochia', sans),
              _RowT('Week 1–2', 'Bleeding tapers red → pink/brown; perineal pain eases', sans),
              _RowT('Week 2–6', 'Lochia turns yellowish-white then stops', sans),
              _RowT('6 weeks', 'Checkup; clearance for light exercise / intimacy if appropriate', sans),
              _SubH('Essentials', sans),
              _Bullets(const [
                'Peri bottle, witch hazel pads, padsicles',
                'Ice / perineal cold packs (first 24–48 hrs)',
                'Sitz bath, numbing spray (if recommended)',
                'Stool softener, extra-absorbent pads (not tampons)',
              ], sans),
            ],
          ),
        ),
        _Card(
          color: const Color(0xFFE3F2FD),
          border: const Color(0xFF90CAF9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubH('C-section recovery', sans, color: const Color(0xFF1565C0)),
              _RowT('Days 1–3', 'Hospital ~2–4 days; limited mobility; catheter often out day 1–2', sans, color: const Color(0xFF1565C0)),
              _RowT('Week 1–2', 'Incision tenderness; lift nothing heavier than baby', sans, color: const Color(0xFF1565C0)),
              _RowT('Week 2–4', 'Gradual mobility; incision continues healing', sans, color: const Color(0xFF1565C0)),
              _RowT('6–8 weeks', 'Full clearance for exercise / heavy lifting from doctor', sans, color: const Color(0xFF1565C0)),
              _SubH('Essentials & precautions', sans, color: const Color(0xFF1565C0)),
              _Bullets(const [
                'High-waisted soft underwear; binder if advised',
                'Pillow against incision for cough / laugh / car rides',
                'Stool softener (critical after surgery)',
                'No driving until cleared (often ~2 weeks+)',
                'Watch incision for redness, discharge, fever',
                'Avoid stairs when possible in week 1',
              ], sans, color: const Color(0xFF1565C0)),
            ],
          ),
        ),
      ];
    case 3:
      return [
        _P('Bleeding after birth is normal and changes over weeks.', sans),
        _Card(
          child: Column(
            children: [
              _RowT('Days 1–3', 'Lochia rubra — bright red, heavy-period like; small clots possible', sans, color: const Color(0xFFD23B3B)),
              _RowT('Days 4–10', 'Lochia serosa — pink/brown, moderate, fewer clots', sans, color: const Color(0xFFE8A020)),
              _RowT('Days 10–42', 'Lochia alba — yellowish/creamy white, light, then stops', sans),
            ],
          ),
        ),
        _Card(
          color: const Color(0xFFFDECEC),
          border: const Color(0xFFE89B9B),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubH('Call your doctor if', sans, color: const Color(0xFFD23B3B)),
              _Bullets(const [
                'Bleeding suddenly becomes heavy again',
                'Soaking a pad in under an hour',
                'Large clots (bigger than a golf ball)',
                'Foul smell or fever',
              ], sans, color: const Color(0xFFD23B3B)),
            ],
          ),
        ),
      ];
    case 4:
      return [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubH('If breastfeeding — often normal', sans),
              _Bullets(const [
                'Fullness, engorgement, leaking milk',
                'Tender nipples (especially early days)',
              ], sans),
              _SubH('Seek care if', sans, color: const Color(0xFFE8A020)),
              _Bullets(const [
                'Fever, red painful area, hard lump that doesn’t improve',
                'Flu-like symptoms — possible mastitis',
              ], sans, color: const Color(0xFFE8A020)),
            ],
          ),
        ),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubH('If formula feeding', sans),
              _Bullets(const [
                'Milk may still come in; engorgement for several days',
                'Supportive bra, cold compresses',
                'Avoid stimulating breasts unless advised',
              ], sans),
            ],
          ),
        ),
      ];
    case 5:
      return [
        _P('Pregnancy stretches pelvic muscles. Gentle recovery helps continence and comfort.', sans),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubH('Common symptoms', sans),
              _Bullets(const ['Urine leakage', 'Pelvic heaviness', 'Weak muscles'], sans),
              _SubH('Recovery', sans),
              _Bullets(const [
                'Kegel exercises (when cleared)',
                'Pelvic floor physiotherapy if needed',
                'Avoid heavy lifting early on',
              ], sans),
              _SubH('Seek medical advice if', sans, color: const Color(0xFFE8A020)),
              _Bullets(const [
                'Severe pelvic pressure',
                'Inability to control urine or stool',
                'Bulging sensation in the vagina',
              ], sans, color: const Color(0xFFE8A020)),
            ],
          ),
        ),
      ];
    case 6:
      return [
        _P('Baby blues are common. Depression, anxiety, OCD, and psychosis need professional care.', sans),
        _Compare(
          left: 'Baby blues',
          right: 'Postpartum depression',
          sans: sans,
          rows: const [
            ('Up to ~80% of new moms', '~1 in 7 new moms'),
            ('Starts 2–3 days after birth', 'Anytime in first year'),
            ('Resolves within ~2 weeks', 'Persists / worsens beyond 2 weeks'),
            ('Mood swings, weepiness, mild anxiety', 'Persistent sadness, hopelessness, bonding difficulty'),
          ],
        ),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubH('Also watch for', sans, color: const Color(0xFFE8A020)),
              _Bullets(const [
                'Anxiety: constant worry, racing thoughts, panic, fear baby will stop breathing',
                'OCD: intrusive thoughts, compulsive checking, fear of harming baby',
              ], sans, color: const Color(0xFFE8A020)),
              _SubH('Postpartum psychosis — emergency', sans, color: const Color(0xFFD23B3B)),
              _Bullets(const [
                'Hallucinations, delusions, confusion, extreme agitation',
                'Seek emergency care immediately',
              ], sans, color: const Color(0xFFD23B3B)),
            ],
          ),
        ),
        _Card(
          color: const Color(0xFFE0F2F1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubH('Prepare before birth', sans),
              _Bullets(const [
                'Identify support people (partner, family, friends)',
                'Find a postpartum-aware therapist in advance',
                'Keep OB/midwife mental-health resources handy',
                'Consider a new-parent support group',
                'Set realistic expectations — recovery is not linear',
              ], sans),
            ],
          ),
        ),
      ];
    case 7:
      return [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubH('Often normal', sans),
              _Bullets(const ['Extreme tiredness, broken sleep, day/night confusion'], sans),
              _SubH('Tips', sans),
              _Bullets(const [
                'Sleep when baby sleeps when possible',
                'Accept help; stay hydrated; eat regularly',
              ], sans),
              _SubH('Call doctor if', sans, color: const Color(0xFFE8A020)),
              _Bullets(const [
                'Unable to sleep even when exhausted',
                'Severe anxiety preventing sleep',
              ], sans, color: const Color(0xFFE8A020)),
            ],
          ),
        ),
      ];
    case 8:
      return [
        _P('Focus on healing — especially if breastfeeding.', sans),
        _Card(
          child: _Bullets(const [
            'Protein, iron, calcium, vitamin D, omega-3',
            'Fiber, fruits, vegetables',
            'Hydration: especially while breastfeeding (often ~2–3 L/day as advised)',
            'Continue prenatal / postnatal vitamins if recommended',
          ], sans),
        ),
      ];
    case 9:
      return [
        _P('Only progress when your provider clears you — especially after C-section.', sans),
        _Card(
          child: Column(
            children: [
              _RowT('Week 1', 'Deep breathing, walking inside home, pelvic floor (if cleared)', sans),
              _RowT('Week 2–4', 'Short walks, gentle stretching', sans),
              _RowT('Week 6+', 'Doctor approval first → yoga, swimming, gym, running', sans),
            ],
          ),
        ),
      ];
    case 10:
      return [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubH('Intimacy — often normal', sans),
              _Bullets(const [
                'Vaginal dryness, reduced libido, mild discomfort initially',
                'Discuss resuming intercourse after medical clearance (often around the postpartum checkup; timing varies)',
              ], sans),
              _SubH('Seek care if', sans, color: const Color(0xFFE8A020)),
              _Bullets(const ['Severe pain, heavy bleeding, or fever'], sans, color: const Color(0xFFE8A020)),
              _SubH('Birth control', sans),
              _P('You can get pregnant again before periods return.', sans),
              _Bullets(const [
                'LAM (when criteria are met), condoms, mini-pill',
                'IUD, implant, injectable contraception',
                'Discuss the best option with your provider',
              ], sans),
            ],
          ),
        ),
      ];
    case 11:
      return [
        _Checks(title: 'Nursery / sleep', sans: sans, items: const [
          'Crib or bassinet meeting safety standards',
          'Firm mattress + fitted sheet only (no loose bedding / bumpers)',
          'Sound machine / blackout curtains (optional)',
        ]),
        _Checks(title: 'Feeding station', sans: sans, items: const [
          'Comfortable chair with back/arm support',
          'Side table for water, snacks, phone, burp cloths',
          'Nursing pillow; nipple cream; nursing pads',
          'Bottles / formula / sterilizer if combo or formula feeding',
        ]),
        _Checks(title: 'Changing & general', sans: sans, items: const [
          'Changing pad, diapers (NB + size 1), wipes, rash cream, diaper pail',
          'Stock freezer with easy meals',
          'Nesting stations on each floor (diapers, wipes, burp cloths)',
          'Arrange help for meals / chores for first 2–4 weeks',
          'Install & inspect car seat',
        ]),
      ];
    case 12:
      return [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubH('Pain relief', sans),
              _Bullets(const ['Ibuprofen / acetaminophen as approved', 'Ice packs'], sans),
              _SubH('Bleeding & perineal', sans),
              _Bullets(const [
                'Postpartum pads, disposable underwear',
                'Peri bottle, witch hazel pads, numbing spray, sitz bath',
              ], sans),
              _SubH('Digestive & breast', sans),
              _Bullets(const [
                'Stool softener, fiber, prune juice',
                'Nursing pads, nipple cream, compresses, hand pump',
              ], sans),
              _SubH('Comfort & nutrition', sans),
              _Bullets(const [
                'Loose / nursing-friendly clothes, robe',
                'Large water bottle, easy snacks, electrolytes',
              ], sans),
            ],
          ),
        ),
      ];
    case 13:
      return [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubH('Breastfeeding', sans),
              _Bullets(const [
                'Consider prenatal lactation consult',
                'Nursing bras, pads, nipple cream ready',
                'Know local lactation consultants / support groups',
                'Pump — check insurance coverage',
              ], sans),
              _SubH('Formula / combo', sans),
              _Bullets(const [
                'Choose formula type in advance',
                'Bottles, sterilizer, warmer (optional)',
                'Prepare supplies for both methods if combo feeding',
              ], sans),
            ],
          ),
        ),
      ];
    case 14:
      return [
        _Card(
          child: Column(
            children: [
              _RowT('Week 1', 'Rest, bond, manage pain, establish feeding, accept help', sans),
              _RowT('Week 2', 'Continue rest, monitor healing, adjust to sleep loss, watch warning signs', sans),
              _RowT('Week 3–4', 'Gentle walks if cleared, feeding routine, emotional check-ins', sans),
              _RowT('Week 5–6', 'Prepare for 6-week checkup; discuss exercise / intimacy return', sans),
            ],
          ),
        ),
        _Compare(
          left: 'Often normal',
          right: 'Call the doctor',
          sans: sans,
          rows: const [
            ('Heavy bleeding first days, then tapering', 'Bleeding that increases or large clots'),
            ('Mild cramping (uterus shrinking)', 'Severe abdominal pain'),
            ('Emotional ups and downs first 2 weeks', 'Persistent sadness/anxiety beyond 2 weeks'),
            ('Low-grade discomfort at stitches/incision', 'Fever, redness, discharge, worsening pain'),
            ('Hard to sleep due to baby’s schedule', 'Racing thoughts; can’t sleep even when baby sleeps'),
          ],
        ),
      ];
    case 15:
      return [
        _P('Many mothers continue adjusting through the first year.', sans),
        _Card(
          child: Column(
            children: [
              _RowT('Week 1', 'Physical recovery + learning baby cues', sans),
              _RowT('Month 1', 'Sleep deprivation + building routine', sans),
              _RowT('Month 2', 'Confidence often increases', sans),
              _RowT('Month 3', 'Routine improves for many families', sans),
              _RowT('Month 6', 'Physical recovery continues', sans),
              _RowT('Year 1', 'Ongoing emotional adjustment is common', sans),
            ],
          ),
        ),
      ];
    case 16:
      return [
        _Checks(title: 'Daily checklist', sans: sans, items: const [
          'Drink 2–3 L water (or as advised)',
          'Eat 3 nourishing meals',
          'Take medications / vitamins as prescribed',
          'Shower / freshen up',
          'Rest when you can',
          'Short walk if medically appropriate',
          'Ask for help',
          'Spend a few minutes on yourself',
        ]),
      ];
    case 17:
      return [
        _Card(
          child: Column(
            children: [
              _RowT('24–72 hrs', 'If advised (e.g. blood pressure checks)', sans),
              _RowT('1–2 weeks', 'Especially after C-section or if concerns', sans),
              _RowT('~6 weeks', 'Standard postpartum checkup', sans),
              _RowT('As needed', 'Mental health, breastfeeding, medical issues', sans),
            ],
          ),
        ),
        _P('Also book pediatrician visits early — often within days of birth.', sans),
      ];
    case 18:
      return [
        _Card(
          child: _Bullets(const [
            'Meal train: friends/family bring meals for 2–4 weeks',
            'Visitor boundaries: who, when, health precautions',
            'Help schedule: laundry, dishes, older kids, pets',
            'Partner role: night duties & household tasks planned in advance',
            'Consider a postpartum doula if within budget',
          ], sans),
        ),
      ];
    case 19:
      return [
        _Checks(title: 'Do before birth', sans: sans, items: const [
          'Pre-register at hospital',
          'Understand insurance for delivery + newborn',
          'Choose pediatrician; schedule first visit',
          'Understand birth certificate process',
          'Update life insurance / will if applicable',
          'Arrange parental leave paperwork',
          'Research childcare if returning to work',
        ]),
      ];
    case 20:
      return [
        _Card(
          color: const Color(0xFFFFF6E5),
          border: const Color(0xFFF2DFB0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubH('Call your doctor promptly', sans, color: const Color(0xFFE8A020)),
              _Bullets(const [
                'Heavy bleeding (soaking a pad in under an hour)',
                'Large clots bigger than a golf ball',
                'Fever over 38°C (100.4°F)',
                'Severe headache with vision changes',
                'Leg swelling / redness / pain (possible clot)',
                'Incision or stitches red, swollen, or oozing',
                'Foul-smelling discharge',
              ], sans, color: const Color(0xFFE8A020)),
            ],
          ),
        ),
        _Card(
          color: const Color(0xFFFDECEC),
          border: const Color(0xFFE89B9B),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubH('Seek emergency care immediately', sans, color: const Color(0xFFD23B3B)),
              _Bullets(const [
                'Chest pain or difficulty breathing',
                'Seizures, fainting, confusion, hallucinations',
                'Thoughts of harming yourself or baby',
                'Heavy bleeding that won’t stop',
                'One-sided leg swelling with pain/redness',
              ], sans, color: const Color(0xFFD23B3B)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Builder(
                  builder: (context) {
                    return ElevatedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(const ClipboardData(text: '112'));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('112 copied')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD23B3B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.emergency_outlined),
                      label: Text('Call emergency — 112',
                          style: sans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ];
    default:
      return [Text('Coming soon', style: sans())];
  }
}
