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
  bool _showOnlyFavorites = false;

  List<BibleWord> get _filteredWords {
    final byQuery = bibleWords.where((word) {
      return word.word.toLowerCase().contains(_query.toLowerCase());
    });

    if (!_showOnlyFavorites) {
      return byQuery.toList();
    }

    return byQuery
        .where((word) => FavoritesService.instance.isFavorite(word.word))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final words = _filteredWords;

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search Bible words...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: words.isEmpty
                  ? const Center(
                      child: Text('No words found. Try another search.'),
                    )
                  : ListView.separated(
                      itemCount: words.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final word = words[index];
                        final isFavorite = FavoritesService.instance.isFavorite(word.word);

                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            title: Text(
                              word.word,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            subtitle: Text(word.phonetic),
                            trailing: Icon(
                              isFavorite ? Icons.favorite : Icons.chevron_right,
                              color: isFavorite
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => DetailScreen(word: word),
                                ),
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
    );
  }
}
