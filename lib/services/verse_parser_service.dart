import '../models/bible_word.dart';
import '../models/verse_analysis.dart';
import 'word_repository.dart';

/// Converts free-form verse input into tappable pronunciation targets.
class VerseParserService {
  VerseParserService({WordRepository? repository})
    : _repository = repository ?? const WordRepository() {
    for (final word in _repository.getAllWords()) {
      _wordLookup[_normalizeWord(word.word)] = word;
    }
  }

  final WordRepository _repository;
  final Map<String, BibleWord> _wordLookup = <String, BibleWord>{};

  static final RegExp _segmentPattern = RegExp(r"[A-Za-z]+(?:[-'][A-Za-z]+)*|[^A-Za-z]+", multiLine: true);

  VerseAnalysis analyze(String verse) {
    final trimmed = verse.trim();
    if (trimmed.isEmpty) {
      return const VerseAnalysis(originalVerse: '', segments: <VerseSegment>[], focusWords: <VerseFocusWord>[]);
    }

    final focusByNormalized = <String, VerseFocusWord>{};
    final segments = <VerseSegment>[];

    final matches = _segmentPattern.allMatches(verse);
    for (final match in matches) {
      final raw = match.group(0) ?? '';
      final normalized = _normalizeWord(raw);

      if (normalized.isEmpty) {
        segments.add(VerseSegment(raw: raw));
        continue;
      }

      final datasetWord = _wordLookup[normalized];
      final shouldHighlight = datasetWord != null || _looksLikeDifficultName(raw: raw, normalized: normalized);

      if (!shouldHighlight) {
        segments.add(VerseSegment(raw: raw));
        continue;
      }

      final focusWord = focusByNormalized.putIfAbsent(
        normalized,
        () => VerseFocusWord(
          surface: raw,
          normalized: normalized,
          phonetic: datasetWord?.phonetic ?? _generateFallbackPhonetic(raw),
          generated: datasetWord == null,
          datasetWord: datasetWord,
        ),
      );

      segments.add(VerseSegment(raw: raw, focusWord: focusWord));
    }

    final focusWords = focusByNormalized.values.toList();
    final wordOfVerse = _pickWordOfTheVerse(focusWords);

    return VerseAnalysis(
      originalVerse: verse,
      segments: segments,
      focusWords: focusWords,
      wordOfTheVerse: wordOfVerse,
    );
  }

  static String _normalizeWord(String text) => text.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

  bool _looksLikeDifficultName({required String raw, required String normalized}) {
    final hasUppercaseStart = RegExp(r'^[A-Z]').hasMatch(raw);
    final uncommonLength = normalized.length >= 8;
    final hasComplexClusters = RegExp(r'(ph|th|ch|sh|zz|iah|ezz|adne)').hasMatch(normalized);
    return hasUppercaseStart && (uncommonLength || hasComplexClusters);
  }

  VerseFocusWord? _pickWordOfTheVerse(List<VerseFocusWord> words) {
    if (words.isEmpty) return null;

    final sorted = List<VerseFocusWord>.from(words)..sort((a, b) {
      final generatedWeight = a.generated == b.generated ? 0 : (a.generated ? 1 : -1);
      if (generatedWeight != 0) return generatedWeight;
      return b.normalized.length.compareTo(a.normalized.length);
    });

    return sorted.first;
  }

  String _generateFallbackPhonetic(String rawWord) {
    final lower = rawWord.toLowerCase();
    return lower
        .replaceAll('ph', 'f')
        .replaceAll('ch', 'k')
        .replaceAll('sh', 'sh')
        .replaceAll('th', 'th')
        .replaceAll(RegExp(r'([aeiou])\1+'), r'$1')
        .replaceAll('-', ' ');
  }
}
