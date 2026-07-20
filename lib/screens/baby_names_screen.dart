import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _NameEntry {
  const _NameEntry({
    required this.name,
    required this.meaning,
    required this.tag,
    required this.letterBg,
    required this.letterFg,
    required this.tagBg,
    required this.tagFg,
  });

  final String name;
  final String meaning;
  final String tag;
  final Color letterBg;
  final Color letterFg;
  final Color tagBg;
  final Color tagFg;
}

/// Searchable baby names with filters and favourites.
class BabyNamesScreen extends StatefulWidget {
  const BabyNamesScreen({super.key});

  @override
  State<BabyNamesScreen> createState() => _BabyNamesScreenState();
}

class _BabyNamesScreenState extends State<BabyNamesScreen> {
  static const _names = [
    _NameEntry(
      name: 'Amrita',
      meaning: 'Immortal, nectar of gods',
      tag: 'Malayalam · Girl',
      letterBg: Color(0xFFFFE4EE),
      letterFg: Color(0xFFC2185B),
      tagBg: Color(0xFFFFE4EE),
      tagFg: Color(0xFFAD1457),
    ),
    _NameEntry(
      name: 'Devi',
      meaning: 'Goddess, divine feminine',
      tag: 'Sanskrit · Girl',
      letterBg: Color(0xFFE8F5E9),
      letterFg: Color(0xFF2E7D32),
      tagBg: Color(0xFFE8F5E9),
      tagFg: Color(0xFF00695C),
    ),
    _NameEntry(
      name: 'Lakshmi',
      meaning: 'Goddess of wealth and fortune',
      tag: 'Malayalam · Girl',
      letterBg: Color(0xFFFFF3E0),
      letterFg: Color(0xFF6D4C41),
      tagBg: Color(0xFFFFF3E0),
      tagFg: Color(0xFF5D4037),
    ),
    _NameEntry(
      name: 'Nandita',
      meaning: 'Cheerful, happy',
      tag: 'Sanskrit · Girl',
      letterBg: Color(0xFFF3E5F5),
      letterFg: Color(0xFF6A1B9A),
      tagBg: Color(0xFFF3E5F5),
      tagFg: Color(0xFF4A148C),
    ),
    _NameEntry(
      name: 'Arjun',
      meaning: 'Bright, shining, hero',
      tag: 'Sanskrit · Boy',
      letterBg: Color(0xFFE3F2FD),
      letterFg: Color(0xFF1565C0),
      tagBg: Color(0xFFE3F2FD),
      tagFg: Color(0xFF0D47A1),
    ),
    _NameEntry(
      name: 'Kiran',
      meaning: 'Ray of light',
      tag: 'Malayalam · Unisex',
      letterBg: Color(0xFFE0F7FA),
      letterFg: Color(0xFF00838F),
      tagBg: Color(0xFFE0F7FA),
      tagFg: Color(0xFF006064),
    ),
  ];

  final Set<String> _favourites = {};
  String _filter = 'All';
  String _query = '';

  static const _filters = ['All', 'Girl', 'Boy', 'Unisex', 'Malayalam', 'Sanskrit'];

  bool _matches(_NameEntry n) {
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      if (!n.name.toLowerCase().contains(q) && !n.meaning.toLowerCase().contains(q)) {
        return false;
      }
    }
    switch (_filter) {
      case 'All':
        return true;
      case 'Girl':
        return n.tag.contains('Girl');
      case 'Boy':
        return n.tag.contains('Boy');
      case 'Unisex':
        return n.tag.contains('Unisex');
      case 'Malayalam':
        return n.tag.contains('Malayalam');
      case 'Sanskrit':
        return n.tag.contains('Sanskrit');
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final serif = GoogleFonts.fraunces;
    final sans = GoogleFonts.plusJakartaSans;
    final visible = _names.where(_matches).toList();

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
          'Baby Names',
          style: serif(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.black),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _favourites.isEmpty
                        ? 'No favourites yet'
                        : _favourites.join(', '),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.favorite_border, color: Color(0xFFE04B84), size: 18),
            label: Text(
              'Favourites',
              style: sans(fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFFE04B84)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD54F), Color(0xFF8D6E63)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FIND THE PERFECT NAME',
                  style: sans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Baby Name Finder',
                  style: serif(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Beautiful names with meanings — Malayalam, Sanskrit & more',
                  style: serif(
                    fontSize: 14,
                    height: 1.35,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search names...',
              hintStyle: sans(color: Colors.black38),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.black45),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (context, i) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f = _filters[i];
                final sel = f == _filter;
                return ChoiceChip(
                  label: Text(
                    f == 'Girl'
                        ? 'Girl 🌸'
                        : f == 'Boy'
                            ? 'Boy ✨'
                            : f,
                    style: sans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: sel ? Colors.white : Colors.black87,
                    ),
                  ),
                  selected: sel,
                  onSelected: (_) => setState(() => _filter = f),
                  selectedColor: const Color(0xFF8D6E63),
                  backgroundColor: const Color(0xFFF0F0F0),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          if (visible.isEmpty)
            Text('No names match.', style: serif(fontSize: 16))
          else
            ...visible.map((n) {
              final fav = _favourites.contains(n.name);
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: n.letterBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        n.name.isNotEmpty ? n.name.substring(0, 1) : '?',
                        style: serif(fontSize: 20, fontWeight: FontWeight.w800, color: n.letterFg),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.name, style: serif(fontSize: 18, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(n.meaning, style: sans(fontSize: 13, color: Colors.black54, height: 1.3)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: n.tagBg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              n.tag,
                              style: sans(fontSize: 11, fontWeight: FontWeight.w700, color: n.tagFg),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (fav) {
                            _favourites.remove(n.name);
                          } else {
                            _favourites.add(n.name);
                          }
                        });
                      },
                      icon: Icon(
                        fav ? Icons.favorite : Icons.favorite_border,
                        color: fav ? const Color(0xFFE04B84) : Colors.black38,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
