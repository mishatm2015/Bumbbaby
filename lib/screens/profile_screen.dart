import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'medical_records_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;

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
        title: Text('Profile',
            style: sans(fontWeight: FontWeight.w700, fontSize: 17)),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Edit',
              style: sans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: const Color(0xFFE04B84),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        children: [
          // ── User card ──────────────────────────────────────
          _UserCard(sans: sans),
          const SizedBox(height: 28),

          // ── Quick tools ────────────────────────────────────
          _SectionHeader('QUICK TOOLS', sans),
          const SizedBox(height: 14),
          _QuickToolsGrid(),
          const SizedBox(height: 28),

          // ── Settings & more ────────────────────────────────
          _SectionHeader('SETTINGS & MORE', sans),
          const SizedBox(height: 10),
          _SettingsList(),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, this.sans);
  final String title;
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color, double? letterSpacing}) sans;

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

// ── User card ─────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard({required this.sans});
  final TextStyle Function({FontWeight? fontWeight, double? fontSize, Color? color}) sans;

  @override
  Widget build(BuildContext context) {
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
            decoration: BoxDecoration(
              color: const Color(0xFFB39DDB),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'A',
                style: sans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anusha Nair',
                style: sans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D2A32),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'EDD: July 15, 2025 · Week 24',
                style: sans(
                  fontSize: 13,
                  color: const Color(0xFF6B6570),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'LMP: Oct 8, 2024',
                style: sans(
                  fontSize: 13,
                  color: const Color(0xFF6B6570),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick tools grid ──────────────────────────────────────────────────────────

class _QuickToolsGrid extends StatelessWidget {
  static const _tools = [
    _ToolItem('📅', 'Due date'),
    _ToolItem('⏱️', 'Contraction\ntimer'),
    _ToolItem('👶', 'Kick counter'),
    _ToolItem('⚖️', 'BMI check'),
    _ToolItem('📊', 'Weight\ntracker'),
    _ToolItem('🎒', 'Hospital bag'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: _tools.map((t) => _ToolCard(tool: t)).toList(),
    );
  }
}

class _ToolItem {
  const _ToolItem(this.emoji, this.label);
  final String emoji;
  final String label;
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool});
  final _ToolItem tool;

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    return Container(
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
    );
  }
}

// ── Settings list ─────────────────────────────────────────────────────────────

class _SettingsList extends StatelessWidget {
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
                Divider(height: 1, indent: 58, endIndent: 0, color: const Color(0xFFF0ECF2)),
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
        if (item.title == 'Medical records') {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const MedicalRecordsScreen(),
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
                child: Text(item.emoji,
                    style: const TextStyle(fontSize: 18)),
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
