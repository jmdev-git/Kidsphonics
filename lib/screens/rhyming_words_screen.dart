// lib/screens/rhyming_words_screen.dart
//
// Rhyming Words lesson with Easy / Medium / Hard difficulty.
//
// Easy  : 3 choices, very simple CVC rhymes (cat/bat, dog/log…)
// Medium: 4 choices, slightly longer words
// Hard  : 5 choices, trickier rhymes with more distractors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../models/difficulty.dart';
import '../widgets/shared_widgets.dart';
import 'progress_screen.dart';
import 'lessons_screen.dart';

// ── Data model ────────────────────────────────────────────────────────────

class _RhymeRound {
  final String emoji;
  final String word;
  final String correctRhyme;
  final List<_RhymeOption> options;
  final String hint;

  const _RhymeRound({
    required this.emoji,
    required this.word,
    required this.correctRhyme,
    required this.options,
    required this.hint,
  });
}

class _RhymeOption {
  final String word;
  final String emoji;
  const _RhymeOption(this.word, this.emoji);
}

// ── Difficulty-tiered round lists ─────────────────────────────────────────

// Easy — 3 options, very common short words
const _easyRounds = [
  _RhymeRound(
    emoji: '🐱', word: 'CAT',
    correctRhyme: 'BAT',
    options: [_RhymeOption('BAT','🦇'), _RhymeOption('DOG','🐶'), _RhymeOption('SUN','☀️')],
    hint: 'Cat... Bat! Both end in A-T!',
  ),
  _RhymeRound(
    emoji: '🐝', word: 'BEE',
    correctRhyme: 'TREE',
    options: [_RhymeOption('TREE','🌳'), _RhymeOption('CAT','🐱'), _RhymeOption('HAT','🎩')],
    hint: 'Bee... Tree! Both end in E-E!',
  ),
  _RhymeRound(
    emoji: '🌙', word: 'MOON',
    correctRhyme: 'SPOON',
    options: [_RhymeOption('SPOON','🥄'), _RhymeOption('FISH','🐟'), _RhymeOption('BALL','🏀')],
    hint: 'Moon... Spoon! Both end in O-O-N!',
  ),
  _RhymeRound(
    emoji: '🐷', word: 'PIG',
    correctRhyme: 'BIG',
    options: [_RhymeOption('BIG','🏔️'), _RhymeOption('MOP','🧹'), _RhymeOption('CUP','☕')],
    hint: 'Pig... Big! Both end in I-G!',
  ),
];

// Medium — 4 options, slightly more words
const _mediumRounds = [
  _RhymeRound(
    emoji: '🐱', word: 'CAT',
    correctRhyme: 'BAT',
    options: [_RhymeOption('BAT','🦇'), _RhymeOption('DOG','🐶'), _RhymeOption('SUN','☀️'), _RhymeOption('PIG','🐷')],
    hint: 'Cat... Bat! Both end in A-T!',
  ),
  _RhymeRound(
    emoji: '🎩', word: 'HAT',
    correctRhyme: 'MAT',
    options: [_RhymeOption('PIG','🐷'), _RhymeOption('MAT','🟫'), _RhymeOption('MOON','🌙'), _RhymeOption('FISH','🐟')],
    hint: 'Hat... Mat! Both end in A-T!',
  ),
  _RhymeRound(
    emoji: '🌙', word: 'MOON',
    correctRhyme: 'SPOON',
    options: [_RhymeOption('FISH','🐟'), _RhymeOption('SPOON','🥄'), _RhymeOption('APPLE','🍎'), _RhymeOption('DOG','🐶')],
    hint: 'Moon... Spoon! Both end in O-O-N!',
  ),
  _RhymeRound(
    emoji: '🐷', word: 'PIG',
    correctRhyme: 'BIG',
    options: [_RhymeOption('BIG','🏔️'), _RhymeOption('TREE','🌳'), _RhymeOption('SPOON','🥄'), _RhymeOption('HAT','🎩')],
    hint: 'Pig... Big! Both end in I-G!',
  ),
  _RhymeRound(
    emoji: '🐛', word: 'BUG',
    correctRhyme: 'MUG',
    options: [_RhymeOption('DOG','🐶'), _RhymeOption('CAT','🐱'), _RhymeOption('MUG','☕'), _RhymeOption('SUN','☀️')],
    hint: 'Bug... Mug! Both end in U-G!',
  ),
  _RhymeRound(
    emoji: '🐝', word: 'BEE',
    correctRhyme: 'TREE',
    options: [_RhymeOption('TREE','🌳'), _RhymeOption('CAT','🐱'), _RhymeOption('HAT','🎩'), _RhymeOption('BUG','🐛')],
    hint: 'Bee... Tree! Both end in E-E!',
  ),
];

// Hard — 5 options, trickier + more distractors
const _hardRounds = [
  _RhymeRound(
    emoji: '🐱', word: 'CAT',
    correctRhyme: 'FLAT',
    options: [_RhymeOption('FLAT','🏠'), _RhymeOption('DOG','🐶'), _RhymeOption('SUN','☀️'), _RhymeOption('PIG','🐷'), _RhymeOption('MOON','🌙')],
    hint: 'Cat... Flat! Both end in A-T!',
  ),
  _RhymeRound(
    emoji: '🌙', word: 'MOON',
    correctRhyme: 'BALLOON',
    options: [_RhymeOption('FISH','🐟'), _RhymeOption('BALLOON','🎈'), _RhymeOption('APPLE','🍎'), _RhymeOption('DOG','🐶'), _RhymeOption('HAT','🎩')],
    hint: 'Moon... Balloon! Both end in O-O-N!',
  ),
  _RhymeRound(
    emoji: '🌟', word: 'STAR',
    correctRhyme: 'CAR',
    options: [_RhymeOption('CAR','🚗'), _RhymeOption('FISH','🐟'), _RhymeOption('BEE','🐝'), _RhymeOption('HAT','🎩'), _RhymeOption('MUG','☕')],
    hint: 'Star... Car! Both end in A-R!',
  ),
  _RhymeRound(
    emoji: '🐸', word: 'FROG',
    correctRhyme: 'LOG',
    options: [_RhymeOption('LOG','🪵'), _RhymeOption('CAT','🐱'), _RhymeOption('MOON','🌙'), _RhymeOption('BEE','🐝'), _RhymeOption('STAR','🌟')],
    hint: 'Frog... Log! Both end in O-G!',
  ),
  _RhymeRound(
    emoji: '🏠', word: 'HOUSE',
    correctRhyme: 'MOUSE',
    options: [_RhymeOption('MOUSE','🐭'), _RhymeOption('CAR','🚗'), _RhymeOption('FROG','🐸'), _RhymeOption('LOG','🪵'), _RhymeOption('STAR','🌟')],
    hint: 'House... Mouse! Both end in O-U-S-E!',
  ),
  _RhymeRound(
    emoji: '🎂', word: 'CAKE',
    correctRhyme: 'LAKE',
    options: [_RhymeOption('LAKE','🏞️'), _RhymeOption('FROG','🐸'), _RhymeOption('MOUSE','🐭'), _RhymeOption('BUG','🐛'), _RhymeOption('HAT','🎩')],
    hint: 'Cake... Lake! Both end in A-K-E!',
  ),
  _RhymeRound(
    emoji: '🦊', word: 'FOX',
    correctRhyme: 'BOX',
    options: [_RhymeOption('BOX','📦'), _RhymeOption('CAKE','🎂'), _RhymeOption('LAKE','🏞️'), _RhymeOption('MOUSE','🐭'), _RhymeOption('CAR','🚗')],
    hint: 'Fox... Box! Both end in O-X!',
  ),
];

List<_RhymeRound> _roundsForDifficulty(Difficulty d) {
  switch (d) {
    case Difficulty.easy:   return _easyRounds;
    case Difficulty.medium: return _mediumRounds;
    case Difficulty.hard:   return _hardRounds;
  }
}

// ── Screen ────────────────────────────────────────────────────────────────

class RhymingWordsScreen extends StatefulWidget {
  final Difficulty difficulty;
  const RhymingWordsScreen({super.key, this.difficulty = Difficulty.medium});

  @override
  State<RhymingWordsScreen> createState() => _RhymingWordsScreenState();
}

class _RhymingWordsScreenState extends State<RhymingWordsScreen>
    with SingleTickerProviderStateMixin {
  int _roundIndex = 0;
  String? _picked;
  bool _answered = false;
  int _correct = 0;
  late List<_RhymeOption> _shuffled;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  List<_RhymeRound> get _rounds => _roundsForDifficulty(widget.difficulty);
  _RhymeRound get _round => _rounds[_roundIndex];

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -8)
        .animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
    _shuffleOptions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().voiceFeedback.playIntroRhyming();
    });
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _shuffleOptions() {
    _shuffled = List<_RhymeOption>.from(_round.options)..shuffle();
  }

  void _restart() {
    setState(() {
      _roundIndex = 0;
      _picked = null;
      _answered = false;
      _correct = 0;
      _shuffleOptions();
    });
  }

  void _pick(String word) async {
    if (_answered) return;
    final isCorrect = word == _round.correctRhyme;
    setState(() {
      _picked = word;
      _answered = true;
      if (isCorrect) _correct++;
    });

    final provider = context.read<AppProvider>();
    if (isCorrect) {
      provider.audio.playCorrect();
      _confettiKey.currentState?.fire();
      provider.addXP((8 * widget.difficulty.xpMultiplier).round());
      provider.addStar();
      provider.voiceFeedback.playPraise();
      await provider.speak(
          '${_round.word} and ${_round.correctRhyme} rhyme! ${_round.hint}');
    } else {
      provider.audio.playWrong();
      provider.voiceFeedback.playWrongRhyming();
      await provider.speak(
          'Not quite! ${_round.word} rhymes with ${_round.correctRhyme}! ${_round.hint}');
    }
  }

  void _next() {
    if (_roundIndex < _rounds.length - 1) {
      setState(() {
        _roundIndex++;
        _picked = null;
        _answered = false;
        _shuffleOptions();
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final provider = context.read<AppProvider>();
    provider.audio.playWin();
    provider.addXP((20 * widget.difficulty.xpMultiplier).round());
    provider.markRhymingWordsDone();
    _confettiKey.currentState?.fire();
    provider.voiceFeedback.playWinByScore(_correct, _rounds.length, game: 'rhyming');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_correct >= (_rounds.length * 0.7).ceil() ? '🏆' : '😊',
              style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 8),
          Text('Rhyming Done!',
              style: GoogleFonts.fredoka(fontSize: 22, color: AppColors.gold)),
          Text('$_correct / ${_rounds.length} correct!',
              style: GoogleFonts.nunito(
                  fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.teal)),
          Text('+${(20 * widget.difficulty.xpMultiplier).round()} XP Earned!',
              style: GoogleFonts.nunito(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: const Color(0xFFA5D6A7))),
          const SizedBox(height: 18),
          // Play Again
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () { Navigator.pop(context); _restart(); },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAD1457),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: Text('🔄 Play Again',
                  style: GoogleFonts.fredoka(color: Colors.white, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 8),
          // Change Difficulty
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                showDifficultyPicker(
                  context: context,
                  gameTitle: 'Rhyming Words',
                  gameIcon: '🗣️',
                  onSelected: (d) => Navigator.pushReplacement(context,
                      MaterialPageRoute(
                          builder: (_) => RhymingWordsScreen(difficulty: d))),
                );
              },
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: const Color(0xFFAD1457).withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: Text('🎯 Change Difficulty',
                  style: GoogleFonts.fredoka(
                      color: const Color(0xFFAD1457), fontSize: 15)),
            ),
          ),
          const SizedBox(height: 8),
          // Back to Lessons
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
            title: '🗣️ Rhyming Words',
            gradient: const LinearGradient(
                colors: [Color(0xFFAD1457), Color(0xFF880E4F)]),
            textColor: const Color(0xFFFCE4EC),
            onBack: () => Navigator.pop(context),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${widget.difficulty.emoji} ${widget.difficulty.label}',
                    style: GoogleFonts.nunito(
                        fontSize: 11, fontWeight: FontWeight.w900,
                        color: Colors.white)),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${_roundIndex + 1} / ${_rounds.length}',
                    style: GoogleFonts.nunito(
                        fontSize: 13, fontWeight: FontWeight.w900,
                        color: Colors.white)),
              ),
            ]),
          ),

          // Progress bar
          LinearProgressIndicator(
            value: (_roundIndex + 1) / _rounds.length,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFF48FB1)),
            minHeight: 6,
          ),

          Expanded(
            child: Container(
              color: const Color(0xFF1A0010),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  // ── Word card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF880E4F), Color(0xFFAD1457)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(
                          color: const Color(0xFFAD1457).withOpacity(0.4),
                          blurRadius: 20, offset: const Offset(0, 6))],
                    ),
                    child: Column(children: [
                      AnimatedBuilder(
                        animation: _bounceAnim,
                        builder: (_, __) => Transform.translate(
                          offset: Offset(0, _bounceAnim.value),
                          child: Text(_round.emoji,
                              style: const TextStyle(fontSize: 72)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_round.word,
                          style: GoogleFonts.fredoka(
                              fontSize: 32, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Which word rhymes with this?',
                          style: GoogleFonts.nunito(
                              fontSize: 12, fontWeight: FontWeight.w700,
                              color: Colors.white60)),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => provider.speak(
                            '${_round.word}. ${_round.hint}'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🔊',
                                    style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text('Hear the word',
                                    style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white)),
                              ]),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  Text('Tap the word that rhymes!',
                      style: GoogleFonts.nunito(
                          fontSize: 11, fontWeight: FontWeight.w900,
                          color: const Color(0xFF880E4F),
                          letterSpacing: 1.2)),
                  const SizedBox(height: 12),

                  // ── Options ──
                  ...(_shuffled.map((opt) {
                    final isCorrect = opt.word == _round.correctRhyme;
                    final isPicked = _picked == opt.word;

                    Color borderColor = Colors.white.withOpacity(0.1);
                    Color bgColor = Colors.white.withOpacity(0.05);

                    if (_answered) {
                      if (isCorrect) {
                        borderColor = AppColors.teal;
                        bgColor = AppColors.teal.withOpacity(0.12);
                      } else if (isPicked && !isCorrect) {
                        borderColor = AppColors.wrong;
                        bgColor = AppColors.wrong.withOpacity(0.1);
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: _answered ? null : () => _pick(opt.word),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor, width: 2.5),
                          ),
                          child: Row(children: [
                            Text(opt.emoji,
                                style: const TextStyle(fontSize: 32)),
                            const SizedBox(width: 16),
                            Text(opt.word,
                                style: GoogleFonts.fredoka(fontSize: 22,
                                    color: _answered && isCorrect
                                        ? AppColors.teal
                                        : _answered && isPicked && !isCorrect
                                            ? AppColors.wrong
                                            : Colors.white)),
                            const Spacer(),
                            if (_answered && isCorrect)
                              const Text('✅', style: TextStyle(fontSize: 20)),
                            if (_answered && isPicked && !isCorrect)
                              const Text('❌', style: TextStyle(fontSize: 20)),
                          ]),
                        ),
                      ),
                    );
                  })),

                  const SizedBox(height: 8),

                  // Next button
                  if (_answered)
                    GestureDetector(
                      onTap: _next,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Color(0xFFAD1457), Color(0xFF880E4F)]),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Text(
                          _roundIndex < _rounds.length - 1
                              ? 'Next Word →'
                              : '🎉 See Results!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                              fontSize: 17, color: Colors.white),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
          ),

          KidsBottomNav(currentIndex: 1, onTap: (i) {
            if (i == 0) Navigator.pop(context);
            if (i == 1) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LessonsScreen()));
            }
            if (i == 3) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProgressScreen()));
            }
          }),
        ]),
      ),
    );
  }
}
