import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/pregnancy_progress.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/user_repository.dart';
import 'bmi_weight_screen.dart';
import 'contraction_timer_screen.dart';
import 'hospital_bag_screen.dart';
import 'kick_counter_screen.dart';
import 'medical_records_screen.dart';
import 'music_mantras_screen.dart';
import 'reminders_screen.dart';
import 'week_guide_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FC),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text('Profile',
            style: sans(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: uid == null
          ? const Center(child: Text('Not signed in'))
          : StreamBuilder<UserProfile?>(
              stream: UserRepository().watchProfile(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final profile = snapshot.data;
                final authUser = FirebaseAuth.instance.currentUser;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  children: [
                    _UserCard(
                      sans: sans,
                      name: profile?.fullName ??
                          authUser?.displayName ??
                          'MamaBloom user',
                      initials: profile?.initials ??
                          ((authUser?.displayName?.isNotEmpty ?? false)
                              ? authUser!.displayName![0].toUpperCase()
                              : '?'),
                      edd: profile?.edd,
                      week: profile?.currentWeek,
                      lmp: profile?.lmp,
                      email: profile?.email ?? authUser?.email,
                    ),
                    const SizedBox(height: 28),
                    _SectionHeader('QUICK TOOLS', sans),
                    const SizedBox(height: 14),
                    _QuickToolsGrid(profile: profile),
                    const SizedBox(height: 28),
                    _SectionHeader('SETTINGS & MORE', sans),
                    const SizedBox(height: 10),
                    const _SettingsList(),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () async {
                          await AuthService().signOut();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE04B84),
                          side: const BorderSide(color: Color(0xFFFFD0E0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Sign out',
                          style: sans(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, this.sans);
  final String title;
  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
    double? letterSpacing,
  }) sans;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: sans(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: const Color(0xFF2D2A32),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.sans,
    required this.name,
    required this.initials,
    this.edd,
    this.week,
    this.lmp,
    this.email,
  });

  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color})
      sans;
  final String name;
  final String initials;
  final String? edd;
  final int? week;
  final String? lmp;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[];
    if (edd != null && edd!.isNotEmpty) subtitleParts.add('EDD: $edd');
    if (week != null) subtitleParts.add('Week $week');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEDE7F6), Color(0xFFD8CBF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFB39DDB),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: sans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: sans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2A32),
                  ),
                ),
                if (subtitleParts.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitleParts.join(' · '),
                    style: sans(
                      fontSize: 13,
                      color: const Color(0xFF6B6570),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (lmp != null && lmp!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'LMP: $lmp',
                    style: sans(
                      fontSize: 13,
                      color: const Color(0xFF6B6570),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (email != null && email!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email!,
                    style: sans(
                      fontSize: 12,
                      color: const Color(0xFF9A939E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _QuickTool {
  dueDate,
  contractionTimer,
  kickCounter,
  bmiCheck,
  weightTracker,
  hospitalBag,
}

class _QuickToolsGrid extends StatelessWidget {
  const _QuickToolsGrid({this.profile});

  final UserProfile? profile;

  static const _tools = [
    _ToolItem(_QuickTool.dueDate, '📅', 'Due date'),
    _ToolItem(_QuickTool.contractionTimer, '⏱️', 'Contraction\ntimer'),
    _ToolItem(_QuickTool.kickCounter, '👶', 'Kick counter'),
    _ToolItem(_QuickTool.bmiCheck, '⚖️', 'BMI check'),
    _ToolItem(_QuickTool.weightTracker, '📊', 'Weight\ntracker'),
    _ToolItem(_QuickTool.hospitalBag, '🎒', 'Hospital bag'),
  ];

  void _openTool(BuildContext context, _QuickTool tool) {
    switch (tool) {
      case _QuickTool.dueDate:
        _showDueDateSheet(context, profile);
        return;
      case _QuickTool.contractionTimer:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ContractionTimerScreen(),
          ),
        );
        return;
      case _QuickTool.kickCounter:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const KickCounterScreen(),
          ),
        );
        return;
      case _QuickTool.bmiCheck:
      case _QuickTool.weightTracker:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const BmiWeightScreen(),
          ),
        );
        return;
      case _QuickTool.hospitalBag:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const HospitalBagScreen(),
          ),
        );
        return;
    }
  }

  static String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  static void _showDueDateSheet(BuildContext context, UserProfile? profile) {
    final sans = GoogleFonts.plusJakartaSans;
    final progress = PregnancyProgress.fromLmp(profile?.lmp);
    final eddText = profile?.edd?.trim().isNotEmpty == true
        ? profile!.edd!
        : (progress != null ? _fmtDate(progress.edd) : null);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0DCE4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Due date',
                style: sans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D2A32),
                ),
              ),
              const SizedBox(height: 8),
              if (eddText != null) ...[
                Text(
                  eddText,
                  style: sans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE04B84),
                  ),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    '${progress.daysLeft} days left · ${progress.weekDayLabel}',
                    style: sans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B6570),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    progress.trimesterLabel,
                    style: sans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9A939E),
                    ),
                  ),
                ],
              ] else
                Text(
                  'Add your LMP or EDD in your profile to see your due date.',
                  style: sans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B6570),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const WeekGuideScreen(),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE04B84),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Open weekly guide',
                    style: sans(fontWeight: FontWeight.w700, fontSize: 15),
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
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: _tools
          .map(
            (t) => _ToolCard(
              tool: t,
              onTap: () => _openTool(context, t.id),
            ),
          )
          .toList(),
    );
  }
}

class _ToolItem {
  const _ToolItem(this.id, this.emoji, this.label);
  final _QuickTool id;
  final String emoji;
  final String label;
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool, required this.onTap});
  final _ToolItem tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(tool.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(
                tool.label,
                textAlign: TextAlign.center,
                style: sans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2A32),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsList extends StatelessWidget {
  const _SettingsList();

  static const _items = [
    _SettingItem(
      '🔔',
      'Reminders & notifications',
      'Medicines, water, appointments',
    ),
    _SettingItem(
      '📋',
      'Medical records',
      'Scans, reports, blood work',
    ),
    _SettingItem(
      '🎵',
      'Music & mantras',
      'Relaxation and baby bonding',
    ),
    _SettingItem(
      '🌐',
      'Language',
      'English · Malayalam · Hindi',
    ),
    _SettingItem(
      '📤',
      'Export report (PDF)',
      'Share with your doctor',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(_items.length, (i) {
          return Column(
            children: [
              _SettingRow(item: _items[i]),
              if (i < _items.length - 1)
                const Divider(
                  height: 1,
                  indent: 58,
                  endIndent: 0,
                  color: Color(0xFFF0ECF2),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _SettingItem {
  const _SettingItem(this.emoji, this.title, this.subtitle);
  final String emoji;
  final String title;
  final String subtitle;
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.item});
  final _SettingItem item;

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    return InkWell(
      onTap: () {
        final title = item.title;
        if (title == 'Medical records') {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const MedicalRecordsScreen(),
            ),
          );
        } else if (title == 'Reminders & notifications') {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const RemindersScreen(),
            ),
          );
        } else if (title == 'Music & mantras') {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const MusicMantrasScreen(),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F0F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(item.emoji, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: sans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2A32),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: sans(
                      fontSize: 12,
                      color: const Color(0xFF9A939E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCCC8D0), size: 20),
          ],
        ),
      ),
    );
  }
}
