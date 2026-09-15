// lib/services/voice_feedback_service.dart
//
// Plays contextual voice feedback from assets/audio/phonics/voice_feedback/.
// All methods are fire-and-forget — call them alongside game logic.

import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class VoiceFeedbackService {
  static final VoiceFeedbackService _i = VoiceFeedbackService._internal();
  factory VoiceFeedbackService() => _i;
  VoiceFeedbackService._internal();

  final AudioPlayer _player = AudioPlayer();
  final _rng = Random();

  static const _base = 'audio/phonics/voice_feedback';

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  Future<void> _play(String file) async {
    try {
      await _player.stop();
      await _player.play(AssetSource('$_base/$file'));
    } catch (_) {}
  }

  // ── Praise (random so it feels fresh) ────────────────────────────────────
  Future<void> playPraise() => _play('praise_${_rng.nextInt(8) + 1}.mp3');

  // ── Wrong answer (random) ─────────────────────────────────────────────────
  Future<void> playWrong() => _play('wrong_${_rng.nextInt(5) + 1}.mp3');

  // ── Game-specific wrong explanations ─────────────────────────────────────
  Future<void> playWrongSoundMatch()  => _play('wrong_sound_match.mp3');
  Future<void> playWrongQuiz()        => _play('wrong_quiz.mp3');
  Future<void> playWrongWordBuilder() => _play('wrong_word.mp3');
  Future<void> playWrongMemory()      => _play('wrong_memory.mp3');
  Future<void> playWrongAlphabet()    => _play('wrong_alphabet.mp3');
  Future<void> playWrongRhyming()     => _play('wrong_rhyming.mp3');

  // ── Win / completion ──────────────────────────────────────────────────────
  Future<void> playWinPerfect()      => _play('win_perfect.mp3');
  Future<void> playWinGreat()        => _play('win_great.mp3');
  Future<void> playWinGood()         => _play('win_good.mp3');
  Future<void> playWinSoundMatch()   => _play('win_sound_match.mp3');
  Future<void> playWinMemory()       => _play('win_memory.mp3');
  Future<void> playWinQuiz()         => _play('win_quiz.mp3');
  Future<void> playWinWordBuilder()  => _play('win_word_builder.mp3');
  Future<void> playWinAlphabet()     => _play('win_alphabet.mp3');
  Future<void> playWinRhyming()      => _play('win_rhyming.mp3');
  Future<void> playWinVoice()        => _play('win_voice.mp3');

  /// Auto-select win phrase based on score ratio (correct / total)
  Future<void> playWinByScore(int correct, int total, {String game = ''}) {
    final ratio = total == 0 ? 1.0 : correct / total;
    final gameMap = {
      'sound_match'  : playWinSoundMatch,
      'memory'       : playWinMemory,
      'quiz'         : playWinQuiz,
      'word_builder' : playWinWordBuilder,
      'alphabet'     : playWinAlphabet,
      'rhyming'      : playWinRhyming,
      'voice'        : playWinVoice,
    };
    if (ratio == 1.0) return playWinPerfect();
    if (ratio >= 0.7) return gameMap[game]?.call() ?? playWinGreat();
    return playWinGood();
  }

  // ── Game intros ───────────────────────────────────────────────────────────
  Future<void> playIntroSoundMatch()  => _play('intro_sound_match.mp3');
  Future<void> playIntroMemory()      => _play('intro_memory.mp3');
  Future<void> playIntroQuiz()        => _play('intro_quiz.mp3');
  Future<void> playIntroWordBuilder() => _play('intro_word_builder.mp3');
  Future<void> playIntroAlphabet()    => _play('intro_alphabet.mp3');
  Future<void> playIntroRhyming()     => _play('intro_rhyming.mp3');
  Future<void> playIntroVoice()       => _play('intro_voice.mp3');

  // ── Milestones ────────────────────────────────────────────────────────────
  Future<void> playLevelUp()               => _play('level_up.mp3');
  Future<void> playAchievementFirst()      => _play('achievement_first.mp3');
  Future<void> playAchievement5Letters()   => _play('achievement_5.mp3');
  Future<void> playAchievement13Letters()  => _play('achievement_13.mp3');
  Future<void> playAchievement26Letters()  => _play('achievement_26.mp3');
  Future<void> playAchievementXP()         => _play('achievement_xp.mp3');
  Future<void> playAchievementStreak()     => _play('achievement_streak.mp3');

  /// Call after any XP/letter/star change to check milestones.
  Future<void> checkMilestones({
    required int learnedCount,
    required int xp,
    required int streak,
    required int prevLearnedCount,
    required int prevXp,
    required int prevStreak,
    required int level,
    required int prevLevel,
  }) async {
    if (level > prevLevel)           { await playLevelUp(); return; }
    if (learnedCount >= 26 && prevLearnedCount < 26) { await playAchievement26Letters(); return; }
    if (learnedCount >= 13 && prevLearnedCount < 13) { await playAchievement13Letters(); return; }
    if (learnedCount >= 5  && prevLearnedCount < 5)  { await playAchievement5Letters();  return; }
    if (learnedCount >= 1  && prevLearnedCount < 1)  { await playAchievementFirst();     return; }
    if (xp >= 100 && prevXp < 100)  { await playAchievementXP();     return; }
    if (streak >= 3 && prevStreak < 3) { await playAchievementStreak(); return; }
  }

  void dispose() => _player.dispose();
}
