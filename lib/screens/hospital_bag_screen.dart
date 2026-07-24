import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/hospital_bag_item.dart';
import '../services/hospital_bag_service.dart';

typedef _TextStyleFn = TextStyle Function({
  Color? color,
  TextDecoration? decoration,
  Color? decorationColor,
  double? fontSize,
  FontWeight? fontWeight,
  double? height,
  double? letterSpacing,
});

class HospitalBagScreen extends StatefulWidget {
  const HospitalBagScreen({super.key});

  @override
  State<HospitalBagScreen> createState() => _HospitalBagScreenState();
}

class _HospitalBagScreenState extends State<HospitalBagScreen> {
  static const _ink = Color(0xFF2D2A32);
  static const _teal = Color(0xFF1A8C6A);

  final _searchCtrl = TextEditingController();
  List<HospitalBagItem> _items = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final items = await HospitalBagService.load();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = HospitalBagService.defaults();
        _loading = false;
      });
    }
  }

  Future<void> _persist() => HospitalBagService.save(_items);

  int get _totalItems => _items.length;
  int get _packedItems => _items.where((i) => i.checked).length;

  List<HospitalBagItem> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items.where((i) {
      return i.label.toLowerCase().contains(q) ||
          (i.subcategory?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> _toggle(HospitalBagItem item) async {
    setState(() => item.checked = !item.checked);
    await _persist();
  }

  Future<void> _remove(HospitalBagItem item) async {
    setState(() => _items.removeWhere((e) => e.id == item.id));
    await _persist();
  }

  Future<void> _showAddSheet() async {
    final result = await showModalBottomSheet<_AddResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _AddItemSheet(),
    );
    if (result == null || !mounted) return;

    final id =
        'custom|${result.categoryId}|${DateTime.now().millisecondsSinceEpoch}';
    final item = HospitalBagItem(
      id: id,
      label: result.label,
      categoryId: result.categoryId,
      subcategory: 'Custom',
      isCustom: true,
    );
    setState(() => _items.add(item));
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    final _TextStyleFn sans = GoogleFonts.plusJakartaSans;
    final _TextStyleFn serif = GoogleFonts.fraunces;
    final progress = _totalItems == 0 ? 0.0 : _packedItems / _totalItems;
    final pct = (progress * 100).round();
    final filtered = _filtered;

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
          style: sans(fontWeight: FontWeight.w700, fontSize: 17, color: _ink),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$pct%',
                style: sans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: _teal,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add item',
          style: sans(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _teal))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                _HeaderCard(
                  packedItems: _packedItems,
                  totalItems: _totalItems,
                  progress: progress,
                  sans: sans,
                  serif: serif,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search items…',
                    hintStyle: sans(
                      color: const Color(0xFF9A94A0),
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Color(0xFF9A94A0)),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: sans(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to mark packed · Long-press to remove',
                  style: sans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9A94A0),
                  ),
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        _query.isEmpty
                            ? 'No items yet — add something to pack'
                            : 'No items match “$_query”',
                        style: sans(
                          fontSize: 14,
                          color: const Color(0xFF6B6570),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                else
                  ...HospitalBagService.categories.map((cat) {
                    final catItems =
                        filtered.where((i) => i.categoryId == cat.id).toList();
                    if (catItems.isEmpty) return const SizedBox.shrink();
                    final packed = catItems.where((i) => i.checked).length;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CategoryHeader(
                          emoji: cat.emoji,
                          name: cat.name,
                          packed: packed,
                          total: catItems.length,
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
                            children: _buildCategoryRows(catItems, sans),
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

  List<Widget> _buildCategoryRows(
    List<HospitalBagItem> catItems,
    _TextStyleFn sans,
  ) {
    final widgets = <Widget>[];
    String? lastSub;
    for (var i = 0; i < catItems.length; i++) {
      final item = catItems[i];
      final isLast = i == catItems.length - 1;
      final sub = item.subcategory;
      if (sub != null && sub != lastSub) {
        lastSub = sub;
        widgets.add(
          Padding(
            padding: EdgeInsets.fromLTRB(16, i == 0 ? 12 : 8, 16, 4),
            child: Text(
              sub.toUpperCase(),
              style: sans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: const Color(0xFF9A94A0),
              ),
            ),
          ),
        );
      }
      widgets.add(
        _ItemRow(
          label: item.label,
          checked: item.checked,
          isCustom: item.isCustom,
          isLast: isLast,
          sans: sans,
          onTap: () => _toggle(item),
          onLongPress: () => _confirmRemove(item),
        ),
      );
    }
    return widgets;
  }

  Future<void> _confirmRemove(HospitalBagItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove item?'),
        content: Text('Remove “${item.label}” from your hospital bag list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) await _remove(item);
  }
}

class _AddResult {
  const _AddResult({required this.label, required this.categoryId});
  final String label;
  final String categoryId;
}

class _AddItemSheet extends StatefulWidget {
  const _AddItemSheet();

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _ctrl = TextEditingController();
  String _categoryId = HospitalBagService.categories.first.id;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _TextStyleFn sans = GoogleFonts.plusJakartaSans;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0D8DC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add to hospital bag',
            style: sans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2D2A32),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add anything else you want to pack — snacks, gifts, extras.',
            style: sans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B6570),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Item name',
              hintText: 'e.g. Favorite pillow',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            style: sans(fontSize: 15, fontWeight: FontWeight.w500),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 14),
          Text(
            'Category',
            style: sans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2A32),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: HospitalBagService.categories.map((c) {
              final selected = c.id == _categoryId;
              return ChoiceChip(
                label: Text('${c.emoji} ${c.name}'),
                selected: selected,
                onSelected: (_) => setState(() => _categoryId = c.id),
                selectedColor: const Color(0xFF1A8C6A).withValues(alpha: 0.15),
                labelStyle: sans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? const Color(0xFF1A8C6A)
                      : const Color(0xFF2D2A32),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A8C6A),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Add item',
              style: sans(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final label = _ctrl.text.trim();
    if (label.isEmpty) return;
    Navigator.pop(
      context,
      _AddResult(label: label, categoryId: _categoryId),
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
  final _TextStyleFn sans;
  final _TextStyleFn serif;

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
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$packedItems of $totalItems packed',
            style: serif(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            packedItems == totalItems && totalItems > 0
                ? 'You\'re all packed — ready for the big day! 🎉'
                : packedItems > totalItems * 0.7
                    ? 'You\'re doing great — almost ready!'
                    : 'Keep going, you\'re making progress!',
            style: sans(
              fontSize: 13,
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
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
  final _TextStyleFn sans;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: sans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2A32),
            ),
          ),
        ),
        Text(
          '$packed / $total',
          style: sans(
            fontSize: 13,
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
    required this.isCustom,
    required this.isLast,
    required this.sans,
    required this.onTap,
    required this.onLongPress,
  });

  final String label;
  final bool checked;
  final bool isCustom;
  final bool isLast;
  final _TextStyleFn sans;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
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
                    color:
                        checked ? const Color(0xFF1A8C6A) : Colors.transparent,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: checked
                          ? const Color(0xFF6B6570)
                          : const Color(0xFF2D2A32),
                      decoration: checked ? TextDecoration.lineThrough : null,
                      decorationColor: const Color(0xFF6B6570),
                    ),
                  ),
                ),
                if (isCustom)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'Yours',
                      style: sans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A8C6A),
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
