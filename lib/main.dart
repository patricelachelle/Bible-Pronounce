import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/favorites_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FavoritesService.instance.init();
  runApp(const BiblePronounceApp());
}

class BiblePronounceApp extends StatelessWidget {
  const BiblePronounceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bible Pronounce',
      themeMode: ThemeMode.system,
      theme: _theme(brightness: Brightness.light),
      darkTheme: _theme(brightness: Brightness.dark),
      home: const HomeScreen(),
    );
  }

  ThemeData _theme({required Brightness brightness}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5A48D6),
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      visualDensity: VisualDensity.comfortable,
      scaffoldBackgroundColor: colorScheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
