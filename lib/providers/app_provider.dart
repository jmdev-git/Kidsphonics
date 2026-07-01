// lib/providers/app_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audio_service.dart';
import '../services/phonics_audio_service.dart';

class AppProvider extends ChangeNotifier {
  final AudioService audio = AudioService();
  final PhonicsAudioService phonicsAudio = PhonicsAudioService();

  bool _voiceEnabled = true;
  bool _sfxEnabled = true;
  bool _gameAccess = true;
  bool _timeLimitEnabled = false;
  bool _rhymingWordsDone = false;
  int _xp = 0;
  int _streak = 0;
  int _stars = 0;
  Set<String> _learnedLetters = {};

  // ── Session timer ─────────────────────────────────────────────────────────
  static const int timeLimitMinutes = 30;
  int _sessionSeconds = 0;
  Timer? _sessionTimer;
  bool _timeLimitReached = false;

  // Getters
  bool get voiceEnabled      => _voiceEnabled;
  bool get sfxEnabled        => _sfxEnabled;
  bool get gameAccess        => _gameAccess;
  bool get timeLimitEnabled  => _timeLimitEnabled;
  bool get timeLimitReached  => _timeLimitReached;
  bool get rhymingWordsDone  => _rhymingWordsDone;
  int  get sessionSeconds    => _sessionSeconds;
  int  get sessionMinutesLeft =>
      (timeLimitMinutes - (_sessionSeconds / 60).floor()).clamp(0, timeLimitMinutes);
  int get xp       => _xp;
  int get streak   => _streak;
  int get stars    => _stars;
  Set<String> get learnedLetters => _learnedLetters;

  int get level => (_xp / 200).floor() + 1;

  AppProvider() {
    _loadPrefs();
  }

  // ── Session timer ─────────────────────────────────────────────────────────

  void startSessionTimer() {
    if (!_timeLimitEnabled) return;
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _sessionSeconds++;
      if (_sessionSeconds >= timeLimitMinutes * 60 && !_timeLimitReached) {
        _timeLimitReached = true;
        _sessionTimer?.cancel();
      }
      notifyListeners();
    });
  }

  void resetSessionTimer() {
    _sessionSeconds = 0;
    _timeLimitReached = false;
    _sessionTimer?.cancel();
    if (_timeLimitEnabled) startSessionTimer();
    notifyListeners();
  }

  void _stopSessionTimer() {
    _sessionTimer?.cancel();
    _sessionSeconds = 0;
    _timeLimitReached = false;
  }

  // ── Toggles ───────────────────────────────────────────────────────────────

  /// Play pre-recorded audio for [text].
  /// No TTS — all speech comes from assets/audio/phonics/ folders.
  /// If voice is disabled or phrase has no file, stays silent.
  Future<void> speak(String text) async {
    if (!_voiceEnabled) return;
    await phonicsAudio.tryPlay(text);
  }

  void toggleVoice() {
    _voiceEnabled = !_voiceEnabled;
    notifyListeners();
    _savePrefs();
  }

  void toggleSfx() {
    _sfxEnabled = !_sfxEnabled;
    audio.enabled = _sfxEnabled;
    notifyListeners();
    _savePrefs();
  }

  void toggleGameAccess() {
    _gameAccess = !_gameAccess;
    notifyListeners();
    _savePrefs();
  }

  void toggleTimeLimit() {
    _timeLimitEnabled = !_timeLimitEnabled;
    if (_timeLimitEnabled) {
      startSessionTimer();
    } else {
      _stopSessionTimer();
    }
    notifyListeners();
    _savePrefs();
  }

  // ── XP / Progress ─────────────────────────────────────────────────────────

  void addXP(int amount) {
    _xp += amount;
    notifyListeners();
    _savePrefs();
  }

  void addStar() {
    _stars++;
    notifyListeners();
    _savePrefs();
  }

  void markLetterLearned(String letter) {
    if (_learnedLetters.contains(letter)) return;
    _learnedLetters.add(letter);
    _stars++;
    notifyListeners();
    _savePrefs();
  }

  void markRhymingWordsDone() {
    if (_rhymingWordsDone) return;
    _rhymingWordsDone = true;
    notifyListeners();
    _savePrefs();
  }

  void incrementStreak() {
    _streak++;
    notifyListeners();
    _savePrefs();
  }

  void resetProgress() {
    _xp = 0;
    _streak = 0;
    _stars = 0;
    _learnedLetters = {};
    _rhymingWordsDone = false;
    notifyListeners();
    _savePrefs();
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  void _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _voiceEnabled     = prefs.getBool('voice')        ?? true;
    _sfxEnabled       = prefs.getBool('sfx')          ?? true;
    _gameAccess       = prefs.getBool('gameAccess')   ?? true;
    _timeLimitEnabled = prefs.getBool('timeLimit')    ?? false;
    _rhymingWordsDone = prefs.getBool('rhymingDone')  ?? false;
    _xp               = prefs.getInt('xp')            ?? 0;
    _streak           = prefs.getInt('streak')      ?? 0;
    _stars            = prefs.getInt('stars')       ?? 0;
    final saved       = prefs.getStringList('learned') ?? [];
    _learnedLetters   = Set<String>.from(saved);
    audio.enabled     = _sfxEnabled;
    notifyListeners();
  }

  void _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('voice',       _voiceEnabled);
    prefs.setBool('sfx',         _sfxEnabled);
    prefs.setBool('gameAccess',  _gameAccess);
    prefs.setBool('timeLimit',   _timeLimitEnabled);
    prefs.setBool('rhymingDone', _rhymingWordsDone);
    prefs.setInt('xp',           _xp);
    prefs.setInt('streak',      _streak);
    prefs.setInt('stars',       _stars);
    prefs.setStringList('learned', _learnedLetters.toList());
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}
