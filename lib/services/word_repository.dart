import '../data/bible_words_data.dart';
import '../models/bible_word.dart';

/// Small repository layer keeps UI widgets simple and beginner-friendly.
class WordRepository {
  const WordRepository();

  List<BibleWord> getAllWords() => bibleWords;

  List<BibleWord> filterWords({
    required String query,
    BibleWordCategory? category,
    Set<String>? favorites,
    bool onlyFavorites = false,
  }) {
    final normalizedQuery = query.trim().toLowerCase();

    return bibleWords.where((word) {
      final queryMatch =
          normalizedQuery.isEmpty || word.word.toLowerCase().contains(normalizedQuery);
      final categoryMatch = category == null || word.category == category;
      final favoriteMatch = !onlyFavorites || (favorites?.contains(word.word) ?? false);
      return queryMatch && categoryMatch && favoriteMatch;
    }).toList();
  }
}
