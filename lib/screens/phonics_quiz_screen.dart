// lib/screens/phonics_quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/shared_widgets.dart';
import '../data/letter_data.dart';
import '../models/difficulty.dart';
import 'progress_screen.dart';

class PhonicsQuizScreen extends StatefulWidget {
  final Difficulty difficulty;
  const PhonicsQuizScreen({super.key, this.difficulty = Difficulty.medium});
  @override
  State<PhonicsQuizScreen> createState() => _PhonicsQuizScreenState();
}

class _PhonicsQuizScreenState extends State<PhonicsQuizScreen> {
  int _qIndex = 0;
  String? _selected;
  bool _answered = false;
  int _correct = 0;
  late List<String> _shuffledOpts;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  List<QuizQuestion> get _questions => quizQuestionsForDifficulty(widget.difficulty);

  @override
  void initState() {
    super.initState();
    _shuffleOpts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().voiceFeedback.playIntroQuiz();
    });
  }

  void _shuffleOpts() {
    _shuffledOpts = List<String>.from(_questions[_qIndex].options)..shuffle();
  }

  QuizQuestion get _q => _questions[_qIndex];

  void _pick(String letter) async {
    if (_answered) return;
    final isCorrect = letter == _q.correctLetter;
    setState(() { _selected = letter; _answered = true; if (isCorrect) _correct++; });

    final provider = context.read<AppProvider>();
    if (isCorrect) {
      provider.audio.playCorrect();
      _confettiKey.currentState?.fire();
      provider.addXP((5 * widget.difficulty.xpMultiplier).round());
      provider.addStar();
      await Future.delayed(const Duration(milliseconds: 700));
      await provider.speak('Correct! ${_q.correctLetter} is the right answer! Well done!');
    } else {
      provider.audio.playWrong();
      await Future.delayed(const Duration(milliseconds: 700));
      await provider.speak('Not quite! The answer is ${_q.correctLetter}! ${_q.voiceHint}');
    }
  }

  void _nextQuestion() {
    if (_qIndex < _questions.length - 1) {
      setState(() {
        _qIndex++;
        _selected = null;
        _answered = false;
        _shuffleOpts();
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final provider = context.read<AppProvider>();
    provider.addXP((20 * widget.difficulty.xpMultiplier).round());
    provider.audio.playWin();
    _confettiKey.currentState?.fire();
    provider.voiceFeedback.playWinByScore(_correct, _questions.length, game: 'quiz');
    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      backgroundColor: AppColors.darkBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(_correct >= (_questions.length * 0.7).ceil() ? '🏆' : '😊', style: const TextStyle(fontSize: 60)),
        Text('Quiz Done!', style: GoogleFonts.fredoka(fontSize: 22, color: AppColors.gold)),
        Text('$_correct / ${_questions.length} correct!',
            style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.teal)),
        Text('+${(25 * widget.difficulty.xpMultiplier).round()} XP Earned!',
            style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFFA5D6A7))),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() { _qIndex = 0; _selected = null; _answered = false; _correct = 0; _shuffleOpts(); });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
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
                gameTitle: 'Phonics Quiz',
                gameIcon: '❓',
                onSelected: (d) => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => PhonicsQuizScreen(difficulty: d)),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.green.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: Text('🎯 Change Difficulty',
                style: GoogleFonts.fredoka(color: AppColors.green, fontSize: 15)),
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
    final provider = context.read<AppProvider>();
    return Scaffold(
      body: ConfettiOverlay(
        overlayKey: _confettiKey,
        child: Column(children: [
          KidsHeader(
            title: '❓ Phonics Quiz',
            gradient: const LinearGradient(colors: [AppColors.green, AppColors.greenDark]),
            textColor: const Color(0xFFC8E6C9),
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
                child: Text('Q ${_qIndex + 1}/${_questions.length}',
                    style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ]),
          ),

          // Progress bar
          ClipRRect(
            child: LinearProgressIndicator(
              value: (_qIndex + 1) / _questions.length,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF69F0AE)),
              minHeight: 8,
            ),
          ),

          Expanded(
            child: Container(
              color: const Color(0xFF051208),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(children: [
                  // ── Big picture clue ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withOpacity(0.09)),
                    ),
                    child: Column(children: [
                      Text(_q.emoji, style: const TextStyle(fontSize: 72)),
                      const SizedBox(height: 8),
                      Text('What sound does this start with?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(fontSize: 19, color: Colors.white)),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('Tap to listen!',
                            style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800,
                                color: const Color(0xFF4CAF50))),
                        const SizedBox(width: 10),
                        SpeakButton(
                          onTap: () => provider.speakHint(_q.voiceHint),
                          size: 40,
                          bgColor: AppColors.teal,
                        ),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // Letter options — each has a DIFFERENT emoji from the question
                  // so kids can't just picture-match; they must think about the sound
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8, mainAxisSpacing: 8,
                    childAspectRatio: 1.3,
                    children: List.generate(_shuffledOpts.length, (idx) {
                      final lt = _shuffledOpts[idx];
                      // Find original index in _q.options to get its emoji
                      final origIdx = _q.options.indexOf(lt);
                      final optEmoji = origIdx >= 0 && origIdx < _q.optionEmojis.length
                          ? _q.optionEmojis[origIdx]
                          : '❓';
                      final isSelected = _selected == lt;
                      final isCorrect = lt == _q.correctLetter;
                      Color borderColor = Colors.white.withOpacity(0.1);
                      Color bgColor = Colors.white.withOpacity(0.05);
                      if (_answered && isSelected) {
                        borderColor = isCorrect ? const Color(0xFF69F0AE) : AppColors.wrong;
                        bgColor = isCorrect ? const Color(0xFF69F0AE).withOpacity(0.1) : AppColors.wrong.withOpacity(0.1);
                      } else if (_answered && isCorrect) {
                        borderColor = const Color(0xFF69F0AE);
                        bgColor = const Color(0xFF69F0AE).withOpacity(0.08);
                      }

                      return GestureDetector(
                        onTap: () => _pick(lt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: borderColor, width: 2.5),
                          ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(optEmoji, style: const TextStyle(fontSize: 30)),
                            const SizedBox(height: 4),
                            Text(lt,
                                style: GoogleFonts.fredoka(fontSize: 24,
                                    color: (_answered && isCorrect) ? const Color(0xFF69F0AE) : Colors.white)),
                            Text('${lt.toLowerCase()}-sound',
                                style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800,
                                    color: Colors.white.withOpacity(0.45))),
                          ]),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),

                  if (_answered)
                    GestureDetector(
                      onTap: _nextQuestion,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.green, AppColors.greenDark]),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Text(
                          _qIndex < _questions.length - 1 ? 'Next Question →' : '🎉 See Results!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(fontSize: 17, color: const Color(0xFFC8E6C9)),
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
