// lib/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';

/// Lightweight sound-effect service.
/// All sounds are generated from short asset files placed in assets/audio/.
/// If an asset is missing the call is silently ignored so the app never crashes.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  bool _enabled = true;
  bool get enabled => _enabled;
  set enabled(bool v) => _enabled = v;

  Future<void> _play(String assetName) async {
    if (!_enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/$assetName'));
    } catch (_) {
      // Asset missing or platform error — fail silently
    }
  }

  Future<void> playTap()     => _play('tap.mp3');
  Future<void> playCorrect() => _play('correct.mp3');
  Future<void> playWrong()   => _play('wrong.mp3');
  Future<void> playWin()     => _play('win.mp3');
  Future<void> playFlip()    => _play('flip.mp3');

  void dispose() => _player.dispose();
}
