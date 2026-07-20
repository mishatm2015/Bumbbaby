import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _TimelineItem {
  const _TimelineItem({
    required this.dot,
    required this.title,
    required this.body,
  });

  final Color dot;
  final String title;
  final String body;
}

class _TopicTile extends StatefulWidget {
  _TopicTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.iconBackground,
    required this.serif,
    required this.sans,
    this.detail,
    this.bullets,
  }) : assert(
          (detail != null && detail.isNotEmpty) !=
              (bullets != null && bullets.isNotEmpty),
          'Provide either detail or bullets',
        );

  final String emoji;
  final String title;
  final String subtitle;
  final Color iconBackground;
  final String? detail;
  final List<String>? bullets;
  final TextStyle Function({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  })
  serif;
  final TextStyle Function({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  })
  sans;

  @override
  State<_TopicTile> createState() => _TopicTileState();
}

class _TopicTileState extends State<_TopicTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _open = !_open),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.iconBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(widget.emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: widget.sans(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: const Color(0xFF37474F),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: widget.sans(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Icon(_open ? Icons.expand_less : Icons.expand_more, color: Colors.black45),
                ],
              ),
              if (_open) ...[
                const SizedBox(height: 10),
                if (widget.bullets != null)
                  ...widget.bullets!.map((line) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 6, right: 10),
                            decoration: const BoxDecoration(
                              color: Color(0xFF00897B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              line,
                              style: widget.sans(fontSize: 13, color: Colors.black87).copyWith(height: 1.45),
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                else
                  Text(
                    widget.detail!,
                    style: widget.sans(fontSize: 13, color: Colors.black87).copyWith(height: 1.45),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Fourth trimester guide: timeline and coping topics.
class PostpartumPrepScreen extends StatelessWidget {
  const PostpartumPrepScreen({super.key});

  static const _timeline = [
    _TimelineItem(
      dot: Color(0xFFE91E63),
      title: 'Days 1–3 · In hospital',
      body:
          'Colostrum (first milk) comes in · Baby learns to latch · Rest as much as possible · '
          'Your body starts healing · Lochia (postpartum bleeding) begins',
    ),
    _TimelineItem(
      dot: Color(0xFF64B5F6),
      title: 'Week 1–2 · Coming home',
      body:
          'Sleep when baby sleeps · Accept help from family · Breast milk comes in fully · '
          'Mood may dip — baby blues are normal · Watch stitches / C-section wound',
    ),
    _TimelineItem(
      dot: Color(0xFF7CB342),
      title: 'Week 3–6 · Early recovery',
      body:
          '6-week postnatal checkup with doctor · Breastfeeding gets easier · Uterus shrinks back to normal size · '
          'Gentle walks okay · Avoid strenuous exercise until cleared',
    ),
    _TimelineItem(
      dot: Color(0xFFFFB74D),
      title: 'Week 6–12 · Fourth trimester',
      body:
          'Your body is still healing · Hormones stabilise · Watch for postpartum depression signs · '
          'Resume gentle exercise if doctor agrees · Baby develops rapidly — smiling, tracking',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final serif = GoogleFonts.fraunces;
    final sans = GoogleFonts.plusJakartaSans;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Postpartum Prep',
          style: serif(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Personalised checklist coming soon')),
              );
            },
            child: Text(
              'What to expect',
              style: sans(fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF00897B)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFFB2DFDB), Color(0xFF1B5E20)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AFTER BIRTH',
                  style: sans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The fourth trimester',
                  style: serif(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'The first 12 weeks after birth — your body, baby & recovery',
                  style: serif(
                    fontSize: 14,
                    height: 1.35,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'RECOVERY TIMELINE',
            style: serif(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          ..._timeline.map((t) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(color: t.dot, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: serif(fontWeight: FontWeight.w800, fontSize: 16, height: 1.25),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t.body,
                          style: serif(
                            fontSize: 13,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Text(
            'WHAT TO EXPECT & HOW TO COPE',
            style: serif(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          _TopicTile(
            emoji: '🤱',
            title: 'Breastfeeding basics',
            subtitle: 'Latching, supply, pain relief',
            iconBackground: const Color(0xFFFFE4EE),
            detail:
                'Feed on demand in the early days, aim for a comfortable deep latch, and hand-express or pump '
                'if you need relief between feeds. Nipple pain that lasts beyond the first week is worth checking '
                'with a lactation consultant. Hydration and calories support supply — prioritize rest when you can.',
            serif: serif,
            sans: sans,
          ),
          const Divider(height: 24),
          _TopicTile(
            emoji: '🧘',
            title: 'Physical recovery',
            subtitle: 'Healing, exercises, pain',
            iconBackground: const Color(0xFFE0F2F1),
            detail:
                'Lochia and soreness are normal at first. Follow wound-care instructions for tears or a C-section, '
                'and avoid heavy lifting until your doctor clears you. Short walks and gentle pelvic-floor work are '
                'usually fine early on; build activity slowly as strength returns.',
            serif: serif,
            sans: sans,
          ),
          const Divider(height: 24),
          _TopicTile(
            emoji: '💜',
            title: 'Mental wellbeing',
            subtitle: 'Baby blues vs postpartum depression',
            iconBackground: const Color(0xFFF3E5F5),
            detail:
                'Many parents feel weepy, irritable, or overwhelmed in the first two weeks — “baby blues” often '
                'lift with sleep and support. If low mood, anxiety, panic, or intrusive thoughts last beyond two weeks, '
                'feel intense, or make it hard to care for yourself or baby, seek medical help. Treatment works.',
            serif: serif,
            sans: sans,
          ),
          const Divider(height: 24),
          _TopicTile(
            emoji: '🍲',
            title: 'Postpartum nutrition',
            subtitle: 'Foods to recover & boost milk',
            iconBackground: const Color(0xFFE8F5E9),
            bullets: const [
              'Continue iron & folic acid supplements for at least 3 months after delivery.',
              'Eat iron-rich foods: horse gram (mutton soup), drumstick leaves, dates, ragi.',
              'Galactagogues (milk-boosting foods): fenugreek seeds, jeera water, oats, fennel.',
              'Stay hydrated — breastfeeding needs an extra 700 ml of water per day.',
            ],
            serif: serif,
            sans: sans,
          ),
        ],
      ),
    );
  }
}
