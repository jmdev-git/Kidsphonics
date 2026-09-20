// lib/screens/lessons_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/shared_widgets.dart';
import 'games_screen.dart';
import 'letter_sounds_screen.dart';
import 'rhyming_words_screen.dart';
import 'progress_screen.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Scaffold(
      body: Column(
        children: [
          KidsHeader(
            title: '📖 My Lessons',
            gradient: const LinearGradient(colors: [AppColors.teal, AppColors.tealDark]),
            textColor: Colors.white,
            onBack: () => Navigator.pop(context),
            trailing: const VoiceChip(),
          ),
          Expanded(
            child: Container(
              color: AppColors.darkBg,
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  // Phonics instruction note for panelists
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.teal.withOpacity(0.25)),
                    ),
                    child: Row(children: [
                      const Text('📚', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                        'Multisensory phonics instruction — tap any lesson to see & hear each letter sound.',
                        style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700,
                            color: AppColors.teal),
                      )),
                    ]),
                  ),
                  _LessonRow(
                    icon: '🔤', title: 'Letter Sounds A–Z',
                    subtitle: 'Tap each letter · see the picture · hear the sound',
                    status: LessonStatus.done, stars: 3,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LetterSoundsScreen())),
                    onSpeak: () => context.read<AppProvider>().speak('A says Ahh! B says Buh! C says Cuh!'),
                  ),
                  const SizedBox(height: 10),
                  _LessonRow(
                    icon: '🎵', title: 'Vowel Sounds',
                    subtitle: 'A · E · I · O · U — pictures & audio',
                    status: LessonStatus.done, stars: 2,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LetterSoundsScreen(vowelsOnly: true))),
                    onSpeak: () => context.read<AppProvider>().speak('A says Ahh, like Apple! E says Ehh, like Egg! I says Ihh, like Ice Cream! O says Ohh, like Octopus! U says Uhh, like Umbrella!'),
                  ),
                  const SizedBox(height: 10),
                  _LessonRow(
                    icon: '🗣️', title: 'Rhyming Words',
                    subtitle: provider.rhymingWordsDone
                        ? 'Completed! Tap to play again'
                        : 'Find the word that rhymes · Easy to Hard',
                    status: provider.rhymingWordsDone
                        ? LessonStatus.done
                        : LessonStatus.active,
                    stars: provider.rhymingWordsDone ? 3 : 0,
                    progress: provider.rhymingWordsDone ? null : 0.5,
                    onTap: () => showDifficultyPicker(
                      context: context,
                      gameTitle: 'Rhyming Words',
                      gameIcon: '🗣️',
                      onSelected: (d) => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => RhymingWordsScreen(difficulty: d))),
                    ),
                    onSpeak: () => context.read<AppProvider>().speak('Cat, Bat, Hat! They rhyme!'),
                  ),
                ],
              ),
            ),
          ),
          KidsBottomNav(
            currentIndex: 1,
            onTap: (i) {
              if (i == 0) Navigator.pop(context);
              if (i == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const GamesScreen()));
              if (i == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen()));
            },
          ),
        ],
      ),
    );
  }
}

enum LessonStatus { done, active, locked }

class _LessonRow extends StatelessWidget {
  final String icon, title, subtitle;
  final LessonStatus status;
  final int stars;
  final double? progress;
  final VoidCallback onTap;
  final VoidCallback? onSpeak;

  const _LessonRow({
    required this.icon, required this.title, required this.subtitle,
    required this.status, required this.onTap,
    this.stars = 0, this.progress, this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = status == LessonStatus.done;
    final isActive = status == LessonStatus.active;
    final isLocked = status == LessonStatus.locked;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDone ? AppColors.teal.withOpacity(0.08)
              : isActive ? AppColors.gold.withOpacity(0.06)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDone ? AppColors.teal
                : isActive ? AppColors.gold
                : Colors.white.withOpacity(0.09),
          ),
          boxShadow: isActive ? [BoxShadow(color: AppColors.gold.withOpacity(0.2), blurRadius: 12)] : [],
        ),
        child: Opacity(
          opacity: isLocked ? 0.38 : 1.0,
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.teal.withOpacity(0.18)
                      : isActive ? AppColors.gold.withOpacity(0.14)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(child: Text(icon, style: const TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: GoogleFonts.nunito(fontSize: 11, color: const Color(0xFF7A5FA0))),
                    if (stars > 0) ...[
                      const SizedBox(height: 4),
                      Row(children: List.generate(3, (i) =>
                          Text(i < stars ? '⭐' : '☆', style: TextStyle(
                              fontSize: 13,
                              color: i < stars ? AppColors.gold : Colors.white24)))),
                    ],
                    if (progress != null) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (onSpeak != null)
                GestureDetector(
                  onTap: onSpeak,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.teal, AppColors.tealDark]),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(child: Text('🔊', style: TextStyle(fontSize: 18))),
                  ),
                ),
              const SizedBox(width: 6),
              Text(
                isDone ? '✅' : isActive ? '▶️' : '🔒',
                style: const TextStyle(fontSize: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
