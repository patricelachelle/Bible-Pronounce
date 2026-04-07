import 'package:flutter/material.dart';

import '../models/bible_word.dart';
import '../services/favorites_service.dart';
import '../services/word_repository.dart';
import 'detail_screen.dart';

class WordLibraryScreen extends StatefulWidget {
  const WordLibraryScreen({super.key});

  @override
  State<WordLibraryScreen> createState() => _WordLibraryScreenState();
}

class _WordLibraryScreenState extends State<WordLibraryScreen> {
  final WordRepository _repository = const WordRepository();

  String _query = '';
  BibleWordCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final words = _repository.filterWords(
      query: _query,
      category: _selectedCategory,
      favorites: FavoritesService.instance.favorites,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search instantly as you type...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedCategory == null,
                  onSelected: (_) => setState(() => _selectedCategory = null),
                ),
                ...BibleWordCategory.values.map(
                  (category) => ChoiceChip(
                    label: Text(category.label),
                    selected: _selectedCategory == category,
                    onSelected: (_) => setState(() => _selectedCategory = category),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: words.isEmpty
                  ? const Center(child: Text('No words match this filter.'))
                  : ListView.separated(
                      key: ValueKey('${_query}_${_selectedCategory?.name ?? 'all'}'),
                      itemCount: words.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final word = words[index];
                        final favorite = FavoritesService.instance.isFavorite(word.word);
                        return Card(
                          child: ListTile(
                            leading: Icon(_iconForCategory(word.category)),
                            title: Text(word.word),
                            subtitle: Text('${word.phonetic} • ${word.category.label}'),
                            trailing: Icon(
                              favorite ? Icons.favorite : Icons.chevron_right,
                              color: favorite ? Theme.of(context).colorScheme.primary : null,
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => DetailScreen(word: word)),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
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
