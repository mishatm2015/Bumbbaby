import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/medicine.dart';
import '../services/medicine_service.dart';

/// Track medications / supplements: add them, then tick each one as taken.
/// The "taken" state resets every day; the medicine list persists.
class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  static const _green = Color(0xFF4CAF6A);
  static const _ink = Color(0xFF2D2A32);

  List<Medicine> _meds = [];
  Set<String> _taken = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final meds = await MedicineService.getMedicines();
    final taken = await MedicineService.getTodayTaken();
    if (!mounted) return;
    setState(() {
      _meds = meds;
      _taken = taken;
      _loading = false;
    });
  }

  Future<void> _toggle(Medicine m) async {
    setState(() {
      if (_taken.contains(m.id)) {
        _taken.remove(m.id);
      } else {
        _taken.add(m.id);
      }
    });
    await MedicineService.setTodayTaken(_taken);
  }

  Future<void> _saveMeds() async => MedicineService.saveMedicines(_meds);

  Future<void> _addOrEdit({Medicine? existing}) async {
    final result = await showModalBottomSheet<Medicine>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _MedicineEditor(existing: existing),
    );
    if (result == null) return;
    setState(() {
      final idx = _meds.indexWhere((m) => m.id == result.id);
      if (idx >= 0) {
        _meds[idx] = result;
      } else {
        _meds.add(result);
      }
    });
    await _saveMeds();
  }

  Future<void> _delete(Medicine m) async {
    setState(() {
      _meds.removeWhere((x) => x.id == m.id);
      _taken.remove(m.id);
    });
    await _saveMeds();
    await MedicineService.setTodayTaken(_taken);
  }

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    final total = _meds.length;
    final done = _meds.where((m) => _taken.contains(m.id)).length;
    final frac = total == 0 ? 0.0 : done / total;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FC),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Medicine',
            style: sans(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEdit(),
        backgroundColor: _green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add medicine',
            style: sans(fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                // ── Summary header ───────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _green.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.medication_rounded,
                            color: _green, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              total == 0
                                  ? 'No medicines yet'
                                  : '$done of $total taken today',
                              style: sans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _ink,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: frac,
                                minHeight: 8,
                                backgroundColor: const Color(0xFFE9EFEB),
                                valueColor:
                                    const AlwaysStoppedAnimation(_green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'TODAY\'S LIST',
                  style: sans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 12),
                if (_meds.isEmpty)
                  _EmptyState(sans: sans)
                else
                  ..._meds.map((m) => _MedicineTile(
                        med: m,
                        taken: _taken.contains(m.id),
                        sans: sans,
                        onToggle: () => _toggle(m),
                        onEdit: () => _addOrEdit(existing: m),
                        onDelete: () => _delete(m),
                      )),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.sans});
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color, double? letterSpacing, double? height}) sans;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.medication_outlined,
              size: 40, color: Color(0xFFC6D0DA)),
          const SizedBox(height: 12),
          Text(
            'Tap “Add medicine” to start tracking\nyour tablets and supplements.',
            textAlign: TextAlign.center,
            style: sans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B6570),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicineTile extends StatelessWidget {
  const _MedicineTile({
    required this.med,
    required this.taken,
    required this.sans,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Medicine med;
  final bool taken;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color, double? letterSpacing, double? height, TextDecoration? decoration}) sans;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4CAF6A);
    final sub = [med.dose, med.time].where((e) => e != null && e.isNotEmpty).join(' • ');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: taken ? green.withValues(alpha: 0.4) : const Color(0xFFEDEFF2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onTap: onToggle,
        leading: GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: taken ? green : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: taken ? green : const Color(0xFFC6D0DA),
                width: 2,
              ),
            ),
            child: taken
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),
        ),
        title: Text(
          med.name,
          style: sans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D2A32),
            decoration: taken ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: sub.isEmpty
            ? null
            : Text(sub,
                style: sans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B6570),
                )),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFF9A939E)),
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet form to add or edit a medicine.
class _MedicineEditor extends StatefulWidget {
  const _MedicineEditor({this.existing});
  final Medicine? existing;

  @override
  State<_MedicineEditor> createState() => _MedicineEditorState();
}

class _MedicineEditorState extends State<_MedicineEditor> {
  late final TextEditingController _name;
  late final TextEditingController _dose;
  String? _time;

  static const _times = ['Morning', 'Afternoon', 'Evening', 'Night'];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _dose = TextEditingController(text: widget.existing?.dose ?? '');
    _time = widget.existing?.time;
  }

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final id = widget.existing?.id ??
        DateTime.now().microsecondsSinceEpoch.toString();
    Navigator.pop(
      context,
      Medicine(
        id: id,
        name: name,
        dose: _dose.text.trim().isEmpty ? null : _dose.text.trim(),
        time: _time,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    const green = Color(0xFF4CAF6A);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.existing == null ? 'Add medicine' : 'Edit medicine',
            style: sans(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. Folic acid',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dose,
            decoration: InputDecoration(
              labelText: 'Dose (optional)',
              hintText: 'e.g. 1 tablet, 500 mg',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('When (optional)',
              style: sans(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _times.map((t) {
              final selected = _time == t;
              return ChoiceChip(
                label: Text(t),
                selected: selected,
                selectedColor: green.withValues(alpha: 0.18),
                onSelected: (_) => setState(() => _time = selected ? null : t),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text('Save',
                  style: sans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
