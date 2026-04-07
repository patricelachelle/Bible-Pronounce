import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists favorite words so users keep them after app restart.
class FavoritesService {
  FavoritesService._();

  static final FavoritesService instance = FavoritesService._();
  static const String _key = 'favorite_words';

  late SharedPreferences _prefs;
  final Set<String> _favorites = <String>{};

  /// UI listens to this notifier to refresh when favorites change.
  final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _favorites
      ..clear()
      ..addAll(_prefs.getStringList(_key) ?? <String>[]);
  }

  Set<String> get favorites => _favorites;

  bool isFavorite(String word) => _favorites.contains(word);

  Future<void> toggleFavorite(String word) async {
    if (_favorites.contains(word)) {
      _favorites.remove(word);
    } else {
      _favorites.add(word);
    }
    await _prefs.setStringList(_key, _favorites.toList()..sort());
    changeNotifier.value++;
  }
}
