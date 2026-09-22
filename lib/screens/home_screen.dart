// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/shared_widgets.dart';
import 'lessons_screen.dart';
import 'games_screen.dart';
import 'parent_screen.dart';
import 'progress_screen.dart';

// ── Floating particle model ───────────────────────────────────────────────
class _Particle {
  double x, y, size, speed, opacity;
  Color color;
  _Particle({
    required this.x, required this.y, required this.size,
    required this.speed, required this.opacity, required this.color,
  });
}

// ── Animated starfield painter (twinkling) ────────────────────────────────
class _TwinkleStarPainter extends CustomPainter {
  final List<Offset> stars;
  final List<double> sizes;
  final List<Color> colors;
  final double twinkle; // 0.0 → 1.0 animation value

  _TwinkleStarPainter({
    required this.stars,
    required this.sizes,
    required this.colors,
    required this.twinkle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < stars.length; i++) {
      // Each star twinkles at a different phase
      final phase = (i / stars.length);
      final t = (sin((twinkle + phase) * pi * 2) + 1) / 2; // 0..1 sine wave
      final opacity = 0.2 + t * 0.7;
      final radius = sizes[i] * (0.7 + t * 0.6);

      final paint = Paint()
        ..color = colors[i % colors.length].withOpacity(opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.8);

      canvas.drawCircle(
        Offset(stars[i].dx * size.width, stars[i].dy * size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TwinkleStarPainter old) => old.twinkle != twinkle;
}

// ── Floating orb painter ──────────────────────────────────────────────────
class _OrbPainter extends CustomPainter {
  final List<_Particle> particles;

  _OrbPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withOpacity(p.opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 1.5);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) => true;
}

// ── Home screen ───────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Mascot float
  late AnimationController _mascotCtrl;
  late Animation<double> _mascotAnim;

  // Mascot pulse glow
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  // Starfield twinkle
  late AnimationController _starCtrl;
  late Animation<double> _starAnim;

  // Floating orbs
  late AnimationController _orbCtrl;
  final List<_Particle> _orbs = [];

  // Staggered entrance for sections
  late AnimationController _entranceCtrl;

  // Shimmer on XP bar
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  // Stars & colors
  late List<Offset> _stars;
  late List<double> _starSizes;
  final _starColors = [
    AppColors.gold, AppColors.pink, AppColors.teal,
    const Color(0xFFC9A0FF), Colors.white, const Color(0xFF90CAF9)
  ];
  final _rng = Random();

  @override
  void initState() {
    super.initState();

    // ── Mascot float ──
    _mascotCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _mascotAnim = Tween<double>(begin: 0, end: -12).animate(
        CurvedAnimation(parent: _mascotCtrl, curve: Curves.easeInOut));

    // ── Mascot glow pulse ──
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    // ── Twinkling stars ──
    _stars = List.generate(38, (_) => Offset(_rng.nextDouble(), _rng.nextDouble()));
    _starSizes = List.generate(38, (_) => _rng.nextDouble() * 2.5 + 0.8);
    _starCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _starAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_starCtrl);

    // ── Floating orbs ──
    _orbs.addAll(List.generate(10, (i) => _Particle(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      size: _rng.nextDouble() * 18 + 8,
      speed: _rng.nextDouble() * 0.0008 + 0.0003,
      opacity: _rng.nextDouble() * 0.12 + 0.04,
      color: [
        AppColors.gold, AppColors.pink, AppColors.teal,
        const Color(0xFFC9A0FF), AppColors.blue,
      ][i % 5],
    )));
    _orbCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_updateOrbs)
      ..repeat();

    // ── Entrance animations (staggered) ──
    _entranceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _entranceCtrl.forward();

    // ── XP bar shimmer ──
    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
        CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().startSessionTimer();
    });
  }

  void _updateOrbs() {
    for (final orb in _orbs) {
      orb.y -= orb.speed;
      if (orb.y < -0.05) {
        orb.y = 1.05;
        orb.x = _rng.nextDouble();
        orb.opacity = _rng.nextDouble() * 0.12 + 0.04;
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _mascotCtrl.dispose();
    _glowCtrl.dispose();
    _starCtrl.dispose();
    _orbCtrl.dispose();
    _entranceCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    final provider = context.read<AppProvider>();
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LessonsScreen()));
    } else if (index == 2) {
      if (!provider.gameAccess) { _showGameLockedSnack(); return; }
      Navigator.push(context, MaterialPageRoute(builder: (_) => const GamesScreen()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen()));
    }
  }

  void _showGameLockedSnack() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('🎮 Games are locked by your parent.',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      backgroundColor: const Color(0xFF37474F),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1B0A4F), AppColors.darkBg, AppColors.darkBg3],
                ),
              ),
              child: Stack(
                children: [
                  // ── Twinkling starfield ──
                  AnimatedBuilder(
                    animation: _starAnim,
                    builder: (_, __) => CustomPaint(
                      size: Size.infinite,
                      painter: _TwinkleStarPainter(
                        stars: _stars,
                        sizes: _starSizes,
                        colors: _starColors,
                        twinkle: _starAnim.value,
                      ),
                    ),
                  ),

                  // ── Floating color orbs ──
                  CustomPaint(
                    size: Size.infinite,
                    painter: _OrbPainter(_orbs),
                  ),

                  SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // ── Logo with animated glow ──
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                            child: AnimatedBuilder(
                              animation: _glowAnim,
                              builder: (_, __) => Column(
                                children: [
                                  Text('KidsPhonics',
                                      style: GoogleFonts.fredoka(
                                          fontSize: 30,
                                          color: AppColors.gold,
                                          shadows: [
                                            Shadow(
                                              color: AppColors.gold.withOpacity(_glowAnim.value * 0.7),
                                              blurRadius: 20 + _glowAnim.value * 12,
                                            ),
                                          ])),
                                  Text('Grade 1 · Learn · Play · Level Up',
                                      style: GoogleFonts.nunito(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF9B6FC4),
                                          letterSpacing: 2)),
                                ],
                              ),
                            ),
                          ),

                          // ── Mascot with glow ring ──
                          AnimatedBuilder(
                            animation: Listenable.merge([_mascotAnim, _glowAnim]),
                            builder: (_, __) => Transform.translate(
                              offset: Offset(0, _mascotAnim.value),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Glow ring behind mascot
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.gold.withOpacity(_glowAnim.value * 0.35),
                                          blurRadius: 30 + _glowAnim.value * 20,
                                          spreadRadius: 5,
                                        ),
                                        BoxShadow(
                                          color: AppColors.pink.withOpacity(_glowAnim.value * 0.2),
                                          blurRadius: 40,
                                          spreadRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Text('🦄', style: TextStyle(fontSize: 72)),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          // ── XP card with entrance + shimmer ──
                          FadeTransition(
                            opacity: CurvedAnimation(parent: _entranceCtrl,
                                curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _entranceCtrl,
                                curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
                              )),
                              child: _XpCard(
                                  provider: provider, shimmerAnim: _shimmerAnim),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ── Gem row with entrance ──
                          FadeTransition(
                            opacity: CurvedAnimation(parent: _entranceCtrl,
                                curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack)),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _entranceCtrl,
                                curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
                              )),
                              child: _GemRow(provider: provider),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ── Section label ──
                          FadeTransition(
                            opacity: CurvedAnimation(parent: _entranceCtrl,
                                curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack)),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(18, 0, 16, 8),
                                child: Text('What do you want to do?',
                                    style: GoogleFonts.nunito(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF6A3FA0),
                                        letterSpacing: 1.5)),
                              ),
                            ),
                          ),

                          // ── Main grid with entrance ──
                          FadeTransition(
                            opacity: CurvedAnimation(parent: _entranceCtrl,
                                curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack)),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _entranceCtrl,
                                curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
                              )),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                                child: GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1.0,
                                  children: [
                                    _MainCard(
                                      icon: '📖', title: 'Lessons',
                                      subtitle: 'Letter sounds + pictures!',
                                      gradient: const LinearGradient(
                                          colors: [AppColors.teal, AppColors.tealDark]),
                                      onTap: () => Navigator.push(context,
                                          MaterialPageRoute(
                                              builder: (_) => const LessonsScreen())),
                                    ),
                                    _MainCard(
                                      icon: provider.gameAccess ? '🎮' : '🔒',
                                      title: 'Game Zone',
                                      subtitle: provider.gameAccess
                                          ? 'Play & earn XP'
                                          : 'Locked by parent',
                                      gradient: provider.gameAccess
                                          ? const LinearGradient(
                                              colors: [AppColors.pink, Color(0xFFC2185B)])
                                          : LinearGradient(colors: [
                                              Colors.grey.shade800,
                                              Colors.grey.shade900
                                            ]),
                                      isDisabled: !provider.gameAccess,
                                      onTap: () {
                                        if (!provider.gameAccess) {
                                          _showGameLockedSnack();
                                          return;
                                        }
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (_) => const GamesScreen()));
                                      },
                                    ),
                                    _MainCard(
                                      icon: '📊', title: 'Progress',
                                      subtitle: 'See your stats!',
                                      gradient: const LinearGradient(
                                          colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)]),
                                      onTap: () => Navigator.push(context,
                                          MaterialPageRoute(
                                              builder: (_) => const ProgressScreen())),
                                    ),
                                    _MainCard(
                                      icon: '👨‍👩‍👧',
                                      iconWidget: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: const [
                                          Text('👨', style: TextStyle(fontSize: 24)),
                                          Text('👧', style: TextStyle(fontSize: 20)),
                                          Text('👩', style: TextStyle(fontSize: 24)),
                                        ],
                                      ),
                                      title: 'Parents',
                                      subtitle: 'Controls & goals',
                                      gradient: const LinearGradient(
                                          colors: [Color(0xFF37474F), Color(0xFF263238)]),
                                      onTap: () => Navigator.push(context,
                                          MaterialPageRoute(
                                              builder: (_) => const ParentScreen())),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          KidsBottomNav(currentIndex: 0, onTap: _onNavTap),
        ],
      ),
    );
  }
}

// ── XP Card with shimmer ──────────────────────────────────────────────────
class _XpCard extends StatelessWidget {
  final AppProvider provider;
  final Animation<double> shimmerAnim;
  const _XpCard({required this.provider, required this.shimmerAnim});

  @override
  Widget build(BuildContext context) {
    final level = provider.level;
    final xpInLevel = provider.xp % 200;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          // Avatar with pulsing border
          AnimatedBuilder(
            animation: shimmerAnim,
            builder: (_, __) => Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.pink, AppColors.orange]),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.25), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pink.withOpacity(
                        0.2 + ((shimmerAnim.value + 1) / 3) * 0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Center(child: Text('🐣', style: TextStyle(fontSize: 24))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('Grade 1 Learner ',
                      style: GoogleFonts.nunito(
                          fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                    decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('LVL $level',
                        style: GoogleFonts.nunito(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF5A3000))),
                  ),
                ]),
                const SizedBox(height: 5),
                Row(children: [
                  Expanded(
                    child: AnimatedBuilder(
                      animation: shimmerAnim,
                      builder: (_, __) => ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Stack(
                          children: [
                            LinearProgressIndicator(
                              value: xpInLevel / 200,
                              backgroundColor: Colors.white.withOpacity(0.12),
                              valueColor:
                                  const AlwaysStoppedAnimation(AppColors.gold),
                              minHeight: 9,
                            ),
                            // Shimmer sweep
                            Positioned.fill(
                              child: FractionallySizedBox(
                                widthFactor: xpInLevel / 200,
                                alignment: Alignment.centerLeft,
                                child: LayoutBuilder(
                                  builder: (_, c) => ShaderMask(
                                    shaderCallback: (rect) => LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.5),
                                        Colors.transparent,
                                      ],
                                      stops: [
                                        (shimmerAnim.value - 0.3).clamp(0.0, 1.0),
                                        shimmerAnim.value.clamp(0.0, 1.0),
                                        (shimmerAnim.value + 0.3).clamp(0.0, 1.0),
                                      ],
                                    ).createShader(
                                      Rect.fromLTWH(0, 0, rect.width, rect.height),
                                    ),
                                    child: Container(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text('${provider.xp} XP',
                      style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFC9A0FF))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gem row ───────────────────────────────────────────────────────────────
class _GemRow extends StatelessWidget {
  final AppProvider provider;
  const _GemRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final gems = [
      ('🔥', '${provider.streak}-Day', 'Streak'),
      ('⭐', '${provider.stars} Stars', 'Earned'),
      ('🔤', '${provider.learnedLetters.length}/26', 'Letters'),
      ('🏆', 'LVL ${provider.level}', 'Level'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: gems.map((g) => Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 7),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: Column(children: [
              Text(g.$1, style: const TextStyle(fontSize: 17)),
              const SizedBox(height: 2),
              Text(g.$2,
                  style: GoogleFonts.nunito(
                      fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.gold)),
              Text(g.$3,
                  style: GoogleFonts.nunito(
                      fontSize: 9, color: const Color(0xFF7A5FA0))),
            ]),
          ),
        )).toList(),
      ),
    );
  }
}

// ── Main card with press-scale + bounce ───────────────────────────────────
class _MainCard extends StatefulWidget {
  final String icon, title, subtitle;
  final Widget? iconWidget;
  final Gradient gradient;
  final VoidCallback onTap;
  final String? badge;
  final bool isDisabled;

  const _MainCard({
    required this.icon, required this.title, required this.subtitle,
    required this.gradient, required this.onTap,
    this.iconWidget, this.badge, this.isDisabled = false,
  });

  @override
  State<_MainCard> createState() => _MainCardState();
}

class _MainCardState extends State<_MainCard> with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;
  double _pressScale = 1.0;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1800 + widget.title.length * 50))
      ..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -7).animate(
        CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isDisabled
          ? null
          : (_) => setState(() => _pressScale = 0.93),
      onTapUp: widget.isDisabled
          ? null
          : (_) {
              setState(() => _pressScale = 1.0);
              widget.onTap();
            },
      onTapCancel: () => setState(() => _pressScale = 1.0),
      child: AnimatedScale(
        scale: _pressScale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(22),
            border: widget.isDisabled
                ? Border.all(color: Colors.white.withOpacity(0.09))
                : null,
            boxShadow: widget.isDisabled
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
          padding: const EdgeInsets.all(14),
          child: Stack(
            children: [
              SizedBox.expand(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _bounceAnim,
                      builder: (_, __) => Transform.translate(
                        offset: Offset(
                            0, widget.isDisabled ? 0 : _bounceAnim.value),
                        child: widget.iconWidget ??
                            Text(widget.icon,
                                style: TextStyle(
                                    fontSize: widget.isDisabled ? 28 : 36)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(widget.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                            fontSize: widget.isDisabled ? 13 : 16,
                            color: widget.isDisabled
                                ? const Color(0xFF5A3F7A)
                                : Colors.white)),
                    const SizedBox(height: 3),
                    Text(widget.subtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: widget.isDisabled
                                ? const Color(0xFF4A3060)
                                : Colors.white.withOpacity(0.75))),
                  ],
                ),
              ),
              if (widget.badge != null)
                Positioned(
                  top: 0, right: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFF4757),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(widget.badge!,
                        style: GoogleFonts.nunito(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
