import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/pregnancy_progress.dart';
import '../models/week_content.dart';
import '../services/auth_service.dart';
import '../services/user_repository.dart';
import '../services/week_content_repository.dart';

class WeekGuideScreen extends StatefulWidget {
  const WeekGuideScreen({super.key, this.initialWeek});

  /// When null, the screen resolves the current week from the user's LMP.
  final int? initialWeek;

  @override
  State<WeekGuideScreen> createState() => _WeekGuideScreenState();
}

class _WeekGuideScreenState extends State<WeekGuideScreen>
    with SingleTickerProviderStateMixin {
  final _contentRepo = WeekContentRepository();
  final _userRepo = UserRepository();

  late int _currentWeek;
  late WeekContent _content;
  late TabController _tabController;

  static const _totalWeeks = 40;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _currentWeek = widget.initialWeek ?? 24;
    _content = WeekContent.forWeek(_currentWeek);
    _loadContent(_currentWeek);
    if (widget.initialWeek == null) {
      _resolveCurrentWeekFromProfile();
    }
  }

  Future<void> _resolveCurrentWeekFromProfile() async {
    final uid = AuthService().currentUser?.uid;
    if (uid == null) return;
    final profile = await _userRepo.getProfile(uid);
    final progress = PregnancyProgress.fromLmp(profile?.lmp);
    if (progress == null || !mounted) return;
    setState(() => _currentWeek = progress.contentWeek);
    _loadContent(_currentWeek);
  }

  Future<void> _loadContent(int week) async {
    final loaded = await _contentRepo.getWeek(week);
    if (!mounted || loaded.week != _currentWeek) return;
    setState(() => _content = loaded);
  }

  void _goToWeek(int week) {
    setState(() {
      _currentWeek = week;
      _content = WeekContent.forWeek(week);
    });
    _loadContent(week);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    final serif = GoogleFonts.fraunces;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FC),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          'Week Guide',
          style: sans(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: Column(
        children: [
          _WeekCard(
            week: _currentWeek,
            info: _content,
            onPrev: _currentWeek > 1 ? () => _goToWeek(_currentWeek - 1) : null,
            onNext: _currentWeek < _totalWeeks
                ? () => _goToWeek(_currentWeek + 1)
                : null,
            sans: sans,
            serif: serif,
          ),
          const SizedBox(height: 4),
          _TabBar(controller: _tabController, sans: sans),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _BulletSection(
                  header: 'Baby\'s development this week',
                  items: _content.development,
                  dotColor: const Color(0xFF4A9FE8),
                  bodyHeader: 'Your body this week',
                  bodyItems: _content.bodyChanges,
                  bodyDotColor: const Color(0xFF9ED47A),
                ),
                _BulletSection(
                  header: 'Symptoms this week',
                  items: _content.symptoms,
                  dotColor: const Color(0xFFE88A4A),
                ),
                _BulletSection(
                  header: 'Tips for week $_currentWeek',
                  items: _content.tips,
                  dotColor: const Color(0xFFB48AE8),
                ),
                _DosDontsTab(dos: _content.dos, donts: _content.donts),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Week hero card ────────────────────────────────────────────────────────────

class _WeekCard extends StatelessWidget {
  const _WeekCard({
    required this.week,
    required this.info,
    required this.onPrev,
    required this.onNext,
    required this.sans,
    required this.serif,
  });

  final int week;
  final WeekContent info;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color}) sans;
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color, FontStyle? fontStyle}) serif;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5BC4F5), Color(0xFF4499E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Week $week',
                        style: serif(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        info.fruit,
                        style: sans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${info.length} · ${info.weight}',
                        style: sans(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(info.emoji, style: const TextStyle(fontSize: 70)),
              ],
            ),
          ),
          Positioned(
            left: 6,
            top: 0,
            bottom: 0,
            child: Center(
              child: _NavChevron(icon: Icons.chevron_left, onTap: onPrev),
            ),
          ),
          Positioned(
            right: 6,
            top: 0,
            bottom: 0,
            child: Center(
              child: _NavChevron(icon: Icons.chevron_right, onTap: onNext),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavChevron extends StatelessWidget {
  const _NavChevron({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: onTap == null ? 0.1 : 0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: onTap == null ? 0.4 : 1),
          size: 20,
        ),
      ),
    );
  }
}

// ── Tab bar ───────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  const _TabBar({required this.controller, required this.sans});

  final TabController controller;
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color}) sans;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
      indicator: BoxDecoration(
        color: const Color(0xFF3A86D4),
        borderRadius: BorderRadius.circular(20),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      labelColor: Colors.white,
      unselectedLabelColor: const Color(0xFF888888),
      labelStyle: sans(fontWeight: FontWeight.w700, fontSize: 13),
      unselectedLabelStyle: sans(fontWeight: FontWeight.w500, fontSize: 13),
      tabs: const [
        Tab(text: 'Development'),
        Tab(text: 'Symptoms'),
        Tab(text: 'Tips'),
        Tab(text: 'Do\'s & Don\'ts'),
      ],
    );
  }
}

// ── Bullet list section ───────────────────────────────────────────────────────

class _BulletSection extends StatelessWidget {
  const _BulletSection({
    required this.header,
    required this.items,
    required this.dotColor,
    this.bodyHeader,
    this.bodyItems,
    this.bodyDotColor,
  });

  final String header;
  final List<String> items;
  final Color dotColor;
  final String? bodyHeader;
  final List<String>? bodyItems;
  final Color? bodyDotColor;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        Text(
          header,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D2A32),
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((e) => _BulletItem(text: e, dotColor: dotColor)),
        if (bodyHeader != null && bodyItems != null) ...[
          const SizedBox(height: 24),
          Text(
            bodyHeader!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2D2A32),
            ),
          ),
          const SizedBox(height: 12),
          ...bodyItems!.map((e) =>
              _BulletItem(text: e, dotColor: bodyDotColor ?? dotColor)),
        ],
      ],
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text, required this.dotColor});

  final String text;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 10),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF4A4550),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Do's & Don'ts tab ─────────────────────────────────────────────────────────

class _DosDontsTab extends StatelessWidget {
  const _DosDontsTab({required this.dos, required this.donts});

  final List<String> dos;
  final List<String> donts;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        _DosDontsSection(
          title: "Do's",
          items: dos,
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF4CAF6A),
        ),
        const SizedBox(height: 24),
        _DosDontsSection(
          title: "Don'ts",
          items: donts,
          icon: Icons.cancel_rounded,
          color: const Color(0xFFE85A5A),
        ),
      ],
    );
  }
}

class _DosDontsSection extends StatelessWidget {
  const _DosDontsSection({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });

  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D2A32),
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1, right: 10),
                  child: Icon(icon, color: color, size: 18),
                ),
                Expanded(
                  child: Text(
                    e,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: const Color(0xFF4A4550),
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
