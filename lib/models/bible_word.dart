enum BibleWordCategory {
  people(label: 'People'),
  places(label: 'Places'),
  books(label: 'Books of the Bible');

  const BibleWordCategory({required this.label});

  final String label;
}

class BibleWord {
  const BibleWord({
    required this.word,
    required this.phonetic,
    required this.category,
  });

  final String word;

  /// Human-readable pronunciation guide used as TTS input for better accuracy.
  final String phonetic;

  /// Simple grouping for filter chips and practice focus.
  final BibleWordCategory category;
}
