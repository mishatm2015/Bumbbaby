import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Trimester-safe yoga & gentle movement (UI matches design references).
class YogaExerciseScreen extends StatefulWidget {
  const YogaExerciseScreen({super.key});

  @override
  State<YogaExerciseScreen> createState() => _YogaExerciseScreenState();
}

class _YogaExerciseScreenState extends State<YogaExerciseScreen> {
  static const _ink = Color(0xFF2D2A32);
  static const _teal = Color(0xFF1A8C6A);

  int _trimester = 0;

  static final List<_TrimesterBlock> _blocks = [
    _TrimesterBlock(
      tabLabel: '1st Trimester',
      kicker: 'FIRST TRIMESTER',
      title: 'Weeks 1–12 • Gentle & grounding',
      subtitle:
          'Focus on breathing and avoiding any lying-flat poses after week 10.',
      poses: [
        _YogaPose(
          emoji: '🌬️',
          title: 'Cat-Cow stretch',
          sanskrit: 'Marjaryasana-Bitilasana',
          duration: '5 min',
          focus: 'Back relief',
          steps: [
            'Start on hands and knees, wrists under shoulders.',
            'Inhale — drop belly, lift chest and tailbone (Cow).',
            'Exhale — round back, tuck chin and tailbone (Cat).',
            'Repeat slowly 8–10 times, syncing with breath.',
          ],
          caution: 'Avoid if you have wrist pain. Use fists instead.',
        ),
        _YogaPose(
          emoji: '🦋',
          title: 'Butterfly pose',
          sanskrit: 'Baddha Konasana',
          duration: '3 min',
          focus: 'Hip opener',
          steps: [
            'Sit tall, bring soles of feet together, let knees fall out.',
            'Hold feet or ankles, sit tall without rounding back.',
            'Gently flap knees up and down like butterfly wings.',
            'Stay for 3–5 minutes, breathing deeply.',
          ],
          caution:
              'Place folded blanket under hips if uncomfortable.',
        ),
        _YogaPose(
          emoji: '⛰️',
          title: 'Mountain pose',
          sanskrit: 'Tadasana',
          duration: '2 min',
          focus: 'Balance',
          steps: [
            'Stand with feet hip-width apart, arms by sides.',
            'Lift toes, spread them, place them back down.',
            'Draw belly in gently, lengthen spine upward.',
            'Breathe deeply for 8–10 breaths.',
          ],
          caution: 'Stand near a wall if you feel light-headed.',
        ),
      ],
    ),
    _TrimesterBlock(
      tabLabel: '2nd Trimester',
      kicker: 'SECOND TRIMESTER',
      title: 'Weeks 13–27 • Strength & space',
      subtitle:
          'Avoid deep twists and lying flat on your back for long stretches.',
      poses: [
        _YogaPose(
          emoji: '🪑',
          title: 'Supported side stretch',
          sanskrit: 'Parsva Sukhasana',
          duration: '4 min',
          focus: 'Side body',
          steps: [
            'Sit on a cushion, legs crossed comfortably.',
            'Place right hand down, sweep left arm overhead.',
            'Breathe into the left side; switch sides.',
            'Keep both sit bones grounded.',
          ],
          caution: 'Don’t compress the belly — open to the side, not forward.',
        ),
        _YogaPose(
          emoji: '🧘',
          title: 'Wide-knee child’s pose',
          sanskrit: 'Balasana (variation)',
          duration: '5 min',
          focus: 'Rest & breath',
          steps: [
            'Knees wide, big toes touching, sit back toward heels.',
            'Support chest with stacked bolsters or pillows.',
            'Rest forehead on props; breathe into the back.',
            'Come up slowly if dizzy.',
          ],
          caution: 'Skip if knee pain — use seated forward lean instead.',
        ),
      ],
    ),
    _TrimesterBlock(
      tabLabel: '3rd Trimester',
      kicker: 'THIRD TRIMESTER',
      title: 'Weeks 28–40 • Calm & prepare',
      subtitle:
          'Prioritise stability, pelvic floor awareness, and restful positions.',
      poses: [
        _YogaPose(
          emoji: '🪷',
          title: 'Supported goddess squat',
          sanskrit: 'Utkata Konasana (supported)',
          duration: '3 min',
          focus: 'Pelvic opening',
          steps: [
            'Hold a sturdy chair or wall; feet wider than hips.',
            'Toes out slightly; sink hips only as far as feels stable.',
            'Press evenly through feet; breathe steadily.',
            'Rise slowly using legs and support.',
          ],
          caution: 'Stop if you feel pressure, pain, or contractions.',
        ),
        _YogaPose(
          emoji: '🌙',
          title: 'Legs-up-the-wall (supported)',
          sanskrit: 'Viparita Karani',
          duration: '6 min',
          focus: 'Swelling relief',
          steps: [
            'Hip-distance from wall; swing legs up with a bolster under hips.',
            'Arms relaxed by sides; soften shoulders.',
            'Slow nasal breaths; avoid if breathless.',
            'Slide off carefully to one side to exit.',
          ],
          caution: 'Avoid if baby is breech and your provider advised against.',
        ),
      ],
    ),
  ];

  void _showSafePosesSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final sans = GoogleFonts.plusJakartaSans;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Safe poses — quick guide',
                style: GoogleFonts.fraunces(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 12),
              ...[
                'Move slowly; stop if anything feels sharp or wrong.',
                'Avoid hot yoga, deep closed twists, and long time flat on your back.',
                'Use props (wall, chair, bolsters) for balance and comfort.',
                'Hydrate; pause if dizzy, cramping, or bleeding — contact your doctor.',
              ].map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: sans(fontSize: 15.0, color: _teal)),
                      Expanded(
                        child: Text(
                          t,
                          style: sans(
                            fontSize: 14.0,
                            height: 1.4,
                            color: const Color(0xFF4A4450),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    final serif = GoogleFonts.fraunces;
    final block = _blocks[_trimester];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8FA),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Yoga & Exercise',
          style: sans(
            fontWeight: FontWeight.w700,
            fontSize: 17.0,
            color: _ink,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _showSafePosesSheet,
            child: Text(
              'Safe poses',
              style: sans(
                fontWeight: FontWeight.w700,
                fontSize: 14.0,
                color: _teal,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        children: [
          _TrimesterTabs(
            selected: _trimester,
            labels: _blocks.map((b) => b.tabLabel).toList(),
            sans: sans,
            onChanged: (i) => setState(() => _trimester = i),
          ),
          const SizedBox(height: 16),
          _TrimesterHero(
            block: block,
            sans: sans,
            serif: serif,
          ),
          const SizedBox(height: 20),
          ...block.poses.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _PoseCard(
                pose: p,
                sans: sans,
                serif: serif,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrimesterTabs extends StatelessWidget {
  const _TrimesterTabs({
    required this.selected,
    required this.labels,
    required this.sans,
    required this.onChanged,
  });

  final int selected;
  final List<String> labels;
  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
  }) sans;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (i) {
        final sel = i == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 6, right: i == labels.length - 1 ? 0 : 6),
            child: Material(
              color: sel ? const Color(0xFF1A8C6A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => onChanged(i),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel
                          ? const Color(0xFF1A8C6A)
                          : const Color(0xFFE8E0E4),
                    ),
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: sans(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: sel ? Colors.white : const Color(0xFF2D2A32),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _TrimesterHero extends StatelessWidget {
  const _TrimesterHero({
    required this.block,
    required this.sans,
    required this.serif,
  });

  final _TrimesterBlock block;
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFD8F2EA),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            block.kicker,
            style: sans(
              fontSize: 11.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: const Color(0xFF0F5C45),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            block.title,
            style: serif(
              fontSize: 22.0,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F5C45),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            block.subtitle,
            style: sans(
              fontSize: 13.0,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2D4A40),
            ),
          ),
        ],
      ),
    );
  }
}

class _PoseCard extends StatefulWidget {
  const _PoseCard({
    required this.pose,
    required this.sans,
    required this.serif,
  });

  final _YogaPose pose;
  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
    FontStyle? fontStyle,
    double? height,
  }) sans;
  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
  }) serif;

  @override
  State<_PoseCard> createState() => _PoseCardState();
}

class _PoseCardState extends State<_PoseCard> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    final p = widget.pose;
    final sans = widget.sans;
    final serif = widget.serif;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: () => setState(() => _open = !_open),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8E0E4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8F2EA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(p.emoji, style: const TextStyle(fontSize: 26.0)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.title,
                            style: serif(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2D2A32),
                            ),
                          ),
                          Text(
                            p.sanskrit,
                            style: GoogleFonts.fraunces(
                              fontSize: 13.0,
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFF6B6570),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD8F2EA),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 14,
                                      color: _YogaExerciseScreenState._teal,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      p.duration,
                                      style: sans(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w700,
                                        color: _YogaExerciseScreenState._teal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                p.focus,
                                style: sans(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6B6570),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _open
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF6B6570),
                    ),
                  ],
                ),
              ),
              if (_open) ...[
                const Divider(height: 1, color: Color(0xFFF0E8EC)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                  child: Column(
                    children: p.steps.asMap().entries.map((e) {
                      final n = e.key + 1;
                      final s = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1A8C6A),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$n',
                                style: sans(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                s,
                                style: sans(
                                  fontSize: 14.0,
                                  height: 1.4,
                                  color: const Color(0xFF2D2A32),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE8DC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: Colors.brown.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            p.caution,
                            style: sans(
                              fontSize: 13.0,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7A4A32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TrimesterBlock {
  const _TrimesterBlock({
    required this.tabLabel,
    required this.kicker,
    required this.title,
    required this.subtitle,
    required this.poses,
  });

  final String tabLabel;
  final String kicker;
  final String title;
  final String subtitle;
  final List<_YogaPose> poses;
}

class _YogaPose {
  const _YogaPose({
    required this.emoji,
    required this.title,
    required this.sanskrit,
    required this.duration,
    required this.focus,
    required this.steps,
    required this.caution,
  });

  final String emoji;
  final String title;
  final String sanskrit;
  final String duration;
  final String focus;
  final List<String> steps;
  final String caution;
}
