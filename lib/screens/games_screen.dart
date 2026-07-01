// lib/screens/games_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/difficulty.dart';
import '../widgets/shared_widgets.dart';
import 'sound_match_screen.dart';
import 'memory_game_screen.dart';
import 'phonics_quiz_screen.dart';
import 'word_builder_screen.dart';
import 'voice_recognition_screen.dart';
import 'alphabet_order_screen.dart';
import 'lessons_screen.dart';
import 'progress_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  // ── Helper: show difficulty picker, then navigate ──────────────────────
  void _launchGame<T extends Widget>({
    required BuildContext context,
    required String gameTitle,
    required String gameIcon,
    required T Function(Difficulty) builder,
  }) {
    showDifficultyPicker(
      context: context,
      gameTitle: gameTitle,
      gameIcon: gameIcon,
      onSelected: (difficulty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => builder(difficulty)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          KidsHeader(
            title: '🎮 Game Zone',
            gradient: const LinearGradient(colors: [AppColors.pink, Color(0xFFC2185B)]),
            textColor: Colors.white,
            onBack: () => Navigator.pop(context),
            trailing: const VoiceChip(),
          ),

          Expanded(
            child: Container(
              color: AppColors.darkBg,
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  // ── Entertainment section ──
                  _SectionLabel(
                    label: '🎉 Entertainment',
                    color: AppColors.pink,
                    pill: 'For Fun',
                    pillColor: const Color(0xFFFF6B9D),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _GameCard(
                      icon: '🔊', title: 'Sound Match',
                      desc: 'See a picture, pick the letter!',
                      xp: '+15 XP',
                      gradient: const LinearGradient(colors: [Color(0xFFF9A825), AppColors.orangeDark]),
                      textColor: const Color(0xFF3E2000),
                      xpColor: AppColors.gold,
                      onTap: () => _launchGame(
                        context: context,
                        gameTitle: 'Sound Match',
                        gameIcon: '🔊',
                        builder: (d) => SoundMatchScreen(difficulty: d),
                      ),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _GameCard(
                      icon: '🃏', title: 'Memory Flip',
                      desc: 'Match letters to pictures!',
                      xp: '+20 XP',
                      gradient: const LinearGradient(colors: [AppColors.blue, AppColors.blueDark]),
                      textColor: const Color(0xFFBBDEFB),
                      xpColor: const Color(0xFF90CAF9),
                      onTap: () => _launchGame(
                        context: context,
                        gameTitle: 'Memory Flip',
                        gameIcon: '🃏',
                        builder: (d) => MemoryGameScreen(difficulty: d),
                      ),
                    )),
                  ]),
                  const SizedBox(height: 18),

                  // ── Academic section ──
                  _SectionLabel(
                    label: '🎓 Academic',
                    color: AppColors.teal,
                    pill: 'Learning',
                    pillColor: AppColors.teal,
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _GameCard(
                      icon: '❓', title: 'Phonics Quiz',
                      desc: 'See the picture, name the sound!',
                      xp: '+25 XP',
                      gradient: const LinearGradient(colors: [AppColors.green, AppColors.greenDark]),
                      textColor: const Color(0xFFC8E6C9),
                      xpColor: const Color(0xFFA5D6A7),
                      onTap: () => _launchGame(
                        context: context,
                        gameTitle: 'Phonics Quiz',
                        gameIcon: '❓',
                        builder: (d) => PhonicsQuizScreen(difficulty: d),
                      ),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _GameCard(
                      icon: '🔡', title: 'Word Builder',
                      desc: 'Tap letters, spell the picture!',
                      xp: '+30 XP',
                      gradient: const LinearGradient(colors: [AppColors.purple, AppColors.purpleDark]),
                      textColor: const Color(0xFFE1BEE7),
                      xpColor: const Color(0xFFCE93D8),
                      onTap: () => _launchGame(
                        context: context,
                        gameTitle: 'Word Builder',
                        gameIcon: '🔡',
                        builder: (d) => WordBuilderScreen(difficulty: d),
                      ),
                    )),
                  ]),
                  const SizedBox(height: 18),

                  // ── Voice Recognition section ──
                  _SectionLabel(
                    label: '🎤 Pronunciation',
                    color: const Color(0xFFCE93D8),
                    pill: 'New',
                    pillColor: const Color(0xFF9C27B0),
                  ),
                  const SizedBox(height: 10),
                  _GameCard(
                    icon: '🎤', title: 'Say It Right!',
                    desc: 'Speak the word — Kidsphonics checks your pronunciation!',
                    xp: '+10 XP per word',
                    gradient: const LinearGradient(
                        colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)]),
                    textColor: const Color(0xFFE1BEE7),
                    xpColor: const Color(0xFFCE93D8),
                    wide: true,
                    onTap: () => _launchGame(
                      context: context,
                      gameTitle: 'Say It Right!',
                      gameIcon: '🎤',
                      builder: (d) => VoiceRecognitionScreen(difficulty: d),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Alphabet Order ──
                  _SectionLabel(
                    label: '🔤 Order & Sequence',
                    color: const Color(0xFF4DB6AC),
                    pill: 'New',
                    pillColor: const Color(0xFF00796B),
                  ),
                  const SizedBox(height: 10),
                  _GameCard(
                    icon: '🔤', title: 'Alphabet Order',
                    desc: 'Tap A → Z in the right order!',
                    xp: '+3 XP per letter',
                    gradient: const LinearGradient(
                        colors: [Color(0xFF00796B), Color(0xFF004D40)]),
                    textColor: const Color(0xFFB2DFDB),
                    xpColor: const Color(0xFF80CBC4),
                    wide: true,
                    onTap: () => _launchGame(
                      context: context,
                      gameTitle: 'Alphabet Order',
                      gameIcon: '🔤',
                      builder: (d) => AlphabetOrderScreen(difficulty: d),
                    ),
                  ),
                ],
              ),
            ),
          ),

          KidsBottomNav(
            currentIndex: 2,
            onTap: (i) {
              if (i == 0) Navigator.pop(context);
              if (i == 1) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LessonsScreen()));
              }
              if (i == 3) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProgressScreen()));
              }
            },
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label, pill;
  final Color color, pillColor;
  const _SectionLabel(
      {required this.label,
      required this.color,
      required this.pill,
      required this.pillColor});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label,
          style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: pillColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: pillColor.withOpacity(0.4)),
        ),
        child: Text(pill,
            style: GoogleFonts.nunito(
                fontSize: 9, fontWeight: FontWeight.w900, color: pillColor)),
      ),
    ]);
  }
}

// ── Game card ─────────────────────────────────────────────────────────────
class _GameCard extends StatefulWidget {
  final String icon, title, desc, xp;
  final Gradient gradient;
  final Color textColor, xpColor;
  final VoidCallback onTap;
  final bool wide;

  const _GameCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.xp,
    required this.gradient,
    required this.textColor,
    required this.xpColor,
    required this.onTap,
    this.wide = false,
  });

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _a = Tween<double>(begin: 0, end: -8)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(22)),
        child: Stack(children: [
          widget.wide
              ? Row(children: [
                  AnimatedBuilder(
                    animation: _a,
                    builder: (_, __) => Transform.translate(
                      offset: Offset(0, _a.value),
                      child:
                          Text(widget.icon, style: const TextStyle(fontSize: 40)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.title,
                              style: GoogleFonts.fredoka(
                                  fontSize: 15, color: widget.textColor)),
                          const SizedBox(height: 4),
                          Text(widget.desc,
                              style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: widget.textColor.withOpacity(0.75))),
                        ]),
                  ),
                ])
              : Column(children: [
                  AnimatedBuilder(
                    animation: _a,
                    builder: (_, __) => Transform.translate(
                      offset: Offset(0, _a.value),
                      child:
                          Text(widget.icon, style: const TextStyle(fontSize: 40)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                          fontSize: 15, color: widget.textColor)),
                  const SizedBox(height: 6),
                  Text(widget.desc,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: widget.textColor.withOpacity(0.7))),
                ]),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20)),
              child: Text(widget.xp,
                  style: GoogleFonts.nunito(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: widget.xpColor)),
            ),
          ),
        ]),
      ),
    );
  }
}
