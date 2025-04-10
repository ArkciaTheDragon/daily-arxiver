import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../widgets/article_card.dart';

class ArticleListScreen extends StatelessWidget {
  final List<Article> articles;
  final String searchQuery;

  const ArticleListScreen({
    super.key,
    required this.articles,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "$searchQuery"'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filtering coming soon')),
              );
            },
          ),
        ],
      ),
      body:
          articles.isEmpty
              ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No articles found', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text(
                      'Try modifying your search criteria',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  return ArticleCard(article: articles[index]);
                },
              ),
    );
  }
}
