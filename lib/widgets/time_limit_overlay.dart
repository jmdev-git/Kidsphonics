// lib/widgets/time_limit_overlay.dart
//
// Full-screen overlay that appears when the 30-minute session timer expires.
// It blocks all interaction until a parent taps "I'm the parent" and confirms.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class TimeLimitOverlay extends StatefulWidget {
  final Widget child;
  const TimeLimitOverlay({super.key, required this.child});

  @override
  State<TimeLimitOverlay> createState() => _TimeLimitOverlayState();
}

class _TimeLimitOverlayState extends State<TimeLimitOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _showUnlockDialog(BuildContext ctx, AppProvider provider) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D0122),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🔐', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text('Parent Confirmation',
              style: GoogleFonts.fredoka(fontSize: 20, color: Colors.white)),
          const SizedBox(height: 6),
          Text(
            'Tap "Unlock" to give your child more time, or leave locked so they take a break.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white60),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                provider.resetSessionTimer();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: Text('✅ Unlock & Reset Timer',
                  style: GoogleFonts.fredoka(
                      color: Colors.white, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: Text('Keep Locked',
                  style: GoogleFonts.fredoka(
                      color: Colors.white54, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        return Stack(
          children: [
            // The actual app underneath
            widget.child,

            // Lock overlay — only shown when time is up
            if (provider.timeLimitReached)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xEE0D0122), Color(0xEE120A2E)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Pulsing clock emoji
                          AnimatedBuilder(
                            animation: _pulse,
                            builder: (_, child) => Transform.scale(
                              scale: _pulse.value,
                              child: child,
                            ),
                            child: const Text('⏰',
                                style: TextStyle(fontSize: 90)),
                          ),
                          const SizedBox(height: 20),

                          Text('Rest Time!',
                              style: GoogleFonts.fredoka(
                                  fontSize: 38, color: AppColors.gold)),
                          const SizedBox(height: 10),

                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              "You've been learning for 30 minutes.\nTime for a little break! 🌟",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white70,
                                  height: 1.6),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Stars earned this session
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.gold.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('⭐',
                                    style: TextStyle(fontSize: 28)),
                                const SizedBox(width: 10),
                                Text(
                                  '${provider.stars} stars earned today!',
                                  style: GoogleFonts.fredoka(
                                      fontSize: 18, color: AppColors.gold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Parent unlock button
                          GestureDetector(
                            onTap: () =>
                                _showUnlockDialog(ctx, provider),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        Colors.white.withOpacity(0.15)),
                              ),
                              child: Text(
                                '👨👩👧 I\'m the parent — unlock',
                                style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white54),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
