// lib/screens/voice_recognition_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/shared_widgets.dart';
import '../data/letter_data.dart';
import '../models/difficulty.dart';
import 'progress_screen.dart';

class VoiceRecognitionScreen extends StatefulWidget {
  final Difficulty difficulty;
  const VoiceRecognitionScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<VoiceRecognitionScreen> createState() => _VoiceRecognitionScreenState();
}

class _VoiceRecognitionScreenState extends State<VoiceRecognitionScreen>
    with TickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  bool _isInitialized = false;

  String _recognized = '';
  bool? _isCorrect;
  int _wordIndex = 0;
  int _score = 0;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  List<Map<String, String>> get _words =>
      voiceWords[widget.difficulty] ?? voiceWords[Difficulty.easy]!;

  Map<String, String> get _current => _words[_wordIndex];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.18)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _initSpeech();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().voiceFeedback.playIntroVoice();
    });
  }

  Future<void> _initSpeech() async {
    _isAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (mounted) setState(() => _isInitialized = true);
  }

  Future<void> _listen() async {
    if (!_isAvailable || !_isInitialized) return;
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    setState(() {
      _recognized = '';
      _isCorrect = null;
      _isListening = true;
    });

    await _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() => _recognized = result.recognizedWords);
          if (result.finalResult) {
            _evaluate(result.recognizedWords);
          }
        }
      },
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 2),
      localeId: 'en_US',
    );
  }

  void _evaluate(String recognized) async {
    final target = _current['word']!.toLowerCase().trim();
    final heard = recognized.toLowerCase().trim();

    // Accept if the target word appears anywhere in the recognized phrase
    final isCorrect = heard.contains(target) || target.contains(heard) ||
        _levenshtein(target, heard) <= 1;

    setState(() {
      _isCorrect = isCorrect;
      _isListening = false;
    });

    final provider = context.read<AppProvider>();
    if (isCorrect) {
      _score += (10 * widget.difficulty.xpMultiplier).round();
      provider.addXP((10 * widget.difficulty.xpMultiplier).round());
      provider.addStar();
      provider.audio.playCorrect();
      _confettiKey.currentState?.fire();
      provider.voiceFeedback.playPraise();
      await provider.speak('Great job! You said ${_current['word']} correctly!');
    } else {
      provider.audio.playWrong();
      provider.voiceFeedback.playWrong();
      await provider.speak(
          'Good try! Listen and try again. The word is ${_current['word']}. ${_current['hint']}');
    }
  }

  void _nextWord() {
    if (_wordIndex < _words.length - 1) {
      setState(() {
        _wordIndex++;
        _recognized = '';
        _isCorrect = null;
      });
    } else {
      _showResults();
    }
  }

  void _playWord() {
    final provider = context.read<AppProvider>();
    provider.speak('${_current['word']}! ${_current['hint']}');
  }

  void _showResults() {
    final provider = context.read<AppProvider>();
    provider.audio.playWin();
    provider.addXP(15);
    provider.voiceFeedback.playWinVoice();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🎤', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 8),
          Text('Practice Done!',
              style: GoogleFonts.fredoka(fontSize: 22, color: AppColors.gold)),
          Text('Score: $_score points',
              style: GoogleFonts.nunito(
                  fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.teal)),
          Text('+15 bonus XP!',
              style: GoogleFonts.nunito(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: const Color(0xFFA5D6A7))),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _wordIndex = 0;
                  _recognized = '';
                  _isCorrect = null;
                  _score = 0;
                });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
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
                  gameTitle: 'Say It Right!',
                  gameIcon: '🎤',
                  onSelected: (d) => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => VoiceRecognitionScreen(difficulty: d)),
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

  /// Simple Levenshtein distance for fuzzy matching (≤1 typo = accept)
  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    final matrix =
        List.generate(a.length + 1, (i) => List.filled(b.length + 1, 0));
    for (int i = 0; i <= a.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= b.length; j++) matrix[0][j] = j;
    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
      }
    }
    return matrix[a.length][b.length];
  }

  @override
  void dispose() {
    _speech.stop();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConfettiOverlay(
        overlayKey: _confettiKey,
        child: Column(children: [
          KidsHeader(
            title: '🎤 Say It Right!',
            gradient: const LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)]),
            textColor: const Color(0xFFE1BEE7),
            onBack: () => Navigator.pop(context),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${widget.difficulty.emoji} ${widget.difficulty.label}',
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
                child: Text('⭐ $_score',
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.gold)),
              ),
            ]),
          ),

          // Progress bar
          LinearProgressIndicator(
            value: (_wordIndex + 1) / _words.length,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor:
                const AlwaysStoppedAnimation(Color(0xFFCE93D8)),
            minHeight: 6,
          ),

          Expanded(
            child: Container(
              color: const Color(0xFF0D0122),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  // Word counter
                  Text('Word ${_wordIndex + 1} of ${_words.length}',
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFCE93D8))),
                  const SizedBox(height: 14),

                  // ── Word card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF7B1FA2).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6))
                      ],
                    ),
                    child: Column(children: [
                      Text(_current['emoji']!,
                          style: const TextStyle(fontSize: 80)),
                      const SizedBox(height: 10),
                      Text(_current['word']!,
                          style: GoogleFonts.fredoka(
                              fontSize: 32, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Say this word out loud!',
                          style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white60)),
                      const SizedBox(height: 12),
                      // Listen button
                      GestureDetector(
                        onTap: _playWord,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Text('🔊',
                                style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text('Hear the word',
                                style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white)),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // ── Mic button ──
                  if (!_isInitialized)
                    Text('Starting microphone...',
                        style: GoogleFonts.nunito(
                            fontSize: 13, color: Colors.white54))
                  else if (!_isAvailable)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.wrong.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.wrong.withOpacity(0.3)),
                      ),
                      child: Text(
                        '⚠️ Microphone not available.\nPlease allow microphone access in device settings.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.wrong),
                      ),
                    )
                  else
                    Column(children: [
                      // Pulsing mic
                      GestureDetector(
                        onTap: _listen,
                        child: AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (_, child) => Transform.scale(
                            scale: _isListening ? _pulseAnim.value : 1.0,
                            child: child,
                          ),
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isListening
                                    ? [
                                        const Color(0xFFE91E63),
                                        const Color(0xFF880E4F)
                                      ]
                                    : [
                                        const Color(0xFF7B1FA2),
                                        const Color(0xFF4A148C)
                                      ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_isListening
                                          ? const Color(0xFFE91E63)
                                          : const Color(0xFF7B1FA2))
                                      .withOpacity(0.5),
                                  blurRadius: _isListening ? 24 : 12,
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _isListening ? '🎙️' : '🎤',
                                style: const TextStyle(fontSize: 40),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isListening
                            ? 'Listening... speak now!'
                            : 'Tap the mic and say the word!',
                        style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: _isListening
                                ? const Color(0xFFE91E63)
                                : Colors.white70),
                      ),
                    ]),
                  const SizedBox(height: 16),

                  // ── Result card ──
                  if (_recognized.isNotEmpty) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isCorrect == true
                            ? AppColors.teal.withOpacity(0.12)
                            : _isCorrect == false
                                ? AppColors.wrong.withOpacity(0.1)
                                : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isCorrect == true
                              ? AppColors.teal
                              : _isCorrect == false
                                  ? AppColors.wrong
                                  : Colors.transparent,
                        ),
                      ),
                      child: Column(children: [
                        Text(
                          _isCorrect == true
                              ? '✅ Perfect pronunciation!'
                              : _isCorrect == false
                                  ? '❌ Try again!'
                                  : '...',
                          style: GoogleFonts.fredoka(
                              fontSize: 18,
                              color: _isCorrect == true
                                  ? AppColors.teal
                                  : _isCorrect == false
                                      ? AppColors.wrong
                                      : Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text('I heard: "$_recognized"',
                            style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70)),
                      ]),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── Next / Try again buttons ──
                  if (_isCorrect == true)
                    GestureDetector(
                      onTap: _nextWord,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppColors.teal, AppColors.tealDark]),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Text(
                          _wordIndex < _words.length - 1
                              ? 'Next Word →'
                              : '🎉 See Results!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                              fontSize: 17,
                              color: Colors.white),
                        ),
                      ),
                    ),

                  if (_isCorrect == false)
                    GestureDetector(
                      onTap: _listen,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF7B1FA2), Color(0xFF4A148C)]),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Text(
                          '🎤 Try Again',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                              fontSize: 17, color: Colors.white),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Hint chip
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '💡 Sound it out: ${_current['hint']}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFCE93D8)),
                    ),
                  ),
                ]),
              ),
            ),
          ),

          KidsBottomNav(currentIndex: 2, onTap: (i) {
            if (i != 2) Navigator.pop(context);
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
