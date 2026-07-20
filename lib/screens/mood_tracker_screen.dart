import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'yoga_exercise_screen.dart';

/// Daily mood log with weekly snapshot and mood-swing support copy.
class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  static const _ink = Color(0xFF2D2A32);
  static const _muted = Color(0xFF6B6570);
  static const _accent = Color(0xFF5B6EE8);
  static const _lavender = Color(0xFFE8E4FA);

  final _noteCtrl = TextEditingController();

  int _moodIndex = 0;

  static const _moods = [
    _MoodOption('😄', 'Joyful'),
    _MoodOption('😊', 'Happy'),
    _MoodOption('😐', 'Neutral'),
    _MoodOption('😴', 'Tired'),
    _MoodOption('😢', 'Sad'),
    _MoodOption('😰', 'Anxious'),
    _MoodOption('😤', 'Irritable'),
  ];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _openYoga() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const YogaExerciseScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    final serif = GoogleFonts.fraunces;

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
          'Mood Tracker',
          style: sans(
            fontWeight: FontWeight.w700,
            fontSize: 17.0,
            color: _ink,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History coming soon')),
              );
            },
            child: Text(
              'History',
              style: sans(
                fontWeight: FontWeight.w700,
                fontSize: 14.0,
                color: _accent,
              ),
            ),
          ),
          TextButton(
            onPressed: _openYoga,
            child: Text(
              'Exercise',
              style: sans(
                fontWeight: FontWeight.w700,
                fontSize: 14.0,
                color: const Color(0xFF1A8C6A),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        children: [
          _MoodHeroCard(sans: sans, serif: serif),
          const SizedBox(height: 24),
          Text(
            'HOW ARE YOU FEELING NOW?',
            style: serif(
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: _ink,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _moods.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final m = _moods[i];
                final sel = i == _moodIndex;
                return GestureDetector(
                  onTap: () => setState(() => _moodIndex = i),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: sel ? _lavender : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: sel ? _accent : const Color(0xFFE8E0E4),
                            width: sel ? 2 : 1,
                          ),
                        ),
                        child: Text(m.emoji, style: const TextStyle(fontSize: 28.0)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        m.label,
                        style: sans(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          color: sel ? _accent : _muted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'ADD A NOTE (OPTIONAL)',
            style: serif(
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: _ink,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _noteCtrl,
            maxLines: 4,
            style: sans(fontSize: 14.0, color: _ink),
            decoration: InputDecoration(
              hintText:
                  'What\'s on your mind today? Any symptoms, thoughts, or moments you want to remember...',
              hintStyle: sans(fontSize: 13.0, color: _muted.withValues(alpha: 0.75)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE8E0E4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE8E0E4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _accent, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Saved: ${_moods[_moodIndex].label}',
                      style: sans(fontSize: 14.0),
                    ),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Save today\'s mood ✓',
                style: sans(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Text(
                  'THIS WEEK\'S MOOD',
                  style: serif(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: _ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly mood pattern',
                style: sans(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
              Text(
                'Last 7 days',
                style: sans(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: _muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _WeekMoodRow(sans: sans),
          const SizedBox(height: 20),
          _MoodSwingsCard(
            sans: sans,
            serif: serif,
            onExerciseTap: _openYoga,
          ),
          const SizedBox(height: 24),
          Text(
            'RECENT MOOD LOG',
            style: serif(
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: _ink,
            ),
          ),
          const SizedBox(height: 12),
          _RecentLogTile(
            sans: sans,
            serif: serif,
            emoji: '😊',
            title: 'Happy',
            detail: 'Baby kicked 10 times! Feeling great.',
            when: 'Today, 2:30 PM',
          ),
          const SizedBox(height: 10),
          _RecentLogTile(
            sans: sans,
            serif: serif,
            emoji: '😴',
            title: 'Tired',
            detail: 'Couldn\'t sleep well last night.',
            when: 'Today, 9:00 AM',
          ),
          const SizedBox(height: 10),
          _RecentLogTile(
            sans: sans,
            serif: serif,
            emoji: '😰',
            title: 'Anxious',
            detail: 'Worried about scan results.',
            when: 'Yesterday',
          ),
        ],
      ),
    );
  }
}

class _MoodOption {
  const _MoodOption(this.emoji, this.label);
  final String emoji;
  final String label;
}

class _MoodHeroCard extends StatelessWidget {
  const _MoodHeroCard({required this.sans, required this.serif});

  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E4FA),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW ARE YOU FEELING?',
            style: sans(
              fontSize: 11.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: _MoodTrackerScreenState._accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log your mood',
            style: serif(
              fontSize: 26.0,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E1A2E),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Hormones are real — your feelings matter 💜',
            style: serif(
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF5B4D8A),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekMoodRow extends StatelessWidget {
  const _WeekMoodRow({required this.sans});

  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
  }) sans;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _emojis = ['😊', '😴', '😐', '😢', '😰', '😄', '😁'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        return Column(
          children: [
            Text(_emojis[i], style: const TextStyle(fontSize: 26.0)),
            const SizedBox(height: 4),
            Text(
              _days[i],
              style: sans(
                fontSize: 10.0,
                fontWeight: FontWeight.w700,
                color: _MoodTrackerScreenState._muted,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _MoodSwingsCard extends StatelessWidget {
  const _MoodSwingsCard({
    required this.sans,
    required this.serif,
    required this.onExerciseTap,
  });

  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
    double? height,
  }) sans;
  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
    double? height,
  }) serif;
  final VoidCallback onExerciseTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD4C9F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💜', style: TextStyle(fontSize: 18.0)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'It\'s normal to feel this way',
                  style: sans(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4A56A8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Mood swings in pregnancy are caused by hormonal changes '
            '(oestrogen and progesterone surging). You\'re not alone — talk to '
            'your doctor if feelings become overwhelming.',
            style: sans(
              fontSize: 13.0,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF5B5F8A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Gentle movement, breath, and light stretching can steady your '
            'nervous system and lift your mood. Trimester-safe ideas are a tap away.',
            style: sans(
              fontSize: 13.0,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF5B5F8A),
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onExerciseTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.self_improvement_rounded,
                    size: 22,
                    color: const Color(0xFF1A8C6A),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Yoga & Exercise',
                    style: serif(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A8C6A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: const Color(0xFF1A8C6A),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentLogTile extends StatelessWidget {
  const _RecentLogTile({
    required this.sans,
    required this.serif,
    required this.emoji,
    required this.title,
    required this.detail,
    required this.when,
  });

  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
    double? height,
  }) sans;
  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
  }) serif;
  final String emoji;
  final String title;
  final String detail;
  final String when;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E0E4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28.0)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: serif(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: _MoodTrackerScreenState._ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: sans(
                    fontSize: 13.0,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: _MoodTrackerScreenState._muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            when,
            style: sans(
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              color: _MoodTrackerScreenState._muted,
            ),
          ),
        ],
      ),
    );
  }
}
