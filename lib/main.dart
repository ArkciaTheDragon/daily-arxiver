// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/keywords_screen.dart';
import '../screens/query_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/user_selection_screen.dart';
import '../services/api_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ApiService())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Arxiv',
      debugShowCheckedModeBanner: false,
      theme: _buildAppTheme(), // Light theme
      darkTheme: _buildDarkAppTheme(), // Dark theme
      themeMode: ThemeMode.dark, // Use dark mode by default
      initialRoute: '/',
      routes: {
        '/': (context) => const UserSelectionScreen(),
        '/query': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return QueryScreen(username: args['username'] as String);
        },
        '/keywords': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return KeywordsScreen(username: args['username'] as String);
        },
        '/settings': (context) => SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle undefined routes
        return MaterialPageRoute(
          builder:
              (context) => Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: Center(child: Text('Page ${settings.name} not found')),
              ),
        );
      },
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      primarySwatch: Colors.blueGrey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  ThemeData _buildDarkAppTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: Colors.blueGrey,
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
