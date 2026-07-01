// lib/screens/parent_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/shared_widgets.dart';
import 'progress_screen.dart';
import 'lessons_screen.dart';
import 'games_screen.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});
  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  final _barHeights = [40.0, 50.0, 35.0, 55.0, 0.0];
  final _days = ['M', 'T', 'W', 'T', 'F'];

  void _confirmReset(AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset Progress?',
            style: GoogleFonts.fredoka(color: AppColors.wrong, fontSize: 20)),
        content: Text(
          'This will clear all XP, stars, streak, and learned letters. This cannot be undone.',
          style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.nunito(
                    color: AppColors.teal, fontWeight: FontWeight.w800)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.resetProgress();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Progress reset!',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                  backgroundColor: AppColors.wrong,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.wrong,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: Text('Reset',
                style: GoogleFonts.nunito(
                    color: Colors.white, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      body: Column(children: [
        KidsHeader(
          title: '👨👩👧 Parent Panel',
          gradient: const LinearGradient(
              colors: [Color(0xFF37474F), Color(0xFF263238)]),
          textColor: const Color(0xFFCFD8DC),
          onBack: () => Navigator.pop(context),
        ),

        Expanded(
          child: Container(
            color: AppColors.darkBg,
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                // Stats card
                _PanelCard(
                  title: '📊 Progress Summary',
                  child: Row(children: [
                    _StatBox(
                        value: '${provider.learnedLetters.length}',
                        label: 'Letters'),
                    const SizedBox(width: 8),
                    _StatBox(value: '${provider.xp}', label: 'XP Earned'),
                    const SizedBox(width: 8),
                    _StatBox(value: '${provider.streak}', label: 'Streak'),
                  ]),
                ),
                const SizedBox(height: 12),

                // Controls
                _PanelCard(
                  title: '⚙️ Controls',
                  child: Column(children: [
                    _ToggleRow(
                      label: '🔊 Voice Assistance',
                      value: provider.voiceEnabled,
                      onChanged: (_) => provider.toggleVoice(),
                    ),
                    _ToggleRow(
                      label: '🎵 Sound Effects',
                      value: provider.sfxEnabled,
                      onChanged: (_) => provider.toggleSfx(),
                    ),
                    _ToggleRow(
                      label: '🎮 Game Access',
                      value: provider.gameAccess,
                      onChanged: (_) => provider.toggleGameAccess(),
                    ),
                    _ToggleRow(
                      label: '⏱️ Time Limit (30 min)',
                      value: provider.timeLimitEnabled,
                      onChanged: (_) => provider.toggleTimeLimit(),
                      isLast: !provider.timeLimitEnabled,
                    ),
                    // Show timer status when time limit is on
                    if (provider.timeLimitEnabled) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: provider.timeLimitReached
                              ? AppColors.wrong.withOpacity(0.1)
                              : AppColors.teal.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: provider.timeLimitReached
                                ? AppColors.wrong.withOpacity(0.4)
                                : AppColors.teal.withOpacity(0.2),
                          ),
                        ),
                        child: Row(children: [
                          Text(
                            provider.timeLimitReached ? '🔒' : '⏳',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.timeLimitReached
                                      ? 'Time\'s up! Screen is locked.'
                                      : '${provider.sessionMinutesLeft} min remaining',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: provider.timeLimitReached
                                        ? AppColors.wrong
                                        : AppColors.teal,
                                  ),
                                ),
                                if (!provider.timeLimitReached)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: provider.sessionSeconds /
                                          (AppProvider.timeLimitMinutes * 60),
                                      backgroundColor:
                                          Colors.white.withOpacity(0.1),
                                      valueColor: AlwaysStoppedAnimation(
                                        AppColors.teal,
                                      ),
                                      minHeight: 5,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (provider.timeLimitReached)
                            TextButton(
                              onPressed: () => provider.resetSessionTimer(),
                              child: Text('Unlock',
                                  style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.teal)),
                            ),
                        ]),
                      ),
                    ],
                  ]),
                ),
                const SizedBox(height: 12),

                // Weekly chart
                _PanelCard(
                  title: '📈 Weekly Activity',
                  child: SizedBox(
                    height: 80,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(
                          5,
                          (i) => Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    AnimatedContainer(
                                      duration: Duration(
                                          milliseconds: 600 + i * 100),
                                      curve: Curves.easeOut,
                                      height: _barHeights[i],
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: i == 3
                                            ? AppColors.gold
                                            : AppColors.teal,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(4)),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(_days[i],
                                        style: GoogleFonts.nunito(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: i == 3
                                                ? AppColors.gold
                                                : const Color(0xFF546E7A))),
                                  ],
                                ),
                              )),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Learned letters
                _PanelCard(
                  title:
                      '🔤 Letters Learned (${provider.learnedLetters.length}/26)',
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(26, (i) {
                      final lt = String.fromCharCode(65 + i);
                      final learned = provider.learnedLetters.contains(lt);
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: learned
                              ? AppColors.teal.withOpacity(0.2)
                              : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: learned
                                  ? AppColors.teal
                                  : Colors.white.withOpacity(0.1)),
                        ),
                        child: Center(
                          child: Text(lt,
                              style: GoogleFonts.fredoka(
                                  fontSize: 14,
                                  color: learned
                                      ? AppColors.teal
                                      : const Color(0xFF3D2A6E))),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),

                // Reset button
                GestureDetector(
                  onTap: () => _confirmReset(provider),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.wrong.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppColors.wrong.withOpacity(0.4)),
                    ),
                    child: Text(
                      "🗑️ Reset Child's Progress",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.wrong),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        KidsBottomNav(
          currentIndex: 0,
          onTap: (i) {
            if (i == 0) Navigator.pop(context);
            if (i == 1) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LessonsScreen()));
            }
            if (i == 2) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const GamesScreen()));
            }
            if (i == 3) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProgressScreen()));
            }
          },
        ),
      ]),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────

class _PanelCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _PanelCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF546E7A),
                letterSpacing: 1,
                height: 1)),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value, label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Text(value,
              style: GoogleFonts.fredoka(fontSize: 22, color: Colors.white)),
          Text(label,
              style: GoogleFonts.nunito(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF546E7A),
                  letterSpacing: 0.5)),
        ]),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {  final String label;
  final bool value;
  final Function(bool) onChanged;
  final bool isLast;

  const _ToggleRow(
      {required this.label,
      required this.value,
      required this.onChanged,
      this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Row(children: [
        Expanded(
            child: Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFCFD8DC)))),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.teal,
          activeTrackColor: AppColors.teal.withOpacity(0.3),
          inactiveThumbColor: Colors.white54,
          inactiveTrackColor: Colors.white.withOpacity(0.15),
        ),
      ]),
    );
  }
}
