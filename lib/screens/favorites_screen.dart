import 'package:flutter/material.dart';

import '../models/bible_word.dart';
import '../services/favorites_service.dart';
import '../services/word_repository.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  FavoritesScreen({super.key});

  final WordRepository _repository = const WordRepository();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: FavoritesService.instance.changeNotifier,
      builder: (_, __, ___) {
        final words = _repository.filterWords(
          query: '',
          favorites: FavoritesService.instance.favorites,
          onlyFavorites: true,
        );

        if (words.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No favorites yet. Tap the heart icon on a word to save it.'),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: words.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final word = words[index];
            return Card(
              child: ListTile(
                title: Text(word.word),
                subtitle: Text(word.phonetic),
                leading: Icon(_iconForCategory(word.category)),
                trailing: const Icon(Icons.favorite),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DetailScreen(word: word)),
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _iconForCategory(BibleWordCategory category) {
    switch (category) {
      case BibleWordCategory.people:
        return Icons.person;
      case BibleWordCategory.places:
        return Icons.place;
      case BibleWordCategory.books:
        return Icons.menu_book;
    }
  }
}
