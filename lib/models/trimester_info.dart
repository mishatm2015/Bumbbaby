/// Trimester overview chart content (stored in Firestore `trimesterInfo/{1|2|3}`).
class TrimesterInfo {
  const TrimesterInfo({
    required this.trimester,
    required this.title,
    required this.weeksLabel,
    required this.summary,
    required this.symptoms,
    required this.bodyChanges,
    required this.tips,
    required this.dos,
    required this.donts,
  });

  final int trimester;
  final String title;
  final String weeksLabel;
  final String summary;
  final List<String> symptoms;
  final List<String> bodyChanges;
  final List<String> tips;
  final List<String> dos;
  final List<String> donts;

  Map<String, dynamic> toMap() => {
        'trimester': trimester,
        'title': title,
        'weeksLabel': weeksLabel,
        'summary': summary,
        'symptoms': symptoms,
        'bodyChanges': bodyChanges,
        'tips': tips,
        'dos': dos,
        'donts': donts,
      };

  factory TrimesterInfo.fromMap(int trimester, Map<String, dynamic> data) {
    List<String> list(String key) {
      final v = data[key];
      if (v is List) return v.whereType<String>().toList();
      return const [];
    }

    return TrimesterInfo(
      trimester: trimester,
      title: data['title'] as String? ?? 'Trimester $trimester',
      weeksLabel: data['weeksLabel'] as String? ?? '',
      summary: data['summary'] as String? ?? '',
      symptoms: list('symptoms'),
      bodyChanges: list('bodyChanges'),
      tips: list('tips'),
      dos: list('dos'),
      donts: list('donts'),
    );
  }

  /// Bundled defaults used to seed Firestore.
  static TrimesterInfo bundled(int trimester) {
    switch (trimester) {
      case 2:
        return const TrimesterInfo(
          trimester: 2,
          title: 'Second Trimester',
          weeksLabel: 'Weeks 13–26',
          summary:
              'Often called the "honeymoon" phase — energy returns, the bump shows, and you may feel baby move.',
          symptoms: [
            'More energy as morning sickness eases',
            'Round ligament pain as the uterus grows',
            'Nasal congestion and occasional headaches',
            'Visible bump and mild backache',
          ],
          bodyChanges: [
            'Your bump becomes noticeable as the uterus rises',
            'Skin changes such as a darker line (linea nigra) may appear',
            'You may feel first flutters of movement (quickening)',
          ],
          tips: [
            'Start gentle exercise like walking or prenatal yoga',
            'Sleep on your side to improve circulation',
            'Keep up with antenatal appointments and scans',
            'Moisturise your belly to soothe stretching skin',
          ],
          dos: [
            'Stay active with doctor-approved exercise',
            'Eat iron-rich foods and stay hydrated',
            'Attend the anomaly scan around weeks 18–22',
          ],
          donts: [
            'Don\'t ignore unusual pain or bleeding',
            'Avoid lying flat on your back for long periods later in this trimester',
            'Don\'t skip prenatal vitamins',
          ],
        );
      case 3:
        return const TrimesterInfo(
          trimester: 3,
          title: 'Third Trimester',
          weeksLabel: 'Weeks 27–40',
          summary:
              'Baby gains weight quickly. Track movements, prepare for birth, and watch for labor signs.',
          symptoms: [
            'Back pain as your centre of gravity shifts',
            'Braxton Hicks contractions — mild, irregular tightenings',
            'Swollen feet and ankles, heartburn and shortness of breath',
            'Trouble sleeping and frequent urination',
          ],
          bodyChanges: [
            'Uterus expands up towards the ribcage',
            'Braxton Hicks contractions become more common',
            'Increased pressure on the bladder and pelvis',
          ],
          tips: [
            'Sleep on your left side to improve blood flow to baby',
            'Track baby movements — report any reduction promptly',
            'Prepare your hospital bag and birth plan',
            'Practise breathing and relaxation techniques',
          ],
          dos: [
            'Count fetal movements daily from ~28 weeks',
            'Know the 5-1-1 rule for labor contractions',
            'Pack your hospital bag by week 36',
          ],
          donts: [
            'Don\'t ignore reduced baby movements',
            'Avoid travel far from your hospital late in pregnancy without a plan',
            'Don\'t dismiss regular contractions before 37 weeks',
          ],
        );
      default:
        return const TrimesterInfo(
          trimester: 1,
          title: 'First Trimester',
          weeksLabel: 'Weeks 1–12',
          summary:
              'Baby\'s major organs form. Focus on folic acid, rest, and settling into prenatal care.',
          symptoms: [
            'Nausea or morning sickness, often worse on an empty stomach',
            'Tender, swollen breasts',
            'Fatigue and a need for more sleep',
            'Frequent urination and food aversions',
          ],
          bodyChanges: [
            'Rising hormones prepare your body for pregnancy',
            'The uterus is starting to grow',
            'Increased blood volume may make you feel warm',
          ],
          tips: [
            'Take a daily folic acid and prenatal vitamin',
            'Eat small, frequent meals to ease nausea',
            'Stay hydrated and rest whenever you can',
            'Avoid alcohol, smoking and raw/undercooked foods',
          ],
          dos: [
            'Take your folic acid and prenatal vitamins daily',
            'Book your first antenatal (booking) appointment',
            'Eat a balanced diet rich in iron and calcium',
            'Get plenty of rest',
          ],
          donts: [
            'Avoid alcohol, smoking and recreational drugs',
            'Avoid raw fish, unpasteurised cheese and undercooked meat',
            'Don\'t take medicines without checking with your doctor',
          ],
        );
    }
  }
}
