import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores recently analyzed verses so users can quickly revisit practice text.
class RecentVersesService {
  RecentVersesService._();

  static final RecentVersesService instance = RecentVersesService._();
  static const String _key = 'recent_verses';
  static const int _maxItems = 8;

  late SharedPreferences _prefs;
  final List<String> _recentVerses = <String>[];

  final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _recentVerses
      ..clear()
      ..addAll(_prefs.getStringList(_key) ?? <String>[]);
  }

  List<String> get recentVerses => List<String>.unmodifiable(_recentVerses);

  Future<void> saveVerse(String verse) async {
    final trimmed = verse.trim();
    if (trimmed.isEmpty) return;

    _recentVerses.remove(trimmed);
    _recentVerses.insert(0, trimmed);
    if (_recentVerses.length > _maxItems) {
      _recentVerses.removeRange(_maxItems, _recentVerses.length);
    }

    await _prefs.setStringList(_key, _recentVerses);
    changeNotifier.value++;
  }
}
