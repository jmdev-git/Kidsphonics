// lib/screens/alphabet_order_screen.dart
//
// Alphabet Order game: letters are shown shuffled — the child taps them
// in the correct A→Z order. Wrong tap shows a shake + red flash.
// Difficulty controls how many letters are in play:
//   Easy   → A–F  (6 letters)
//   Medium → A–M  (13 letters)
//   Hard   → A–Z  (26 letters)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/shared_widgets.dart';
import '../models/difficulty.dart';
import 'progress_screen.dart';

class AlphabetOrderScreen extends StatefulWidget {
  final Difficulty difficulty;
  const AlphabetOrderScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<AlphabetOrderScreen> createState() => _AlphabetOrderScreenState();
}

class _AlphabetOrderScreenState extends State<AlphabetOrderScreen>
    with TickerProviderStateMixin {
  late List<String> _letters;      // all letters for this difficulty
  late List<String> _shuffled;     // displayed in this order
  int _nextExpected = 0;           // index into _letters (sorted)
  Set<String> _correct = {};       // tapped correctly
  String? _wrongLetter;            // flashes red briefly

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 10)
        .animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
    _setupRound();
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  List<String> _lettersForDifficulty() {
    const all = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    switch (widget.difficulty) {
      case Difficulty.easy:   return all.substring(0, 6).split('');
      case Difficulty.medium: return all.substring(0, 13).split('');
      case Difficulty.hard:   return all.split('');
    }
  }

  void _setupRound() {
    _letters = _lettersForDifficulty();
    _shuffled = List<String>.from(_letters)..shuffle();
    _nextExpected = 0;
    _correct = {};
    _wrongLetter = null;
  }

  void _restart() => setState(_setupRound);

  int get _totalLetters => _letters.length;
  bool get _finished => _correct.length == _totalLetters;

  // ── tap handler ───────────────────────────────────────────────────────────

  void _tap(String letter) async {
    if (_correct.contains(letter)) return;   // already done
    final provider = context.read<AppProvider>();

    if (letter == _letters[_nextExpected]) {
      // Correct
      provider.audio.playCorrect();
      provider.addXP((3 * widget.difficulty.xpMultiplier).round());
      provider.addStar();
      setState(() {
        _correct.add(letter);
        _nextExpected++;
        _wrongLetter = null;
      });
      await provider.speak(letter);

      if (_finished) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _confettiKey.currentState?.fire();
          provider.audio.playWin();
          provider.addXP((15 * widget.difficulty.xpMultiplier).round());
          _showWinDialog();
        }
      }
    } else {
      // Wrong
      provider.audio.playWrong();
      setState(() => _wrongLetter = letter);
      _shakeCtrl.forward(from: 0);
      await provider.speak('Try ${_letters[_nextExpected]}! Find it in order!');
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) setState(() => _wrongLetter = null);
    }
  }

  // ── win dialog ────────────────────────────────────────────────────────────

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🏆', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 8),
          Text('Alphabet Master!',
              style: GoogleFonts.fredoka(fontSize: 22, color: AppColors.gold)),
          Text('All $_totalLetters letters in order!',
              style: GoogleFonts.nunito(
                  fontSize: 14, fontWeight: FontWeight.w800,
                  color: AppColors.teal)),
          Text('+${(15 * widget.difficulty.xpMultiplier).round()} bonus XP!',
              style: GoogleFonts.nunito(
                  fontSize: 13, fontWeight: FontWeight.w700,
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
                  backgroundColor: AppColors.teal,
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
                  gameTitle: 'Alphabet Order',
                  gameIcon: '🔤',
                  onSelected: (d) => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AlphabetOrderScreen(difficulty: d)),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.teal.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: Text('🎯 Change Difficulty',
                  style: GoogleFonts.fredoka(
                      color: AppColors.teal, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();

    // Cols: 4 for easy/medium, 5 for hard (26 letters)
    final crossCount = widget.difficulty == Difficulty.hard ? 5 : 4;

    return Scaffold(
      body: ConfettiOverlay(
        overlayKey: _confettiKey,
        child: Column(children: [
          KidsHeader(
            title: '🔤 Alphabet Order',
            gradient: const LinearGradient(
                colors: [Color(0xFF00796B), Color(0xFF004D40)]),
            textColor: const Color(0xFFB2DFDB),
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
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${_correct.length} / $_totalLetters',
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.gold)),
              ),
            ]),
          ),

          // Progress bar
          LinearProgressIndicator(
            value: _correct.length / _totalLetters,
            backgroundColor: Colors.white.withOpacity(0.08),
            valueColor:
                const AlwaysStoppedAnimation(Color(0xFF4DB6AC)),
            minHeight: 6,
          ),

          Expanded(
            child: Container(
              color: const Color(0xFF04120F),
              child: Column(children: [
                // ── Instruction banner ──
                Container(
                  margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00796B).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFF4DB6AC).withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Text('📚', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        // Easy: show the next letter as a guide
                        // Medium/Hard: no hint — child must rely on own knowledge
                        widget.difficulty == Difficulty.easy
                            ? 'Tap A → Z in order!  Next: ${_nextExpected < _totalLetters ? _letters[_nextExpected] : "🎉 Done!"}'
                            : 'Tap the letters in A → Z order!',
                        style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF80CBC4)),
                      ),
                    ),
                    // Speak button — always available as audio guide
                    if (_nextExpected < _totalLetters)
                      GestureDetector(
                        onTap: () => provider.speak(
                            '${_letters[_nextExpected]} says... ${_letters[_nextExpected]}!'),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                              color: const Color(0xFF00796B).withOpacity(0.3),
                              shape: BoxShape.circle),
                          child: const Center(
                              child: Text('🔊',
                                  style: TextStyle(fontSize: 15))),
                        ),
                      ),
                  ]),
                ),
                const SizedBox(height: 10),

                // ── Letter grid ──
                Expanded(
                  child: AnimatedBuilder(
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
                          0),
                      child: child,
                    ),
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossCount,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _shuffled.length,
                      itemBuilder: (_, i) =>
                          _buildTile(_shuffled[i]),
                    ),
                  ),
                ),
              ]),
            ),
          ),

          KidsBottomNav(currentIndex: 2, onTap: (i) {
            if (i != 2) Navigator.pop(context);
            if (i == 3) {
              Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const ProgressScreen()));
            }
          }),
        ]),
      ),
    );
  }

  Widget _buildTile(String letter) {
    final isDone = _correct.contains(letter);
    final isWrong = _wrongLetter == letter;
    // Only highlight the next letter on Easy — Medium/Hard must figure it out
    final isNext = widget.difficulty == Difficulty.easy &&
        !isDone &&
        _nextExpected < _totalLetters &&
        letter == _letters[_nextExpected];

    // colours
    Color borderColor;
    Color bgColor;
    Color textColor;

    if (isDone) {
      borderColor = const Color(0xFF4DB6AC);
      bgColor = const Color(0xFF4DB6AC).withOpacity(0.18);
      textColor = const Color(0xFF4DB6AC);
    } else if (isWrong) {
      borderColor = AppColors.wrong;
      bgColor = AppColors.wrong.withOpacity(0.14);
      textColor = AppColors.wrong;
    } else if (isNext) {
      // Subtle pulse hint for the next correct letter
      borderColor = AppColors.gold;
      bgColor = AppColors.gold.withOpacity(0.1);
      textColor = AppColors.gold;
    } else {
      borderColor = Colors.white.withOpacity(0.1);
      bgColor = Colors.white.withOpacity(0.05);
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: isDone ? null : () => _tap(letter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isDone)
              const Text('✅', style: TextStyle(fontSize: 22))
            else
              Text(letter,
                  style: GoogleFonts.fredoka(
                      fontSize: 28, color: textColor)),
            if (!isDone)
              Text(letter.toLowerCase(),
                  style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: textColor.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}
