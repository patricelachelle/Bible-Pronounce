class BibleWord {
  const BibleWord({
    required this.word,
    required this.phonetic,
  });

  final String word;

  /// Human-readable pronunciation guide used as TTS input for better accuracy.
  final String phonetic;
}
