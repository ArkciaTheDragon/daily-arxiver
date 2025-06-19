// main.dart
import 'package:daily_arxiver/providers/theme_provider.dart';
import 'package:daily_arxiver/providers/user_provider.dart';
import 'package:daily_arxiver/screens/favorites_screen.dart';
import 'package:daily_arxiver/screens/home_screen.dart';
import 'package:daily_arxiver/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/keywords_screen.dart';
import '../screens/query_screen.dart';
import '../screens/settings_screen.dart';
import '../services/api_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiService()),
        ChangeNotifierProxyProvider<ApiService, UserProvider>(
          create: (context) => UserProvider(),
          update: (context, apiService, userProvider) =>
              userProvider!..setApiService(apiService),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Daily Arxiv',
          debugShowCheckedModeBanner: false,
          theme: _buildAppTheme(), // Light theme
          darkTheme: _buildDarkAppTheme(), // Dark theme
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const UsersScreen(),
            '/home': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map;
              final username = args['username'] as String;
              return HomeScreen(username: username);
            },
            '/query': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map;
              final username = args['username'] as String;
              // Use a local StatefulWidget to safely handle context after async gap
              return _QueryScreenWithUserSet(username: username);
            },
            '/favorites': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map;
              final username = args['username'] as String;
              return FavoritesScreen(username: username);
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
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: Center(child: Text('Page ${settings.name} not found')),
              ),
            );
          },
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
      cardTheme: CardThemeData(
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
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _QueryScreenWithUserSet extends StatefulWidget {
  final String username;
  const _QueryScreenWithUserSet({required this.username});

  @override
  State<_QueryScreenWithUserSet> createState() =>
      _QueryScreenWithUserSetState();
}

class _QueryScreenWithUserSetState extends State<_QueryScreenWithUserSet> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<UserProvider>(
          context,
          listen: false,
        ).setUser(widget.username);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return QueryScreen(username: widget.username);
  }
}
