// lib/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';

/// Lightweight sound-effect service.
/// correct.mp3 and wrong.mp3 get their own dedicated players so they
/// fire instantly and never get blocked by other audio.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // General SFX player (tap, win, flip)
  final AudioPlayer _player = AudioPlayer();

  // Dedicated players so correct/wrong always fire immediately
  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _wrongPlayer   = AudioPlayer();

  bool _enabled = true;
  bool get enabled => _enabled;
  set enabled(bool v) => _enabled = v;

  Future<void> _play(String assetName) async {
    if (!_enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/$assetName'));
    } catch (_) {}
  }

  Future<void> playTap() => _play('tap.mp3');
  Future<void> playWin() => _play('win.mp3');
  Future<void> playFlip() => _play('flip.mp3');

  /// Always plays immediately — dedicated player, never blocked.
  Future<void> playCorrect() async {
    if (!_enabled) return;
    try {
      await _correctPlayer.stop();
      await _correctPlayer.play(AssetSource('audio/correct.mp3'));
    } catch (_) {}
  }

  /// Always plays immediately — dedicated player, never blocked.
  Future<void> playWrong() async {
    if (!_enabled) return;
    try {
      await _wrongPlayer.stop();
      await _wrongPlayer.play(AssetSource('audio/wrong.mp3'));
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
    _correctPlayer.dispose();
    _wrongPlayer.dispose();
  }
}
