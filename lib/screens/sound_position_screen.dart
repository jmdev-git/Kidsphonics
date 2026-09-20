// lib/screens/sound_position_screen.dart
//
// Beginning / Middle / End Sound — shows a word + picture, asks where
// a given letter sound appears (Beginning, Middle, or End).
//
// Easy   : Beginning only (3 words)
// Medium : Beginning + End (5 words)
// Hard   : Beginning + Middle + End (7 words)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../models/difficulty.dart';
import '../widgets/shared_widgets.dart';
import 'progress_screen.dart';

// ── Data ──────────────────────────────────────────────────────────────────

enum _SoundPos { beginning, middle, end }

extension _SoundPosLabel on _SoundPos {
  String get label {
    switch (this) {
      case _SoundPos.beginning: return 'Beginning';
      case _SoundPos.middle:    return 'Middle';
      case _SoundPos.end:       return 'End';
    }
  }
  String get emoji {
    switch (this) {
      case _SoundPos.beginning: return '⬅️';
      case _SoundPos.middle:    return '⬛';
      case _SoundPos.end:       return '➡️';
    }
  }
}

class _SoundPosRound {
  final String emoji;
  final String word;
  final String targetLetter;
  final _SoundPos correctPos;
  final List<_SoundPos> options;
  final String hint;

  const _SoundPosRound({
    required this.emoji,
    required this.word,
    required this.targetLetter,
    required this.correctPos,
    required this.options,
    required this.hint,
  });
}

// Easy — only BEGINNING position, 3 unique words, 2 choices (Beginning/End)
const _easyRounds = [
  _SoundPosRound(emoji: '🍎', word: 'APPLE', targetLetter: 'A',
      correctPos: _SoundPos.beginning,
      options: [_SoundPos.beginning, _SoundPos.end],
      hint: 'A-P-P-L-E. A is the FIRST sound!'),
  _SoundPosRound(emoji: '🍌', word: 'BANANA', targetLetter: 'B',
      correctPos: _SoundPos.beginning,
      options: [_SoundPos.beginning, _SoundPos.end],
      hint: 'B-A-N-A-N-A. B is the FIRST sound!'),
  _SoundPosRound(emoji: '🥚', word: 'EGG', targetLetter: 'E',
      correctPos: _SoundPos.beginning,
      options: [_SoundPos.beginning, _SoundPos.end],
      hint: 'E-G-G. E is the FIRST sound!'),
];

// Medium — BEGINNING + END, 5 unique words (none from Easy), 2 choices
const _mediumRounds = [
  _SoundPosRound(emoji: '🐟', word: 'FISH', targetLetter: 'F',
      correctPos: _SoundPos.beginning,
      options: [_SoundPos.beginning, _SoundPos.end],
      hint: 'F-I-S-H. F is at the BEGINNING!'),
  _SoundPosRound(emoji: '🐟', word: 'FISH', targetLetter: 'H',
      correctPos: _SoundPos.end,
      options: [_SoundPos.beginning, _SoundPos.end],
      hint: 'F-I-S-H. H is at the END!'),
  _SoundPosRound(emoji: '🌙', word: 'MOON', targetLetter: 'M',
      correctPos: _SoundPos.beginning,
      options: [_SoundPos.beginning, _SoundPos.end],
      hint: 'M-O-O-N. M is at the BEGINNING!'),
  _SoundPosRound(emoji: '🌙', word: 'MOON', targetLetter: 'N',
      correctPos: _SoundPos.end,
      options: [_SoundPos.beginning, _SoundPos.end],
      hint: 'M-O-O-N. N is at the END!'),
  _SoundPosRound(emoji: '🪁', word: 'KITE', targetLetter: 'K',
      correctPos: _SoundPos.beginning,
      options: [_SoundPos.beginning, _SoundPos.end],
      hint: 'K-I-T-E. K is at the BEGINNING!'),
];

// Hard — BEGINNING + MIDDLE + END, 7 unique words (none from Easy/Medium), 3 choices
const _hardRounds = [
  _SoundPosRound(emoji: '🦁', word: 'LION', targetLetter: 'L',
      correctPos: _SoundPos.beginning,
      options: [_SoundPos.beginning, _SoundPos.middle, _SoundPos.end],
      hint: 'L-I-O-N. L is at the BEGINNING!'),
  _SoundPosRound(emoji: '🦁', word: 'LION', targetLetter: 'I',
      correctPos: _SoundPos.middle,
      options: [_SoundPos.beginning, _SoundPos.middle, _SoundPos.end],
      hint: 'L-I-O-N. I is in the MIDDLE!'),
  _SoundPosRound(emoji: '🦁', word: 'LION', targetLetter: 'N',
      correctPos: _SoundPos.end,
      options: [_SoundPos.beginning, _SoundPos.middle, _SoundPos.end],
      hint: 'L-I-O-N. N is at the END!'),
  _SoundPosRound(emoji: '🌈', word: 'RAIN', targetLetter: 'R',
      correctPos: _SoundPos.beginning,
      options: [_SoundPos.beginning, _SoundPos.middle, _SoundPos.end],
      hint: 'R-A-I-N. R is at the BEGINNING!'),
  _SoundPosRound(emoji: '🌈', word: 'RAIN', targetLetter: 'A',
      correctPos: _SoundPos.middle,
      options: [_SoundPos.beginning, _SoundPos.middle, _SoundPos.end],
      hint: 'R-A-I-N. A is in the MIDDLE!'),
  _SoundPosRound(emoji: '🌈', word: 'RAIN', targetLetter: 'N',
      correctPos: _SoundPos.end,
      options: [_SoundPos.beginning, _SoundPos.middle, _SoundPos.end],
      hint: 'R-A-I-N. N is at the END!'),
  _SoundPosRound(emoji: '🐋', word: 'WHALE', targetLetter: 'W',
      correctPos: _SoundPos.beginning,
      options: [_SoundPos.beginning, _SoundPos.middle, _SoundPos.end],
      hint: 'W-H-A-L-E. W is at the BEGINNING!'),
];

List<_SoundPosRound> _roundsFor(Difficulty d) {
  switch (d) {
    case Difficulty.easy:   return _easyRounds;
    case Difficulty.medium: return _mediumRounds;
    case Difficulty.hard:   return _hardRounds;
  }
}

// ── Screen ────────────────────────────────────────────────────────────────

class SoundPositionScreen extends StatefulWidget {
  final Difficulty difficulty;
  const SoundPositionScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<SoundPositionScreen> createState() => _SoundPositionScreenState();
}

class _SoundPositionScreenState extends State<SoundPositionScreen>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  _SoundPos? _picked;
  bool _answered = false;
  int _correct = 0;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  List<_SoundPosRound> get _rounds => _roundsFor(widget.difficulty);
  _SoundPosRound get _round => _rounds[_index];

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -8)
        .animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().voiceFeedback.playIntroQuiz();
    });
  }

  @override
  void dispose() { _bounceCtrl.dispose(); super.dispose(); }

  void _pick(_SoundPos pos) async {
    if (_answered) return;
    final isCorrect = pos == _round.correctPos;
    setState(() => _picked = pos);

    final provider = context.read<AppProvider>();
    if (isCorrect) {
      setState(() { _answered = true; _correct++; });
      // Play correct.mp3 tone first — no voice feedback competing with it
      provider.audio.playCorrect();
      _confettiKey.currentState?.fire();
      provider.addXP((8 * widget.difficulty.xpMultiplier).round());
      provider.addStar();
      // Wait for tone to finish before speaking
      await Future.delayed(const Duration(milliseconds: 700));
      await provider.speak('${_round.targetLetter} is at the ${_round.correctPos.label}! ${_round.hint}');
    } else {
      // Wrong — play wrong.mp3 tone first, then voice
      provider.audio.playWrong();
      await Future.delayed(const Duration(milliseconds: 700));
      await provider.speak('Try again! Listen carefully!');
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _picked = null);
    }
  }

  void _next() {
    if (_index < _rounds.length - 1) {
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
    _confettiKey.currentState?.fire();
    provider.voiceFeedback.playWinByScore(_correct, _rounds.length, game: 'quiz');

    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_correct == _rounds.length ? '🏆' : '😊', style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 8),
          Text('Sound Position!', style: GoogleFonts.fredoka(fontSize: 22, color: AppColors.gold)),
          Text('$_correct / ${_rounds.length} correct!',
              style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.teal)),
          Text('+${(15 * widget.difficulty.xpMultiplier).round()} XP!',
              style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFA5D6A7))),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () { Navigator.pop(context); _restart(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: Text('🔄 Play Again', style: GoogleFonts.fredoka(color: Colors.white, fontSize: 16)),
          )),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              showDifficultyPicker(context: context, gameTitle: 'Sound Position', gameIcon: '📍',
                onSelected: (d) => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => SoundPositionScreen(difficulty: d))));
            },
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.teal.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: Text('🎯 Change Difficulty', style: GoogleFonts.fredoka(color: AppColors.teal, fontSize: 15)),
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

    return Scaffold(
      body: ConfettiOverlay(
        overlayKey: _confettiKey,
        child: Column(children: [
          KidsHeader(
            title: '📍 Sound Position',
            gradient: const LinearGradient(colors: [Color(0xFF00796B), Color(0xFF004D40)]),
            textColor: const Color(0xFFB2DFDB),
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
                child: Text('${_index + 1} / ${_rounds.length}',
                    style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.gold)),
              ),
            ]),
          ),

          LinearProgressIndicator(
            value: (_index + 1) / _rounds.length,
            backgroundColor: Colors.white.withOpacity(0.08),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF4DB6AC)),
            minHeight: 6,
          ),

          Expanded(
            child: Container(
              color: const Color(0xFF04120F),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(children: [

                  // ── Word + letter card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF004D40), Color(0xFF00796B)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: const Color(0xFF00796B).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))],
                    ),
                    child: Column(children: [
                      AnimatedBuilder(
                        animation: _bounceAnim,
                        builder: (_, __) => Transform.translate(
                          offset: Offset(0, _bounceAnim.value),
                          child: Text(_round.emoji, style: const TextStyle(fontSize: 72)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Word with target letter underlined (no yellow — difficulty-neutral)
                      RichText(
                        text: TextSpan(
                          children: _round.word.split('').map((ch) {
                            final isTarget = ch == _round.targetLetter;
                            // Only underline on Easy — Medium/Hard show no hint
                            final showUnderline = isTarget &&
                                widget.difficulty == Difficulty.easy;
                            return TextSpan(
                              text: ch,
                              style: GoogleFonts.fredoka(
                                fontSize: 36,
                                color: Colors.white,
                                decoration: showUnderline
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                                decorationColor: Colors.white,
                                decorationThickness: 3,
                                fontWeight: (isTarget && widget.difficulty != Difficulty.hard)
                                    ? FontWeight.w900
                                    : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          'Where is the "${_round.targetLetter}" sound?',
                          style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Speaker button shown on all difficulties
                      GestureDetector(
                        onTap: () => provider.speakHint(_round.word[0].toUpperCase() + _round.word.substring(1).toLowerCase()),
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

                  // ── Position buttons ──
                  Text('Tap where the sound is!',
                      style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900,
                          color: const Color(0xFF4DB6AC), letterSpacing: 1.2)),
                  const SizedBox(height: 14),

                  Row(children: _round.options.map((pos) {
                    final isCorrect = pos == _round.correctPos;
                    final isPicked = _picked == pos;

                    Color bg = Colors.white.withOpacity(0.06);
                    Color border = Colors.white.withOpacity(0.15);
                    Color text = Colors.white;

                    if (_answered && isCorrect) { bg = AppColors.teal.withOpacity(0.15); border = AppColors.teal; text = AppColors.teal; }
                    else if (!_answered && _picked == pos && pos != _round.correctPos) { bg = AppColors.wrong.withOpacity(0.12); border = AppColors.wrong; text = AppColors.wrong; }

                    return Expanded(
                      child: GestureDetector(
                        onTap: _answered ? null : () => _pick(pos),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                              color: bg, borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: border, width: 2.5)),
                          child: Column(children: [
                            Text(pos.emoji, style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 6),
                            Text(pos.label,
                                style: GoogleFonts.fredoka(fontSize: 14, color: text)),
                            if (_answered && isCorrect) const Text('✅', style: TextStyle(fontSize: 16)),
                            if (!_answered && _picked == pos && pos != _round.correctPos) const Text('❌', style: TextStyle(fontSize: 16)),
                          ]),
                        ),
                      ),
                    );
                  }).toList()),
                  const SizedBox(height: 20),

                  if (_answered)
                    GestureDetector(
                      onTap: _next,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF00796B), Color(0xFF004D40)]),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Text(
                          _index < _rounds.length - 1 ? 'Next Word →' : '🎉 See Results!',
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
