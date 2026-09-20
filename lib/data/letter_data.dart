// lib/data/letter_data.dart
import '../models/difficulty.dart';

class LetterItem {
  final String letter;
  final String emoji;
  final String word;
  final String sound; // TTS phrase
  bool isLearned;

  LetterItem({
    required this.letter,
    required this.emoji,
    required this.word,
    required this.sound,
    this.isLearned = false,
  });
}

final List<LetterItem> allLetters = [
  LetterItem(letter: 'A', emoji: '🍎', word: 'Apple',     sound: 'A says Ahh! Like Apple!'),
  LetterItem(letter: 'B', emoji: '🍌', word: 'Banana',    sound: 'B says Buh! Like Banana!'),
  LetterItem(letter: 'C', emoji: '🐱', word: 'Cat',       sound: 'C says Cuh! Like Cat!'),
  LetterItem(letter: 'D', emoji: '🐶', word: 'Dog',       sound: 'D says Duh! Like Dog!'),
  LetterItem(letter: 'E', emoji: '🥚', word: 'Egg',       sound: 'E says Ehh! Like Egg!'),
  LetterItem(letter: 'F', emoji: '🐟', word: 'Fish',      sound: 'F says Fff! Like Fish!'),
  LetterItem(letter: 'G', emoji: '🍇', word: 'Grapes',    sound: 'G says Guh! Like Grapes!'),
  LetterItem(letter: 'H', emoji: '🏠', word: 'House',     sound: 'H says Hhh! Like House!'),
  LetterItem(letter: 'I', emoji: '🍦', word: 'Ice Cream', sound: 'I says Ihh! Like Ice Cream!'),
  LetterItem(letter: 'J', emoji: '🥤', word: 'Juice',     sound: 'J says Juh! Like Juice!'),
  LetterItem(letter: 'K', emoji: '🪁', word: 'Kite',      sound: 'K says Kuh! Like Kite!'),
  LetterItem(letter: 'L', emoji: '🦁', word: 'Lion',      sound: 'L says Lll! Like Lion!'),
  LetterItem(letter: 'M', emoji: '🌙', word: 'Moon',      sound: 'M says Mmm! Like Moon!'),
  LetterItem(letter: 'N', emoji: '🌰', word: 'Nut',       sound: 'N says Nnn! Like Nut!'),
  LetterItem(letter: 'O', emoji: '🐙', word: 'Octopus',   sound: 'O says Ohh! Like Octopus!'),
  LetterItem(letter: 'P', emoji: '🐷', word: 'Pig',       sound: 'P says Puh! Like Pig!'),
  LetterItem(letter: 'Q', emoji: '👑', word: 'Queen',     sound: 'Q says Kww! Like Queen!'),
  LetterItem(letter: 'R', emoji: '🌈', word: 'Rainbow',   sound: 'R says Rrr! Like Rainbow!'),
  LetterItem(letter: 'S', emoji: '☀️', word: 'Sun',       sound: 'S says Sss! Like Sun!'),
  LetterItem(letter: 'T', emoji: '🐢', word: 'Turtle',    sound: 'T says Tuh! Like Turtle!'),
  LetterItem(letter: 'U', emoji: '☂️', word: 'Umbrella',  sound: 'U says Uhh! Like Umbrella!'),
  LetterItem(letter: 'V', emoji: '🎻', word: 'Violin',    sound: 'V says Vvv! Like Violin!'),
  LetterItem(letter: 'W', emoji: '🐋', word: 'Whale',     sound: 'W says Www! Like Whale!'),
  LetterItem(letter: 'X', emoji: '❌', word: 'X-Sign', sound: 'X says Ksss! Like X-Sign!'),
  LetterItem(letter: 'Y', emoji: '🧶', word: 'Yarn',      sound: 'Y says Yyy! Like Yarn!'),
  LetterItem(letter: 'Z', emoji: '🦓', word: 'Zebra',     sound: 'Z says Zzz! Like Zebra!'),
];

// Sound Match rounds
class SoundRound {
  final String emoji;
  final String word;
  final String correctLetter;
  final List<String> options;
  final String voiceHint;

  SoundRound({
    required this.emoji,
    required this.word,
    required this.correctLetter,
    required this.options,
    required this.voiceHint,
  });
}

final List<SoundRound> soundRounds = [
  SoundRound(emoji: '🍎', word: 'Apple',   correctLetter: 'A', options: ['A','B','C','D'], voiceHint: 'Apple! Ahh... Apple!'),
  SoundRound(emoji: '🐶', word: 'Dog',     correctLetter: 'D', options: ['B','D','F','G'], voiceHint: 'Dog! Duh... Dog!'),
  SoundRound(emoji: '☀️', word: 'Sun',     correctLetter: 'S', options: ['S','T','P','R'], voiceHint: 'Sun! Sss... Sun!'),
  SoundRound(emoji: '🐟', word: 'Fish',    correctLetter: 'F', options: ['E','F','H','K'], voiceHint: 'Fish! Fff... Fish!'),
  SoundRound(emoji: '🌈', word: 'Rainbow', correctLetter: 'R', options: ['L','M','R','N'], voiceHint: 'Rainbow! Rrr... Rainbow!'),
];

// Quiz questions
class QuizQuestion {
  final String emoji;       // question image
  final String question;
  final String correctLetter;
  final List<String> options; // 4 letters
  final List<String> optionEmojis; // one emoji per option — DIFFERENT from question emoji
  final String voiceHint;

  QuizQuestion({
    required this.emoji,
    required this.question,
    required this.correctLetter,
    required this.options,
    required this.optionEmojis,
    required this.voiceHint,
  });
}

final List<QuizQuestion> quizQuestions = [
  QuizQuestion(emoji: '🐶', question: 'What sound does Dog start with?',
      correctLetter: 'D', options: ['B','C','D','G'],
      optionEmojis: ['🍌','🐱','🌈','🍇'],
      voiceHint: 'Dog! Duh... Dog! The first sound is D!'),
  QuizQuestion(emoji: '☀️', question: 'What sound does Sun start with?',
      correctLetter: 'S', options: ['S','P','T','R'],
      optionEmojis: ['🌸','🐷','🐢','🌈'],
      voiceHint: 'Sun! Sss... Sun! The first sound is S!'),
  QuizQuestion(emoji: '🍎', question: 'What sound does Apple start with?',
      correctLetter: 'A', options: ['A','E','I','O'],
      optionEmojis: ['🦋','🥚','🍦','🐙'],
      voiceHint: 'Apple! Ahh... Apple! The first sound is A!'),
  QuizQuestion(emoji: '🐟', question: 'What sound does Fish start with?',
      correctLetter: 'F', options: ['H','F','V','B'],
      optionEmojis: ['🏠','🍇','🎻','🍌'],
      voiceHint: 'Fish! Fff... Fish! The first sound is F!'),
  QuizQuestion(emoji: '🌈', question: 'What sound does Rainbow start with?',
      correctLetter: 'R', options: ['L','W','R','N'],
      optionEmojis: ['🦁','🐋','🌸','🌰'],
      voiceHint: 'Rainbow! Rrr... Rainbow! The first sound is R!'),
];

// Memory pairs: letter ↔ picture
class MemoryPair {
  final String letter;
  final String emoji;
  final String word;
  MemoryPair({required this.letter, required this.emoji, required this.word});
}

final List<MemoryPair> memoryPairs = [
  MemoryPair(letter: 'A', emoji: '🍎', word: 'Apple'),
  MemoryPair(letter: 'B', emoji: '🍌', word: 'Banana'),
  MemoryPair(letter: 'C', emoji: '🐱', word: 'Cat'),
  MemoryPair(letter: 'D', emoji: '🐶', word: 'Dog'),
  MemoryPair(letter: 'S', emoji: '☀️', word: 'Sun'),
  MemoryPair(letter: 'F', emoji: '🐟', word: 'Fish'),
];

// ── Difficulty-tiered Sound Match rounds ─────────────────────────────────

/// Easy: S–X, 3 choices — unique set, different from Phonics Quiz Easy (A–E)
final List<SoundRound> soundRoundsEasy = [
  SoundRound(emoji: '☀️',  word: 'Sun',      correctLetter: 'S', options: ['S','T','R'],       voiceHint: 'Sun! Sss... Sun!'),
  SoundRound(emoji: '🐢',  word: 'Turtle',   correctLetter: 'T', options: ['S','T','U'],       voiceHint: 'Turtle! Tuh... Turtle!'),
  SoundRound(emoji: '☂️',  word: 'Umbrella', correctLetter: 'U', options: ['U','V','O'],       voiceHint: 'Umbrella! Uhh... Umbrella!'),
  SoundRound(emoji: '🎻',  word: 'Violin',   correctLetter: 'V', options: ['V','W','B'],       voiceHint: 'Violin! Vvv... Violin!'),
  SoundRound(emoji: '🐋',  word: 'Whale',    correctLetter: 'W', options: ['W','V','Y'],       voiceHint: 'Whale! Www... Whale!'),
  SoundRound(emoji: '❌',  word: 'X-Sign',   correctLetter: 'X', options: ['X','Z','S'],       voiceHint: 'X-Sign! Ksss... X-Sign!'),
];

/// Medium: N–T, 4 choices — unique set, different from Phonics Quiz Medium (F–K)
final List<SoundRound> soundRoundsMedium = [
  SoundRound(emoji: '🌰',  word: 'Nut',      correctLetter: 'N', options: ['N','M','R','L'],   voiceHint: 'Nut! Nnn... Nut!'),
  SoundRound(emoji: '🐙',  word: 'Octopus',  correctLetter: 'O', options: ['O','U','A','E'],   voiceHint: 'Octopus! Ohh... Octopus!'),
  SoundRound(emoji: '🐷',  word: 'Pig',      correctLetter: 'P', options: ['P','B','D','T'],   voiceHint: 'Pig! Puh... Pig!'),
  SoundRound(emoji: '👑',  word: 'Queen',    correctLetter: 'Q', options: ['Q','K','C','G'],   voiceHint: 'Queen! Kww... Queen!'),
  SoundRound(emoji: '🌈',  word: 'Rainbow',  correctLetter: 'R', options: ['R','L','W','N'],   voiceHint: 'Rainbow! Rrr... Rainbow!'),
  SoundRound(emoji: '☀️',  word: 'Sun',      correctLetter: 'S', options: ['S','Z','C','X'],   voiceHint: 'Sun! Sss... Sun!'),
  SoundRound(emoji: '🐢',  word: 'Turtle',   correctLetter: 'T', options: ['T','D','S','P'],   voiceHint: 'Turtle! Tuh... Turtle!'),
];

/// Hard: U–Z + harder combos, 5 choices — unique set, different from Phonics Quiz Hard (L–R)
final List<SoundRound> soundRoundsHard = [
  SoundRound(emoji: '☂️',  word: 'Umbrella', correctLetter: 'U', options: ['U','A','O','E','I'], voiceHint: 'Umbrella! Uhh... Umbrella!'),
  SoundRound(emoji: '🎻',  word: 'Violin',   correctLetter: 'V', options: ['V','B','F','W','P'], voiceHint: 'Violin! Vvv... Violin!'),
  SoundRound(emoji: '🐋',  word: 'Whale',    correctLetter: 'W', options: ['W','V','Y','M','H'], voiceHint: 'Whale! Www... Whale!'),
  SoundRound(emoji: '❌',  word: 'X-Sign',   correctLetter: 'X', options: ['X','Z','S','C','J'], voiceHint: 'X-Sign! Ksss... X-Sign!'),
  SoundRound(emoji: '🧶',  word: 'Yarn',     correctLetter: 'Y', options: ['Y','J','W','I','E'], voiceHint: 'Yarn! Yyy... Yarn!'),
  SoundRound(emoji: '🦓',  word: 'Zebra',    correctLetter: 'Z', options: ['Z','S','X','C','J'], voiceHint: 'Zebra! Zzz... Zebra!'),
  SoundRound(emoji: '👑',  word: 'Queen',    correctLetter: 'Q', options: ['Q','K','C','G','W'], voiceHint: 'Queen! Kww... Queen!'),
];

List<SoundRound> soundRoundsForDifficulty(Difficulty d) {
  switch (d) {
    case Difficulty.easy:   return soundRoundsEasy;
    case Difficulty.medium: return soundRoundsMedium;
    case Difficulty.hard:   return soundRoundsHard;
  }
}

// ── Difficulty-tiered Quiz questions ─────────────────────────────────────

final List<QuizQuestion> quizQuestionsEasy = [
  QuizQuestion(emoji: '🍎', question: 'What sound does Apple start with?',
      correctLetter: 'A', options: ['A','B','C'],
      optionEmojis: ['🦋','🍌','🐱'],
      voiceHint: 'Apple! Ahh... Apple! The first sound is A!'),
  QuizQuestion(emoji: '🍌', question: 'What sound does Banana start with?',
      correctLetter: 'B', options: ['B','C','D'],
      optionEmojis: ['🌸','🐱','🐶'],
      voiceHint: 'Banana! Buh... Banana! The first sound is B!'),
  QuizQuestion(emoji: '🐱', question: 'What sound does Cat start with?',
      correctLetter: 'C', options: ['A','C','D'],
      optionEmojis: ['🍎','🌈','🐶'],
      voiceHint: 'Cat! Cuh... Cat! The first sound is C!'),
  QuizQuestion(emoji: '🐶', question: 'What sound does Dog start with?',
      correctLetter: 'D', options: ['B','D','F'],
      optionEmojis: ['🍌','🌸','🐟'],
      voiceHint: 'Dog! Duh... Dog! The first sound is D!'),
  QuizQuestion(emoji: '🥚', question: 'What sound does Egg start with?',
      correctLetter: 'E', options: ['A','E','I'],
      optionEmojis: ['🍎','🌈','🍦'],
      voiceHint: 'Egg! Ehh... Egg! The first sound is E!'),
];

/// Medium: F–L, 4 choices — completely different from Easy (A–E)
final List<QuizQuestion> quizQuestionsMedium = [
  QuizQuestion(emoji: '🐟', question: 'What sound does Fish start with?',
      correctLetter: 'F', options: ['H','F','V','B'],
      optionEmojis: ['🏠','🌈','🎻','🍌'],
      voiceHint: 'Fish! Fff... Fish! The first sound is F!'),
  QuizQuestion(emoji: '🍇', question: 'What sound does Grapes start with?',
      correctLetter: 'G', options: ['G','J','K','H'],
      optionEmojis: ['🌸','🥤','🪁','🏠'],
      voiceHint: 'Grapes! Guh... Grapes! The first sound is G!'),
  QuizQuestion(emoji: '🏠', question: 'What sound does House start with?',
      correctLetter: 'H', options: ['H','J','K','G'],
      optionEmojis: ['🌸','🥤','🪁','🍇'],
      voiceHint: 'House! Hhh... House! The first sound is H!'),
  QuizQuestion(emoji: '🍦', question: 'What sound does Ice Cream start with?',
      correctLetter: 'I', options: ['A','E','I','O'],
      optionEmojis: ['🍎','🥚','🌸','🐙'],
      voiceHint: 'Ice Cream! Ihh... Ice Cream! The first sound is I!'),
  QuizQuestion(emoji: '🥤', question: 'What sound does Juice start with?',
      correctLetter: 'J', options: ['J','G','K','H'],
      optionEmojis: ['🌸','🍇','🪁','🏠'],
      voiceHint: 'Juice! Juh... Juice! The first sound is J!'),
  QuizQuestion(emoji: '🪁', question: 'What sound does Kite start with?',
      correctLetter: 'K', options: ['K','C','G','Q'],
      optionEmojis: ['🌸','🐱','🍇','👑'],
      voiceHint: 'Kite! Kuh... Kite! The first sound is K!'),
];

/// Hard: S–Z, 4 choices — unique, different from Easy (A–E) and Medium (F–K)
final List<QuizQuestion> quizQuestionsHard = [
  QuizQuestion(emoji: '☀️', question: 'What sound does Sun start with?',
      correctLetter: 'S', options: ['S','Z','C','X'],
      optionEmojis: ['🌸','🦓','🐱','❌'],
      voiceHint: 'Sun! Sss... Sun! The first sound is S!'),
  QuizQuestion(emoji: '🐢', question: 'What sound does Turtle start with?',
      correctLetter: 'T', options: ['T','D','S','P'],
      optionEmojis: ['🌸','🐶','☀️','🐷'],
      voiceHint: 'Turtle! Tuh... Turtle! The first sound is T!'),
  QuizQuestion(emoji: '☂️', question: 'What sound does Umbrella start with?',
      correctLetter: 'U', options: ['U','A','O','E'],
      optionEmojis: ['🌸','🍎','🐙','🥚'],
      voiceHint: 'Umbrella! Uhh... Umbrella! The first sound is U!'),
  QuizQuestion(emoji: '🎻', question: 'What sound does Violin start with?',
      correctLetter: 'V', options: ['V','B','F','W'],
      optionEmojis: ['🌸','🍌','🐟','🐋'],
      voiceHint: 'Violin! Vvv... Violin! The first sound is V!'),
  QuizQuestion(emoji: '🐋', question: 'What sound does Whale start with?',
      correctLetter: 'W', options: ['W','V','H','M'],
      optionEmojis: ['🌸','🎻','🏠','🌙'],
      voiceHint: 'Whale! Www... Whale! The first sound is W!'),
  QuizQuestion(emoji: '🧶', question: 'What sound does Yarn start with?',
      correctLetter: 'Y', options: ['Y','J','W','I'],
      optionEmojis: ['🌸','🥤','🐋','🍦'],
      voiceHint: 'Yarn! Yyy... Yarn! The first sound is Y!'),
  QuizQuestion(emoji: '🦓', question: 'What sound does Zebra start with?',
      correctLetter: 'Z', options: ['Z','S','X','C'],
      optionEmojis: ['🌸','☀️','❌','🐱'],
      voiceHint: 'Zebra! Zzz... Zebra! The first sound is Z!'),
];

List<QuizQuestion> quizQuestionsForDifficulty(Difficulty d) {
  switch (d) {
    case Difficulty.easy:   return quizQuestionsEasy;
    case Difficulty.medium: return quizQuestionsMedium;
    case Difficulty.hard:   return quizQuestionsHard;
  }
}

// ── Difficulty-tiered Memory pairs ────────────────────────────────────────

final List<MemoryPair> memoryPairsEasy = [
  MemoryPair(letter: 'A', emoji: '🍎', word: 'Apple'),
  MemoryPair(letter: 'B', emoji: '🍌', word: 'Banana'),
  MemoryPair(letter: 'C', emoji: '🐱', word: 'Cat'),
  MemoryPair(letter: 'D', emoji: '🐶', word: 'Dog'),
]; // 4 pairs → 8 cards

/// Medium: E–J, 6 pairs → 12 cards — completely different from Easy (A–D)
final List<MemoryPair> memoryPairsMedium = [
  MemoryPair(letter: 'E', emoji: '🥚', word: 'Egg'),
  MemoryPair(letter: 'F', emoji: '🐟', word: 'Fish'),
  MemoryPair(letter: 'G', emoji: '🍇', word: 'Grapes'),
  MemoryPair(letter: 'H', emoji: '🏠', word: 'House'),
  MemoryPair(letter: 'I', emoji: '🍦', word: 'Ice Cream'),
  MemoryPair(letter: 'J', emoji: '🥤', word: 'Juice'),
];

/// Hard: K–R, 8 pairs → 16 cards — completely different from Easy (A–D) and Medium (E–J)
final List<MemoryPair> memoryPairsHard = [
  MemoryPair(letter: 'K', emoji: '🪁', word: 'Kite'),
  MemoryPair(letter: 'L', emoji: '🦁', word: 'Lion'),
  MemoryPair(letter: 'M', emoji: '🌙', word: 'Moon'),
  MemoryPair(letter: 'N', emoji: '🌰', word: 'Nut'),
  MemoryPair(letter: 'O', emoji: '🐙', word: 'Octopus'),
  MemoryPair(letter: 'P', emoji: '🐷', word: 'Pig'),
  MemoryPair(letter: 'Q', emoji: '👑', word: 'Queen'),
  MemoryPair(letter: 'R', emoji: '🌈', word: 'Rainbow'),
]; // 8 pairs → 16 cards

List<MemoryPair> memoryPairsForDifficulty(Difficulty d) {
  switch (d) {
    case Difficulty.easy:   return memoryPairsEasy;
    case Difficulty.medium: return memoryPairsMedium;
    case Difficulty.hard:   return memoryPairsHard;
  }
}

// ── Voice Recognition words per difficulty ────────────────────────────────

/// Words used in the pronunciation practice screen.
/// Easy: F–J  |  Medium: K–P  |  Hard: Q–V
/// Completely separate from Phonics Quiz (A–R) and Sound Match (S–Z)
final Map<Difficulty, List<Map<String, String>>> voiceWords = {
  Difficulty.easy: [
    {'word': 'Fish',     'emoji': '🐟', 'hint': 'F-ish'},
    {'word': 'Grapes',   'emoji': '🍇', 'hint': 'Gr-apes'},
    {'word': 'House',    'emoji': '🏠', 'hint': 'H-ouse'},
    {'word': 'Ice Cream','emoji': '🍦', 'hint': 'I-ce Cream'},
    {'word': 'Juice',    'emoji': '🥤', 'hint': 'J-uice'},
  ],
  Difficulty.medium: [
    {'word': 'Kite',     'emoji': '🪁', 'hint': 'K-ite'},
    {'word': 'Lion',     'emoji': '🦁', 'hint': 'L-ion'},
    {'word': 'Moon',     'emoji': '🌙', 'hint': 'M-oon'},
    {'word': 'Nut',      'emoji': '🌰', 'hint': 'N-ut'},
    {'word': 'Octopus',  'emoji': '🐙', 'hint': 'Oc-to-pus'},
    {'word': 'Pig',      'emoji': '🐷', 'hint': 'P-ig'},
  ],
  Difficulty.hard: [
    {'word': 'Queen',    'emoji': '👑', 'hint': 'Qu-een'},
    {'word': 'Rainbow',  'emoji': '🌈', 'hint': 'Rain-bow'},
    {'word': 'Sun',      'emoji': '☀️', 'hint': 'S-un'},
    {'word': 'Turtle',   'emoji': '🐢', 'hint': 'Tur-tle'},
    {'word': 'Umbrella', 'emoji': '☂️', 'hint': 'Um-brel-la'},
    {'word': 'Violin',   'emoji': '🎻', 'hint': 'Vi-o-lin'},
    {'word': 'Whale',    'emoji': '🐋', 'hint': 'Wh-ale'},
  ],
};
