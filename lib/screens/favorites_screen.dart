import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  final String username;

  const FavoritesScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: const Center(child: Text('Favorites Screen - Coming Soon!')),
    );
  }
}
