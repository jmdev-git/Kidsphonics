// lib/screens/sound_match_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/shared_widgets.dart';
import '../data/letter_data.dart';
import '../models/difficulty.dart';
import 'progress_screen.dart';

class SoundMatchScreen extends StatefulWidget {
  final Difficulty difficulty;
  const SoundMatchScreen({super.key, this.difficulty = Difficulty.medium});
  @override
  State<SoundMatchScreen> createState() => _SoundMatchScreenState();
}

class _SoundMatchScreenState extends State<SoundMatchScreen> {
  int _roundIndex = 0;
  int _score = 0;
  Map<String, bool?> _picks = {}; // letter -> correct?
  bool _roundDone = false;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  List<SoundRound> get _rounds => soundRoundsForDifficulty(widget.difficulty);
  SoundRound get _round => _rounds[_roundIndex];
  List<String> get _shuffledOpts {
    final opts = List<String>.from(_round.options);
    opts.shuffle();
    return opts;
  }
  late List<String> _opts;

  @override
  void initState() {
    super.initState();
    _opts = _shuffledOpts;
    // No intro voice — keep Sound Match silent until child taps
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  void _nextRound() {
    if (_roundIndex < _rounds.length - 1) {
      setState(() {
        _roundIndex++;
        _picks = {};
        _roundDone = false;
        _opts = _shuffledOpts;
      });
    } else {
      _showWinDialog();
    }
  }

  void _restart() {
    setState(() {
      _roundIndex = 0;
      _score = 0;
      _picks = {};
      _roundDone = false;
      _opts = _shuffledOpts;
    });
  }

  void _showWinDialog() {
    final provider = context.read<AppProvider>();
    provider.audio.playWin();
    provider.addXP((10 * widget.difficulty.xpMultiplier).round());
    _confettiKey.currentState?.fireWin();
    // No win voice — tones only

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🏆', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 8),
          Text('Round Complete!',
              style: GoogleFonts.fredoka(fontSize: 22, color: AppColors.gold)),
          Text('Score: $_score points',
              style: GoogleFonts.nunito(
                  fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.teal)),
          Text('+${(10 * widget.difficulty.xpMultiplier).round()} bonus XP!',
              style: GoogleFonts.nunito(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: const Color(0xFFA5D6A7))),
          const SizedBox(height: 18),
          // Play Again — same difficulty
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _restart();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
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
                Navigator.pop(context); // close dialog only
                showDifficultyPicker(
                  context: context,
                  gameTitle: 'Sound Match',
                  gameIcon: '🔊',
                  onSelected: (d) => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SoundMatchScreen(difficulty: d)),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.orange.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: Text('🎯 Change Difficulty',
                  style: GoogleFonts.fredoka(
                      color: AppColors.orange, fontSize: 15)),
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

  void _pick(String letter) async {
    if (_roundDone) return;
    // Block re-tap only if already marked correct (green) — wrong picks are retryable
    if (_picks[letter] == true) return;

    final isCorrect = letter == _round.correctLetter;
    setState(() {
      _picks[letter] = isCorrect;
      if (isCorrect) {
        _score += (5 * widget.difficulty.xpMultiplier).round();
        _roundDone = true;
      }
    });
    final provider = context.read<AppProvider>();
    if (isCorrect) {
      provider.audio.playCorrect();
      _confettiKey.currentState?.fire();
      provider.addXP((5 * widget.difficulty.xpMultiplier).round());
      provider.addStar();
      // No voice — correct.mp3 tone only, then move to next round
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) _nextRound();
    } else {
      // Wrong — play tone, show red flash briefly, then clear so child can retry
      provider.audio.playWrong();
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) setState(() => _picks.remove(letter));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    return Scaffold(
      body: ConfettiOverlay(
        overlayKey: _confettiKey,
        child: Column(children: [
          KidsHeader(
            title: '🔊 Sound Match',
            gradient: const LinearGradient(colors: [Color(0xFFF9A825), AppColors.orangeDark]),
            textColor: const Color(0xFF3E2000),
            onBack: () => Navigator.pop(context),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20)),
                child: Text('${widget.difficulty.emoji} ${widget.difficulty.label}',
                    style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('Score: $_score',
                    style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFF3E2000))),
              ),
            ]),
          ),

          Expanded(
            child: Container(
              color: const Color(0xFF1A0D00),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(children: [
                  // Progress
                  Row(children: [
                    Text('Round ${_roundIndex + 1} / ${_rounds.length}',
                        style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.orange)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: (_roundIndex + 1) / _rounds.length,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                          minHeight: 10,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),

                  // ── BIG picture card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1500),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: AppColors.orange.withOpacity(0.3)),
                    ),
                    child: Column(children: [
                      Text(_round.emoji, style: const TextStyle(fontSize: 90)),
                      const SizedBox(height: 8),
                      Text(_round.word,
                          style: GoogleFonts.fredoka(fontSize: 24, color: AppColors.gold)),
                      Text('What letter does it start with?',
                          style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800,
                              color: const Color(0xFF9B6720))),
                      const SizedBox(height: 12),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('Tap to hear the word!',
                            style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w900,
                                color: const Color(0xFF9B6720))),
                        const SizedBox(width: 10),
                        SpeakButton(
                          onTap: () => provider.speakHint(_round.voiceHint),
                          size: 50,
                        ),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // Letter choices
                  Text('Tap the correct starting letter!',
                      style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900,
                          color: const Color(0xFF9B6720), letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: _opts.map((lt) {
                      final result = _picks[lt];
                      final isOk = result == true;
                      final isNo = result == false;
                      return GestureDetector(
                        onTap: () => _pick(lt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            color: isOk ? AppColors.teal.withOpacity(0.18)
                                : isNo ? AppColors.wrong.withOpacity(0.14)
                                : Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isOk ? AppColors.teal
                                  : isNo ? AppColors.wrong
                                  : Colors.white.withOpacity(0.12),
                              width: 2.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(lt,
                                  style: GoogleFonts.fredoka(fontSize: 30,
                                      color: isOk ? AppColors.teal
                                          : isNo ? AppColors.wrong
                                          : Colors.white)),
                              Text('${lt.toLowerCase()}uh',
                                  style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800,
                                      color: Colors.white.withOpacity(0.5))),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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
