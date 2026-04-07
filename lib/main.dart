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
    final baseText = Typography.material2021().black;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bible Pronounce',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5A48D6)),
        useMaterial3: true,
        textTheme: baseText.copyWith(
          headlineMedium: baseText.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          titleLarge: baseText.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        cardTheme: const CardThemeData(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5A48D6),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
