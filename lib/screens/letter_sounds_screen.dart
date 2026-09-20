// lib/screens/letter_sounds_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/shared_widgets.dart';
import '../data/letter_data.dart';
import 'progress_screen.dart';

class LetterSoundsScreen extends StatefulWidget {
  /// If [vowelsOnly] is true, only A/E/I/O/U are shown (Vowel Sounds lesson).
  final bool vowelsOnly;
  const LetterSoundsScreen({super.key, this.vowelsOnly = false});

  @override
  State<LetterSoundsScreen> createState() => _LetterSoundsScreenState();
}

class _LetterSoundsScreenState extends State<LetterSoundsScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;
  bool _isSpeaking = false;

  /// Filtered list based on vowelsOnly flag
  List<LetterItem> get _letters => widget.vowelsOnly
      ? allLetters.where((l) => ['A','E','I','O','U'].contains(l.letter)).toList()
      : allLetters;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -10).animate(
        CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
    // Mark the first displayed letter as learned on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().markLetterLearned(_letters[_currentIndex].letter);
    });
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  LetterItem get _current => _letters[_currentIndex];

  void _speak() async {
    final provider = context.read<AppProvider>();
    setState(() => _isSpeaking = true);
    provider.audio.playTap();
    final wasNew = !provider.learnedLetters.contains(_current.letter);
    provider.markLetterLearned(_current.letter);
    if (wasNew) provider.voiceFeedback.playPraise();
    await provider.speak(_current.sound);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) setState(() => _isSpeaking = false);
  }

  void _navigate(int dir) {
    context.read<AppProvider>().audio.playTap();
    final newIndex = (_currentIndex + dir + _letters.length) % _letters.length;
    // Mark as learned when navigated to
    context.read<AppProvider>().markLetterLearned(_letters[newIndex].letter);
    setState(() => _currentIndex = newIndex);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      body: Column(
        children: [
          KidsHeader(
            title: widget.vowelsOnly ? '🔤 Vowel Sounds' : 'Letter Sounds',
            gradient: const LinearGradient(colors: [Color(0xFFFF8C42), AppColors.orangeDark]),
            textColor: Colors.white,
            onBack: () => Navigator.pop(context),
            trailing: const VoiceChip(),
          ),

          Expanded(
            child: Container(
              color: AppColors.darkBg,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ── Big letter + picture hero card ──
                    Container(
                      margin: const EdgeInsets.all(14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF8C42), Color(0xFFFF6B00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [BoxShadow(
                          color: AppColors.orange.withOpacity(0.35),
                          blurRadius: 20, offset: const Offset(0, 6))],
                      ),
                      child: Row(
                        children: [
                          // Big letter
                          Expanded(
                            child: Text(_current.letter,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.fredoka(fontSize: 90, color: Colors.white,
                                    shadows: [const Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(0,4))])),
                          ),
                          // Picture with bounce
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _bounceAnim,
                              builder: (_, __) => Transform.translate(
                                offset: Offset(0, _bounceAnim.value),
                                child: Text(_current.emoji,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 72)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Word label
                    Text('${_current.letter} is for ${_current.word}',
                        style: GoogleFonts.fredoka(fontSize: 20, color: Colors.white.withOpacity(0.85))),
                    const SizedBox(height: 12),

                    // Speak row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _isSpeaking ? '🔊 Speaking...' : 'Tap 🔊 to hear the sound!',
                              style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900,
                                  color: const Color(0xFFC9A0FF)),
                            ),
                          ),
                          GestureDetector(
                            onTap: _speak,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 60, height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _isSpeaking
                                      ? [const Color(0xFF00C9A7), const Color(0xFF007A6A)]
                                      : [AppColors.gold, const Color(0xFFFF8C00)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(
                                    color: (_isSpeaking ? AppColors.teal : AppColors.gold).withOpacity(0.5),
                                    blurRadius: 14)],
                              ),
                              child: const Center(child: Text('🔊', style: TextStyle(fontSize: 28))),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Prev / Next buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _navigate(-1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text('← Prev', textAlign: TextAlign.center,
                                    style: GoogleFonts.fredoka(fontSize: 15, color: const Color(0xFFC9A0FF))),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _navigate(1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFFF8C00)]),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text('Next →', textAlign: TextAlign.center,
                                    style: GoogleFonts.fredoka(fontSize: 15, color: const Color(0xFF3E2000))),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── All 26 letters grid ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text('Tap any letter to learn it!',
                          style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w900,
                              color: const Color(0xFF6A3FA0), letterSpacing: 1.2)),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5, crossAxisSpacing: 6, mainAxisSpacing: 6,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: _letters.length,
                        itemBuilder: (_, i) {
                          final ltr = _letters[i];
                          final isActive = i == _currentIndex;
                          final isDone = provider.learnedLetters.contains(ltr.letter);

                          return GestureDetector(
                            onTap: () {
                              final p = context.read<AppProvider>();
                              p.audio.playTap();
                              p.markLetterLearned(ltr.letter);
                              setState(() => _currentIndex = i);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.gold.withOpacity(0.12)
                                    : isDone
                                    ? AppColors.teal.withOpacity(0.1)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isActive ? AppColors.gold
                                      : isDone ? AppColors.teal
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(ltr.letter,
                                        style: GoogleFonts.fredoka(
                                            fontSize: 17, color: Colors.white)),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(ltr.emoji,
                                        style: const TextStyle(fontSize: 15)),
                                  ),
                                  if (isDone)
                                    const Text('⭐',
                                        style: TextStyle(fontSize: 9)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          KidsBottomNav(
            currentIndex: 1,
            onTap: (i) {
              if (i != 1) Navigator.pop(context);
              if (i == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen()));
            },
          ),
        ],
      ),
    );
  }
}
