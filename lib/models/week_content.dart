/// Weekly pregnancy content: the "fruit" comparison, size, and guidance shown
/// on the dashboard and week guide. Content can come from Firestore
/// (`weeklyContent/{week}`) and falls back to the bundled dataset below.
class WeekContent {
  const WeekContent({
    required this.week,
    required this.fruit,
    required this.emoji,
    required this.length,
    required this.weight,
    required this.summary,
    required this.development,
    required this.symptoms,
    required this.bodyChanges,
    required this.tips,
    required this.dos,
    required this.donts,
  });

  final int week;
  final String fruit;
  final String emoji;
  final String length;
  final String weight;
  final String summary;
  final List<String> development;
  final List<String> symptoms;
  final List<String> bodyChanges;
  final List<String> tips;
  final List<String> dos;
  final List<String> donts;

  Map<String, dynamic> toMap() => {
        'week': week,
        'fruit': fruit,
        'emoji': emoji,
        'length': length,
        'weight': weight,
        'summary': summary,
        'development': development,
        'symptoms': symptoms,
        'bodyChanges': bodyChanges,
        'tips': tips,
        'dos': dos,
        'donts': donts,
      };

  factory WeekContent.fromMap(int week, Map<String, dynamic> data) {
    final base = WeekContent.forWeek(week);
    List<String> list(String key, List<String> fallback) {
      final v = data[key];
      if (v is List) {
        final parsed = v.whereType<String>().toList();
        if (parsed.isNotEmpty) return parsed;
      }
      return fallback;
    }

    String str(String key, String fallback) {
      final v = data[key];
      return (v is String && v.trim().isNotEmpty) ? v : fallback;
    }

    return WeekContent(
      week: week,
      fruit: str('fruit', base.fruit),
      emoji: str('emoji', base.emoji),
      length: str('length', base.length),
      weight: str('weight', base.weight),
      summary: str('summary', base.summary),
      development: list('development', base.development),
      symptoms: list('symptoms', base.symptoms),
      bodyChanges: list('bodyChanges', base.bodyChanges),
      tips: list('tips', base.tips),
      dos: list('dos', base.dos),
      donts: list('donts', base.donts),
    );
  }

  /// Builds full content for [week] from the bundled dataset, filling
  /// symptoms/body/tips/dos/donts from trimester-level guidance.
  factory WeekContent.forWeek(int week) {
    final w = week.clamp(1, 40);
    final fruit = _fruits[w] ?? _fruits[4]!;
    final tri = w < 13 ? 1 : (w < 27 ? 2 : 3);
    final detailed = _development[w];
    final development = <String>[
      fruit.shape,
      if (detailed != null) ...detailed else ..._developmentFallback[tri]!,
    ];
    final hasSize = RegExp(r'\d').hasMatch(fruit.length);
    final summary = hasSize
        ? 'At week $w, your baby is about the size of ${_article(fruit.name)} '
            '${fruit.name.toLowerCase()} — around ${fruit.length} and '
            '${fruit.weight}. ${fruit.shape}.'
        : 'At week $w, your baby is about the size of ${_article(fruit.name)} '
            '${fruit.name.toLowerCase()}. ${fruit.shape}.';
    return WeekContent(
      week: w,
      fruit: fruit.name,
      emoji: fruit.emoji,
      length: fruit.length,
      weight: fruit.weight,
      summary: summary,
      development: development,
      symptoms: _symptoms[tri]!,
      bodyChanges: <String>[fruit.momChange, ..._bodyChanges[tri]!],
      tips: _tips[tri]!,
      dos: _dos[tri]!,
      donts: _donts[tri]!,
    );
  }

  static String _article(String word) {
    final first = word.isNotEmpty ? word[0].toLowerCase() : 'x';
    return 'aeiou'.contains(first) ? 'an' : 'a';
  }
}

class _Fruit {
  const _Fruit(
    this.name,
    this.emoji,
    this.length,
    this.weight,
    this.shape,
    this.momChange,
  );
  final String name;
  final String emoji;
  final String length;
  final String weight;

  /// Short "baby shape / development" highlight for the week.
  final String shape;

  /// Short "mom size & changes" note for the week.
  final String momChange;
}

// Week-by-week size, development and mom changes.
const Map<int, _Fruit> _fruits = {
  1: _Fruit('Poppy seed', '⚫', '—', '—', 'Fertilization', 'No visible change'),
  2: _Fruit('Sesame seed', '⚪', '—', '—', 'Implantation', 'Mild cramps'),
  3: _Fruit('Rice grain', '🌾', '0.1 cm', '< 1 g', 'Neural tube forms', 'Bloating'),
  4: _Fruit('Lentil', '🫘', '0.4 cm', '< 1 g', 'Heart begins', 'Missed period'),
  5: _Fruit('Apple seed', '🍏', '0.5 cm', '< 1 g', 'Heartbeat starts', 'Breast tenderness'),
  6: _Fruit('Sweet pea', '🫛', '1.2 cm', '1 g', 'Limb buds', 'Nausea'),
  7: _Fruit('Blueberry', '🫐', '1.6 cm', '1 g', 'Brain growth', 'Fatigue'),
  8: _Fruit('Raspberry', '🍒', '2.3 cm', '2 g', 'Fingers form', 'Morning sickness'),
  9: _Fruit('Grape', '🍇', '3 cm', '4 g', 'Human shape', 'Mood swings'),
  10: _Fruit('Strawberry', '🍓', '3.5 cm', '7 g', 'Facial features', 'Slight belly'),
  11: _Fruit('Fig', '🟣', '4.5 cm', '10 g', 'Organ growth', 'Clothes tight'),
  12: _Fruit('Lime', '🟢', '5.4 cm', '14 g', 'Fully formed', 'Small bump'),
  13: _Fruit('Peach', '🍑', '7.4 cm', '23 g', 'Skeleton forms', 'Belly shows'),
  14: _Fruit('Lemon', '🍋', '8.7 cm', '43 g', 'Facial muscles', 'Visible bump'),
  15: _Fruit('Apple', '🍎', '10 cm', '70 g', 'Bone hardening', 'Rounded belly'),
  16: _Fruit('Avocado', '🥑', '11.6 cm', '100 g', 'Eyes move', 'Waist gone'),
  17: _Fruit('Pear', '🍐', '13 cm', '140 g', 'Fat stores', 'Stretch marks'),
  18: _Fruit('Sweet potato', '🍠', '14 cm', '190 g', 'Hearing develops', 'Baby kicks'),
  19: _Fruit('Mango', '🥭', '15.3 cm', '240 g', 'Protective skin', 'Belly growth'),
  20: _Fruit('Banana', '🍌', '16.4 cm', '300 g', 'Active movements', 'Halfway bump'),
  21: _Fruit('Carrot', '🥕', '26 cm', '360 g', 'Swallowing', 'Heavier belly'),
  22: _Fruit('Papaya', '🥭', '27.8 cm', '430 g', 'Eyebrows form', 'Back pain'),
  23: _Fruit('Grapefruit', '🍊', '28.9 cm', '500 g', 'Lung practice', 'Belly tight'),
  24: _Fruit('Corn', '🌽', '30 cm', '600 g', 'Viability stage', 'Swollen feet'),
  25: _Fruit('Cauliflower', '🥦', '34 cm', '660 g', 'Weight gain', 'Balance change'),
  26: _Fruit('Lettuce', '🥬', '35.6 cm', '760 g', 'Brain growth', 'Lower back pain'),
  27: _Fruit('Cabbage', '🥬', '36.6 cm', '875 g', 'Eyes open', 'Prominent bump'),
  28: _Fruit('Eggplant', '🍆', '37.6 cm', '1 kg', 'Fat layers', 'Heavy bump'),
  29: _Fruit('Butternut squash', '🎃', '38.6 cm', '1.2 kg', 'Strong kicks', 'Breathing discomfort'),
  30: _Fruit('Cucumber', '🥒', '39.9 cm', '1.4 kg', 'Brain growth', 'Tight belly'),
  31: _Fruit('Coconut', '🥥', '41.1 cm', '1.6 kg', 'More fat', 'Sleep issues'),
  32: _Fruit('Squash', '🎃', '42.4 cm', '1.8 kg', 'Toenails', 'Pelvic pressure'),
  33: _Fruit('Pineapple', '🍍', '43.7 cm', '2 kg', 'Head down', 'Waddling walk'),
  34: _Fruit('Cantaloupe', '🍈', '45 cm', '2.3 kg', 'Lung maturity', 'Braxton Hicks'),
  35: _Fruit('Honeydew melon', '🍈', '46.2 cm', '2.5 kg', 'Rounder body', 'Belly drop'),
  36: _Fruit('Papaya', '🥭', '47.4 cm', '2.7 kg', 'Ready position', 'Frequent urination'),
  37: _Fruit('Winter melon', '🍈', '48.6 cm', '2.9 kg', 'Full-term', 'Labor signs'),
  38: _Fruit('Pumpkin', '🎃', '49.8 cm', '3.1 kg', 'Firm skull', 'Back pain'),
  39: _Fruit('Watermelon', '🍉', '50.7 cm', '3.3 kg', 'Fully developed', 'Very heavy'),
  40: _Fruit('Large watermelon', '🍉', '51–52 cm', '3.5 kg', 'Birth ready', 'Labor ready'),
};

// Per-week baby development highlights.
const Map<int, List<String>> _development = {
  4: [
    'The embryo implants and the placenta begins to form',
    'Neural tube (future brain and spinal cord) starts developing',
    'Amniotic sac and yolk sac are forming to nourish the embryo',
  ],
  5: [
    'The heart begins to form and may start beating this week',
    'Neural tube closes along the developing back',
    'Tiny buds that become arms and legs appear',
  ],
  6: [
    'A regular heartbeat can often be detected on ultrasound',
    'Facial features begin to form — eyes, nose and jaw',
    'Arm and leg buds grow longer',
  ],
  7: [
    'The brain is growing rapidly and dividing into sections',
    'Hands and feet emerge as small paddles',
    'Kidneys and other organs continue to develop',
  ],
  8: [
    'Fingers and toes begin to form with webbing',
    'Baby starts making tiny spontaneous movements',
    'All essential organs have begun to develop',
  ],
  9: [
    'Baby is now officially a fetus',
    'Tiny muscles are forming, allowing first movements',
    'Eyelids form and cover the developing eyes',
  ],
  10: [
    'Vital organs are fully formed and starting to function',
    'Nails begin to develop on fingers and toes',
    'Bones and cartilage are forming',
  ],
  11: [
    'Baby can open and close fists and stretch',
    'Tooth buds and nail beds are developing',
    'Genitals are developing though not visible yet',
  ],
  12: [
    'Reflexes develop — baby may curl fingers and toes',
    'Kidneys begin producing urine',
    'Face now looks distinctly human',
  ],
  13: [
    'Vocal cords and fingerprints are forming',
    'Intestines move into the abdomen from the umbilical cord',
    'Baby can make sucking movements',
  ],
  14: [
    'Baby can squint, frown and make facial expressions',
    'Fine hair (lanugo) begins to cover the body',
    'The liver and spleen start functioning',
  ],
  15: [
    'Baby can sense light even though eyes are still closed',
    'Bones are getting stronger and are visible on scans',
    'Baby is practising breathing movements',
  ],
  16: [
    'Baby can make coordinated arm and leg movements',
    'Eyes can move slowly and ears are near their final position',
    'The backbone and tiny muscles are strengthening',
  ],
  17: [
    'Fat stores begin to develop to help regulate body heat',
    'The umbilical cord grows stronger and thicker',
    'Baby\'s heart is pumping around 100 pints of blood a day',
  ],
  18: [
    'Ears are in position and baby may start to hear sounds',
    'A protective coating (vernix) covers the skin',
    'Baby is becoming more active with rolls and kicks',
  ],
  19: [
    'Vernix caseosa protects the delicate skin',
    'Sensory areas of the brain are developing',
    'Kidneys continue making urine; hair grows on the scalp',
  ],
  20: [
    'You\'re halfway there! Baby can hear your voice',
    'Baby swallows more and produces meconium',
    'The anomaly scan checks organs and growth this week',
  ],
  21: [
    'Baby\'s movements become stronger and more regular',
    'Taste buds are forming and baby swallows amniotic fluid',
    'Bone marrow starts making blood cells',
  ],
  22: [
    'Senses of touch and taste are developing rapidly',
    'Eyebrows and eyelids are fully formed',
    'Baby now looks like a miniature newborn',
  ],
  23: [
    'Baby can hear loud sounds from outside the womb',
    'Lungs develop blood vessels to prepare for breathing',
    'Skin is still wrinkled as fat continues to build',
  ],
  24: [
    'Inner ear is fully formed — baby can hear your voice',
    'Lungs develop branches and cells that produce surfactant',
    'Baby has a real chance of survival if born now (viability)',
  ],
  25: [
    'Baby is gaining fat and skin becomes less wrinkled',
    'Hair is growing and gaining colour and texture',
    'Nostrils begin to open for breathing practice',
  ],
  26: [
    'Eyes begin to open and baby can blink',
    'Lungs produce more surfactant for breathing after birth',
    'Baby responds to sounds with movement or pulse changes',
  ],
  27: [
    'Baby has regular sleep and wake cycles',
    'Brain activity increases significantly',
    'Baby may hiccup — you might feel small rhythmic jerks',
  ],
  28: [
    'Eyes can open and close and detect light',
    'Baby dreams (REM sleep) and adds baby fat',
    'Lungs are maturing but still need more time',
  ],
  29: [
    'Muscles and lungs continue to mature',
    'Baby\'s head grows to make room for the developing brain',
    'Bones fully developed but still soft and pliable',
  ],
  30: [
    'Baby\'s brain develops grooves and wrinkles',
    'Bone marrow takes over red blood cell production',
    'Lanugo hair begins to disappear',
  ],
  31: [
    'Baby can turn its head and is putting on weight fast',
    'The five senses are all working now',
    'Movements are strong and well coordinated',
  ],
  32: [
    'Baby practises breathing by inhaling amniotic fluid',
    'Toenails and fingernails are fully formed',
    'Baby usually settles into a head-down position soon',
  ],
  33: [
    'Baby\'s skull bones stay soft and separate for birth',
    'The immune system is strengthening with your antibodies',
    'Baby can detect light and its pupils constrict',
  ],
  34: [
    'Central nervous system and lungs are maturing well',
    'A baby born now usually does very well',
    'The waxy vernix coating thickens',
  ],
  35: [
    'Baby\'s kidneys are fully developed',
    'The liver can process some waste products',
    'Most growth now is weight gain and fat',
  ],
  36: [
    'Baby is likely head-down preparing for birth',
    'The digestive system is nearly ready for milk',
    'Baby sheds most of the lanugo and vernix',
  ],
  37: [
    'Baby is considered "early term" this week',
    'Practising breathing, sucking and blinking',
    'Firm grasp and continued fat gain',
  ],
  38: [
    'Organs are mature and ready to function on their own',
    'Baby continues to add fat for temperature control',
    'Meconium builds up in the bowels for the first stool',
  ],
  39: [
    'Baby is full term and ready to meet you',
    'Brain and lungs continue final maturation',
    'A fresh layer of skin forms beneath the old',
  ],
  40: [
    'Your due date is here — baby is fully developed',
    'Baby continues to gain a little weight',
    'Only about 5% of babies arrive exactly on the due date',
  ],
};

const Map<int, List<String>> _developmentFallback = {
  1: [
    'The early stages of pregnancy are beginning',
    'Your body is preparing to support a growing baby',
  ],
  2: [
    'Baby\'s major organs and systems are developing',
    'Growth is rapid during the first trimester',
  ],
  3: [
    'Baby is growing steadily and gaining strength',
    'Movements and senses continue to develop',
  ],
};

const Map<int, List<String>> _symptoms = {
  1: [
    'Nausea or morning sickness, often worse on an empty stomach',
    'Tender, swollen breasts',
    'Fatigue and a need for more sleep',
    'Frequent urination and food aversions',
  ],
  2: [
    'More energy as morning sickness eases',
    'Round ligament pain as the uterus grows',
    'Nasal congestion and occasional headaches',
    'Visible bump and mild backache',
  ],
  3: [
    'Back pain as your centre of gravity shifts',
    'Braxton Hicks contractions — mild, irregular tightenings',
    'Swollen feet and ankles, heartburn and shortness of breath',
    'Trouble sleeping and frequent urination',
  ],
};

const Map<int, List<String>> _bodyChanges = {
  1: [
    'Rising hormones prepare your body for pregnancy',
    'The uterus is starting to grow',
    'Increased blood volume may make you feel warm',
  ],
  2: [
    'Your bump becomes noticeable as the uterus rises',
    'Skin changes such as a darker line (linea nigra) may appear',
    'You may feel first flutters of movement (quickening)',
  ],
  3: [
    'Uterus expands up towards the ribcage',
    'Braxton Hicks contractions become more common',
    'Increased pressure on the bladder and pelvis',
  ],
};

const Map<int, List<String>> _tips = {
  1: [
    'Take a daily folic acid and prenatal vitamin',
    'Eat small, frequent meals to ease nausea',
    'Stay hydrated and rest whenever you can',
    'Avoid alcohol, smoking and raw/undercooked foods',
  ],
  2: [
    'Start gentle exercise like walking or prenatal yoga',
    'Sleep on your side to improve circulation',
    'Keep up with antenatal appointments and scans',
    'Moisturise your belly to soothe stretching skin',
  ],
  3: [
    'Sleep on your left side to improve blood flow to baby',
    'Track baby movements — report any reduction promptly',
    'Prepare your hospital bag and birth plan',
    'Practise breathing and relaxation techniques',
  ],
};

const Map<int, List<String>> _dos = {
  1: [
    'Take your folic acid and prenatal vitamins daily',
    'Book your first antenatal (booking) appointment',
    'Eat a balanced diet rich in iron and calcium',
    'Get plenty of rest',
  ],
  2: [
    'Stay active with pregnancy-safe exercise',
    'Drink 8–10 glasses of water a day',
    'Attend your anomaly scan around week 20',
    'Wear comfortable, supportive footwear',
  ],
  3: [
    'Attend all antenatal checkups',
    'Monitor baby\'s kicks daily',
    'Rest with your feet up to reduce swelling',
    'Finalise your birth plan and hospital bag',
  ],
};

const Map<int, List<String>> _donts = {
  1: [
    'Avoid alcohol, smoking and recreational drugs',
    'Don\'t eat raw or undercooked meat, fish or eggs',
    'Avoid unpasteurised dairy and soft cheeses',
    'Don\'t take medication without checking with your doctor',
  ],
  2: [
    'Avoid lying flat on your back for long periods',
    'Don\'t lift heavy objects',
    'Avoid hot tubs, saunas and overheating',
    'Don\'t ignore unusual pain or bleeding',
  ],
  3: [
    'Avoid long periods of standing',
    'Don\'t ignore severe swelling, headaches or vision changes',
    'Avoid travel far from your care provider near term',
    'Don\'t skip meals — baby needs steady nutrition',
  ],
};
