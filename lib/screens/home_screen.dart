import 'package:flutter/material.dart';

import 'favorites_screen.dart';
import 'practice_screen.dart';
import 'word_library_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  late final List<Widget> _screens = <Widget>[
    const WordLibraryScreen(),
    FavoritesScreen(),
    const PracticeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final titles = ['Word Library', 'Favorites', 'Practice'];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(titles[_tabIndex]),
      ),
      body: IndexedStack(index: _tabIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.library_books_outlined), label: 'Words'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), label: 'Favorites'),
          NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Practice'),
        ],
      ),
    );
  }
}
