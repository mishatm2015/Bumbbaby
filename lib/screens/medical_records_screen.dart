import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Data models ───────────────────────────────────────────────────────────────

enum _RecordCategory { scan, bloodWork, prescription }

class _MedicalRecord {
  const _MedicalRecord({
    required this.title,
    required this.source,
    required this.date,
    required this.sizeMb,
    required this.category,
  });
  final String title;
  final String source;
  final String date;
  final String sizeMb;
  final _RecordCategory category;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  static const _ink = Color(0xFF2D2A32);
  static const _bg = Color(0xFFF8F9FC);
  static const _accent = Color(0xFFE04B84);

  static const _records = <_MedicalRecord>[
    _MedicalRecord(
      title: 'Anomaly Scan Report',
      source: 'Dr. Priya Nair',
      date: '18 Mar 2025',
      sizeMb: '2.4 MB',
      category: _RecordCategory.scan,
    ),
    _MedicalRecord(
      title: 'CBC Blood Report',
      source: 'Amrita Lab',
      date: '10 Mar 2025',
      sizeMb: '1.1 MB',
      category: _RecordCategory.bloodWork,
    ),
    _MedicalRecord(
      title: 'Prescription — Week 20',
      source: 'Dr. Smitha Rajan',
      date: '1 Mar 2025',
      sizeMb: '0.4 MB',
      category: _RecordCategory.prescription,
    ),
    _MedicalRecord(
      title: 'Foetal Doppler Report',
      source: 'Aster Hospital',
      date: '22 Feb 2025',
      sizeMb: '3.2 MB',
      category: _RecordCategory.scan,
    ),
    _MedicalRecord(
      title: 'Thyroid & Iron levels',
      source: 'Amrita Lab',
      date: '14 Feb 2025',
      sizeMb: '0.9 MB',
      category: _RecordCategory.bloodWork,
    ),
    _MedicalRecord(
      title: 'Prescription — Week 16',
      source: 'Dr. Smitha Rajan',
      date: '3 Feb 2025',
      sizeMb: '0.3 MB',
      category: _RecordCategory.prescription,
    ),
    _MedicalRecord(
      title: 'NT Scan Report',
      source: 'Aster Hospital',
      date: '20 Jan 2025',
      sizeMb: '1.8 MB',
      category: _RecordCategory.scan,
    ),
    _MedicalRecord(
      title: 'HbA1c & Glucose',
      source: 'SRL Diagnostics',
      date: '8 Jan 2025',
      sizeMb: '0.6 MB',
      category: _RecordCategory.bloodWork,
    ),
  ];

  _RecordCategory? _activeFilter;

  List<_MedicalRecord> get _filtered => _activeFilter == null
      ? _records
      : _records.where((r) => r.category == _activeFilter).toList();

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: _ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Medical Records',
          style: sans(fontSize: 17, fontWeight: FontWeight.w700, color: _ink),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: _accent, size: 24),
            onPressed: _showUploadSheet,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: _SummaryCard(total: _records.length),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _FilterTabRow(
              active: _activeFilter,
              onChanged: (v) => setState(() => _activeFilter = v),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _UploadZone(onTap: _showUploadSheet),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _RecordTile(record: _filtered[i]),
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _UploadSheet(),
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B8DEF), Color(0xFF4A6FD4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR RECORDS',
            style: sans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$total files',
            style: sans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Scans',
                  style: sans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text('·',
                    style: sans(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.6))),
              ),
              Text('Blood reports',
                  style: sans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text('·',
                    style: sans(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.6))),
              ),
              Text('Prescriptions',
                  style: sans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9))),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Filter tabs ───────────────────────────────────────────────────────────────

class _FilterTabRow extends StatelessWidget {
  const _FilterTabRow({required this.active, required this.onChanged});
  final _RecordCategory? active;
  final ValueChanged<_RecordCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterTab(
              label: 'All',
              selected: active == null,
              onTap: () => onChanged(null)),
          const SizedBox(width: 8),
          _FilterTab(
              label: 'Scans',
              selected: active == _RecordCategory.scan,
              onTap: () => onChanged(_RecordCategory.scan)),
          const SizedBox(width: 8),
          _FilterTab(
              label: 'Blood work',
              selected: active == _RecordCategory.bloodWork,
              onTap: () => onChanged(_RecordCategory.bloodWork)),
          const SizedBox(width: 8),
          _FilterTab(
              label: 'Prescriptions',
              selected: active == _RecordCategory.prescription,
              onTap: () => onChanged(_RecordCategory.prescription)),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2D2A32) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          label,
          style: sans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF6B6570),
          ),
        ),
      ),
    );
  }
}

// ── Upload zone ───────────────────────────────────────────────────────────────

class _UploadZone extends StatelessWidget {
  const _UploadZone({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFCBC7CF),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F4FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                color: Color(0xFF5B8DEF),
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Upload a document',
              style: sans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2A32)),
            ),
            const SizedBox(height: 4),
            Text(
              'PDF, JPG, PNG  —  up to 20 MB',
              style: sans(
                  fontSize: 12,
                  color: const Color(0xFF9A939E),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Record tile ───────────────────────────────────────────────────────────────

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});
  final _MedicalRecord record;

  Color get _iconBg {
    switch (record.category) {
      case _RecordCategory.scan:
        return const Color(0xFFEDE9F6);
      case _RecordCategory.bloodWork:
        return const Color(0xFFFDEDED);
      case _RecordCategory.prescription:
        return const Color(0xFFFFF0E8);
    }
  }

  Color get _iconColor {
    switch (record.category) {
      case _RecordCategory.scan:
        return const Color(0xFF7B6FA0);
      case _RecordCategory.bloodWork:
        return const Color(0xFFD94F4F);
      case _RecordCategory.prescription:
        return const Color(0xFFE07B3A);
    }
  }

  IconData get _icon {
    switch (record.category) {
      case _RecordCategory.scan:
        return Icons.monitor_heart_outlined;
      case _RecordCategory.bloodWork:
        return Icons.bloodtype_outlined;
      case _RecordCategory.prescription:
        return Icons.medication_outlined;
    }
  }

  (String, Color, Color) get _chipStyle {
    switch (record.category) {
      case _RecordCategory.scan:
        return (
          'Scan',
          const Color(0xFFEDE9F6),
          const Color(0xFF7B6FA0),
        );
      case _RecordCategory.bloodWork:
        return (
          'Blood work',
          const Color(0xFFFDEDED),
          const Color(0xFFD94F4F),
        );
      case _RecordCategory.prescription:
        return (
          'Prescription',
          const Color(0xFFFFF0E8),
          const Color(0xFFE07B3A),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    final (chipLabel, chipBg, chipFg) = _chipStyle;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon, color: _iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: sans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D2A32)),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${record.source} · ${record.date}',
                      style: sans(
                          fontSize: 12,
                          color: const Color(0xFF9A939E),
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        chipLabel,
                        style: sans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: chipFg),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                record.sizeMb,
                style: sans(
                    fontSize: 12,
                    color: const Color(0xFF9A939E),
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.more_vert_rounded,
                  color: Color(0xFFCCC8D0), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Upload bottom sheet ───────────────────────────────────────────────────────

class _UploadSheet extends StatelessWidget {
  const _UploadSheet();

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDD8E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Upload a document',
            style: sans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D2A32)),
          ),
          const SizedBox(height: 6),
          Text(
            'PDF, JPG, PNG — up to 20 MB',
            style: sans(
                fontSize: 13,
                color: const Color(0xFF9A939E),
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          _UploadOption(
              icon: Icons.photo_library_outlined, label: 'Choose from gallery'),
          const SizedBox(height: 12),
          _UploadOption(
              icon: Icons.camera_alt_outlined, label: 'Take a photo'),
          const SizedBox(height: 12),
          _UploadOption(
              icon: Icons.insert_drive_file_outlined, label: 'Browse files'),
        ],
      ),
    );
  }
}

class _UploadOption extends StatelessWidget {
  const _UploadOption({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(icon, color: const Color(0xFF7B6FA0), size: 18),
            ),
            const SizedBox(width: 14),
            Text(label,
                style: sans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2A32))),
            const Spacer(),
            const Icon(Icons.chevron_right,
                color: Color(0xFFCCC8D0), size: 20),
          ],
        ),
      ),
    );
  }
}
