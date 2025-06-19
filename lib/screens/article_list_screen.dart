import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article_model.dart';
import '../widgets/article_card.dart';
import '../providers/user_provider.dart';

class ArticleListScreen extends StatefulWidget {
  final List<Article> articles;
  final List<String> searchQuery;

  const ArticleListScreen({
    super.key,
    required this.articles,
    required this.searchQuery,
  });

  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  bool _showUnreadOnly = false;

  void _toggleFilter() {
    setState(() {
      _showUnreadOnly = !_showUnreadOnly;
    });
  }

  @override
  Widget build(BuildContext context) {
    final keywordCount = widget.searchQuery.length;
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        List<Article> articles = widget.articles;
        if (_showUnreadOnly) {
          articles =
              articles
                  .where(
                    (article) => !userProvider.isArticleRead(article.arxivId),
                  )
                  .toList();
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Result on $keywordCount Keyword${keywordCount != 1 ? 's' : ''}',
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _showUnreadOnly ? Icons.visibility_off : Icons.visibility,
                  semanticLabel: "Toggle unread filter",
                ),
                onPressed: _toggleFilter,
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
                        Text(
                          'No articles found',
                          style: TextStyle(fontSize: 18),
                        ),
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
      },
    );
  }
}
