import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class _SignItem {
  const _SignItem(this.text, this.level);

  final String text;
  final String level;
}

class _ContactRow {
  const _ContactRow({
    required this.name,
    required this.subtitle,
    required this.phone,
    required this.icon,
    required this.circle,
  });

  final String name;
  final String subtitle;
  final String phone;
  final IconData icon;
  final Color circle;
}

/// Urgency-grouped warning signs and emergency contacts.
class WarningSignsScreen extends StatelessWidget {
  const WarningSignsScreen({super.key});

  static const _hospital = [
    _SignItem('Heavy vaginal bleeding', 'Critical'),
    _SignItem('Severe abdominal pain or cramping', 'Critical'),
    _SignItem('No fetal movement for 12+ hours', 'Critical'),
    _SignItem('Sudden vision changes or severe headache', 'Critical'),
    _SignItem('Water breaking before week 37', 'Critical'),
  ];

  static const _doctorSoon = [
    _SignItem('Fever above 38°C', 'Urgent'),
    _SignItem('Swelling in face or hands', 'Urgent'),
    _SignItem('Burning pain when urinating', 'Urgent'),
  ];

  static const _contacts = [
    _ContactRow(
      name: 'Dr. Priya Nair',
      subtitle: 'OB-GYN · Amrita Hospital',
      phone: '+91 98765 43210',
      icon: Icons.medical_services_outlined,
      circle: Color(0xFFFFE4EE),
    ),
    _ContactRow(
      name: 'Amrita Hospital',
      subtitle: 'Labour & delivery ward',
      phone: '0487 302 1000',
      icon: Icons.local_hospital_outlined,
      circle: Color(0xFFE3F2FD),
    ),
    _ContactRow(
      name: 'National Emergency',
      subtitle: 'Ambulance · Police · Fire',
      phone: '112',
      icon: Icons.emergency_outlined,
      circle: Color(0xFFFFF3E0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final serif = GoogleFonts.fraunces;
    final sans = GoogleFonts.plusJakartaSans;

    return Scaffold(
      backgroundColor: Colors.white,
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
          style: serif(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4EE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Emergency',
                  style: serif(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFB71C1C)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8A80),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KNOW THE SIGNS',
                  style: sans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: const Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'When to seek help immediately',
                  style: serif(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap each sign to learn more. When in doubt — call your doctor.',
                  style: serif(
                    fontSize: 14,
                    height: 1.35,
                    color: const Color(0xFF3E2723),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _CategoryHeader(color: const Color(0xFFD32F2F), title: 'GO TO HOSPITAL IMMEDIATELY', serif: serif),
          const SizedBox(height: 12),
          ..._hospital.map((s) => _SignTile(item: s, serif: serif, isCritical: true)),
          const SizedBox(height: 28),
          _CategoryHeader(color: const Color(0xFFFFC107), title: 'CALL YOUR DOCTOR SOON', serif: serif),
          const SizedBox(height: 12),
          ..._doctorSoon.map((s) => _SignTile(item: s, serif: serif, isCritical: false)),
          const SizedBox(height: 28),
          Row(
            children: [
              const Icon(Icons.phone_in_talk_outlined, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'EMERGENCY CONTACTS',
                  style: serif(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._contacts.map((c) => _ContactCard(row: c, serif: serif, sans: sans)),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.color, required this.title, required this.serif});

  final Color color;
  final String title;
  final TextStyle Function({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
  })
  serif;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: serif(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

class _SignTile extends StatelessWidget {
  const _SignTile({
    required this.item,
    required this.serif,
    required this.isCritical,
  });

  final _SignItem item;
  final TextStyle Function({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  })
  serif;
  final bool isCritical;

  @override
  Widget build(BuildContext context) {
    final dot = isCritical ? const Color(0xFFD32F2F) : const Color(0xFFFF9800);
    final tagBg = isCritical ? const Color(0xFFFFEBEE) : const Color(0xFFFFF8E1);
    final tagFg = isCritical ? const Color(0xFFB71C1C) : const Color(0xFF795548);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(item.text, style: serif(fontWeight: FontWeight.w700, fontSize: 16)),
            content: Text(
              'If you experience this, contact your care team right away or go to the nearest hospital.',
              style: serif(fontSize: 14).copyWith(height: 1.35),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
            ],
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.text,
                  style: serif(fontSize: 15, color: Colors.black).copyWith(height: 1.35),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  item.level,
                  style: serif(fontSize: 11, fontWeight: FontWeight.w700, color: tagFg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.row,
    required this.serif,
    required this.sans,
  });

  final _ContactRow row;
  final TextStyle Function({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  })
  serif;
  final TextStyle Function({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  })
  sans;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: row.phone.replaceAll(' ', '')));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Copied ${row.phone}')),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: row.circle,
                  child: Icon(row.icon, color: Colors.black87),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(row.name, style: serif(fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(row.subtitle, style: sans(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
                Text(
                  row.phone,
                  style: serif(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: const Color(0xFFE04B84),
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
