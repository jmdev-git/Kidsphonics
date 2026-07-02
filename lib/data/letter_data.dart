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
  LetterItem(letter: 'X', emoji: '🎶', word: 'Xylophone', sound: 'X says Ksss! Like Xylophone!'),
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

/// Easy: A–F, 3 choices
final List<SoundRound> soundRoundsEasy = [
  SoundRound(emoji: '🍎', word: 'Apple',  correctLetter: 'A', options: ['A','B','C'],    voiceHint: 'Apple! Ahh... Apple!'),
  SoundRound(emoji: '🍌', word: 'Banana', correctLetter: 'B', options: ['A','B','C'],    voiceHint: 'Banana! Buh... Banana!'),
  SoundRound(emoji: '🐱', word: 'Cat',    correctLetter: 'C', options: ['B','C','D'],    voiceHint: 'Cat! Cuh... Cat!'),
  SoundRound(emoji: '🐶', word: 'Dog',    correctLetter: 'D', options: ['C','D','E'],    voiceHint: 'Dog! Duh... Dog!'),
  SoundRound(emoji: '🥚', word: 'Egg',    correctLetter: 'E', options: ['D','E','F'],    voiceHint: 'Egg! Ehh... Egg!'),
  SoundRound(emoji: '🐟', word: 'Fish',   correctLetter: 'F', options: ['E','F','G'],    voiceHint: 'Fish! Fff... Fish!'),
];

/// Medium: A–N, 4 choices (same as original)
final List<SoundRound> soundRoundsMedium = soundRounds;

/// Hard: A–Z, 5 choices, less obvious distractors
final List<SoundRound> soundRoundsHard = [
  SoundRound(emoji: '🍎', word: 'Apple',    correctLetter: 'A', options: ['A','E','O','I','U'],   voiceHint: 'Apple! Ahh... Apple!'),
  SoundRound(emoji: '🍌', word: 'Banana',   correctLetter: 'B', options: ['B','D','P','G','V'],   voiceHint: 'Banana! Buh... Banana!'),
  SoundRound(emoji: '🌙', word: 'Moon',     correctLetter: 'M', options: ['M','N','W','R','L'],   voiceHint: 'Moon! Mmm... Moon!'),
  SoundRound(emoji: '🐋', word: 'Whale',    correctLetter: 'W', options: ['W','V','Y','M','H'],   voiceHint: 'Whale! Www... Whale!'),
  SoundRound(emoji: '🦓', word: 'Zebra',    correctLetter: 'Z', options: ['Z','S','X','C','J'],   voiceHint: 'Zebra! Zzz... Zebra!'),
  SoundRound(emoji: '👑', word: 'Queen',    correctLetter: 'Q', options: ['Q','K','C','G','W'],   voiceHint: 'Queen! Kww... Queen!'),
  SoundRound(emoji: '🎻', word: 'Violin',   correctLetter: 'V', options: ['V','B','F','W','P'],   voiceHint: 'Violin! Vvv... Violin!'),
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

final List<QuizQuestion> quizQuestionsMedium = quizQuestions;

final List<QuizQuestion> quizQuestionsHard = [
  QuizQuestion(emoji: '🌙', question: 'What sound does Moon start with?',
      correctLetter: 'M', options: ['M','N','R','W'],
      optionEmojis: ['🌸','🌰','🌈','🐋'],
      voiceHint: 'Moon! Mmm... Moon! The first sound is M!'),
  QuizQuestion(emoji: '🪁', question: 'What sound does Kite start with?',
      correctLetter: 'K', options: ['K','C','G','Q'],
      optionEmojis: ['🌸','🐱','🍇','👑'],
      voiceHint: 'Kite! Kuh... Kite! The first sound is K!'),
  QuizQuestion(emoji: '🦁', question: 'What sound does Lion start with?',
      correctLetter: 'L', options: ['L','R','N','W'],
      optionEmojis: ['🌸','🌈','🌰','🐋'],
      voiceHint: 'Lion! Lll... Lion! The first sound is L!'),
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
  QuizQuestion(emoji: '🦓', question: 'What sound does Zebra start with?',
      correctLetter: 'Z', options: ['Z','S','X','C'],
      optionEmojis: ['🌸','☀️','🎶','🐱'],
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

final List<MemoryPair> memoryPairsMedium = memoryPairs; // 6 pairs → 12 cards

final List<MemoryPair> memoryPairsHard = [
  MemoryPair(letter: 'A', emoji: '🍎', word: 'Apple'),
  MemoryPair(letter: 'B', emoji: '🍌', word: 'Banana'),
  MemoryPair(letter: 'C', emoji: '🐱', word: 'Cat'),
  MemoryPair(letter: 'D', emoji: '🐶', word: 'Dog'),
  MemoryPair(letter: 'E', emoji: '🥚', word: 'Egg'),
  MemoryPair(letter: 'F', emoji: '🐟', word: 'Fish'),
  MemoryPair(letter: 'G', emoji: '🍇', word: 'Grapes'),
  MemoryPair(letter: 'H', emoji: '🏠', word: 'House'),
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
final Map<Difficulty, List<Map<String, String>>> voiceWords = {
  Difficulty.easy: [
    {'word': 'Apple',  'emoji': '🍎', 'hint': 'A-pple'},
    {'word': 'Ball',   'emoji': '⚽', 'hint': 'B-all'},
    {'word': 'Cat',    'emoji': '🐱', 'hint': 'C-at'},
    {'word': 'Dog',    'emoji': '🐶', 'hint': 'D-og'},
    {'word': 'Egg',    'emoji': '🥚', 'hint': 'E-gg'},
  ],
  Difficulty.medium: [
    {'word': 'Fish',    'emoji': '🐟', 'hint': 'F-ish'},
    {'word': 'Grapes',  'emoji': '🍇', 'hint': 'Gr-apes'},
    {'word': 'House',   'emoji': '🏠', 'hint': 'H-ouse'},
    {'word': 'Ice Cream','emoji': '🍦', 'hint': 'I-ce Cream'},
    {'word': 'Juice',   'emoji': '🥤', 'hint': 'J-uice'},
    {'word': 'Kite',    'emoji': '🪁', 'hint': 'K-ite'},
  ],
  Difficulty.hard: [
    {'word': 'Lion',     'emoji': '🦁', 'hint': 'L-ion'},
    {'word': 'Moon',     'emoji': '🌙', 'hint': 'M-oon'},
    {'word': 'Rainbow',  'emoji': '🌈', 'hint': 'Rain-bow'},
    {'word': 'Umbrella', 'emoji': '☂️', 'hint': 'Um-brel-la'},
    {'word': 'Violin',   'emoji': '🎻', 'hint': 'Vi-o-lin'},
    {'word': 'Xylophone','emoji': '🎶', 'hint': 'Xy-lo-phone'},
    {'word': 'Zebra',    'emoji': '🦓', 'hint': 'Ze-bra'},
  ],
};
