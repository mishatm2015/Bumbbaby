import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bmi_weight_screen.dart';
import 'kick_counter_screen.dart';
import 'contraction_timer_screen.dart';
import 'hospital_bag_screen.dart';
import 'music_mantras_screen.dart';
import 'reminders_screen.dart';
import 'mood_tracker_screen.dart';
import 'yoga_exercise_screen.dart';
import 'birth_plan_screen.dart';
import 'appointments_screen.dart';
import 'sleep_tracker_screen.dart';
import 'warning_signs_screen.dart';
import 'baby_names_screen.dart';
import 'postpartum_prep_screen.dart';

/// Matches optional named parameters on `GoogleFonts.fraunces` / `GoogleFonts.plusJakartaSans`.
typedef _TextStyleFn = TextStyle Function({
  Paint? background,
  Color? backgroundColor,
  Color? color,
  TextDecoration? decoration,
  Color? decorationColor,
  TextDecorationStyle? decorationStyle,
  double? decorationThickness,
  List<FontFeature>? fontFeatures,
  double? fontSize,
  FontStyle? fontStyle,
  FontWeight? fontWeight,
  Paint? foreground,
  double? height,
  double? letterSpacing,
  Locale? locale,
  List<Shadow>? shadows,
  TextBaseline? textBaseline,
  TextStyle? textStyle,
  double? wordSpacing,
});

/// Home dashboard matching MamaBloom visual design (trimester card, trackers, etc.).
class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  static const _bg = Color(0xFFFDF8FA);
  static const _ink = Color(0xFF2D2A32);
  static const _muted = Color(0xFF6B6570);
  static const _bloom = Color(0xFFC97B9A);
  static const _cardPinkStart = Color(0xFFFFE4EE);
  static const _cardPinkEnd = Color(0xFFF5C6DC);

  @override
  Widget build(BuildContext context) {
    final serif = GoogleFonts.fraunces;
    final sans = GoogleFonts.plusJakartaSans;

    return ColoredBox(
      color: _bg,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
                child: Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        style: sans(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: _ink,
                        ),
                        children: [
                          const TextSpan(text: 'mama'),
                          TextSpan(
                            text: 'bloom',
                            style: serif(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: _bloom,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF8FB4),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        'AN',
                        style: sans(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.more_horiz, color: _muted.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                  _TrimesterHero(serif: serif, sans: sans),
                  const SizedBox(height: 24),
                  _SectionTitle('TODAY\'S SNAPSHOT', sans),
                  const SizedBox(height: 12),
                  _SnapshotRow(sans: sans),
                  const SizedBox(height: 28),
                  _ProgressBlock(serif: serif, sans: sans),
                  const SizedBox(height: 28),
                  _SectionTitle('TODAY\'S UPDATE', sans),
                  const SizedBox(height: 12),
                  _TodayUpdateCard(serif: serif, sans: sans),
                  const SizedBox(height: 28),
                  _SectionTitle('HEALTH TRACKERS', sans),
                  const SizedBox(height: 12),
                  _HealthTrackersGrid(sans: sans),
                  const SizedBox(height: 28),
                  _SectionTitle('PREGNANCY TOOLKIT', sans),
                  const SizedBox(height: 12),
                  _PregnancyToolkitGrid(sans: sans),
                  const SizedBox(height: 28),
                  _SectionTitle('QUICK LINKS', sans),
                  const SizedBox(height: 12),
                  _QuickLinksRow(sans: sans),
                  const SizedBox(height: 28),
                  _SectionTitle('UPCOMING APPOINTMENTS', sans),
                  const SizedBox(height: 12),
                  _AppointmentTile(
                    sans: sans,
                    dayMonth: '28',
                    month: 'MAR',
                    title: 'Anomaly Scan',
                    subtitle: 'Dr. Priya Nair — Amrita Hospital',
                    time: '10:30 AM',
                  ),
                  const SizedBox(height: 10),
                  _AppointmentTile(
                    sans: sans,
                    dayMonth: '4',
                    month: 'APR',
                    title: 'OB-GYN Checkup',
                    subtitle: 'City Women\'s Clinic',
                    time: '11:00 AM',
                  ),
                  const SizedBox(height: 100),
                ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, this.sans);

  final String text;
  final _TextStyleFn sans;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: sans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: DashboardHomeScreen._ink,
      ),
    );
  }
}

class _TrimesterHero extends StatelessWidget {
  const _TrimesterHero({required this.serif, required this.sans});

  final _TextStyleFn serif;
  final _TextStyleFn sans;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DashboardHomeScreen._cardPinkStart,
            DashboardHomeScreen._cardPinkEnd,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: DashboardHomeScreen._bloom.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 18, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEEK 24 · DAY 3',
                  style: sans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: DashboardHomeScreen._muted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Second Trimester',
                  style: serif(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: DashboardHomeScreen._ink,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '168 days down, 112 to go',
                  style: sans(
                    fontSize: 14,
                    color: DashboardHomeScreen._muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroChip('112 Days left', sans),
                    _HeroChip('60% Complete', sans),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('🌽', style: TextStyle(fontSize: 56)),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip(this.label, this.sans);

  final String label;
  final _TextStyleFn sans;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: Text(
        label,
        style: sans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: DashboardHomeScreen._ink,
        ),
      ),
    );
  }
}

class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({required this.sans});

  final _TextStyleFn sans;

  @override
  Widget build(BuildContext context) {
    Widget cell({
      required IconData icon,
      required Color iconBg,
      required String value,
      required String label,
    }) {
      return Expanded(
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconBg, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: sans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DashboardHomeScreen._ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: sans(
                fontSize: 11,
                color: DashboardHomeScreen._muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        cell(
          icon: Icons.water_drop_rounded,
          iconBg: const Color(0xFF4A9FE8),
          value: '1.8L',
          label: 'Water today',
        ),
        cell(
          icon: Icons.medication_liquid_rounded,
          iconBg: const Color(0xFFE85A5A),
          value: '2/3',
          label: 'Meds taken',
        ),
        cell(
          icon: Icons.directions_walk_rounded,
          iconBg: const Color(0xFFFF9B50),
          value: '4,230',
          label: 'Steps',
        ),
      ],
    );
  }
}

class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({required this.serif, required this.sans});

  final _TextStyleFn serif;
  final _TextStyleFn sans;

  @override
  Widget build(BuildContext context) {
    const progress = 0.6;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Pregnancy progress',
              style: serif(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DashboardHomeScreen._ink,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE0EC),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '2nd Trimester',
                style: sans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFC94F7D),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            const markerFrac = 0.58;
            return Column(
              children: [
                SizedBox(
                  height: 28,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: const Color(0xFFF0E8EC),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF7BAC),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: w * markerFrac - 6,
                        top: 0,
                        child: const Icon(
                          Icons.arrow_drop_up,
                          size: 28,
                          color: Color(0xFFFF5A9A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Week 1',
                      style: sans(
                        fontSize: 11,
                        color: DashboardHomeScreen._muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Wk 24',
                      style: sans(
                        fontSize: 11,
                        color: const Color(0xFFE04B84),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Week 40',
                      style: sans(
                        fontSize: 11,
                        color: DashboardHomeScreen._muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TodayUpdateCard extends StatelessWidget {
  const _TodayUpdateCard({required this.serif, required this.sans});

  final _TextStyleFn serif;
  final _TextStyleFn sans;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD6E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Day 168 — Corn size',
                    style: sans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: DashboardHomeScreen._muted,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, color: DashboardHomeScreen._muted.withValues(alpha: 0.5)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Baby can now hear your voice',
                  style: serif(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: DashboardHomeScreen._ink,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your baby\'s ears are maturing and they may start responding '
                  'to familiar sounds. Keep talking, singing, and reading—it all '
                  'helps their growing brain make sense of the world.',
                  style: sans(
                    fontSize: 13,
                    height: 1.45,
                    color: DashboardHomeScreen._muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFFD0E0),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(19)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _UpdateFoot(Icons.psychology_alt_outlined, 'Brain development', sans),
                _UpdateFoot(Icons.hearing_outlined, 'Hearing active', sans),
                _UpdateFoot(Icons.air, 'Lungs forming', sans),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateFoot extends StatelessWidget {
  const _UpdateFoot(this.icon, this.label, this.sans);

  final IconData icon;
  final String label;
  final _TextStyleFn sans;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF8E3D5C)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: sans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6B2F45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthTrackersGrid extends StatelessWidget {
  const _HealthTrackersGrid({required this.sans});

  final _TextStyleFn sans;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _TrackerCard(
                  sans: sans,
                  icon: Icons.water_drop_rounded,
                iconColor: const Color(0xFF4A9FE8),
                title: 'Water intake',
                subtitle: '1.8 / 3L today',
                status: '60%',
                lineColor: const Color(0xFF4A9FE8),
                progress: 0.6,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TrackerCard(
                sans: sans,
                icon: Icons.medication_rounded,
                iconColor: const Color(0xFF4CAF6A),
                title: 'Medicine',
                subtitle: '2 of 3 taken',
                status: '67%',
                lineColor: const Color(0xFF4CAF6A),
                progress: 0.67,
              ),
            ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _TrackerCard(
                  sans: sans,
                  icon: Icons.monitor_weight_outlined,
                iconColor: const Color(0xFFB88A6A),
                title: 'Weight',
                subtitle: '+7.2kg gained',
                status: 'On track',
                lineColor: const Color(0xFFB88A6A),
                progress: 0.72,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BmiWeightScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TrackerCard(
                sans: sans,
                icon: Icons.sentiment_satisfied_alt_rounded,
                iconColor: const Color(0xFF9B7ED9),
                title: 'Mood log',
                subtitle: 'Feeling calm',
                status: 'Good',
                lineColor: const Color(0xFF9B7ED9),
                progress: 0.85,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MoodTrackerScreen()),
                ),
              ),
            ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _TrackerCard(
                  sans: sans,
                  icon: Icons.child_friendly_rounded,
                iconColor: const Color(0xFFE04B84),
                title: 'Kick counter',
                subtitle: '0 kicks today',
                status: 'Log now',
                lineColor: const Color(0xFFE04B84),
                progress: 0.0,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const KickCounterScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TrackerCard(
                sans: sans,
                icon: Icons.timer_outlined,
                iconColor: const Color(0xFF1A8C6A),
                title: 'Contractions',
                subtitle: 'Tap to start timer',
                status: 'Ready',
                lineColor: const Color(0xFF1A8C6A),
                progress: 0.0,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ContractionTimerScreen()),
                ),
              ),
            ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrackerCard extends StatelessWidget {
  const _TrackerCard({
    required this.sans,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.lineColor,
    required this.progress,
    this.onTap,
  });

  final _TextStyleFn sans;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String status;
  final Color lineColor;
  final double progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: iconColor, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: sans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: DashboardHomeScreen._ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: sans(
                                  fontSize: 11,
                                  color: DashboardHomeScreen._muted,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          status,
                          style: sans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: DashboardHomeScreen._muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 4,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const ColoredBox(color: Color(0xFFF4EDF1)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: progress.clamp(0.0, 1.0),
                          heightFactor: 1,
                          child: ColoredBox(color: lineColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({
    required this.sans,
    required this.dayMonth,
    required this.month,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final _TextStyleFn sans;
  final String dayMonth;
  final String month;
  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0E6EA)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE0EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayMonth,
                  style: sans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFD94A7A),
                    height: 1,
                  ),
                ),
                Text(
                  month,
                  style: sans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC94F7D),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: sans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: DashboardHomeScreen._ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: sans(
                    fontSize: 12,
                    color: DashboardHomeScreen._muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: sans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: DashboardHomeScreen._muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PregnancyToolkitGrid extends StatelessWidget {
  const _PregnancyToolkitGrid({required this.sans});

  final _TextStyleFn sans;

  @override
  Widget build(BuildContext context) {
    Widget cell({required String emoji, required String label, required VoidCallback onTap}) {
      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withValues(alpha: 0.85), width: 2),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 30)),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: sans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: DashboardHomeScreen._ink,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: cell(
                emoji: '📋',
                label: 'Birth plan',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const BirthPlanScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: cell(
                emoji: '📅',
                label: 'Appointments',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AppointmentsScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: cell(
                emoji: '🌙',
                label: 'Sleep tracker',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SleepTrackerScreen()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: cell(
                emoji: '🚨',
                label: 'Warning signs',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const WarningSignsScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: cell(
                emoji: '✨',
                label: 'Baby names',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const BabyNamesScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: cell(
                emoji: '🤱',
                label: 'Postpartum prep',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const PostpartumPrepScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickLinksRow extends StatelessWidget {
  const _QuickLinksRow({required this.sans});

  final _TextStyleFn sans;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickLinkCard(
                sans: sans,
                emoji: '🧳',
                label: 'Hospital\nBag',
                bg: const Color(0xFFE6F7F2),
                fgColor: const Color(0xFF1A8C6A),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HospitalBagScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickLinkCard(
                sans: sans,
                emoji: '🎵',
                label: 'Music &\nMantras',
                bg: const Color(0xFFFFE4EE),
                fgColor: const Color(0xFFE04B84),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MusicMantrasScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickLinkCard(
                sans: sans,
                emoji: '🔔',
                label: 'Reminders',
                bg: const Color(0xFFEEF0FC),
                fgColor: const Color(0xFF5B6EE8),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RemindersScreen()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickLinkCard(
                sans: sans,
                emoji: '🧘',
                label: 'Yoga &\nExercise',
                bg: const Color(0xFFD8F2EA),
                fgColor: const Color(0xFF1A8C6A),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const YogaExerciseScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  const _QuickLinkCard({
    required this.sans,
    required this.emoji,
    required this.label,
    required this.bg,
    required this.fgColor,
    required this.onTap,
  });

  final _TextStyleFn sans;
  final String emoji;
  final String label;
  final Color bg;
  final Color fgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: sans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: fgColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
