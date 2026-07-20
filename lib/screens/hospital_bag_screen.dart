import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HospitalBagScreen extends StatefulWidget {
  const HospitalBagScreen({super.key});

  @override
  State<HospitalBagScreen> createState() => _HospitalBagScreenState();
}

class _HospitalBagScreenState extends State<HospitalBagScreen> {
  static const _ink = Color(0xFF2D2A32);

  final List<_BagCategory> _categories = [
    _BagCategory(
      emoji: '🐻',
      name: 'For mama',
      items: [
        _BagItem('Maternity nightgown × 2', checked: true),
        _BagItem('Comfortable slippers', checked: true),
        _BagItem('Nursing bra × 2', checked: true),
        _BagItem('Maternity pads (heavy)', checked: true),
        _BagItem('Toiletries & face wash', checked: true),
        _BagItem('Phone charger & earphones', checked: true),
        _BagItem('Nipple cream (lanolin)'),
        _BagItem('Snacks & energy bars'),
        _BagItem('Comfortable loose clothes'),
        _BagItem('Hair ties & face wipes'),
      ],
    ),
    _BagCategory(
      emoji: '🐣',
      name: 'For baby',
      items: [
        _BagItem('Receiving blanket × 2', checked: true),
        _BagItem('Newborn nappies (pack)', checked: true),
        _BagItem('Baby socks & mittens', checked: true),
        _BagItem('Baby cap / beanie', checked: true),
        _BagItem('Baby wipes (unscented)'),
        _BagItem('Car seat (installed)'),
        _BagItem('Coming-home outfit'),
        _BagItem('Swaddle cloth × 2'),
      ],
    ),
    _BagCategory(
      emoji: '📄',
      name: 'Documents',
      items: [
        _BagItem('Aadhaar card (mama)', checked: true),
        _BagItem('Health insurance card', checked: true),
        _BagItem('Doctor\'s contact number', checked: true),
        _BagItem('Birth plan copy', checked: true),
        _BagItem('All medical records folder'),
        _BagItem('Hospital registration papers'),
        _BagItem('Cash / UPI ready'),
      ],
    ),
  ];

  int get _totalItems => _categories.fold(0, (s, c) => s + c.items.length);
  int get _packedItems =>
      _categories.fold(0, (s, c) => s + c.items.where((i) => i.checked).length);

  void _toggle(int catIdx, int itemIdx) {
    setState(() {
      _categories[catIdx].items[itemIdx].checked =
          !_categories[catIdx].items[itemIdx].checked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    final serif = GoogleFonts.fraunces;
    final progress = _totalItems == 0 ? 0.0 : _packedItems / _totalItems;
    final pct = (progress * 100).round();

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
          'Hospital Bag',
          style: sans(fontWeight: FontWeight.w700, fontSize: 17.0, color: _ink),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$pct%',
                style: sans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.0,
                  color: const Color(0xFF1A8C6A),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          _HeaderCard(
            packedItems: _packedItems,
            totalItems: _totalItems,
            progress: progress,
            sans: sans,
            serif: serif,
          ),
          const SizedBox(height: 20),
          ..._categories.asMap().entries.map((entry) {
            final catIdx = entry.key;
            final cat = entry.value;
            final packed = cat.items.where((i) => i.checked).length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CategoryHeader(
                  emoji: cat.emoji,
                  name: cat.name,
                  packed: packed,
                  total: cat.items.length,
                  sans: sans,
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: cat.items.asMap().entries.map((e) {
                      final itemIdx = e.key;
                      final item = e.value;
                      final isLast = itemIdx == cat.items.length - 1;
                      return _ItemRow(
                        label: item.label,
                        checked: item.checked,
                        isLast: isLast,
                        sans: sans,
                        onTap: () => _toggle(catIdx, itemIdx),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.packedItems,
    required this.totalItems,
    required this.progress,
    required this.sans,
    required this.serif,
  });

  final int packedItems;
  final int totalItems;
  final double progress;
  final dynamic sans;
  final dynamic serif;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2DB78A), Color(0xFF1A8C6A)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A8C6A).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PACK BY WEEK 36',
            style: sans(
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$packedItems of $totalItems packed',
            style: serif(
              fontSize: 28.0,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            packedItems == totalItems
                ? 'You\'re all packed — ready for the big day! 🎉'
                : packedItems > totalItems * 0.7
                    ? 'You\'re doing great — almost ready!'
                    : 'Keep going, you\'re making progress!',
            style: sans(
              fontSize: 13.0,
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.emoji,
    required this.name,
    required this.packed,
    required this.total,
    required this.sans,
  });

  final String emoji;
  final String name;
  final int packed;
  final int total;
  final dynamic sans;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20.0)),
        const SizedBox(width: 8),
        Text(
          name,
          style: sans(
            fontSize: 15.0,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D2A32),
          ),
        ),
        const Spacer(),
        Text(
          '$packed / $total',
          style: sans(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A8C6A),
          ),
        ),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.label,
    required this.checked,
    required this.isLast,
    required this.sans,
    required this.onTap,
  });

  final String label;
  final bool checked;
  final bool isLast;
  final dynamic sans;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.vertical(bottom: Radius.circular(18))
          : BorderRadius.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: checked
                        ? const Color(0xFF1A8C6A)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    border: checked
                        ? null
                        : Border.all(
                            color: const Color(0xFFCCC5C9), width: 1.5),
                  ),
                  child: checked
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: sans(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: checked
                          ? const Color(0xFF6B6570)
                          : const Color(0xFF2D2A32),
                      decoration:
                          checked ? TextDecoration.lineThrough : null,
                      decorationColor: const Color(0xFF6B6570),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isLast)
            const Divider(
              height: 1,
              indent: 54,
              endIndent: 0,
              color: Color(0xFFF0E8EC),
            ),
        ],
      ),
    );
  }
}

class _BagCategory {
  _BagCategory({required this.emoji, required this.name, required this.items});
  final String emoji;
  final String name;
  final List<_BagItem> items;
}

class _BagItem {
  _BagItem(this.label, {this.checked = false});
  final String label;
  bool checked;
}
