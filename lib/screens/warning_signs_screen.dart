import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Severity: normal (green), warning (amber), emergency (red).
enum _Severity { normal, warning, emergency }

class _Bullet {
  const _Bullet(this.text, {this.detail});
  final String text;
  final String? detail;
}

class _Section {
  const _Section({
    required this.title,
    required this.severity,
    required this.items,
  });
  final String title;
  final _Severity severity;
  final List<_Bullet> items;
}

class _TrimesterData {
  const _TrimesterData({
    required this.label,
    required this.weeks,
    required this.blurb,
    required this.sections,
  });
  final String label;
  final String weeks;
  final String blurb;
  final List<_Section> sections;
}

/// Comprehensive trimester warning signs with color-coded severity.
class WarningSignsScreen extends StatefulWidget {
  const WarningSignsScreen({super.key});

  @override
  State<WarningSignsScreen> createState() => _WarningSignsScreenState();
}

class _WarningSignsScreenState extends State<WarningSignsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  static const _anyTimeEmergency = [
    _Bullet('Heavy vaginal bleeding or passing large clots'),
    _Bullet('Severe abdominal pain'),
    _Bullet('No fetal movement or a sudden big drop in movement'),
    _Bullet('Seizures, confusion, or trouble speaking'),
    _Bullet('Severe shortness of breath, blue lips, or chest pain'),
    _Bullet('Severe headache with vision changes'),
    _Bullet('Swollen face/hands with headache or vision changes'),
    _Bullet('High fever with chills'),
    _Bullet('Loss of consciousness or collapse'),
    _Bullet('Umbilical cord visible after waters break'),
    _Bullet('Green amniotic fluid with reduced baby movement'),
    _Bullet('Thoughts of harming yourself — seek help now'),
  ];

  static const _trimesters = [
    _TrimesterData(
      label: '1st',
      weeks: 'Weeks 1–13',
      blurb:
          'Organs are forming. Mild symptoms are common — know when pain, bleeding, or dehydration need care.',
      sections: [
        _Section(
          title: 'Normal symptoms',
          severity: _Severity.normal,
          items: [
            _Bullet('Missed period, implantation spotting (light pink/brown)'),
            _Bullet('Mild cramping, breast tenderness, enlarged breasts'),
            _Bullet('Darkening of nipples, morning sickness / day-long nausea'),
            _Bullet('Vomiting, increased saliva, fatigue, frequent urination'),
            _Bullet('Bloating, constipation, food cravings or aversions'),
            _Bullet('Metallic taste, mild headaches, mood swings, acne'),
            _Bullet('Mild dizziness, clear/white vaginal discharge'),
          ],
        ),
        _Section(
          title: 'Warning — contact your doctor',
          severity: _Severity.warning,
          items: [
            _Bullet('Heavy bleeding, bright red bleeding, or passing clots'),
            _Bullet('Bleeding with severe cramps'),
            _Bullet('Severe abdominal pain or one-sided pelvic pain',
                detail: 'May indicate miscarriage or ectopic pregnancy'),
            _Bullet('Severe lower back pain or shoulder-tip pain with bleeding',
                detail: 'Shoulder-tip pain can be an ectopic emergency'),
            _Bullet(
                'Severe nausea/vomiting — cannot eat, drink, or keep water down',
                detail: 'Risk of dehydration (hyperemesis gravidarum)'),
            _Bullet('Fever above 38°C (100.4°F) or chills'),
            _Bullet('Burning while urinating or foul-smelling discharge'),
            _Bullet('Severe dizziness, fainting, vision problems, fast heartbeat'),
          ],
        ),
        _Section(
          title: 'Emergency — go to ED / call now',
          severity: _Severity.emergency,
          items: [
            _Bullet('Heavy bleeding soaking a pad every hour'),
            _Bullet('Severe one-sided pain'),
            _Bullet('Collapse or loss of consciousness'),
            _Bullet('Severe shoulder pain with bleeding'),
            _Bullet('Difficulty breathing or chest pain'),
          ],
        ),
        _Section(
          title: 'Self-care tips',
          severity: _Severity.normal,
          items: [
            _Bullet('Drink plenty of water; eat small, frequent meals'),
            _Bullet('Take prenatal vitamins with folic acid'),
            _Bullet('Rest often; avoid smoking, alcohol, raw meat'),
            _Bullet('Avoid unpasteurized dairy and heavy lifting'),
          ],
        ),
      ],
    ),
    _TrimesterData(
      label: '2nd',
      weeks: 'Weeks 14–27',
      blurb:
          'Often the “golden” trimester — more energy, first kicks. Watch for preterm labor and preeclampsia signs.',
      sections: [
        _Section(
          title: 'Normal symptoms',
          severity: _Severity.normal,
          items: [
            _Bullet('More energy, reduced nausea, baby movements (quickening)'),
            _Bullet('Round ligament pain (sharp, brief groin/side pain)'),
            _Bullet('Mild foot/ankle swelling by evening, back pain, leg cramps'),
            _Bullet('Heartburn, constipation, nosebleeds, bleeding gums'),
            _Bullet('Stretch marks, increased appetite, skin pigmentation'),
            _Bullet('Occasional Braxton Hicks (irregular, fade with rest)'),
          ],
        ),
        _Section(
          title: 'Warning — contact your doctor',
          severity: _Severity.warning,
          items: [
            _Bullet('Baby moves much less, or no movement for several hours',
                detail: 'Once movements are usually regular'),
            _Bullet(
                'Severe headache, blurred vision, flashing lights, swollen face/hands',
                detail: 'Possible preeclampsia'),
            _Bullet('Rapid weight gain in a short time'),
            _Bullet(
                'Regular contractions, pelvic pressure, period-like cramps, or watery discharge before 37 weeks',
                detail: 'Possible preterm labor'),
            _Bullet('Any vaginal bleeding'),
            _Bullet('Unusual discharge — watery, green, or foul-smelling'),
            _Bullet('Fever or burning with urination'),
            _Bullet('Severe abdominal pain or severe upper-right rib pain'),
          ],
        ),
        _Section(
          title: 'Emergency — go to ED / call now',
          severity: _Severity.emergency,
          items: [
            _Bullet('Heavy bleeding'),
            _Bullet('Waters break early'),
            _Bullet('Severe headache with vision loss'),
            _Bullet('Seizures'),
            _Bullet('Difficulty breathing'),
          ],
        ),
        _Section(
          title: 'Self-care tips',
          severity: _Severity.normal,
          items: [
            _Bullet('Sleep on your left side; stay hydrated'),
            _Bullet('Moderate exercise; wear supportive shoes'),
            _Bullet('Eat iron-rich foods; monitor fetal movement'),
          ],
        ),
      ],
    ),
    _TrimesterData(
      label: '3rd',
      weeks: 'Weeks 28–40',
      blurb:
          'Baby gains weight quickly. Track kicks daily. Know labor, preeclampsia, and fluid-leak signs.',
      sections: [
        _Section(
          title: 'Normal symptoms',
          severity: _Severity.normal,
          items: [
            _Bullet('Braxton Hicks (irregular, don’t intensify or get closer)'),
            _Bullet('Pelvic pressure, baby “dropping”, frequent urination'),
            _Bullet('Difficulty sleeping, mild swelling, back pain, heartburn'),
            _Bullet('Shortness of breath, leaking colostrum, nesting instinct'),
            _Bullet('Occasional lightheadedness when standing up quickly'),
          ],
        ),
        _Section(
          title: 'Warning — contact your doctor',
          severity: _Severity.warning,
          items: [
            _Bullet('Significant decrease or no fetal movement',
                detail: 'Do kick counts; call if pattern drops'),
            _Bullet(
                'Regular painful contractions, pelvic pressure, back pain, or fluid leak before 37 weeks'),
            _Bullet(
                'Water breaking — sudden gush or continuous leak; green/brown/foul fluid'),
            _Bullet(
                'Severe headache, vision changes, swollen face/hands, upper abdominal pain',
                detail: 'Preeclampsia risk rises'),
            _Bullet('Intense itching on palms/soles without a rash',
                detail: 'Possible cholestasis'),
            _Bullet('Fever, chills, or burning urination'),
            _Bullet('Heavy bleeding or severe abdominal pain',
                detail: 'Possible placental problem'),
            _Bullet(
                'Labor-like signs before 37 weeks: low back pain, pelvic pressure, period cramps, increased discharge'),
          ],
        ),
        _Section(
          title: 'Emergency — go to ED / call now',
          severity: _Severity.emergency,
          items: [
            _Bullet('Baby stops moving'),
            _Bullet('Heavy bleeding'),
            _Bullet('Seizures, chest pain, severe breathing difficulty'),
            _Bullet('Loss of consciousness'),
            _Bullet('Cord visible after waters break'),
            _Bullet('Green fluid with reduced baby movement'),
          ],
        ),
        _Section(
          title: 'Self-care tips',
          severity: _Severity.normal,
          items: [
            _Bullet('Count fetal kicks daily from ~28 weeks'),
            _Bullet('Prepare hospital bag; keep emergency contacts ready'),
            _Bullet('Attend antenatal visits; drink water; sleep on left side'),
          ],
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serif = GoogleFonts.fraunces;
    final sans = GoogleFonts.plusJakartaSans;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Warning Signs',
          style:
              serif(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Know what is normal, what to report, and what needs emergency care. This is guidance — always follow your provider’s advice.',
                  style: sans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B6570),
                      height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    _LegendDot(color: Color(0xFF2E7D32), label: 'Normal'),
                    SizedBox(width: 10),
                    _LegendDot(color: Color(0xFFE8A020), label: 'Call doctor'),
                    SizedBox(width: 10),
                    _LegendDot(color: Color(0xFFD23B3B), label: 'Emergency'),
                  ],
                ),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabs,
                  labelColor: const Color(0xFFE04B84),
                  unselectedLabelColor: const Color(0xFF9A939E),
                  indicatorColor: const Color(0xFFE04B84),
                  labelStyle:
                      sans(fontSize: 14, fontWeight: FontWeight.w800),
                  tabs: [
                    for (final t in _trimesters)
                      Tab(text: '${t.label} · ${t.weeks.replaceFirst('Weeks ', '')}'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                for (final t in _trimesters)
                  _TrimesterTab(
                    data: t,
                    anyTimeEmergency: _anyTimeEmergency,
                    serif: serif,
                    sans: sans,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4A4550),
          ),
        ),
      ],
    );
  }
}

class _TrimesterTab extends StatelessWidget {
  const _TrimesterTab({
    required this.data,
    required this.anyTimeEmergency,
    required this.serif,
    required this.sans,
  });

  final _TrimesterData data;
  final List<_Bullet> anyTimeEmergency;
  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
    double? height,
    double? letterSpacing,
  }) serif;
  final TextStyle Function({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
    double? height,
    double? letterSpacing,
  }) sans;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE4EE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${data.label} trimester · ${data.weeks}',
                style: serif(
                    fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF4A2C4A)),
              ),
              const SizedBox(height: 6),
              Text(
                data.blurb,
                style: sans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B3A55),
                    height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final section in data.sections) ...[
          _SeverityCard(section: section, sans: sans, serif: serif),
          const SizedBox(height: 12),
        ],
        _SeverityCard(
          section: _Section(
            title: 'Emergency at ANY trimester',
            severity: _Severity.emergency,
            items: anyTimeEmergency,
          ),
          sans: sans,
          serif: serif,
        ),
        const SizedBox(height: 16),
        _EmergencyCallCard(sans: sans, serif: serif),
        const SizedBox(height: 12),
        Text(
          'This information is for education only and does not replace medical advice. If you are unsure, call your midwife, doctor, or emergency services.',
          style: sans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9A939E),
              height: 1.4),
        ),
      ],
    );
  }
}

class _SeverityCard extends StatelessWidget {
  const _SeverityCard({
    required this.section,
    required this.sans,
    required this.serif,
  });

  final _Section section;
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
    double? letterSpacing,
  }) serif;

  Color get _accent {
    switch (section.severity) {
      case _Severity.normal:
        return const Color(0xFF2E7D32);
      case _Severity.warning:
        return const Color(0xFFE8A020);
      case _Severity.emergency:
        return const Color(0xFFD23B3B);
    }
  }

  Color get _bg {
    switch (section.severity) {
      case _Severity.normal:
        return const Color(0xFFE8F5E9);
      case _Severity.warning:
        return const Color(0xFFFFF6E5);
      case _Severity.emergency:
        return const Color(0xFFFDECEC);
    }
  }

  String get _emoji {
    switch (section.severity) {
      case _Severity.normal:
        return '🟢';
      case _Severity.warning:
        return '🟡';
      case _Severity.emergency:
        return '🔴';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$_emoji  ${section.title}',
              style: sans(
                  fontSize: 13, fontWeight: FontWeight.w800, color: _accent),
            ),
          ),
          const SizedBox(height: 12),
          for (final item in section.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Icon(Icons.circle, size: 7, color: _accent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.text,
                          style: sans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D2A32),
                              height: 1.35),
                        ),
                        if (item.detail != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            item.detail!,
                            style: sans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B6570),
                                height: 1.35),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EmergencyCallCard extends StatelessWidget {
  const _EmergencyCallCard({required this.sans, required this.serif});

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
    double? letterSpacing,
  }) serif;

  Future<void> _call(BuildContext context, String number) async {
    await Clipboard.setData(ClipboardData(text: number));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Number $number copied — paste into Phone to call')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE89B9B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Emergency contacts',
              style: serif(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFB02525))),
          const SizedBox(height: 6),
          Text(
            'Call your midwife/OB first if you can. For life-threatening signs, call emergency services.',
            style: sans(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF8A2A2A),
                height: 1.4),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _call(context, '112'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD23B3B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.emergency_outlined),
              label: Text('Emergency — 112',
                  style: sans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () => _call(context, '108'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB02525),
                side: const BorderSide(color: Color(0xFFE89B9B)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.local_hospital_outlined, size: 20),
              label: Text('Ambulance — 108',
                  style: sans(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
