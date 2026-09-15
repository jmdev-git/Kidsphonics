// lib/screens/word_builder_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/shared_widgets.dart';
import '../models/difficulty.dart';
import 'progress_screen.dart';

class _WordPuzzle {
  final String emoji;
  final String word;
  final List<String> blanks; // null entry = blank to fill
  final int blankIndex;
  final List<String> tiles;
  final String correctLetter;
  final String voiceHint;

  _WordPuzzle({
    required this.emoji, required this.word, required this.blanks,
    required this.blankIndex, required this.tiles, required this.correctLetter,
    required this.voiceHint,
  });
}

final _puzzlesEasy = [
  _WordPuzzle(emoji: '🐱', word: 'CAT',   blanks: ['C', '', 'T'], blankIndex: 1,
      tiles: ['A','B','E','O'], correctLetter: 'A', voiceHint: 'C... blank... T. What is in the middle?'),
  _WordPuzzle(emoji: '🐶', word: 'DOG',   blanks: ['D', '', 'G'], blankIndex: 1,
      tiles: ['O','U','A','I'], correctLetter: 'O', voiceHint: 'D... blank... G. Fill in the middle!'),
  _WordPuzzle(emoji: '🍎', word: 'APPLE', blanks: ['A', 'P', '', 'L', 'E'], blankIndex: 2,
      tiles: ['P','B','C','D'], correctLetter: 'P', voiceHint: 'A... P... blank... L... E. What is the middle?'),
];

final _puzzles = [
  _WordPuzzle(emoji: '🐱', word: 'CAT',  blanks: ['C', '', 'T'], blankIndex: 1,
      tiles: ['A','B','E','O','I','S'], correctLetter: 'A', voiceHint: 'C... blank... T. What is in the middle?'),
  _WordPuzzle(emoji: '🐶', word: 'DOG',  blanks: ['D', '', 'G'], blankIndex: 1,
      tiles: ['O','U','A','I','E','B'], correctLetter: 'O', voiceHint: 'D... blank... G. Fill in the middle!'),
  _WordPuzzle(emoji: '☀️', word: 'SUN',  blanks: ['S', '', 'N'], blankIndex: 1,
      tiles: ['U','A','O','I','E','Y'], correctLetter: 'U', voiceHint: 'S... blank... N. What letter goes here?'),
  _WordPuzzle(emoji: '🍎', word: 'APPLE', blanks: ['A', 'P', '', 'L', 'E'], blankIndex: 2,
      tiles: ['A','P','C','D','E','F'], correctLetter: 'P', voiceHint: 'A... P... blank... L... E. What is the middle letter?'),
  _WordPuzzle(emoji: '🐟', word: 'FISH',  blanks: ['F', 'I', 'S', ''], blankIndex: 3,
      tiles: ['H','M','P','B','R','T'], correctLetter: 'H', voiceHint: 'F... I... S... blank. What is the last letter?'),
];

final _puzzlesHard = [
  _WordPuzzle(emoji: '☀️', word: 'SUN',     blanks: ['S', '', 'N'],          blankIndex: 1,
      tiles: ['U','A','O','I','E','Y'], correctLetter: 'U', voiceHint: 'S... blank... N. What letter goes here?'),
  _WordPuzzle(emoji: '🐟', word: 'FISH',    blanks: ['F', 'I', 'S', ''],     blankIndex: 3,
      tiles: ['H','M','P','B','R','T'], correctLetter: 'H', voiceHint: 'F... I... S... blank. What is the last letter?'),
  _WordPuzzle(emoji: '🌈', word: 'RAINBOW', blanks: ['R', 'A', 'I', '', 'B', 'O', 'W'], blankIndex: 3,
      tiles: ['N','L','M','B','D','T'], correctLetter: 'N', voiceHint: 'R... A... I... blank... B... O... W. What letter is missing?'),
  _WordPuzzle(emoji: '🏠', word: 'HOUSE',   blanks: ['H', 'O', '', 'S', 'E'], blankIndex: 2,
      tiles: ['U','A','I','O','E','Y'], correctLetter: 'U', voiceHint: 'H... O... blank... S... E. What vowel goes here?'),
  _WordPuzzle(emoji: '🦁', word: 'LION',    blanks: ['L', 'I', '', 'N'],     blankIndex: 2,
      tiles: ['O','A','E','U','B','D'], correctLetter: 'O', voiceHint: 'L... I... blank... N. What letter goes here?'),
  _WordPuzzle(emoji: '🌙', word: 'MOON',    blanks: ['M', 'O', '', 'N'],     blankIndex: 2,
      tiles: ['O','A','U','I','E','Y'], correctLetter: 'O', voiceHint: 'M... O... blank... N. What is the missing letter?'),
];

List<_WordPuzzle> _puzzlesForDifficulty(Difficulty d) {
  switch (d) {
    case Difficulty.easy:   return _puzzlesEasy;
    case Difficulty.medium: return _puzzles;
    case Difficulty.hard:   return _puzzlesHard;
  }
}

class WordBuilderScreen extends StatefulWidget {
  final Difficulty difficulty;
  const WordBuilderScreen({super.key, this.difficulty = Difficulty.medium});
  @override
  State<WordBuilderScreen> createState() => _WordBuilderScreenState();
}

class _WordBuilderScreenState extends State<WordBuilderScreen> with SingleTickerProviderStateMixin {
  int _puzzleIndex = 0;
  String? _picked;
  bool _checked = false;
  bool _correct = false;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  List<_WordPuzzle> get _activePuzzles => _puzzlesForDifficulty(widget.difficulty);
  _WordPuzzle get _puzzle => _activePuzzles[_puzzleIndex];
  late List<String> _shuffledTiles;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 8).animate(
        CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
    _shuffledTiles = List<String>.from(_puzzle.tiles)..shuffle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().voiceFeedback.playIntroWordBuilder();
    });
  }

  @override
  void dispose() { _shakeCtrl.dispose(); super.dispose(); }

  void _tapTile(String letter) {
    if (_checked) return;
    setState(() => _picked = letter);
    final provider = context.read<AppProvider>();
    provider.audio.playTap();
    provider.speak(letter);
  }

  void _check() async {
    if (_picked == null) return;
    final provider = context.read<AppProvider>();
    final isCorrect = _picked == _puzzle.correctLetter;
    setState(() { _checked = true; _correct = isCorrect; });

    if (isCorrect) {
      provider.audio.playCorrect();
      _confettiKey.currentState?.fire();
      provider.addXP((10 * widget.difficulty.xpMultiplier).round());
      provider.addStar();
      provider.voiceFeedback.playPraise();
      await provider.speak('Wonderful! ${_puzzle.word}! You spelled it correctly!');
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      if (_puzzleIndex < _activePuzzles.length - 1) {
        setState(() {
          _puzzleIndex++;
          _picked = null;
          _checked = false;
          _correct = false;
          _shuffledTiles = List<String>.from(_puzzle.tiles)..shuffle();
        });
      } else {
        _showWinDialog();
      }
    } else {
      provider.audio.playWrong();
      _shakeCtrl.forward(from: 0);
      await provider.speak('Try again! Listen to the hint!');
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) setState(() { _checked = false; _picked = null; });
    }
  }

  void _restart() {
    setState(() {
      _puzzleIndex = 0;
      _picked = null;
      _checked = false;
      _correct = false;
      _shuffledTiles = List<String>.from(_puzzle.tiles)..shuffle();
    });
  }

  void _showWinDialog() {
    final provider = context.read<AppProvider>();
    provider.audio.playWin();
    provider.addXP((15 * widget.difficulty.xpMultiplier).round());
    provider.voiceFeedback.playWinWordBuilder();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🎉', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 8),
          Text('All Words Spelled!',
              style: GoogleFonts.fredoka(fontSize: 22, color: AppColors.gold)),
          Text('+${(15 * widget.difficulty.xpMultiplier).round()} bonus XP!',
              style: GoogleFonts.nunito(
                  fontSize: 14, fontWeight: FontWeight.w800,
                  color: const Color(0xFFA5D6A7))),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _restart();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: Text('🔄 Play Again',
                  style: GoogleFonts.fredoka(color: Colors.white, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                showDifficultyPicker(
                  context: context,
                  gameTitle: 'Word Builder',
                  gameIcon: '🔡',
                  onSelected: (d) => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => WordBuilderScreen(difficulty: d)),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.purple.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: Text('🎯 Change Difficulty',
                  style: GoogleFonts.fredoka(
                      color: AppColors.purple, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close game screen
              },
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withOpacity(0.15)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: Text('← Back to Lessons',
                  style: GoogleFonts.fredoka(
                      color: Colors.white54, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();

    return Scaffold(
      body: ConfettiOverlay(
        overlayKey: _confettiKey,
        child: Column(children: [
          KidsHeader(
            title: '🔡 Word Builder',
            gradient: const LinearGradient(colors: [AppColors.purple, AppColors.purpleDark]),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text('⭐ ${(30 * widget.difficulty.xpMultiplier).round()} XP',
                    style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ]),
          ),

          Expanded(
            child: Container(
              color: const Color(0xFF120626),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(children: [
                  // Progress dots
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(
                    _activePuzzles.length, (i) => Container(
                      width: 10, height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: i < _puzzleIndex ? AppColors.teal
                            : i == _puzzleIndex ? AppColors.gold
                            : Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )),
                  const SizedBox(height: 16),

                  // ── Big picture card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.09)),
                    ),
                    child: Column(children: [
                      Text(_puzzle.emoji, style: const TextStyle(fontSize: 64)),
                      const SizedBox(height: 8),
                      Text('Spell the word!',
                          style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900,
                              color: const Color(0xFFCE93D8), letterSpacing: 1)),
                      const SizedBox(height: 12),

                      // Blanks row with shake on wrong
                      AnimatedBuilder(
                        animation: _shakeAnim,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(_shakeCtrl.isAnimating ? _shakeAnim.value * ((_shakeCtrl.value * 10).round().isEven ? 1 : -1) : 0, 0),
                          child: child,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(_puzzle.blanks.length, (i) {
                              final isBlank = i == _puzzle.blankIndex;
                              final letter = isBlank ? _picked : _puzzle.blanks[i];
                              final isCorrectFill = isBlank && _checked && _correct;
                              return Container(
                                width: 46, height: 50,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(
                                    color: isCorrectFill ? const Color(0xFF69F0AE)
                                        : (_checked && isBlank && !_correct) ? AppColors.wrong
                                        : AppColors.purple,
                                    width: 3.5,
                                  )),
                                ),
                                child: Center(
                                  child: Text(letter ?? '',
                                      style: GoogleFonts.fredoka(fontSize: 26,
                                          color: isCorrectFill ? const Color(0xFF69F0AE) : Colors.white)),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  Text('Tap the missing letter!',
                      style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900,
                          color: const Color(0xFF6A3FA0), letterSpacing: 1.2)),
                  const SizedBox(height: 10),

                  // Tile row
                  Wrap(
                    spacing: 9, runSpacing: 9,
                    alignment: WrapAlignment.center,
                    children: _shuffledTiles.map((lt) {
                      final isPicked = _picked == lt;
                      return GestureDetector(
                        onTap: _checked ? null : () => _tapTile(lt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            gradient: isPicked ? const LinearGradient(colors: [AppColors.purple, AppColors.purpleDark]) : null,
                            color: isPicked ? null : AppColors.purple.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isPicked ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2),
                              width: 2.5,
                            ),
                          ),
                          child: Center(
                            child: Text(lt,
                                style: GoogleFonts.fredoka(fontSize: 22,
                                    color: isPicked ? AppColors.gold : const Color(0xFFE1BEE7))),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Voice guide chip — subtle, audio button is primary
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SpeakButton(
                          onTap: () => provider.speak(_puzzle.voiceHint),
                          size: 36,
                          bgColor: AppColors.purple,
                        ),
                        const SizedBox(width: 10),
                        Text('Tap 🔊 for a hint',
                            style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.3))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Check button
                  GestureDetector(
                    onTap: _check,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: _checked && _correct
                            ? const LinearGradient(colors: [AppColors.teal, AppColors.tealDark])
                            : _checked && !_correct
                            ? const LinearGradient(colors: [Color(0xFFC62828), Color(0xFFB71C1C)])
                            : const LinearGradient(colors: [AppColors.purple, AppColors.purpleDark]),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Text(
                        _checked && _correct ? '🎉 Correct! +${(30 * widget.difficulty.xpMultiplier).round()} XP!'
                            : _checked && !_correct ? '❌ Try again!'
                            : 'Check my answer! ✓',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(fontSize: 17, color: const Color(0xFFE1BEE7)),
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
