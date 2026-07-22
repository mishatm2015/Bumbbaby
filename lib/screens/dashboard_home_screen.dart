import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/hydration.dart';
import '../models/pregnancy_progress.dart';
import '../models/step_goal.dart';
import '../models/user_profile.dart';
import '../models/week_content.dart';
import '../services/hydration_service.dart';
import '../services/step_service.dart';
import '../services/user_repository.dart';
import '../services/week_content_repository.dart';
import 'step_counter_screen.dart';
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
import 'water_intake_screen.dart';
import 'medicine_screen.dart';
import 'week_guide_screen.dart';
import '../models/medicine.dart';
import '../models/weight_entry.dart';
import '../models/kick_session.dart';
import '../services/medicine_service.dart';
import '../services/weight_service.dart';
import '../services/kick_service.dart';

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

/// Home dashboard. Week, day, trimester, progress and the weekly "fruit"
/// are all computed from the user's LMP stored in Firestore.
class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  static const _bg = Color(0xFFFDF8FA);
  static const _ink = Color(0xFF2D2A32);
  static const _muted = Color(0xFF6B6570);
  static const _bloom = Color(0xFFC97B9A);
  static const _cardPinkStart = Color(0xFFFFE4EE);
  static const _cardPinkEnd = Color(0xFFF5C6DC);

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  final _userRepo = UserRepository();
  final _contentRepo = WeekContentRepository();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return ColoredBox(
      color: DashboardHomeScreen._bg,
      child: SafeArea(
        bottom: false,
        child: uid == null
            ? _buildBody(context, null, null, null)
            : StreamBuilder<UserProfile?>(
                stream: _userRepo.watchProfile(uid),
                builder: (context, snapshot) {
                  final profile = snapshot.data;
                  final progress = PregnancyProgress.fromLmp(profile?.lmp);
                  final week = progress?.contentWeek ?? 1;
                  return FutureBuilder<WeekContent>(
                    future: _contentRepo.getWeek(week),
                    builder: (context, contentSnap) {
                      final content =
                          contentSnap.data ?? WeekContent.forWeek(week);
                      return _buildBody(context, profile, progress, content);
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    UserProfile? profile,
    PregnancyProgress? progress,
    WeekContent? content,
  ) {
    final serif = GoogleFonts.fraunces;
    final sans = GoogleFonts.plusJakartaSans;
    final wc = content ?? WeekContent.forWeek(progress?.contentWeek ?? 1);
    final trimester = progress?.trimester ?? 1;
    final hydrationGoal = HydrationGoal.compute(
      weightKg: HydrationGoal.parseWeightKg(profile?.prePregnancyWeight),
      trimester: trimester,
    );
    final stepGoal = StepGoal.compute(trimester: trimester);

    void openWeekGuide() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => WeekGuideScreen(initialWeek: progress?.contentWeek),
        ),
      );
    }

    Future<void> openWater() async {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => WaterIntakeScreen(goal: hydrationGoal),
        ),
      );
      if (mounted) setState(() {}); // refresh water totals after logging
    }

    Future<void> openSteps() async {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => StepCounterScreen(
            goal: stepGoal,
            trimester: trimester,
          ),
        ),
      );
      if (mounted) setState(() {}); // refresh step total after tracking
    }

    Future<void> openMeds() async {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const MedicineScreen()),
      );
      if (mounted) setState(() {}); // refresh medicine counts after logging
    }

    Future<void> openWeight() async {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const BmiWeightScreen()),
      );
      if (mounted) setState(() {}); // refresh weight card after logging
    }

    Future<void> openKick() async {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const KickCounterScreen()),
      );
      if (mounted) setState(() {}); // refresh kick card after logging
    }

    final preWeightKg =
        HydrationGoal.parseWeightKg(profile?.prePregnancyWeight);

    return CustomScrollView(
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
                      color: DashboardHomeScreen._ink,
                    ),
                    children: [
                      const TextSpan(text: 'mama'),
                      TextSpan(
                        text: 'bloom',
                        style: serif(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: DashboardHomeScreen._bloom,
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
                    profile?.initials ?? 'MB',
                    style: sans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_horiz,
                      color: DashboardHomeScreen._muted.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            if (progress == null)
              _SetLmpBanner(sans: sans)
            else
              _TrimesterHero(
                serif: serif,
                sans: sans,
                progress: progress,
                content: wc,
                onTap: openWeekGuide,
              ),
            const SizedBox(height: 24),
            _SectionTitle('TODAY\'S SNAPSHOT', sans),
            const SizedBox(height: 12),
            _SnapshotRow(
              sans: sans,
              hydrationGoal: hydrationGoal,
              stepGoal: stepGoal,
              onWaterTap: openWater,
              onStepsTap: openSteps,
            ),
            const SizedBox(height: 28),
            if (progress != null) ...[
              _ProgressBlock(serif: serif, sans: sans, progress: progress),
              const SizedBox(height: 28),
            ],
            _SectionTitle('TODAY\'S UPDATE', sans),
            const SizedBox(height: 12),
            _TodayUpdateCard(
              serif: serif,
              sans: sans,
              content: wc,
              progress: progress,
              onTap: openWeekGuide,
            ),
            const SizedBox(height: 28),
            _SectionTitle('HEALTH TRACKERS', sans),
            const SizedBox(height: 12),
            _HealthTrackersGrid(
              sans: sans,
              hydrationGoal: hydrationGoal,
              onWaterTap: openWater,
              onMedsTap: openMeds,
              onWeightTap: openWeight,
              onKickTap: openKick,
              preWeightKg: preWeightKg,
            ),
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
    );
  }
}

/// Formats an integer step count with thousands separators (e.g. 4230 -> "4,230").
String _formatSteps(int steps) {
  final s = steps.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
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

/// Shown when the user has no valid LMP date yet.
class _SetLmpBanner extends StatelessWidget {
  const _SetLmpBanner({required this.sans});

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
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🌸', style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'Welcome to MamaBloom',
            style: sans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: DashboardHomeScreen._ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add your last menstrual period (LMP) date to your profile to see '
            'your pregnancy week, trimester and how your baby is growing.',
            style: sans(
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: DashboardHomeScreen._muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrimesterHero extends StatelessWidget {
  const _TrimesterHero({
    required this.serif,
    required this.sans,
    required this.progress,
    required this.content,
    required this.onTap,
  });

  final _TextStyleFn serif;
  final _TextStyleFn sans;
  final PregnancyProgress progress;
  final WeekContent content;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
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
                      progress.weekDayLabel,
                      style: sans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: DashboardHomeScreen._muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      progress.trimesterLabel,
                      style: serif(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: DashboardHomeScreen._ink,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      progress.countdownLabel,
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
                        _HeroChip('${progress.daysLeft} Days left', sans),
                        _HeroChip('${progress.percent.round()}% Complete', sans),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Text(content.emoji, style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 78,
                    child: Text(
                      content.fruit,
                      textAlign: TextAlign.center,
                      style: sans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: DashboardHomeScreen._ink,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
  const _SnapshotRow({
    required this.sans,
    required this.hydrationGoal,
    required this.stepGoal,
    required this.onWaterTap,
    required this.onStepsTap,
  });

  final _TextStyleFn sans;
  final HydrationGoal hydrationGoal;
  final StepGoal stepGoal;
  final VoidCallback onWaterTap;
  final VoidCallback onStepsTap;

  Widget _cell({
    required IconData icon,
    required Color iconBg,
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FutureBuilder<int>(
          future: HydrationService.getTodayCups(),
          builder: (context, snap) {
            final cups = snap.data ?? 0;
            final litres = cups * HydrationGoal.cupLitres;
            return _cell(
              icon: Icons.water_drop_rounded,
              iconBg: const Color(0xFF4A9FE8),
              value: '${litres.toStringAsFixed(1)}L',
              label: 'of ${hydrationGoal.litres.toStringAsFixed(1)}L water',
              onTap: onWaterTap,
            );
          },
        ),
        _cell(
          icon: Icons.medication_liquid_rounded,
          iconBg: const Color(0xFFE85A5A),
          value: '2/3',
          label: 'Meds taken',
        ),
        FutureBuilder<int>(
          future: StepService.getTodaySteps(),
          builder: (context, snap) {
            final steps = snap.data ?? 0;
            return _cell(
              icon: Icons.directions_walk_rounded,
              iconBg: const Color(0xFFFF9B50),
              value: _formatSteps(steps),
              label: 'of ${_formatSteps(stepGoal.steps)} steps',
              onTap: onStepsTap,
            );
          },
        ),
      ],
    );
  }
}

class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({
    required this.serif,
    required this.sans,
    required this.progress,
  });

  final _TextStyleFn serif;
  final _TextStyleFn sans;
  final PregnancyProgress progress;

  @override
  Widget build(BuildContext context) {
    final fraction = progress.fraction;
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
                progress.trimesterShort,
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
            final markerFrac = fraction.clamp(0.0, 1.0);
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
                            value: fraction,
                            minHeight: 10,
                            backgroundColor: const Color(0xFFF0E8EC),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF7BAC),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: (w * markerFrac - 6).clamp(0.0, w - 12),
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
                      'Wk ${progress.weeks}',
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
  const _TodayUpdateCard({
    required this.serif,
    required this.sans,
    required this.content,
    required this.progress,
    required this.onTap,
  });

  final _TextStyleFn serif;
  final _TextStyleFn sans;
  final WeekContent content;
  final PregnancyProgress? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final badge = progress != null
        ? 'Day ${progress!.daysElapsed} — ${content.fruit} size'
        : '${content.fruit} size';
    final highlights = content.development.take(3).toList();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
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
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: sans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: DashboardHomeScreen._muted,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(content.emoji, style: const TextStyle(fontSize: 22)),
                    Icon(Icons.chevron_right,
                        color:
                            DashboardHomeScreen._muted.withValues(alpha: 0.5)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your baby is the size of ${_lower(content.fruit)}',
                      style: serif(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: DashboardHomeScreen._ink,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      content.summary,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD0E0),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(19)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...highlights.map(
                      (h) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2, right: 8),
                              child: Icon(Icons.auto_awesome,
                                  size: 14, color: Color(0xFF8E3D5C)),
                            ),
                            Expanded(
                              child: Text(
                                h,
                                style: sans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6B2F45),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to view the full week ${content.week} guide →',
                      style: sans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF8E3D5C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _lower(String fruit) {
    if (fruit.isEmpty) return fruit;
    final f = fruit.toLowerCase();
    final article = 'aeiou'.contains(f[0]) ? 'an' : 'a';
    return '$article $f';
  }
}

class _HealthTrackersGrid extends StatelessWidget {
  const _HealthTrackersGrid({
    required this.sans,
    required this.hydrationGoal,
    required this.onWaterTap,
    required this.onMedsTap,
    required this.onWeightTap,
    required this.onKickTap,
    required this.preWeightKg,
  });

  final _TextStyleFn sans;
  final HydrationGoal hydrationGoal;
  final VoidCallback onWaterTap;
  final VoidCallback onMedsTap;
  final VoidCallback onWeightTap;
  final VoidCallback onKickTap;
  final double? preWeightKg;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: FutureBuilder<int>(
                  future: HydrationService.getTodayCups(),
                  builder: (context, snap) {
                    final cups = snap.data ?? 0;
                    final litres = cups * HydrationGoal.cupLitres;
                    final goalL = hydrationGoal.litres;
                    final frac = goalL == 0 ? 0.0 : (litres / goalL);
                    return _TrackerCard(
                      sans: sans,
                      icon: Icons.water_drop_rounded,
                      iconColor: const Color(0xFF4A9FE8),
                      title: 'Water intake',
                      subtitle:
                          '${litres.toStringAsFixed(1)} / ${goalL.toStringAsFixed(1)}L today',
                      status: '${(frac * 100).clamp(0, 100).round()}%',
                      lineColor: const Color(0xFF4A9FE8),
                      progress: frac.clamp(0.0, 1.0),
                      onTap: onWaterTap,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FutureBuilder<List<Object>>(
                  future: Future.wait([
                    MedicineService.getMedicines(),
                    MedicineService.getTodayTaken(),
                  ]),
                  builder: (context, snap) {
                    final meds =
                        (snap.data?[0] as List<Medicine>?) ?? const <Medicine>[];
                    final taken =
                        (snap.data?[1] as Set<String>?) ?? const <String>{};
                    final total = meds.length;
                    final done =
                        meds.where((m) => taken.contains(m.id)).length;
                    final frac = total == 0 ? 0.0 : done / total;
                    return _TrackerCard(
                      sans: sans,
                      icon: Icons.medication_rounded,
                      iconColor: const Color(0xFF4CAF6A),
                      title: 'Medicine',
                      subtitle:
                          total == 0 ? 'Tap to add' : '$done of $total taken',
                      status: '${(frac * 100).round()}%',
                      lineColor: const Color(0xFF4CAF6A),
                      progress: frac,
                      onTap: onMedsTap,
                    );
                  },
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
                child: FutureBuilder<List<WeightEntry>>(
                  future: WeightService.getEntries(),
                  builder: (context, snap) {
                    final entries = snap.data ?? const <WeightEntry>[];
                    final current =
                        entries.isNotEmpty ? entries.last.weightKg : preWeightKg;
                    final gained = (current != null && preWeightKg != null)
                        ? current - preWeightKg!
                        : null;
                    final String subtitle;
                    final String status;
                    if (entries.isEmpty) {
                      subtitle = 'Tap to log';
                      status = 'Start';
                    } else {
                      subtitle = '${current!.toStringAsFixed(1)} kg';
                      status = gained == null
                          ? 'Logged'
                          : '${gained >= 0 ? '+' : ''}${gained.toStringAsFixed(1)}kg';
                    }
                    final progress =
                        gained == null ? 0.0 : (gained / 16).clamp(0.0, 1.0);
                    return _TrackerCard(
                      sans: sans,
                      icon: Icons.monitor_weight_outlined,
                      iconColor: const Color(0xFFB88A6A),
                      title: 'Weight',
                      subtitle: subtitle,
                      status: status,
                      lineColor: const Color(0xFFB88A6A),
                      progress: progress,
                      onTap: onWeightTap,
                    );
                  },
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
                child: FutureBuilder<List<KickSession>>(
                  future: KickService.getSessions(),
                  builder: (context, snap) {
                    final sessions = snap.data ?? const <KickSession>[];
                    final now = DateTime.now();
                    final today = sessions.where((s) =>
                        s.start.year == now.year &&
                        s.start.month == now.month &&
                        s.start.day == now.day);
                    final todayMoves =
                        today.fold<int>(0, (sum, s) => sum + s.count);
                    final hasToday = today.isNotEmpty;
                    return _TrackerCard(
                      sans: sans,
                      icon: Icons.child_friendly_rounded,
                      iconColor: const Color(0xFFE04B84),
                      title: 'Kick counter',
                      subtitle: hasToday
                          ? '$todayMoves moves today'
                          : 'Tap to count',
                      status: hasToday ? 'Logged' : 'Log now',
                      lineColor: const Color(0xFFE04B84),
                      progress: (todayMoves / 10).clamp(0.0, 1.0),
                      onTap: onKickTap,
                    );
                  },
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
                    MaterialPageRoute(
                        builder: (_) => const ContractionTimerScreen()),
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
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: lineColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status,
                                style: sans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: lineColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: sans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: DashboardHomeScreen._ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: sans(
                            fontSize: 11,
                            color: DashboardHomeScreen._muted,
                            fontWeight: FontWeight.w500,
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
    Widget cell(
        {required String emoji,
        required String label,
        required VoidCallback onTap}) {
      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: Colors.black.withValues(alpha: 0.85), width: 2),
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
                  MaterialPageRoute<void>(
                      builder: (_) => const AppointmentsScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: cell(
                emoji: '🌙',
                label: 'Sleep tracker',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => const SleepTrackerScreen()),
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
                  MaterialPageRoute<void>(
                      builder: (_) => const WarningSignsScreen()),
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
                  MaterialPageRoute<void>(
                      builder: (_) => const PostpartumPrepScreen()),
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
