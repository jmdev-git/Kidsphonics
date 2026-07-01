// lib/services/phonics_audio_service.dart
//
// Plays pre-recorded phonics MP3 files from assets/audio/phonics/.
// Each entry maps the exact phrase string passed to speak() to a path
// relative to assets/audio/phonics/, e.g.:
//   "A says Ahh! Like Apple!"  →  letter_sounds/letter_a.mp3
//
// If the file doesn't exist the method returns false and the caller
// falls back to flutter_tts.  This means you can ship with partial
// audio coverage and TTS fills the gaps automatically.

import 'package:audioplayers/audioplayers.dart';

class PhonicsAudioService {
  static final PhonicsAudioService _instance = PhonicsAudioService._internal();
  factory PhonicsAudioService() => _instance;
  PhonicsAudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  // ── phrase → filename map ─────────────────────────────────────────────
  // Keys are the exact strings passed to speak() in letter_data.dart and
  // game screens.  Values are paths under assets/audio/phonics/.
  static const Map<String, String> _phraseMap = {

    // ════════════════════════════════════════════════════════════════════════
    // LETTER SOUNDS A-Z (letter_sounds_screen.dart → _current.sound)
    // ════════════════════════════════════════════════════════════════════════
    'A says Ahh! Like Apple!'       : 'letter_sounds/letter_a.mp3',
    'B says Buh! Like Banana!'      : 'letter_sounds/letter_b.mp3',
    'C says Cuh! Like Cat!'         : 'letter_sounds/letter_c.mp3',
    'D says Duh! Like Dog!'         : 'letter_sounds/letter_d.mp3',
    'E says Ehh! Like Egg!'         : 'letter_sounds/letter_e.mp3',
    'F says Fff! Like Fish!'        : 'letter_sounds/letter_f.mp3',
    'G says Guh! Like Grapes!'      : 'letter_sounds/letter_g.mp3',
    'H says Hhh! Like House!'       : 'letter_sounds/letter_h.mp3',
    'I says Ihh! Like Ice Cream!'   : 'letter_sounds/letter_i.mp3',
    'J says Juh! Like Juice!'       : 'letter_sounds/letter_j.mp3',
    'K says Kuh! Like Kite!'        : 'letter_sounds/letter_k.mp3',
    'L says Lll! Like Lion!'        : 'letter_sounds/letter_l.mp3',
    'M says Mmm! Like Moon!'        : 'letter_sounds/letter_m.mp3',
    'N says Nnn! Like Nut!'         : 'letter_sounds/letter_n.mp3',
    'O says Ohh! Like Octopus!'     : 'letter_sounds/letter_o.mp3',
    'P says Puh! Like Pig!'         : 'letter_sounds/letter_p.mp3',
    'Q says Kww! Like Queen!'       : 'letter_sounds/letter_q.mp3',
    'R says Rrr! Like Rainbow!'     : 'letter_sounds/letter_r.mp3',
    'S says Sss! Like Sun!'         : 'letter_sounds/letter_s.mp3',
    'T says Tuh! Like Turtle!'      : 'letter_sounds/letter_t.mp3',
    'U says Uhh! Like Umbrella!'    : 'letter_sounds/letter_u.mp3',
    'V says Vvv! Like Violin!'      : 'letter_sounds/letter_v.mp3',
    'W says Www! Like Whale!'       : 'letter_sounds/letter_w.mp3',
    'X says Ksss! Like Xylophone!'  : 'letter_sounds/letter_x.mp3',
    'Y says Yyy! Like Yarn!'        : 'letter_sounds/letter_y.mp3',
    'Z says Zzz! Like Zebra!'       : 'letter_sounds/letter_z.mp3',

    // ════════════════════════════════════════════════════════════════════════
    // VOWEL SOUNDS (letter_sounds_screen.dart vowelsOnly=true)
    // ════════════════════════════════════════════════════════════════════════
    // Vowels reuse letter_sounds files above for the sounds themselves.
    // Additional vowel-specific phrases:
    'A says Ahh, like Apple! E says Ehh, like Egg! I says Ihh, like Ice Cream! O says Ohh, like Octopus! U says Uhh, like Umbrella!' : 'vowel_sounds/vowels_all.mp3',
    'A, E, I, O, U. These are the vowels!'                                     : 'vowel_sounds/vowels_intro.mp3',

    // ════════════════════════════════════════════════════════════════════════
    // ALPHABET ORDER GAME (alphabet_order_screen.dart)
    // ════════════════════════════════════════════════════════════════════════
    'A' : 'alphabet_order/name_a.mp3',
    'B' : 'alphabet_order/name_b.mp3',
    'C' : 'alphabet_order/name_c.mp3',
    'D' : 'alphabet_order/name_d.mp3',
    'E' : 'alphabet_order/name_e.mp3',
    'F' : 'alphabet_order/name_f.mp3',
    'G' : 'alphabet_order/name_g.mp3',
    'H' : 'alphabet_order/name_h.mp3',
    'I' : 'alphabet_order/name_i.mp3',
    'J' : 'alphabet_order/name_j.mp3',
    'K' : 'alphabet_order/name_k.mp3',
    'L' : 'alphabet_order/name_l.mp3',
    'M' : 'alphabet_order/name_m.mp3',
    'N' : 'alphabet_order/name_n.mp3',
    'O' : 'alphabet_order/name_o.mp3',
    'P' : 'alphabet_order/name_p.mp3',
    'Q' : 'alphabet_order/name_q.mp3',
    'R' : 'alphabet_order/name_r.mp3',
    'S' : 'alphabet_order/name_s.mp3',
    'T' : 'alphabet_order/name_t.mp3',
    'U' : 'alphabet_order/name_u.mp3',
    'V' : 'alphabet_order/name_v.mp3',
    'W' : 'alphabet_order/name_w.mp3',
    'X' : 'alphabet_order/name_x.mp3',
    'Y' : 'alphabet_order/name_y.mp3',
    'Z' : 'alphabet_order/name_z.mp3',
    'A, B, C, D, E, F! Can you put the alphabet in order?' : 'alphabet_order/intro.mp3',
    'Yes! That is correct! Keep going!'                    : 'alphabet_order/correct.mp3',
    'Oops! Try the next letter in order!'                  : 'alphabet_order/wrong.mp3',
    'Amazing! You know the whole alphabet!'                : 'alphabet_order/win.mp3',

    // ════════════════════════════════════════════════════════════════════════
    // SOUND MATCH GAME (sound_match_screen.dart)
    // ════════════════════════════════════════════════════════════════════════
    'Apple! Ahh... Apple!'          : 'sound_match/hint_apple.mp3',
    'Banana! Buh... Banana!'        : 'sound_match/hint_banana.mp3',
    'Cat! Cuh... Cat!'              : 'sound_match/hint_cat.mp3',
    'Dog! Duh... Dog!'              : 'sound_match/hint_dog.mp3',
    'Egg! Ehh... Egg!'              : 'sound_match/hint_egg.mp3',
    'Fish! Fff... Fish!'            : 'sound_match/hint_fish.mp3',
    'Grapes! Guh... Grapes!'        : 'sound_match/hint_grapes.mp3',
    'House! Hhh... House!'          : 'sound_match/hint_house.mp3',
    'Kite! Kuh... Kite!'            : 'sound_match/hint_kite.mp3',
    'Lion! Lll... Lion!'            : 'sound_match/hint_lion.mp3',
    'Moon! Mmm... Moon!'            : 'sound_match/hint_moon.mp3',
    'Queen! Kww... Queen!'          : 'sound_match/hint_queen.mp3',
    'Rainbow! Rrr... Rainbow!'      : 'sound_match/hint_rainbow.mp3',
    'Sun! Sss... Sun!'              : 'sound_match/hint_sun.mp3',
    'Umbrella! Uhh... Umbrella!'    : 'sound_match/hint_umbrella.mp3',
    'Violin! Vvv... Violin!'        : 'sound_match/hint_violin.mp3',
    'Whale! Www... Whale!'          : 'sound_match/hint_whale.mp3',
    'Zebra! Zzz... Zebra!'          : 'sound_match/hint_zebra.mp3',
    'What letter does it start with?'  : 'sound_match/question.mp3',
    'Tap to hear the word!'            : 'sound_match/tap_to_hear.mp3',
    'Tap the correct starting letter!' : 'sound_match/tap_letter.mp3',
    'Hmm, try again! Listen carefully!': 'sound_match/hint_cat.mp3', // fallback

    // ════════════════════════════════════════════════════════════════════════
    // MEMORY FLIP GAME (memory_game_screen.dart)
    // ════════════════════════════════════════════════════════════════════════
    'Match the letter to its picture!'          : 'memory_flip/intro.mp3',
    'Find the letter that matches the picture!' : 'memory_flip/instruction.mp3',
    'Great match!'                              : 'memory_flip/match.mp3',
    'All pairs found! Amazing job!'             : 'memory_flip/win.mp3',
    // Memory flip uses alphabet_order letter names for card flips (A-Z above)

    // ════════════════════════════════════════════════════════════════════════
    // PHONICS QUIZ GAME (phonics_quiz_screen.dart)
    // ════════════════════════════════════════════════════════════════════════
    'Dog! Duh... Dog! The first sound is D!'         : 'phonics_quiz/quiz_dog.mp3',
    'Sun! Sss... Sun! The first sound is S!'         : 'phonics_quiz/quiz_sun.mp3',
    'Apple! Ahh... Apple! The first sound is A!'     : 'phonics_quiz/quiz_apple.mp3',
    'Fish! Fff... Fish! The first sound is F!'       : 'phonics_quiz/quiz_fish.mp3',
    'Rainbow! Rrr... Rainbow! The first sound is R!' : 'phonics_quiz/quiz_rainbow.mp3',
    'Moon! Mmm... Moon! The first sound is M!'       : 'phonics_quiz/quiz_moon.mp3',
    'Kite! Kuh... Kite! The first sound is K!'       : 'phonics_quiz/quiz_kite.mp3',
    'Lion! Lll... Lion! The first sound is L!'       : 'phonics_quiz/quiz_lion.mp3',
    'Umbrella! Uhh... Umbrella! The first sound is U!' : 'phonics_quiz/quiz_umbrella.mp3',
    'Violin! Vvv... Violin! The first sound is V!'   : 'phonics_quiz/quiz_violin.mp3',
    'Whale! Www... Whale! The first sound is W!'     : 'phonics_quiz/quiz_whale.mp3',
    'Zebra! Zzz... Zebra! The first sound is Z!'     : 'phonics_quiz/quiz_zebra.mp3',
    'What sound does it start with?'                 : 'phonics_quiz/question.mp3',
    'Tap to listen!'                                 : 'phonics_quiz/tap_listen.mp3',
    'Quiz done! Great work!'                         : 'phonics_quiz/done.mp3',

    // ════════════════════════════════════════════════════════════════════════
    // WORD BUILDER GAME (word_builder_screen.dart)
    // ════════════════════════════════════════════════════════════════════════
    'C... blank... T. What is in the middle?'          : 'word_builder/hint_cat.mp3',
    'D... blank... G. Fill in the middle!'             : 'word_builder/hint_dog.mp3',
    'S... blank... N. What letter goes here?'          : 'word_builder/hint_sun.mp3',
    'blank... P... E. What is the first letter?'       : 'word_builder/hint_ape.mp3',
    'F... I... blank. What is the last letter?'        : 'word_builder/hint_fin.mp3',
    'R... blank... T. What is the middle?'             : 'word_builder/hint_rat.mp3',
    'H... blank... T. What is the middle?'             : 'word_builder/hint_hut.mp3',
    'L... I... blank. The last letter!'                : 'word_builder/hint_lip.mp3',
    'blank... O... P. What letter starts it?'          : 'word_builder/hint_mop.mp3',
    'Spell the word!'                                  : 'word_builder/spell_word.mp3',
    'Tap the missing letter!'                          : 'word_builder/tap_missing.mp3',
    'Cat'     : 'word_builder/word_cat.mp3',
    'Dog'     : 'word_builder/word_dog.mp3',
    'Sun'     : 'word_builder/word_sun.mp3',
    'Ape'     : 'word_builder/word_ape.mp3',
    'Fin'     : 'word_builder/word_fin.mp3',
    'Rat'     : 'word_builder/word_rat.mp3',
    'Hut'     : 'word_builder/word_hut.mp3',
    'Lip'     : 'word_builder/word_lip.mp3',
    'Mop'     : 'word_builder/word_mop.mp3',

    // ════════════════════════════════════════════════════════════════════════
    // SAY IT RIGHT (voice_recognition_screen.dart)
    // ════════════════════════════════════════════════════════════════════════
    'Apple'    : 'say_it_right/word_apple.mp3',
    'Ball'     : 'say_it_right/word_ball.mp3',
    'Fish'     : 'say_it_right/word_fish.mp3',
    'Grapes'   : 'say_it_right/word_grapes.mp3',
    'House'    : 'say_it_right/word_house.mp3',
    'Ice Cream': 'say_it_right/word_ice_cream.mp3',
    'Juice'    : 'say_it_right/word_juice.mp3',
    'Kite'     : 'say_it_right/word_kite.mp3',
    'Lion'     : 'say_it_right/word_lion.mp3',
    'Moon'     : 'say_it_right/word_moon.mp3',
    'Rainbow'  : 'say_it_right/word_rainbow.mp3',
    'Umbrella' : 'say_it_right/word_umbrella.mp3',
    'Violin'   : 'say_it_right/word_violin.mp3',
    'Xylophone': 'say_it_right/word_xylophone.mp3',
    'Zebra'    : 'say_it_right/word_zebra.mp3',
    'Apple! A-pple'         : 'say_it_right/hint_word_apple.mp3',
    'Ball! B-all'           : 'say_it_right/hint_word_ball.mp3',
    'Cat! C-at'             : 'say_it_right/hint_word_cat.mp3',
    'Dog! D-og'             : 'say_it_right/hint_word_dog.mp3',
    'Egg! E-gg'             : 'say_it_right/hint_word_egg.mp3',
    'Fish! F-ish'           : 'say_it_right/hint_word_fish.mp3',
    'Grapes! Gr-apes'       : 'say_it_right/hint_word_grapes.mp3',
    'House! H-ouse'         : 'say_it_right/hint_word_house.mp3',
    'Ice Cream! I-ce Cream' : 'say_it_right/hint_word_ice_cream.mp3',
    'Juice! J-uice'         : 'say_it_right/hint_word_juice.mp3',
    'Kite! K-ite'           : 'say_it_right/hint_word_kite.mp3',
    'Lion! L-ion'           : 'say_it_right/hint_word_lion.mp3',
    'Moon! M-oon'           : 'say_it_right/hint_word_moon.mp3',
    'Rainbow! Rain-bow'     : 'say_it_right/hint_word_rainbow.mp3',
    'Umbrella! Um-brel-la'  : 'say_it_right/hint_word_umbrella.mp3',
    'Violin! Vi-o-lin'      : 'say_it_right/hint_word_violin.mp3',
    'Xylophone! Xy-lo-phone': 'say_it_right/hint_word_xylophone.mp3',
    'Zebra! Ze-bra'         : 'say_it_right/hint_word_zebra.mp3',
    'Tap the mic and say the word!'     : 'say_it_right/instruction.mp3',
    'Listening... speak now!'           : 'say_it_right/listening.mp3',
    'Great job! You said it correctly!' : 'say_it_right/correct.mp3',
    'Good try! Listen and try again.'   : 'say_it_right/try_again.mp3',
    'Practice done! You did amazing!'   : 'say_it_right/done.mp3',

    // ════════════════════════════════════════════════════════════════════════
    // RHYMING WORDS LESSON (rhyming_words_screen.dart)
    // ════════════════════════════════════════════════════════════════════════
    'Cat... Bat! Both end in A-T!'              : 'rhyming_words/hint_cat_bat.mp3',
    'Bee... Tree! Both end in E-E!'             : 'rhyming_words/hint_bee_tree.mp3',
    'Moon... Spoon! Both end in O-O-N!'         : 'rhyming_words/hint_moon_spoon.mp3',
    'Pig... Big! Both end in I-G!'              : 'rhyming_words/hint_pig_big.mp3',
    'Hat... Mat! Both end in A-T!'              : 'rhyming_words/hint_hat_mat.mp3',
    'Bug... Mug! Both end in U-G!'              : 'rhyming_words/hint_bug_mug.mp3',
    'Star... Car! Both end in A-R!'             : 'rhyming_words/hint_star_car.mp3',
    'Frog... Log! Both end in O-G!'             : 'rhyming_words/hint_frog_log.mp3',
    'House... Mouse! Both end in O-U-S-E!'      : 'rhyming_words/hint_house_mouse.mp3',
    'Cake... Lake! Both end in A-K-E!'          : 'rhyming_words/hint_cake_lake.mp3',
    'Fox... Box! Both end in O-X!'              : 'rhyming_words/hint_fox_box.mp3',
    'Moon... Balloon! Both end in O-O-N!'       : 'rhyming_words/hint_moon_balloon.mp3',
    'Which word rhymes with this?'              : 'rhyming_words/question.mp3',
    'Tap the word that rhymes!'                 : 'rhyming_words/instruction.mp3',
    'Cat, Bat, Hat! They rhyme!'                : 'rhyming_words/intro.mp3',
    'Rhyming words end with the same sound!'    : 'rhyming_words/explain.mp3',

    // ════════════════════════════════════════════════════════════════════════
    // SHARED FEEDBACK (used across all games)
    // ════════════════════════════════════════════════════════════════════════
    'Correct!'                           : 'feedback/correct.mp3',
    'Great job!'                         : 'feedback/great_job.mp3',
    'Wonderful!'                         : 'feedback/wonderful.mp3',
    'Amazing!'                           : 'feedback/amazing.mp3',
    'Try again!'                         : 'feedback/try_again.mp3',
    'Try again! Listen to the hint!'     : 'feedback/try_again_hint.mp3',
    'Well done!'                         : 'feedback/well_done.mp3',
    'You are doing great!'               : 'feedback/doing_great.mp3',
    'Keep going!'                        : 'feedback/keep_going.mp3',
    'All pairs found!'                   : 'feedback/all_pairs.mp3',
    'Round complete! You did it!'        : 'feedback/round_complete.mp3',
    'All words spelled! Fantastic!'      : 'feedback/all_spelled.mp3',
    'Alphabet Master! You know the alphabet!' : 'feedback/alphabet_master.mp3',

    // Lessons screen speak buttons
    'A says Ahh! B says Buh! C says Cuh!' : 'feedback/lesson_abc_intro.mp3',
  };

  /// Play a pre-recorded file for [phrase].
  /// If no mapping exists or the file is missing, does nothing (silent).
  /// TTS is no longer used — all audio comes from assets/audio/phonics/.
  Future<void> tryPlay(String phrase) async {
    final filename = _phraseMap[phrase.trim()];
    if (filename == null) return;

    try {
      await _player.stop();
      await _player.play(AssetSource('audio/phonics/$filename'));
    } catch (_) {
      // File missing from assets — silent, no TTS fallback
    }
  }

  void dispose() => _player.dispose();
}
