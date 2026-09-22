// lib/screens/missing_vowel_screen.dart
//
// Missing Vowel — shows a word with the vowel blanked out (C_T, D_G, S_N).
// Child taps the correct vowel to complete the word.
//
// Easy   : 3 short CVC words, 3 vowel choices (A, E, I)
// Medium : 5 words, 4 vowel choices (A, E, I, O)
// Hard   : 7 words, all 5 vowels (A, E, I, O, U)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../models/difficulty.dart';
import '../widgets/shared_widgets.dart';
import 'progress_screen.dart';

// ── Data ──────────────────────────────────────────────────────────────────

class _VowelPuzzle {
  final String emoji;
  final String word;       // full word e.g. "CAT"
  final String display;    // display with blank e.g. "C_T"
  final String vowel;      // correct vowel e.g. "A"
  final String hint;

  const _VowelPuzzle({
    required this.emoji,
    required this.word,
    required this.display,
    required this.vowel,
    required this.hint,
  });
}

const _easyPuzzles = [
  _VowelPuzzle(emoji: '🐱', word: 'CAT', display: 'C _ T', vowel: 'A', hint: 'C... A... T. Cat!'),
  _VowelPuzzle(emoji: '🥚', word: 'EGG', display: '_ G G', vowel: 'E', hint: 'E... G... G. Egg!'),
  _VowelPuzzle(emoji: '🐟', word: 'FIN', display: 'F _ N', vowel: 'I', hint: 'F... I... N. Fin!'),
];

// Medium — completely different words from Easy, all vowels in A/E/I/O/U set
const _mediumPuzzles = [
  _VowelPuzzle(emoji: '🐷', word: 'PIG',  display: 'P _ G', vowel: 'I', hint: 'P... I... G. Pig!'),
  _VowelPuzzle(emoji: '☀️', word: 'SUN',  display: 'S _ N', vowel: 'U', hint: 'S... U... N. Sun!'),
  _VowelPuzzle(emoji: '🐝', word: 'BEE',  display: 'B _ E', vowel: 'E', hint: 'B... E... E. Bee!'),
  _VowelPuzzle(emoji: '🐗', word: 'HOG',  display: 'H _ G', vowel: 'O', hint: 'H... O... G. Hog!'),
  _VowelPuzzle(emoji: '🦁', word: 'CUB',  display: 'C _ B', vowel: 'U', hint: 'C... U... B. Cub!'),
];

// Hard — completely different words from Easy and Medium
const _hardPuzzles = [
  _VowelPuzzle(emoji: '🐟', word: 'FIN',  display: 'F _ N', vowel: 'I', hint: 'F... I... N. Fin!'),
  _VowelPuzzle(emoji: '🌰', word: 'NUT',  display: 'N _ T', vowel: 'U', hint: 'N... U... T. Nut!'),
  _VowelPuzzle(emoji: '🧹', word: 'MOP',  display: 'M _ P', vowel: 'O', hint: 'M... O... P. Mop!'),
  _VowelPuzzle(emoji: '🐭', word: 'RAT',  display: 'R _ T', vowel: 'A', hint: 'R... A... T. Rat!'),
  _VowelPuzzle(emoji: '🦍', word: 'APE',  display: '_ P E', vowel: 'A', hint: 'A... P... E. Ape!'),
  _VowelPuzzle(emoji: '💋', word: 'LIP',  display: 'L _ P', vowel: 'I', hint: 'L... I... P. Lip!'),
  _VowelPuzzle(emoji: '🌿', word: 'OAK',  display: '_ A K', vowel: 'O', hint: 'O... A... K. Oak!'),
];

List<_VowelPuzzle> _puzzlesFor(Difficulty d) {
  switch (d) {
    case Difficulty.easy:   return _easyPuzzles;
    case Difficulty.medium: return _mediumPuzzles;
    case Difficulty.hard:   return _hardPuzzles;
  }
}

List<String> _vowelsFor(Difficulty d, String correctVowel) {
  // Build the vowel set for this difficulty, always ensuring
  // the correct answer is present — swap out last distractor if needed.
  List<String> base;
  switch (d) {
    case Difficulty.easy:   base = ['A', 'E', 'I']; break;
    case Difficulty.medium: base = ['A', 'E', 'I', 'O']; break;
    case Difficulty.hard:   base = ['A', 'E', 'I', 'O', 'U']; break;
  }
  // If correct vowel is already in set, return as-is
  if (base.contains(correctVowel)) return base;
  // Otherwise replace the last element with the correct vowel
  final result = List<String>.from(base);
  result[result.length - 1] = correctVowel;
  return result;
}

// ── Screen ────────────────────────────────────────────────────────────────

class MissingVowelScreen extends StatefulWidget {
  final Difficulty difficulty;
  const MissingVowelScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<MissingVowelScreen> createState() => _MissingVowelScreenState();
}

class _MissingVowelScreenState extends State<MissingVowelScreen>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  String? _picked;
  bool _answered = false;
  int _correct = 0;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  List<_VowelPuzzle> get _puzzles => _puzzlesFor(widget.difficulty);
  List<String> get _vowels => _vowelsFor(widget.difficulty, _puzzle.vowel);
  _VowelPuzzle get _puzzle => _puzzles[_index];

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -8)
        .animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().voiceFeedback.playIntroQuiz();
    });
  }

  @override
  void dispose() { _bounceCtrl.dispose(); super.dispose(); }

  void _pick(String vowel) async {
    if (_answered) return;
    final isCorrect = vowel == _puzzle.vowel;
    setState(() { _picked = vowel; });

    final provider = context.read<AppProvider>();
    if (isCorrect) {
      setState(() { _answered = true; _correct++; });
      // Play correct.mp3 tone first
      provider.audio.playCorrect();
      _confettiKey.currentState?.fire();
      provider.addXP((8 * widget.difficulty.xpMultiplier).round());
      provider.addStar();
      await Future.delayed(const Duration(milliseconds: 700));
      await provider.speak('${_puzzle.word}! The missing vowel is ${_puzzle.vowel}!');
    } else {
      // Play wrong.mp3 tone first
      provider.audio.playWrong();
      await Future.delayed(const Duration(milliseconds: 700));
      await provider.speak('Try again! Listen carefully!');
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _picked = null);
    }
  }

  void _next() {
    if (_index < _puzzles.length - 1) {
      setState(() { _index++; _picked = null; _answered = false; });
    } else {
      _showResults();
    }
  }

  void _restart() => setState(() { _index = 0; _picked = null; _answered = false; _correct = 0; });

  void _showResults() {
    final provider = context.read<AppProvider>();
    provider.audio.playWin();
    provider.addXP((15 * widget.difficulty.xpMultiplier).round());
    _confettiKey.currentState?.fireWin();
    provider.voiceFeedback.playWinByScore(_correct, _puzzles.length, game: 'quiz');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_correct == _puzzles.length ? '🏆' : '😊', style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 8),
          Text('Vowel Master!', style: GoogleFonts.fredoka(fontSize: 22, color: AppColors.gold)),
          Text('$_correct / ${_puzzles.length} correct!',
              style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.teal)),
          Text('+${(15 * widget.difficulty.xpMultiplier).round()} XP Earned!',
              style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFA5D6A7))),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () { Navigator.pop(context); _restart(); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A0DAD),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: Text('🔄 Play Again', style: GoogleFonts.fredoka(color: Colors.white, fontSize: 16)),
          )),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              showDifficultyPicker(context: context, gameTitle: 'Missing Vowel', gameIcon: '🔵',
                onSelected: (d) => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => MissingVowelScreen(difficulty: d))));
            },
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF6A0DAD)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: Text('🎯 Change Difficulty', style: GoogleFonts.fredoka(color: const Color(0xFF6A0DAD), fontSize: 15)),
          )),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: OutlinedButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withOpacity(0.15)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: Text('← Back to Games', style: GoogleFonts.fredoka(color: Colors.white54, fontSize: 15)),
          )),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    const accent = Color(0xFF6A0DAD);

    return Scaffold(
      body: ConfettiOverlay(
        overlayKey: _confettiKey,
        child: Column(children: [
          KidsHeader(
            title: '🔵 Missing Vowel',
            gradient: const LinearGradient(colors: [Color(0xFF6A0DAD), Color(0xFF9B1FD6)]),
            textColor: const Color(0xFFE1BEE7),
            onBack: () => Navigator.pop(context),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text('${widget.difficulty.emoji} ${widget.difficulty.label}',
                    style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text('${_index + 1} / ${_puzzles.length}',
                    style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.gold)),
              ),
            ]),
          ),

          LinearProgressIndicator(
            value: (_index + 1) / _puzzles.length,
            backgroundColor: Colors.white.withOpacity(0.08),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFCE93D8)),
            minHeight: 6,
          ),

          Expanded(
            child: Container(
              color: const Color(0xFF1A0030),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(children: [

                  // ── Word card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF4A0080), Color(0xFF6A0DAD)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: accent.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))],
                    ),
                    child: Column(children: [
                      AnimatedBuilder(
                        animation: _bounceAnim,
                        builder: (_, __) => Transform.translate(
                          offset: Offset(0, _bounceAnim.value),
                          child: Text(_puzzle.emoji, style: const TextStyle(fontSize: 80)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Word with blank
                      Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: _puzzle.display.split('').map((ch) {
                          if (ch == '_') {
                            // Show picked vowel in blank; teal if correct, red if wrong pick
                            final fill = _answered ? _puzzle.vowel : (_picked ?? '');
                            final color = _answered
                                ? AppColors.teal
                                : (_picked != null && _picked != _puzzle.vowel)
                                    ? AppColors.wrong
                                    : AppColors.gold;
                            return Container(
                              width: 48, height: 58,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: color, width: 3.5)),
                              ),
                              child: Center(child: Text(fill,
                                  style: GoogleFonts.fredoka(fontSize: 32, color: color))),
                            );
                          } else if (ch == ' ') {
                            return const SizedBox(width: 8);
                          } else {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(ch, style: GoogleFonts.fredoka(fontSize: 32, color: Colors.white)),
                            );
                          }
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Text('Fill in the missing vowel!',
                          style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white60)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => provider.speakHint(_puzzle.word[0].toUpperCase() + _puzzle.word.substring(1).toLowerCase()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Text('🔊', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text('Hear the word', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  Text('Tap the missing vowel!',
                      style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900,
                          color: const Color(0xFF9B1FD6), letterSpacing: 1.2)),
                  const SizedBox(height: 14),

                  // ── Vowel buttons — Wrap so it never overflows ──
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: _vowels.map((v) {
                      final isCorrect = v == _puzzle.vowel;
                      Color bg = accent.withOpacity(0.3);
                      Color border = const Color(0xFF7B1FA2);
                      Color text = Colors.white;
                      if (_answered && isCorrect) {
                        bg = AppColors.teal.withOpacity(0.2);
                        border = AppColors.teal;
                        text = AppColors.teal;
                      } else if (!_answered && _picked == v && !isCorrect) {
                        bg = AppColors.wrong.withOpacity(0.15);
                        border = AppColors.wrong;
                        text = AppColors.wrong;
                      }

                      return GestureDetector(
                        onTap: _answered ? null : () => _pick(v),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: bg,
                            shape: BoxShape.circle,
                            border: Border.all(color: border, width: 2.5),
                          ),
                          child: Center(
                            child: Text(v,
                                style: GoogleFonts.fredoka(
                                    fontSize: 24, color: text)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  if (_answered)
                    GestureDetector(
                      onTap: _next,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF6A0DAD), Color(0xFF4A0080)]),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Text(
                          _index < _puzzles.length - 1 ? 'Next Word →' : '🎉 See Results!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(fontSize: 17, color: Colors.white),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
          ),

          KidsBottomNav(currentIndex: 2, onTap: (i) {
            if (i != 2) Navigator.pop(context);
            if (i == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen()));
          }),
        ]),
      ),
    );
  }
}
