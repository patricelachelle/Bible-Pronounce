import 'bible_word.dart';

/// Parsed result used by the Verse Assistant UI.
class VerseAnalysis {
  const VerseAnalysis({
    required this.originalVerse,
    required this.segments,
    required this.focusWords,
    this.wordOfTheVerse,
  });

  final String originalVerse;
  final List<VerseSegment> segments;
  final List<VerseFocusWord> focusWords;
  final VerseFocusWord? wordOfTheVerse;

  bool get hasHighlights => focusWords.isNotEmpty;
}

/// Represents one display chunk from the verse (word or punctuation/space).
class VerseSegment {
  const VerseSegment({
    required this.raw,
    this.focusWord,
  });

  final String raw;
  final VerseFocusWord? focusWord;

  bool get isHighlighted => focusWord != null;
}

/// Pronunciation metadata shown when users tap a highlighted word.
class VerseFocusWord {
  const VerseFocusWord({
    required this.surface,
    required this.normalized,
    required this.phonetic,
    required this.generated,
    this.datasetWord,
  });

  final String surface;
  final String normalized;
  final String phonetic;
  final bool generated;
  final BibleWord? datasetWord;
}
