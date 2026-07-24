import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/food_item.dart';
import '../services/food_repository.dart';
import 'food_detail_screen.dart';

class FoodLibraryScreen extends StatefulWidget {
  const FoodLibraryScreen({
    super.key,
    required this.category,
    required this.title,
  });

  final String category;
  final String title;

  @override
  State<FoodLibraryScreen> createState() => _FoodLibraryScreenState();
}

class _FoodLibraryScreenState extends State<FoodLibraryScreen> {
  static const _ink = Color(0xFF2D2A32);
  static const _muted = Color(0xFF6B6570);
  static const _accent = Color(0xFFE04B84);
  static const _bg = Color(0xFFFDF8FA);

  List<FoodItem> _items = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await FoodRepository.instance.byCategory(widget.category);
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  List<FoodItem> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items
        .where((f) =>
            f.name.toLowerCase().contains(q) ||
            f.benefits.toLowerCase().contains(q) ||
            f.cuisine.toLowerCase().contains(q))
        .toList();
  }

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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          widget.title,
          style: sans(fontWeight: FontWeight.w700, fontSize: 16, color: _ink),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search…',
                      hintStyle: sans(color: const Color(0xFF9A94A0)),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Color(0xFF9A94A0)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_filtered.length} options',
                      style: sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _muted,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) {
                      final food = _filtered[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      FoodDetailScreen(food: food),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: const Color(0xFFF0E6EA)),
                              ),
                              child: Row(
                                children: [
                                  Text(food.emoji,
                                      style: const TextStyle(fontSize: 28)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          food.name,
                                          style: sans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: _ink,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          food.benefits.isEmpty
                                              ? food.cuisine
                                                  .replaceAll('_', ' ')
                                              : food.benefits,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: sans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: _muted,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: Color(0xFF9A939E)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
