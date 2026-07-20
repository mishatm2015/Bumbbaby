import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MusicMantrasScreen extends StatefulWidget {
  const MusicMantrasScreen({super.key});

  @override
  State<MusicMantrasScreen> createState() => _MusicMantrasScreenState();
}

class _MusicMantrasScreenState extends State<MusicMantrasScreen>
    with SingleTickerProviderStateMixin {
  static const _ink = Color(0xFF2D2A32);
  static const _muted = Color(0xFF6B6570);

  static const _categories = [
    'Mantras',
    'Classical',
    'Lullabies',
    'Nature sounds',
    'Meditation',
  ];

  int _selectedCategory = 0;
  int _nowPlayingIdx = 0;
  bool _isPlaying = false;
  bool _headerFav = false;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  final List<_Track> _tracks = [
    _Track(
      emoji: '🎵',
      emojiColor: Color(0xFFFF7BAC),
      title: 'Garbha Raksha Mantra',
      category: 'Classical',
      mood: 'relaxation',
      duration: '8:00',
      isFav: false,
    ),
    _Track(
      emoji: '🕉',
      emojiColor: Color(0xFF9B7ED9),
      title: 'Lalitha Sahasranama',
      category: 'Devotional',
      mood: 'energy',
      duration: '45:00',
      isFav: false,
    ),
    _Track(
      emoji: '🔔',
      emojiColor: Color(0xFFFF9B50),
      title: 'Om Namah Shivaya',
      category: 'Mantra',
      mood: 'calming',
      duration: '15:00',
      isFav: false,
    ),
    _Track(
      emoji: '🎶',
      emojiColor: Color(0xFF4A9FE8),
      title: 'Saraswati Vandana',
      category: 'Classical',
      mood: 'focus',
      duration: '10:00',
      isFav: false,
    ),
    _Track(
      emoji: '🌸',
      emojiColor: Color(0xFFC97B9A),
      title: 'Hanuman Chalisa',
      category: 'Devotional',
      mood: 'strength',
      duration: '20:00',
      isFav: false,
    ),
    _Track(
      emoji: '🌙',
      emojiColor: Color(0xFF1A8C6A),
      title: 'Brahma Murari',
      category: 'Classical',
      mood: 'peaceful',
      duration: '12:00',
      isFav: false,
    ),
    _Track(
      emoji: '✨',
      emojiColor: Color(0xFFE85A5A),
      title: 'Gayatri Mantra',
      category: 'Mantra',
      mood: 'blessing',
      duration: '11:00',
      isFav: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _playTrack(int idx) {
    setState(() {
      if (_nowPlayingIdx == idx && _isPlaying) {
        _isPlaying = false;
      } else {
        _nowPlayingIdx = idx;
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sans = GoogleFonts.plusJakartaSans;
    final serif = GoogleFonts.fraunces;
    final nowPlaying = _tracks[_nowPlayingIdx];

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
          'Music & Mantras',
          style: sans(fontWeight: FontWeight.w700, fontSize: 17.0, color: _ink),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _headerFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _headerFav ? const Color(0xFFE04B84) : _muted,
            ),
            onPressed: () => setState(() => _headerFav = !_headerFav),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        children: [
          // ── Hero card ──────────────────────────────────────────
          _HeroCard(serif: serif, sans: sans),
          const SizedBox(height: 20),

          // ── Now playing ────────────────────────────────────────
          _NowPlayingCard(
            track: nowPlaying,
            isPlaying: _isPlaying,
            pulseAnim: _pulseAnim,
            sans: sans,
            onPlayPause: () => setState(() => _isPlaying = !_isPlaying),
            onPrev: () => setState(() {
              _nowPlayingIdx =
                  (_nowPlayingIdx - 1 + _tracks.length) % _tracks.length;
            }),
            onNext: () => setState(() {
              _nowPlayingIdx = (_nowPlayingIdx + 1) % _tracks.length;
            }),
          ),
          const SizedBox(height: 20),

          // ── Category tabs ──────────────────────────────────────
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, s) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final selected = idx == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = idx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFE04B84)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFE04B84)
                            : const Color(0xFFF0E6EA),
                      ),
                    ),
                    child: Text(
                      _categories[idx],
                      style: sans(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : _muted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // ── Track list ─────────────────────────────────────────
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
              children: _tracks.asMap().entries.map((entry) {
                final idx = entry.key;
                final track = entry.value;
                final isLast = idx == _tracks.length - 1;
                final isActive = idx == _nowPlayingIdx;
                return _TrackTile(
                  track: track,
                  isActive: isActive,
                  isPlaying: isActive && _isPlaying,
                  isLast: isLast,
                  sans: sans,
                  onTap: () => _playTrack(idx),
                  onFav: () => setState(() => track.isFav = !track.isFav),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.serif, required this.sans});

  final dynamic serif;
  final dynamic sans;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE9649A), Color(0xFFC94F7D)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE04B84).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'SOOTHING SOUNDS',
            style: sans(
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'For you & baby',
            style: serif(
              fontSize: 26.0,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Music aids baby brain development',
            style: sans(
              fontSize: 13.0,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NowPlayingCard extends StatelessWidget {
  const _NowPlayingCard({
    required this.track,
    required this.isPlaying,
    required this.pulseAnim,
    required this.sans,
    required this.onPlayPause,
    required this.onPrev,
    required this.onNext,
  });

  final _Track track;
  final bool isPlaying;
  final Animation<double> pulseAnim;
  final dynamic sans;
  final VoidCallback onPlayPause;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: isPlaying ? pulseAnim : const AlwaysStoppedAnimation(1.0),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: track.emojiColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      track.emoji,
                      style: const TextStyle(fontSize: 28.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: sans(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D2A32),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${track.category} · ${track.duration}',
                      style: sans(
                        fontSize: 12.0,
                        color: const Color(0xFF6B6570),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Fake progress bar
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: 0.35,
                  minHeight: 4,
                  backgroundColor: const Color(0xFFF0E8EC),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFFE04B84),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '2:48',
                    style: sans(
                      fontSize: 11.0,
                      color: const Color(0xFF6B6570),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    track.duration,
                    style: sans(
                      fontSize: 11.0,
                      color: const Color(0xFF6B6570),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, size: 30),
                color: const Color(0xFF2D2A32),
                onPressed: onPrev,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onPlayPause,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE04B84),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE04B84).withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, size: 30),
                color: const Color(0xFF2D2A32),
                onPressed: onNext,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({
    required this.track,
    required this.isActive,
    required this.isPlaying,
    required this.isLast,
    required this.sans,
    required this.onTap,
    required this.onFav,
  });

  final _Track track;
  final bool isActive;
  final bool isPlaying;
  final bool isLast;
  final dynamic sans;
  final VoidCallback onTap;
  final VoidCallback onFav;

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
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: track.emojiColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: isActive && isPlaying
                        ? Icon(Icons.equalizer_rounded,
                            color: track.emojiColor, size: 24)
                        : Text(
                            track.emoji,
                            style: const TextStyle(fontSize: 22.0),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: sans(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? const Color(0xFFE04B84)
                              : const Color(0xFF2D2A32),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${track.category} · ${track.mood}',
                        style: sans(
                          fontSize: 12.0,
                          color: const Color(0xFF6B6570),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  track.duration,
                  style: sans(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B6570),
                  ),
                ),
              ],
            ),
          ),
          if (!isLast)
            const Divider(
              height: 1,
              indent: 76,
              endIndent: 0,
              color: Color(0xFFF0E8EC),
            ),
        ],
      ),
    );
  }
}

class _Track {
  _Track({
    required this.emoji,
    required this.emojiColor,
    required this.title,
    required this.category,
    required this.mood,
    required this.duration,
    required this.isFav,
  });

  final String emoji;
  final Color emojiColor;
  final String title;
  final String category;
  final String mood;
  final String duration;
  bool isFav;
}
