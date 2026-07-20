import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeekGuideScreen extends StatefulWidget {
  const WeekGuideScreen({super.key});

  @override
  State<WeekGuideScreen> createState() => _WeekGuideScreenState();
}

class _WeekGuideScreenState extends State<WeekGuideScreen>
    with SingleTickerProviderStateMixin {
  int _currentWeek = 24;
  late TabController _tabController;

  static const _totalWeeks = 40;

  static const _weekData = <int, _WeekInfo>{
    24: _WeekInfo(
      fruit: 'Corn on the cob',
      emoji: '🌽',
      length: '30 cm',
      weight: '600g',
      development: [
        'Inner ear is fully formed — baby can now hear sounds from outside the womb',
        'Lungs are developing rapidly, practicing breathing movements with amniotic fluid',
        'Brain is growing at a rapid pace — billions of neurons forming',
        'Eyelids are almost fully formed and baby may soon open her eyes',
      ],
      symptoms: [
        'Back pain as your centre of gravity shifts',
        'Braxton Hicks contractions — mild, irregular tightenings',
        'Swollen feet and ankles in the evenings',
        'Heartburn and indigestion after meals',
      ],
      bodyChanges: [
        'Uterus is now about the size of a soccer ball, just above your navel',
        'Braxton Hicks contractions may begin — mild, irregular tightenings',
        'Back pain and round ligament pain may increase as bump grows',
      ],
      tips: [
        'Sleep on your left side to improve blood flow to baby',
        'Do gentle prenatal yoga or stretches for back relief',
        'Stay hydrated — aim for 8–10 glasses of water daily',
        'Track baby movements — you should feel at least 10 kicks in 2 hours',
      ],
      dos: [
        'Take your iron and folic acid supplements daily',
        'Eat small frequent meals to ease heartburn',
        'Wear comfortable, supportive footwear',
        'Attend your 24-week antenatal checkup',
      ],
      donts: [
        'Avoid sleeping flat on your back for long periods',
        'Don\'t lift heavy objects without support',
        'Avoid raw or undercooked foods',
        'Don\'t ignore severe swelling or headaches',
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _WeekInfo get _info =>
      _weekData[_currentWeek] ?? _weekData[24]!;

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    final serif = GoogleFonts.fraunces;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FC),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {},
        ),
        title: Text(
          'Week Guide',
          style: sans(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _WeekCard(
            week: _currentWeek,
            info: _info,
            onPrev: _currentWeek > 1
                ? () => setState(() => _currentWeek--)
                : null,
            onNext: _currentWeek < _totalWeeks
                ? () => setState(() => _currentWeek++)
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
                  items: _info.development,
                  dotColor: const Color(0xFF4A9FE8),
                  bodyHeader: 'Your body this week',
                  bodyItems: _info.bodyChanges,
                  bodyDotColor: const Color(0xFF9ED47A),
                ),
                _BulletSection(
                  header: 'Symptoms this week',
                  items: _info.symptoms,
                  dotColor: const Color(0xFFE88A4A),
                ),
                _BulletSection(
                  header: 'Tips for week $_currentWeek',
                  items: _info.tips,
                  dotColor: const Color(0xFFB48AE8),
                ),
                _DosDontsTab(dos: _info.dos, donts: _info.donts),
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
  final _WeekInfo info;
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
          // Prev / Next chevrons
          Positioned(
            left: 6,
            top: 0,
            bottom: 0,
            child: Center(
              child: _NavChevron(
                icon: Icons.chevron_left,
                onTap: onPrev,
              ),
            ),
          ),
          Positioned(
            right: 6,
            top: 0,
            bottom: 0,
            child: Center(
              child: _NavChevron(
                icon: Icons.chevron_right,
                onTap: onNext,
              ),
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
          color: Colors.white.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
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

// ── Data model ────────────────────────────────────────────────────────────────

class _WeekInfo {
  const _WeekInfo({
    required this.fruit,
    required this.emoji,
    required this.length,
    required this.weight,
    required this.development,
    required this.symptoms,
    required this.bodyChanges,
    required this.tips,
    required this.dos,
    required this.donts,
  });

  final String fruit;
  final String emoji;
  final String length;
  final String weight;
  final List<String> development;
  final List<String> symptoms;
  final List<String> bodyChanges;
  final List<String> tips;
  final List<String> dos;
  final List<String> donts;
}
