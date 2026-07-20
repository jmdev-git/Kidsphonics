// lib/screens/picture_word_match_screen.dart
//
// Picture-to-Word Match — 4 pictures shown, tap the one that matches the word.
// Tests word recognition by connecting written text to images.
//
// Easy   : 3 choices, simple 3-letter words
// Medium : 4 choices
// Hard   : 5 choices + longer words

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../models/difficulty.dart';
import '../widgets/shared_widgets.dart';
import 'progress_screen.dart';

// ── Data ──────────────────────────────────────────────────────────────────

class _PicWordRound {
  final String word;         // word to match
  final String correctEmoji; // correct picture
  final List<String> options; // all emojis shown (incl. correct)
  final List<String> labels;  // word labels for each emoji
  final String hint;

  const _PicWordRound({
    required this.word,
    required this.correctEmoji,
    required this.options,
    required this.labels,
    required this.hint,
  });
}

const _easyRounds = [
  _PicWordRound(word: 'CAT',   correctEmoji: '🐱', options: ['🐱','🐶','🌈'], labels: ['Cat','Dog','Rainbow'], hint: 'Cat! C-A-T, Cat!'),
  _PicWordRound(word: 'SUN',   correctEmoji: '☀️', options: ['🌙','☀️','🍎'], labels: ['Moon','Sun','Apple'],   hint: 'Sun! S-U-N, Sun!'),
  _PicWordRound(word: 'EGG',   correctEmoji: '🥚', options: ['🥚','🐟','🏠'], labels: ['Egg','Fish','House'],   hint: 'Egg! E-G-G, Egg!'),
  _PicWordRound(word: 'BEE',   correctEmoji: '🐝', options: ['🐱','🐝','🌙'], labels: ['Cat','Bee','Moon'],     hint: 'Bee! B-E-E, Bee!'),
];

const _mediumRounds = [
  _PicWordRound(word: 'FISH',   correctEmoji: '🐟', options: ['🐱','🐟','🌈','🏠'], labels: ['Cat','Fish','Rainbow','House'], hint: 'Fish! F-I-S-H!'),
  _PicWordRound(word: 'MOON',   correctEmoji: '🌙', options: ['☀️','🌙','🥚','🐷'], labels: ['Sun','Moon','Egg','Pig'],   hint: 'Moon! M-O-O-N!'),
  _PicWordRound(word: 'KITE',   correctEmoji: '🪁', options: ['🪁','🐶','🍎','🐢'], labels: ['Kite','Dog','Apple','Turtle'], hint: 'Kite! K-I-T-E!'),
  _PicWordRound(word: 'LION',   correctEmoji: '🦁', options: ['🦁','🐋','🎻','🌙'], labels: ['Lion','Whale','Violin','Moon'], hint: 'Lion! L-I-O-N!'),
  _PicWordRound(word: 'APPLE',  correctEmoji: '🍎', options: ['🍌','🍎','🐱','☀️'], labels: ['Banana','Apple','Cat','Sun'], hint: 'Apple! A-P-P-L-E!'),
];

const _hardRounds = [
  _PicWordRound(word: 'RAINBOW',  correctEmoji: '🌈', options: ['🌈','🐟','🥚','🐱','🌙'],    labels: ['Rainbow','Fish','Egg','Cat','Moon'],    hint: 'Rainbow! R-A-I-N-B-O-W!'),
  _PicWordRound(word: 'UMBRELLA', correctEmoji: '☂️', options: ['☂️','🦁','🍎','🐋','🎻'],    labels: ['Umbrella','Lion','Apple','Whale','Violin'], hint: 'Umbrella! U-M-B-R-E-L-L-A!'),
  _PicWordRound(word: 'ZEBRA',    correctEmoji: '🦓', options: ['🦓','🐶','🌈','🪁','🥚'],    labels: ['Zebra','Dog','Rainbow','Kite','Egg'],   hint: 'Zebra! Z-E-B-R-A!'),
  _PicWordRound(word: 'VIOLIN',   correctEmoji: '🎻', options: ['🎻','🏠','☀️','🐷','🌙'],    labels: ['Violin','House','Sun','Pig','Moon'],    hint: 'Violin! V-I-O-L-I-N!'),
  _PicWordRound(word: 'OCTOPUS',  correctEmoji: '🐙', options: ['🐙','🦁','🍌','☂️','🦓'],    labels: ['Octopus','Lion','Banana','Umbrella','Zebra'], hint: 'Octopus! O-C-T-O-P-U-S!'),
  _PicWordRound(word: 'XYLOPHONE',correctEmoji: '🎶', options: ['🎶','🐙','🦓','🎻','☂️'],    labels: ['Xylophone','Octopus','Zebra','Violin','Umbrella'], hint: 'Xylophone! X-Y-L-O-P-H-O-N-E!'),
];

List<_PicWordRound> _roundsFor(Difficulty d) {
  switch (d) {
    case Difficulty.easy:   return _easyRounds;
    case Difficulty.medium: return _mediumRounds;
    case Difficulty.hard:   return _hardRounds;
  }
}

// ── Screen ────────────────────────────────────────────────────────────────

class PictureWordMatchScreen extends StatefulWidget {
  final Difficulty difficulty;
  const PictureWordMatchScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<PictureWordMatchScreen> createState() => _PictureWordMatchScreenState();
}

class _PictureWordMatchScreenState extends State<PictureWordMatchScreen>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  String? _picked;
  bool _answered = false;
  int _correct = 0;
  late List<int> _shuffledIdx;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  List<_PicWordRound> get _rounds => _roundsFor(widget.difficulty);
  _PicWordRound get _round => _rounds[_index];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _shuffleIdx();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().voiceFeedback.playIntroQuiz();
    });
  }

  void _shuffleIdx() {
    _shuffledIdx = List.generate(_round.options.length, (i) => i)..shuffle();
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  void _pick(String emoji) async {
    if (_answered) return;
    final isCorrect = emoji == _round.correctEmoji;
    setState(() { _picked = emoji; _answered = true; if (isCorrect) _correct++; });

    final provider = context.read<AppProvider>();
    if (isCorrect) {
      provider.audio.playCorrect();
      _confettiKey.currentState?.fire();
      provider.addXP((8 * widget.difficulty.xpMultiplier).round());
      provider.addStar();
      provider.voiceFeedback.playPraise();
      await provider.speak('${_round.word}! That is right!');
    } else {
      provider.audio.playWrong();
      provider.voiceFeedback.playWrongQuiz();
      await provider.speak('Not quite! The picture for ${_round.word} is ${_round.hint}');
    }
  }

  void _next() {
    if (_index < _rounds.length - 1) {
      setState(() { _index++; _picked = null; _answered = false; _shuffleIdx(); });
    } else {
      _showResults();
    }
  }

  void _restart() => setState(() { _index = 0; _picked = null; _answered = false; _correct = 0; _shuffleIdx(); });

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
          Text('Picture Match Done!', style: GoogleFonts.fredoka(fontSize: 22, color: AppColors.gold)),
          Text('$_correct / ${_rounds.length} correct!',
              style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.teal)),
          Text('+${(15 * widget.difficulty.xpMultiplier).round()} XP!',
              style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFA5D6A7))),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () { Navigator.pop(context); _restart(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: Text('🔄 Play Again', style: GoogleFonts.fredoka(color: Colors.white, fontSize: 16)),
          )),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              showDifficultyPicker(context: context, gameTitle: 'Picture Match', gameIcon: '🖼️',
                onSelected: (d) => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => PictureWordMatchScreen(difficulty: d))));
            },
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.blue.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: Text('🎯 Change Difficulty', style: GoogleFonts.fredoka(color: AppColors.blue, fontSize: 15)),
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
    final cols = widget.difficulty == Difficulty.hard ? 3 : 2;

    return Scaffold(
      body: ConfettiOverlay(
        overlayKey: _confettiKey,
        child: Column(children: [
          KidsHeader(
            title: '🖼️ Picture Match',
            gradient: const LinearGradient(colors: [AppColors.blue, AppColors.blueDark]),
            textColor: const Color(0xFFBBDEFB),
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
            valueColor: const AlwaysStoppedAnimation(Color(0xFF90CAF9)),
            minHeight: 6,
          ),

          Expanded(
            child: Container(
              color: const Color(0xFF071530),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(children: [

                  // ── Word card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.blue, AppColors.blueDark],
                          begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: AppColors.blue.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))],
                    ),
                    child: Column(children: [
                      AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (_, child) => Transform.scale(scale: _pulseAnim.value, child: child),
                        child: Text(_round.word,
                            style: GoogleFonts.fredoka(fontSize: 48, color: Colors.white,
                                shadows: [const Shadow(color: Colors.black26, blurRadius: 8)])),
                      ),
                      const SizedBox(height: 8),
                      Text('Which picture shows this word?',
                          style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white60)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => provider.speak(_round.word[0].toUpperCase() + _round.word.substring(1).toLowerCase()),
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
                  const SizedBox(height: 20),

                  Text('Tap the matching picture!',
                      style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900,
                          color: const Color(0xFF90CAF9), letterSpacing: 1.2)),
                  const SizedBox(height: 12),

                  // ── Picture grid ──
                  GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10, mainAxisSpacing: 10,
                    childAspectRatio: 1.1,
                    children: _shuffledIdx.map((i) {
                      final emoji = _round.options[i];
                      final label = _round.labels[i];
                      final isCorrect = emoji == _round.correctEmoji;
                      final isPicked = _picked == emoji;

                      Color border = Colors.white.withOpacity(0.12);
                      Color bg = Colors.white.withOpacity(0.06);
                      if (_answered && isCorrect) { border = AppColors.teal; bg = AppColors.teal.withOpacity(0.12); }
                      else if (_answered && isPicked && !isCorrect) { border = AppColors.wrong; bg = AppColors.wrong.withOpacity(0.1); }

                      return GestureDetector(
                        onTap: _answered ? null : () => _pick(emoji),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                              color: bg, borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: border, width: 2.5)),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(emoji, style: const TextStyle(fontSize: 44)),
                            if (_answered && isCorrect) const Text('✅', style: TextStyle(fontSize: 16)),
                            if (_answered && isPicked && !isCorrect) const Text('❌', style: TextStyle(fontSize: 16)),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  if (_answered)
                    GestureDetector(
                      onTap: _next,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.blue, AppColors.blueDark]),
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
