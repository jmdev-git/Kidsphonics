// lib/widgets/shared_widgets.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/difficulty.dart';
// NOTE: ProgressScreen is imported lazily inside KidsBottomNav to avoid
// circular imports — it is resolved at runtime via a builder callback.

// ── Starfield background painter ──────────────────────────────────────────
class StarfieldPainter extends CustomPainter {
  final List<Offset> stars;
  final List<double> sizes;
  final List<Color> colors;

  StarfieldPainter({required this.stars, required this.sizes, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < stars.length; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length].withOpacity(0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(stars[i].dx * size.width, stars[i].dy * size.height),
        sizes[i],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── App-wide bottom nav bar ───────────────────────────────────────────────
class KidsBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const KidsBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': '🏠', 'label': 'Home'},
      {'icon': '📖', 'label': 'Lessons'},
      {'icon': '🎮', 'label': 'Games'},
      {'icon': '📊', 'label': 'Progress'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF08051A),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.07))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(items.length, (i) {
          final isActive = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(items[i]['icon']!, style: TextStyle(
                    fontSize: 22,
                    shadows: isActive ? [Shadow(color: AppColors.gold.withOpacity(0.7), blurRadius: 8)] : [],
                  )),
                  const SizedBox(height: 3),
                  Text(
                    items[i]['label']!,
                    style: GoogleFonts.nunito(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: isActive ? AppColors.gold : const Color(0xFF3D2A6E),
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Screen header ─────────────────────────────────────────────────────────
class KidsHeader extends StatelessWidget {
  final String title;
  final Gradient gradient;
  final Color textColor;
  final VoidCallback onBack;
  final Widget? trailing;

  const KidsHeader({
    super.key,
    required this.title,
    required this.gradient,
    required this.textColor,
    required this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16, right: 16, bottom: 14,
      ),
      decoration: BoxDecoration(gradient: gradient),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(Icons.arrow_back_ios_new, color: textColor, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title, style: GoogleFonts.fredoka(fontSize: 21, color: textColor)),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── Speaker button ────────────────────────────────────────────────────────
class SpeakButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  final Color bgColor;

  const SpeakButton({super.key, required this.onTap, this.size = 48, this.bgColor = AppColors.gold});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor, bgColor.withOpacity(0.7)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: bgColor.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)],
        ),
        child: const Center(child: Text('🔊', style: TextStyle(fontSize: 22))),
      ),
    );
  }
}

// ── Voice chip (indicator) ────────────────────────────────────────────────
class VoiceChip extends StatelessWidget {
  const VoiceChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7, height: 7,
            decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text('Audio', style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.gold)),
        ],
      ),
    );
  }
}

// ── XP badge ─────────────────────────────────────────────────────────────
class XpBadge extends StatelessWidget {
  final String text;
  final Color textColor;

  const XpBadge({super.key, required this.text, this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: textColor)),
    );
  }
}

// ── Confetti overlay ──────────────────────────────────────────────────────
class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final GlobalKey<ConfettiOverlayState> overlayKey;

  const ConfettiOverlay({super.key, required this.child, required this.overlayKey});

  @override
  ConfettiOverlayState createState() => ConfettiOverlayState();
}

class ConfettiOverlayState extends State<ConfettiOverlay> with TickerProviderStateMixin {
  List<_ConfettiPiece> _pieces = [];
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  }

  void fire() {
    final colors = [AppColors.gold, AppColors.pink, AppColors.teal, AppColors.purple,
                    const Color(0xFFFF4757), AppColors.blue, AppColors.orange];
    _pieces = List.generate(36, (i) => _ConfettiPiece(
      x: 0.05 + (i % 10) * 0.09,
      color: colors[i % colors.length],
      delay: (i * 0.02),
    ));
    _ctrl.forward(from: 0);
    setState(() {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            if (_ctrl.value == 0) return const SizedBox();
            return IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: _ConfettiPainter(_pieces, _ctrl.value),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ConfettiPiece {
  final double x, delay;
  final Color color;
  _ConfettiPiece({required this.x, required this.color, required this.delay});
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final double progress;
  _ConfettiPainter(this.pieces, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final t = (progress - p.delay).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final paint = Paint()
        ..color = p.color.withOpacity((1 - t).clamp(0, 1))
        ..style = PaintingStyle.fill;
      final y = size.height * 0.15 + t * size.height * 0.7;
      final x = p.x * size.width + (t * 30 * (p.x > 0.5 ? 1 : -1));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * 6.28);
      canvas.drawRect(const Rect.fromLTWH(-4, -4, 8, 8), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

// ── Difficulty picker bottom-sheet ───────────────────────────────────────

/// Shows a bottom-sheet for selecting a difficulty level, then calls [onSelected].
Future<void> showDifficultyPicker({
  required BuildContext context,
  required String gameTitle,
  required String gameIcon,
  required void Function(Difficulty) onSelected,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,   // lets the sheet grow taller than 50% of screen
    builder: (_) => _DifficultySheet(
      gameTitle: gameTitle,
      gameIcon: gameIcon,
      onSelected: onSelected,
    ),
  );
}

class _DifficultySheet extends StatelessWidget {
  final String gameTitle, gameIcon;
  final void Function(Difficulty) onSelected;

  const _DifficultySheet({
    required this.gameTitle,
    required this.gameIcon,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final difficulties = Difficulty.values;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomPad),
      decoration: const BoxDecoration(
        color: Color(0xFF120A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(gameIcon, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 6),
            Text(gameTitle,
                style: GoogleFonts.fredoka(fontSize: 20, color: Colors.white)),
            Text('Choose your difficulty',
                style: GoogleFonts.nunito(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: Colors.white54)),
            const SizedBox(height: 18),
            ...difficulties.map((d) {
              final colors = {
                Difficulty.easy:   [const Color(0xFF1B5E20), const Color(0xFF43A047)],
                Difficulty.medium: [const Color(0xFFF57F17), const Color(0xFFFFB300)],
                Difficulty.hard:   [const Color(0xFFB71C1C), const Color(0xFFE53935)],
              };
              final gradient = colors[d]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onSelected(d);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(children: [
                      Text(d.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(d.label,
                            style: GoogleFonts.fredoka(fontSize: 17, color: Colors.white)),
                        Text(d.description,
                            style: GoogleFonts.nunito(fontSize: 10,
                                fontWeight: FontWeight.w700, color: Colors.white70)),
                      ]),
                      const Spacer(),
                      Text('×${d.xpMultiplier.toStringAsFixed(1)} XP',
                          style: GoogleFonts.nunito(fontSize: 11,
                              fontWeight: FontWeight.w900, color: Colors.white70)),
                    ]),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
