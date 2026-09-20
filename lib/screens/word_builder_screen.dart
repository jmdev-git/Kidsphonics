// lib/screens/word_builder_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/shared_widgets.dart';
import '../models/difficulty.dart';
import 'progress_screen.dart';

// ── Data model ────────────────────────────────────────────────────────────
//
// [blanks] is a List<String?> where null means "blank to fill".
// [correctLetters] is the ordered list of answers for each blank.
// [tiles] are the letter choices shown to the child.

class _WordPuzzle {
  final String emoji;
  final String word;
  final List<String?> blanks;        // null = blank slot
  final List<String> correctLetters; // one per blank slot, in order
  final List<String> tiles;          // letter choices shown
  final String voiceHint;

  const _WordPuzzle({
    required this.emoji,
    required this.word,
    required this.blanks,
    required this.correctLetters,
    required this.tiles,
    required this.voiceHint,
  });
}

// ── Easy — 1 blank (simple CVC) ─────────────────────────────────────────
final _puzzlesEasy = [
  const _WordPuzzle(
    emoji: '🐱', word: 'CAT',
    blanks: ['C', null, 'T'],
    correctLetters: ['A'],
    tiles: ['A', 'B', 'E', 'O'],
    voiceHint: 'C... blank... T. What is in the middle?',
  ),
  const _WordPuzzle(
    emoji: '🐶', word: 'DOG',
    blanks: ['D', null, 'G'],
    correctLetters: ['O'],
    tiles: ['O', 'U', 'A', 'I'],
    voiceHint: 'D... blank... G. Fill in the middle!',
  ),
  const _WordPuzzle(
    emoji: '☀️', word: 'SUN',
    blanks: ['S', null, 'N'],
    correctLetters: ['U'],
    tiles: ['U', 'A', 'O', 'I'],
    voiceHint: 'S... blank... N. What letter goes here?',
  ),
];

// ── Medium — 2 blanks ────────────────────────────────────────────────────
final _puzzlesMedium = [
  const _WordPuzzle(
    emoji: '🍇', word: 'GRAPES',
    blanks: ['G', null, 'A', 'P', null, 'S'],
    correctLetters: ['R', 'E'],
    tiles: ['R', 'E', 'T', 'O', 'U', 'N'],
    voiceHint: 'G... blank... A... P... blank... S. What letters are missing?',
  ),
  const _WordPuzzle(
    emoji: '🏠', word: 'HOUSE',
    blanks: [null, 'O', 'U', 'S', null],
    correctLetters: ['H', 'E'],
    tiles: ['H', 'E', 'B', 'A', 'I', 'T'],
    voiceHint: 'blank... O... U... S... blank. What are the missing letters?',
  ),
  const _WordPuzzle(
    emoji: '🌙', word: 'MOON',
    blanks: ['M', null, null, 'N'],
    correctLetters: ['O', 'O'],
    tiles: ['O', 'A', 'U', 'I', 'E', 'Y'],
    voiceHint: 'M... blank... blank... N. Two letters are missing!',
  ),
  const _WordPuzzle(
    emoji: '🐟', word: 'FISH',
    blanks: ['F', null, 'S', null],
    correctLetters: ['I', 'H'],
    tiles: ['I', 'H', 'A', 'E', 'O', 'T'],
    voiceHint: 'F... blank... S... blank. Fill in the two missing letters!',
  ),
  const _WordPuzzle(
    emoji: '🦁', word: 'LION',
    blanks: ['L', null, 'O', null],
    correctLetters: ['I', 'N'],
    tiles: ['I', 'N', 'A', 'E', 'M', 'T'],
    voiceHint: 'L... blank... O... blank. What letters come next?',
  ),
];

// ── Hard — 2 to 3 blanks ─────────────────────────────────────────────────
final _puzzlesHard = [
  const _WordPuzzle(
    emoji: '🌈', word: 'RAINBOW',
    blanks: ['R', null, 'I', null, 'B', null, 'W'],
    correctLetters: ['A', 'N', 'O'],
    tiles: ['A', 'N', 'O', 'E', 'T', 'U'],
    voiceHint: 'R... blank... I... blank... B... blank... W. Three letters missing!',
  ),
  const _WordPuzzle(
    emoji: '☂️', word: 'UMBRELLA',
    blanks: [null, 'M', null, 'R', 'E', null, 'L', 'A'],
    correctLetters: ['U', 'B', 'L'],
    tiles: ['U', 'B', 'L', 'O', 'A', 'T'],
    voiceHint: 'blank... M... blank... R... E... blank... L... A. Three missing!',
  ),
  const _WordPuzzle(
    emoji: '🦓', word: 'ZEBRA',
    blanks: [null, 'E', null, 'R', null],
    correctLetters: ['Z', 'B', 'A'],
    tiles: ['Z', 'B', 'A', 'X', 'D', 'O'],
    voiceHint: 'blank... E... blank... R... blank. Fill in Z, B, and A!',
  ),
  const _WordPuzzle(
    emoji: '🐢', word: 'TURTLE',
    blanks: ['T', null, 'R', null, 'L', null],
    correctLetters: ['U', 'T', 'E'],
    tiles: ['U', 'T', 'E', 'A', 'O', 'S'],
    voiceHint: 'T... blank... R... blank... L... blank. Three letters to find!',
  ),
  const _WordPuzzle(
    emoji: '🍌', word: 'BANANA',
    blanks: ['B', null, 'N', null, 'N', null],
    correctLetters: ['A', 'A', 'A'],
    tiles: ['A', 'E', 'I', 'O', 'U', 'B'],
    voiceHint: 'B... blank... N... blank... N... blank. What vowel fills all three?',
  ),
];

List<_WordPuzzle> _puzzlesForDifficulty(Difficulty d) {
  switch (d) {
    case Difficulty.easy:   return _puzzlesEasy;
    case Difficulty.medium: return _puzzlesMedium;
    case Difficulty.hard:   return _puzzlesHard;
  }
}

// ── Screen ────────────────────────────────────────────────────────────────

class WordBuilderScreen extends StatefulWidget {
  final Difficulty difficulty;
  const WordBuilderScreen({super.key, this.difficulty = Difficulty.medium});
  @override
  State<WordBuilderScreen> createState() => _WordBuilderScreenState();
}

class _WordBuilderScreenState extends State<WordBuilderScreen>
    with SingleTickerProviderStateMixin {
  int _puzzleIndex = 0;

  // For multi-blank: track which blank is currently being filled (0-based)
  int _activeBlankIndex = 0;
  // Filled answers so far — index = blank slot index
  late List<String?> _filledAnswers;

  bool _allCorrect = false; // true when all blanks filled correctly
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  List<_WordPuzzle> get _activePuzzles => _puzzlesForDifficulty(widget.difficulty);
  _WordPuzzle get _puzzle => _activePuzzles[_puzzleIndex];
  late List<String> _shuffledTiles;

  int get _blankCount => _puzzle.correctLetters.length;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 8)
        .animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
    _initPuzzle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().voiceFeedback.playIntroWordBuilder();
    });
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _initPuzzle() {
    _activeBlankIndex = 0;
    _filledAnswers = List<String?>.filled(_blankCount, null);
    _allCorrect = false;
    _shuffledTiles = List<String>.from(_puzzle.tiles)..shuffle();
  }

  // ── tap a letter tile ──────────────────────────────────────────────────
  void _tapTile(String letter) async {
    if (_allCorrect) return;
    // Still blanks left to fill
    if (_activeBlankIndex >= _blankCount) return;

    final provider = context.read<AppProvider>();
    provider.audio.playTap();

    final isCorrect = letter == _puzzle.correctLetters[_activeBlankIndex];

    if (isCorrect) {
      setState(() {
        _filledAnswers[_activeBlankIndex] = letter;
        _activeBlankIndex++;
        if (_activeBlankIndex >= _blankCount) _allCorrect = true;
      });

      if (_allCorrect) {
        // All blanks correct — play correct.mp3 tone only
        provider.audio.playCorrect();
        _confettiKey.currentState?.fire();
        provider.addXP((10 * widget.difficulty.xpMultiplier).round());
        provider.addStar();
        await Future.delayed(const Duration(milliseconds: 1000));
        if (!mounted) return;
        if (_puzzleIndex < _activePuzzles.length - 1) {
          setState(() {
            _puzzleIndex++;
            _initPuzzle();
          });
        } else {
          _showWinDialog();
        }
      } else {
        // Correct blank filled — play correct.mp3, move to next blank
        provider.audio.playCorrect();
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } else {
      // Wrong letter — play wrong.mp3 only, no voice
      provider.audio.playWrong();
      _shakeCtrl.forward(from: 0);
    }
  }

  void _restart() {
    setState(() {
      _puzzleIndex = 0;
      _initPuzzle();
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
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
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
                  style: GoogleFonts.fredoka(
                      color: Colors.white, fontSize: 16)),
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
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withOpacity(0.15)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: Text('← Back to Games',
                  style: GoogleFonts.fredoka(
                      color: Colors.white54, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Build the word display row ─────────────────────────────────────────
  Widget _buildWordRow() {
    int blankSlot = 0; // tracks which blank we are rendering
    final children = <Widget>[];

    for (int i = 0; i < _puzzle.blanks.length; i++) {
      final isBlank = _puzzle.blanks[i] == null;
      if (isBlank) {
        final slotIndex = blankSlot;
        final filled = slotIndex < _filledAnswers.length
            ? _filledAnswers[slotIndex]
            : null;
        final isActive = slotIndex == _activeBlankIndex && !_allCorrect;
        final isFilledCorrect = filled != null;

        Color underlineColor;
        if (isFilledCorrect) {
          underlineColor = const Color(0xFF69F0AE); // green
        } else if (isActive) {
          underlineColor = AppColors.gold; // gold = currently active blank
        } else {
          underlineColor = AppColors.purple.withOpacity(0.5);
        }

        children.add(
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: underlineColor, width: 3.5),
              ),
            ),
            child: Center(
              child: Text(
                filled ?? (isActive ? '_' : ' '),
                style: GoogleFonts.fredoka(
                  fontSize: 26,
                  color: isFilledCorrect
                      ? const Color(0xFF69F0AE)
                      : AppColors.gold,
                ),
              ),
            ),
          ),
        );
        blankSlot++;
      } else {
        // Fixed letter
        children.add(
          Container(
            width: 40,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            child: Center(
              child: Text(
                _puzzle.blanks[i]!,
                style: GoogleFonts.fredoka(fontSize: 26, color: Colors.white),
              ),
            ),
          ),
        );
      }
    }

    return Wrap(
      alignment: WrapAlignment.center,
      children: children,
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
            gradient: const LinearGradient(
                colors: [AppColors.purple, AppColors.purpleDark]),
            textColor: const Color(0xFFE1BEE7),
            onBack: () => Navigator.pop(context),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                    '${widget.difficulty.emoji} ${widget.difficulty.label}',
                    style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                    '⭐ ${(30 * widget.difficulty.xpMultiplier).round()} XP',
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _activePuzzles.length,
                      (i) => Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: i < _puzzleIndex
                              ? AppColors.teal
                              : i == _puzzleIndex
                                  ? AppColors.gold
                                  : Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Big picture + word card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.09)),
                    ),
                    child: Column(children: [
                      Text(_puzzle.emoji,
                          style: const TextStyle(fontSize: 64)),
                      const SizedBox(height: 8),
                      Text(
                        'Spell the word!',
                        style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFCE93D8),
                            letterSpacing: 1),
                      ),
                      // Blank count badge
                      if (_blankCount > 1) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$_blankCount letters to fill!',
                            style: GoogleFonts.nunito(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.gold),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Word row with blanks
                      AnimatedBuilder(
                        animation: _shakeAnim,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(
                            _shakeCtrl.isAnimating
                                ? _shakeAnim.value *
                                    ((_shakeCtrl.value * 10)
                                                .round()
                                                .isEven
                                            ? 1
                                            : -1)
                                : 0,
                            0,
                          ),
                          child: child,
                        ),
                        child: _buildWordRow(),
                      ),

                      // Active blank indicator
                      if (!_allCorrect && _blankCount > 1) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Filling blank ${_activeBlankIndex + 1} of $_blankCount',
                          style: GoogleFonts.nunito(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold.withOpacity(0.7)),
                        ),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Tap the missing letter${_blankCount > 1 ? 's' : ''}!',
                    style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF6A3FA0),
                        letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 10),

                  // ── Tile row ──
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    alignment: WrapAlignment.center,
                    children: _shuffledTiles.map((lt) {
                      // Dim tiles already used (correctly filled)
                      final usedCount = _filledAnswers
                          .where((f) => f == lt)
                          .length;
                      final availableCount = _puzzle.correctLetters
                          .where((c) => c == lt)
                          .length;
                      final isDepleted =
                          usedCount >= availableCount &&
                          availableCount > 0;

                      return GestureDetector(
                        onTap: (_allCorrect || isDepleted)
                            ? null
                            : () => _tapTile(lt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDepleted
                                ? AppColors.teal.withOpacity(0.2)
                                : AppColors.purple.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isDepleted
                                  ? AppColors.teal
                                  : const Color(0xFF7B1FA2),
                              width: 2.5,
                            ),
                          ),
                          child: Center(
                            child: isDepleted
                                ? const Text('✓',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: AppColors.teal))
                                : Text(lt,
                                    style: GoogleFonts.fredoka(
                                        fontSize: 22,
                                        color: const Color(0xFFE1BEE7))),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // ── Voice hint ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SpeakButton(
                          onTap: () => provider.speakHint(_puzzle.voiceHint),
                          size: 36,
                          bgColor: AppColors.purple,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Tap 🔊 for a hint',
                          style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.3)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Status bar (replaces old check button) ──
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: _allCorrect
                          ? const LinearGradient(
                              colors: [AppColors.teal, AppColors.tealDark])
                          : const LinearGradient(
                              colors: [AppColors.purple, AppColors.purpleDark]),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Text(
                      _allCorrect
                          ? '🎉 Correct! +${(30 * widget.difficulty.xpMultiplier).round()} XP!'
                          : _activeBlankIndex == 0
                              ? 'Tap the first missing letter!'
                              : 'Great! Now tap the next letter!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                          fontSize: 16,
                          color: const Color(0xFFE1BEE7)),
                    ),
                  ),
                ]),
              ),
            ),
          ),

          KidsBottomNav(currentIndex: 2, onTap: (i) {
            if (i != 2) Navigator.pop(context);
            if (i == 3) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProgressScreen()));
            }
          }),
        ]),
      ),
    );
  }
}
