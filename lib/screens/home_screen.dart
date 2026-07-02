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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _mascotCtrl;
  late Animation<double> _mascotAnim;
  late List<Offset> _stars;
  late List<double> _starSizes;
  final _starColors = [AppColors.gold, AppColors.pink, AppColors.teal,
                       const Color(0xFFC9A0FF), Colors.white, const Color(0xFF90CAF9)];

  @override
  void initState() {
    super.initState();
    _mascotCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _mascotAnim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _mascotCtrl, curve: Curves.easeInOut));

    final rng = Random();
    _stars = List.generate(32, (_) => Offset(rng.nextDouble(), rng.nextDouble()));
    _starSizes = List.generate(32, (_) => rng.nextDouble() * 2.5 + 1);

    // Start the session timer as soon as the child reaches home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().startSessionTimer();
    });
  }

  @override
  void dispose() {
    _mascotCtrl.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    final provider = context.read<AppProvider>();
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LessonsScreen()));
    } else if (index == 2) {
      if (!provider.gameAccess) {
        _showGameLockedSnack();
        return;
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) => const GamesScreen()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen()));
    }
  }

  void _showGameLockedSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎮 Games are locked by your parent.',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        backgroundColor: const Color(0xFF37474F),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                  // Starfield
                  CustomPaint(
                    size: Size.infinite,
                    painter: StarfieldPainter(
                      stars: _stars, sizes: _starSizes, colors: _starColors),
                  ),
                  SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Logo
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                            child: Column(
                              children: [
                                Text('KidsPhonics',
                                    style: GoogleFonts.fredoka(fontSize: 30, color: AppColors.gold,
                                        shadows: [Shadow(color: AppColors.gold.withOpacity(0.5), blurRadius: 16)])),
                                Text('Grade 1 · Learn · Play · Level Up',
                                    style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900,
                                        color: const Color(0xFF9B6FC4), letterSpacing: 2)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.teal.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.teal.withOpacity(0.3)),
                                  ),
                                  child: Text('Salapingao Elementary School',
                                      style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w900,
                                          color: AppColors.teal, letterSpacing: 1)),
                                ),
                              ],
                            ),
                          ),

                          // Floating mascot
                          AnimatedBuilder(
                            animation: _mascotAnim,
                            builder: (_, __) => Transform.translate(
                              offset: Offset(0, _mascotAnim.value),
                              child: const Text('🦄', style: TextStyle(fontSize: 72)),
                            ),
                          ),

                          // XP card
                          _XpCard(provider: provider),

                          const SizedBox(height: 8),

                          // Gem row
                          _GemRow(provider: provider),

                          const SizedBox(height: 8),

                          // Section label
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(18, 0, 16, 8),
                              child: Text('What do you want to do?',
                                  style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900,
                                      color: const Color(0xFF6A3FA0), letterSpacing: 1.5)),
                            ),
                          ),

                          // Main grid
                          Padding(
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
                                  gradient: const LinearGradient(colors: [AppColors.teal, AppColors.tealDark]),
                                  onTap: () => Navigator.push(context,
                                      MaterialPageRoute(builder: (_) => const LessonsScreen())),
                                ),
                                _MainCard(
                                  icon: provider.gameAccess ? '🎮' : '🔒',
                                  title: 'Game Zone',
                                  subtitle: provider.gameAccess
                                      ? 'Play & earn XP'
                                      : 'Locked by parent',
                                  gradient: provider.gameAccess
                                      ? const LinearGradient(colors: [AppColors.pink, Color(0xFFC2185B)])
                                      : LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade900]),
                                  isDisabled: !provider.gameAccess,
                                  onTap: () {
                                    if (!provider.gameAccess) {
                                      _showGameLockedSnack();
                                      return;
                                    }
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (_) => const GamesScreen()));
                                  },
                                ),
                                _MainCard(
                                  icon: '📊', title: 'Progress',
                                  subtitle: 'See your stats!',
                                  gradient: const LinearGradient(
                                      colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)]),
                                  onTap: () => Navigator.push(context,
                                      MaterialPageRoute(builder: (_) => const ProgressScreen())),
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
                                      MaterialPageRoute(builder: (_) => const ParentScreen())),
                                ),
                              ],
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

class _XpCard extends StatelessWidget {
  final AppProvider provider;
  const _XpCard({required this.provider});

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
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.pink, AppColors.orange]),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.25), width: 2.5),
            ),
            child: const Center(child: Text('🐣', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('Grade 1 Learner ', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                    decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(20)),
                    child: Text('LVL $level', style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF5A3000))),
                  ),
                ]),
                const SizedBox(height: 5),
                Row(children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: xpInLevel / 200,
                        backgroundColor: Colors.white.withOpacity(0.12),
                        valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                        minHeight: 9,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text('${provider.xp} XP',
                      style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFFC9A0FF))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
              Text(g.$2, style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.gold)),
              Text(g.$3, style: GoogleFonts.nunito(fontSize: 9, color: const Color(0xFF7A5FA0))),
            ]),
          ),
        )).toList(),
      ),
    );
  }
}

class _MainCard extends StatefulWidget {
  final String icon, title, subtitle;
  final Widget? iconWidget;   // optional override — used for Parents card
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

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(vsync: this,
        duration: Duration(milliseconds: 1800 + widget.title.length * 50))..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -7).animate(
        CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _bounceCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isDisabled ? null : widget.onTap,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(22),
            border: widget.isDisabled ? Border.all(color: Colors.white.withOpacity(0.09)) : null,
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
                        offset: Offset(0, widget.isDisabled ? 0 : _bounceAnim.value),
                        child: widget.iconWidget ??
                            Text(widget.icon,
                                style: TextStyle(fontSize: widget.isDisabled ? 28 : 36)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(widget.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(fontSize: widget.isDisabled ? 13 : 16,
                            color: widget.isDisabled ? const Color(0xFF5A3F7A) : Colors.white)),
                    const SizedBox(height: 3),
                    Text(widget.subtitle, textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800,
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
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFFF4757),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(widget.badge!,
                        style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
