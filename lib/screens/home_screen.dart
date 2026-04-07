import 'package:flutter/material.dart';

import '../data/bible_words_data.dart';
import '../models/bible_word.dart';
import '../services/favorites_service.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';
  String _verseText = '';
  bool _showOnlyFavorites = false;

  List<BibleWord> get _filteredWords {
    final byQuery = bibleWords.where((word) {
      return word.word.toLowerCase().contains(_query.toLowerCase());
    });

    if (!_showOnlyFavorites) {
      return byQuery.toList();
    }

    return byQuery.where((word) => FavoritesService.instance.isFavorite(word.word)).toList();
  }

  Set<String> get _difficultWordsInVerse {
    if (_verseText.trim().isEmpty) return <String>{};
    final tokens = _verseText
        .split(RegExp(r'[^a-zA-Z\-]+'))
        .where((token) => token.isNotEmpty)
        .map((token) => token.toLowerCase())
        .toSet();

    return bibleWords
        .map((word) => word.word)
        .where((word) => tokens.contains(word.toLowerCase()))
        .toSet();
  }

  List<TextSpan> _buildHighlightedVerse(BuildContext context) {
    final difficultWords = _difficultWordsInVerse.map((w) => w.toLowerCase()).toSet();
    final segments = _verseText.splitMapJoin(
      RegExp(r'([a-zA-Z\-]+|[^a-zA-Z\-]+)'),
      onMatch: (m) => '${m.group(0)}\n',
      onNonMatch: (_) => '',
    ).split('\n').where((s) => s.isNotEmpty);

    return segments.map((segment) {
      final plain = segment.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z\-]+'), '');
      final highlight = plain.isNotEmpty && difficultWords.contains(plain);
      return TextSpan(
        text: segment,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: highlight ? FontWeight.w700 : FontWeight.w400,
          backgroundColor: highlight ? Colors.amber.withValues(alpha: 0.55) : null,
          color: highlight ? Colors.brown.shade900 : null,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final words = _filteredWords;
    final difficultWords = _difficultWordsInVerse.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Pronounce'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: _showOnlyFavorites ? 'Show all words' : 'Show favorites',
            onPressed: () {
              setState(() {
                _showOnlyFavorites = !_showOnlyFavorites;
              });
            },
            icon: Icon(_showOnlyFavorites ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Search Bible words...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Paste a Bible verse', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextField(
                        minLines: 2,
                        maxLines: 4,
                        onChanged: (value) => setState(() => _verseText = value),
                        decoration: const InputDecoration(
                          hintText: 'Example: Nebuchadnezzar said to Shadrach, Meshach, and Abednego...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (_verseText.trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        RichText(text: TextSpan(children: _buildHighlightedVerse(context))),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: difficultWords.isEmpty
                              ? [
                                  const Chip(
                                    avatar: Icon(Icons.check_circle_outline, size: 18),
                                    label: Text('No difficult words detected'),
                                  ),
                                ]
                              : difficultWords
                                  .map(
                                    (word) => ActionChip(
                                      label: Text(word),
                                      avatar: const Icon(Icons.auto_awesome, size: 18),
                                      onPressed: () async {
                                        final match = bibleWords.firstWhere(
                                          (w) => w.word.toLowerCase() == word.toLowerCase(),
                                        );
                                        await Navigator.of(context).push(
                                          MaterialPageRoute(builder: (_) => DetailScreen(word: match)),
                                        );
                                        if (mounted) setState(() {});
                                      },
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: words.isEmpty
                    ? const Center(child: Text('No words found. Try another search.'))
                    : ListView.separated(
                        itemCount: words.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final word = words[index];
                          final isFavorite = FavoritesService.instance.isFavorite(word.word);

                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              title: Text(word.word, style: Theme.of(context).textTheme.titleMedium),
                              subtitle: Text(word.phonetic),
                              trailing: Icon(
                                isFavorite ? Icons.favorite : Icons.chevron_right,
                                color: isFavorite ? Theme.of(context).colorScheme.primary : null,
                              ),
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => DetailScreen(word: word)),
                                );
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
