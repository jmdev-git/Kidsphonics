// lib/screens/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/shared_widgets.dart';
import '../data/letter_data.dart';
import 'lessons_screen.dart';
import 'games_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final learnedCount = provider.learnedLetters.length;
    final xp = provider.xp;
    final streak = provider.streak;
    final stars = provider.stars;

    // Level calculation: every 200 XP = 1 level
    final level = (xp / 200).floor() + 1;
    final xpInLevel = xp % 200;

    // Overall completion percentage
    final completionPct = (learnedCount / 26 * 100).round();

    return Scaffold(
      body: Column(
        children: [
          KidsHeader(
            title: '📊 My Progress',
            gradient: const LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
            ),
            textColor: const Color(0xFFE1BEE7),
            onBack: () => Navigator.pop(context),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'LVL $level',
                style: GoogleFonts.nunito(
                    fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.gold),
              ),
            ),
          ),

          Expanded(
            child: Container(
              color: AppColors.darkBg,
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  // ── Hero XP card ──────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6A1B9A).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Level $level',
                                  style: GoogleFonts.fredoka(
                                      fontSize: 28, color: AppColors.gold)),
                              Text('$xp XP total',
                                  style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white.withOpacity(0.7))),
                            ]),
                            const Text('🏆', style: TextStyle(fontSize: 52)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // XP progress bar
                        Row(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: xpInLevel / 200,
                                backgroundColor: Colors.white.withOpacity(0.15),
                                valueColor:
                                    const AlwaysStoppedAnimation(AppColors.gold),
                                minHeight: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('$xpInLevel / 200',
                              style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.gold)),
                        ]),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${200 - xpInLevel} XP to Level ${level + 1}',
                            style: GoogleFonts.nunito(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Stats row ─────────────────────────────────────────
                  Row(children: [
                    _StatCard(icon: '🔥', value: '$streak', label: 'Day Streak', color: const Color(0xFFFF6B35)),
                    const SizedBox(width: 10),
                    _StatCard(icon: '⭐', value: '$stars', label: 'Stars', color: AppColors.gold),
                    const SizedBox(width: 10),
                    _StatCard(icon: '🔤', value: '$learnedCount', label: 'Letters', color: AppColors.teal),
                  ]),
                  const SizedBox(height: 14),

                  // ── Significance note ─────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.teal.withOpacity(0.2)),
                    ),
                    child: Row(children: [
                      const Text('💡', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                        'Progress is saved locally on this device — enabling continuous practice outside the classroom.',
                        style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700,
                            color: AppColors.teal),
                      )),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // ── Overall completion ────────────────────────────────
                  _SectionTitle('📈 Overall Completion'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.09)),
                    ),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Alphabet Progress',
                              style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          Text('$completionPct%',
                              style: GoogleFonts.fredoka(
                                  fontSize: 18, color: AppColors.teal)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: learnedCount / 26,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.teal),
                          minHeight: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$learnedCount of 26 letters learned',
                        style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.5)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // ── Letters learned grid ──────────────────────────────
                  _SectionTitle('🔤 Letters Learned'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.09)),
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                        childAspectRatio: 1,
                      ),
                      itemCount: 26,
                      itemBuilder: (_, i) {
                        final letter = allLetters[i];
                        final learned =
                            provider.learnedLetters.contains(letter.letter);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: learned
                                ? AppColors.teal.withOpacity(0.2)
                                : Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: learned
                                  ? AppColors.teal
                                  : Colors.white.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                letter.letter,
                                style: GoogleFonts.fredoka(
                                  fontSize: 16,
                                  color: learned
                                      ? AppColors.teal
                                      : const Color(0xFF3D2A6E),
                                ),
                              ),
                              if (learned)
                                const Text('⭐',
                                    style: TextStyle(fontSize: 8)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Achievements ──────────────────────────────────────
                  _SectionTitle('🎖️ Achievements'),
                  const SizedBox(height: 10),
                  _AchievementRow(
                    icon: '🌟',
                    title: 'First Letter!',
                    desc: 'Learned your first letter',
                    unlocked: learnedCount >= 1,
                  ),
                  const SizedBox(height: 8),
                  _AchievementRow(
                    icon: '🔥',
                    title: 'On Fire!',
                    desc: 'Learned 5 letters',
                    unlocked: learnedCount >= 5,
                  ),
                  const SizedBox(height: 8),
                  _AchievementRow(
                    icon: '🏅',
                    title: 'Halfway There!',
                    desc: 'Learned 13 letters',
                    unlocked: learnedCount >= 13,
                  ),
                  const SizedBox(height: 8),
                  _AchievementRow(
                    icon: '🏆',
                    title: 'Alphabet Master!',
                    desc: 'Learned all 26 letters',
                    unlocked: learnedCount >= 26,
                  ),
                  const SizedBox(height: 8),
                  _AchievementRow(
                    icon: '💎',
                    title: 'XP Hunter',
                    desc: 'Earned 100 XP',
                    unlocked: xp >= 100,
                  ),
                  const SizedBox(height: 8),
                  _AchievementRow(
                    icon: '🔥',
                    title: 'Streak Starter',
                    desc: '3-day streak',
                    unlocked: streak >= 3,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          KidsBottomNav(
            currentIndex: 3,
            onTap: (i) {
              if (i == 0) Navigator.pop(context);
              if (i == 1) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LessonsScreen()));
              }
              if (i == 2) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const GamesScreen()));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF6A3FA0),
        letterSpacing: 1.2,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon, value, label;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.fredoka(fontSize: 22, color: color)),
          Text(label,
              style: GoogleFonts.nunito(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: color.withOpacity(0.7))),
        ]),
      ),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  final String icon, title, desc;
  final bool unlocked;
  const _AchievementRow(
      {required this.icon,
      required this.title,
      required this.desc,
      required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked
            ? AppColors.gold.withOpacity(0.07)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unlocked
              ? AppColors.gold.withOpacity(0.35)
              : Colors.white.withOpacity(0.07),
        ),
      ),
      child: Opacity(
        opacity: unlocked ? 1.0 : 0.35,
        child: Row(children: [
          Text(unlocked ? icon : '🔒',
              style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: unlocked ? AppColors.gold : Colors.white)),
              Text(desc,
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5))),
            ]),
          ),
          if (unlocked)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Unlocked!',
                  style: GoogleFonts.nunito(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gold)),
            ),
        ]),
      ),
    );
  }
}
