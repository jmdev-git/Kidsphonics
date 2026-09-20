// lib/screens/memory_game_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/shared_widgets.dart';
import '../data/letter_data.dart';
import '../models/difficulty.dart';
import 'progress_screen.dart';

enum _CardType { letter, picture }

class _MemCard {
  final String id;      // pair identifier
  final _CardType type;
  final String display; // letter or emoji
  final String word;
  bool isFlipped = false;
  bool isMatched = false;

  _MemCard({required this.id, required this.type, required this.display, required this.word});
}

class MemoryGameScreen extends StatefulWidget {
  final Difficulty difficulty;
  const MemoryGameScreen({super.key, this.difficulty = Difficulty.medium});
  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  late List<_MemCard> _cards;
  List<_MemCard> _flipped = [];
  Set<String> _wrongCardIds = {}; // tracks cards showing red flash
  int _matchCount = 0;
  bool _locked = false;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  @override
  void initState() {
    super.initState();
    _initCards();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().voiceFeedback.playIntroMemory();
    });
  }

  void _initCards() {
    final source = memoryPairsForDifficulty(widget.difficulty);
    final pairs = source.toList();
    final cards = <_MemCard>[];
    for (final p in pairs) {
      cards.add(_MemCard(id: p.letter, type: _CardType.letter, display: p.letter, word: p.word));
      cards.add(_MemCard(id: p.letter, type: _CardType.picture, display: p.emoji, word: p.word));
    }
    cards.shuffle();
    setState(() {
      _cards = cards;
      _flipped = [];
      _wrongCardIds = {};
      _matchCount = 0;
      _locked = false;
    });
  }

  int get _totalPairs => memoryPairsForDifficulty(widget.difficulty).length;

  void _tapCard(_MemCard card) async {
    if (_locked || card.isFlipped || card.isMatched) return;
    final provider = context.read<AppProvider>();
    provider.audio.playFlip();
    setState(() { card.isFlipped = true; _flipped.add(card); });

    if (_flipped.length == 2) {
      _locked = true;
      await Future.delayed(const Duration(milliseconds: 750));

      final a = _flipped[0], b = _flipped[1];
      final isMatch = a.id == b.id && a.type != b.type;

      if (isMatch) {
        a.isMatched = true; b.isMatched = true;
        _matchCount++;
        provider.audio.playCorrect();
        provider.addXP((5 * widget.difficulty.xpMultiplier).round());
        provider.addStar();
        if (_matchCount == _totalPairs) {
          _confettiKey.currentState?.fire();
          provider.audio.playWin();
          provider.addXP((10 * widget.difficulty.xpMultiplier).round());
          provider.voiceFeedback.playWinMemory();
          await Future.delayed(const Duration(milliseconds: 400));
          if (mounted) _showWinDialog();
        }
        setState(() { _flipped = []; _locked = false; });
      } else {
        // Show red flash on mismatched cards — wrong.mp3 only, no voice
        provider.audio.playWrong();
        final wrongA = a.id + a.type.name;
        final wrongB = b.id + b.type.name;
        setState(() {
          _wrongCardIds = {wrongA, wrongB};
        });
        // Hold red flash for 800ms then flip back
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          a.isFlipped = false;
          b.isFlipped = false;
          setState(() {
            _wrongCardIds = {};
            _flipped = [];
            _locked = false;
          });
        }
      }
    }
  }

  void _showWinDialog() {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.darkBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🎉', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 10),
        Text('All pairs found!', style: GoogleFonts.fredoka(fontSize: 22, color: AppColors.gold)),
        Text('+${(20 * widget.difficulty.xpMultiplier).round()} XP Earned!', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.teal)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () { Navigator.pop(context); _initCards(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: Text('🔄 Play Again', style: GoogleFonts.fredoka(color: Colors.white, fontSize: 16)),
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
                gameTitle: 'Memory Flip',
                gameIcon: '🃏',
                onSelected: (d) => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => MemoryGameScreen(difficulty: d)),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.blue.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: Text('🎯 Change Difficulty',
                style: GoogleFonts.fredoka(color: AppColors.blue, fontSize: 15)),
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
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConfettiOverlay(
        overlayKey: _confettiKey,
        child: Column(children: [
          KidsHeader(
            title: '🃏 Memory Flip',
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text('$_matchCount / $_totalPairs',
                    style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ]),
          ),

          Expanded(
            child: Container(
              color: const Color(0xFF071530),
              padding: const EdgeInsets.all(14),
              child: Column(children: [
                // Stats row
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Match letter + picture!',
                      style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF90CAF9))),
                  Row(children: List.generate(_totalPairs, (i) => Container(
                    width: 11, height: 11,
                    margin: const EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                      color: i < _matchCount ? AppColors.gold : Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                  ))),
                ]),
                const SizedBox(height: 12),

                // Card grid 4x3
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: widget.difficulty == Difficulty.easy ? 4 : widget.difficulty == Difficulty.medium ? 4 : 4,
                      crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: _cards.length,
                    itemBuilder: (_, i) => _buildCard(_cards[i]),
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('💡 Find the letter that matches the picture!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF90CAF9))),
                ),
              ]),
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

  Widget _buildCard(_MemCard card) {
    final cardKey = card.id + card.type.name;
    final isWrong = _wrongCardIds.contains(cardKey);

    return GestureDetector(
      onTap: () => _tapCard(card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: card.isMatched
              ? const LinearGradient(colors: [AppColors.teal, AppColors.tealDark])
              : isWrong
              ? LinearGradient(colors: [AppColors.wrong, AppColors.wrong.withOpacity(0.7)])
              : card.isFlipped
              ? null
              : const LinearGradient(colors: [AppColors.blue, AppColors.blueDark]),
          color: (card.isFlipped && !card.isMatched && !isWrong) ? Colors.white : null,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: card.isMatched
                ? const Color(0xFF00E5C4)
                : isWrong
                ? AppColors.wrong
                : card.isFlipped
                ? const Color(0xFF90CAF9)
                : const Color(0xFF1976D2),
            width: 2,
          ),
          boxShadow: card.isFlipped ? [BoxShadow(
            color: (card.isMatched
                ? AppColors.teal
                : isWrong
                ? AppColors.wrong
                : AppColors.blue).withOpacity(0.4),
            blurRadius: 8)] : [],
        ),
        child: Center(
          child: card.isFlipped
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  if (card.type == _CardType.letter)
                    Text(card.display,
                        style: GoogleFonts.fredoka(
                            fontSize: 26,
                            color: card.isMatched
                                ? Colors.white
                                : isWrong
                                ? Colors.white
                                : AppColors.blue))
                  else ...[
                    Text(card.display, style: const TextStyle(fontSize: 26)),
                    Text(card.id,
                        style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: card.isMatched
                                ? Colors.white
                                : isWrong
                                ? Colors.white
                                : AppColors.blue)),
                  ],
                ])
              : Text('?',
                  style: GoogleFonts.fredoka(
                      fontSize: 24, color: Colors.white.withOpacity(0.4))),
        ),
      ),
    );
  }
}
