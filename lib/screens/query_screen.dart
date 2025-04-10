import 'package:daily_arxiv_flutter/models/article_model.dart';
import 'package:daily_arxiv_flutter/models/query_model.dart';
import 'package:daily_arxiv_flutter/screens/keywords_screen.dart';
import 'package:daily_arxiv_flutter/services/api_service.dart';
import 'package:daily_arxiv_flutter/widgets/article_card.dart';
import 'package:daily_arxiv_flutter/widgets/keyword_input.dart';
import 'package:daily_arxiv_flutter/widgets/time_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QueryScreen extends StatefulWidget {
  final String username;

  const QueryScreen({super.key, required this.username});

  @override
  _QueryScreenState createState() => _QueryScreenState();
}

class _QueryScreenState extends State<QueryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _startIndexController = TextEditingController(text: "0");
  final _endIndexController = TextEditingController(text: "10");

  List<String> _selectedKeywords = [];
  DateTimeRange? _selectedDateRange;
  List<Article> _articles = [];
  bool _isLoading = false;

  Future<void> _submitQuery() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));

    try {
      final params = QueryParameters(
        query: _selectedKeywords,
        startTime: _selectedDateRange?.start ?? monthAgo,
        endTime: _selectedDateRange?.end ?? DateTime.now(),
        startIndex: int.parse(_startIndexController.text),
        endIndex: int.parse(_endIndexController.text),
      );

      final result = await Provider.of<ApiService>(
        context,
        listen: false,
      ).executeQuery(params);
      setState(() => _articles = result);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Query failed: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Query from ${widget.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KeywordsScreen(username: widget.username),
                  ),
                ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              KeywordInput(
                onChanged: (keywords) => _selectedKeywords = keywords,
              ),
              const SizedBox(height: 16),
              TimeRangeDisplayPicker(
                initialRange: _selectedDateRange,
                onRangeSelected:
                    (range) => setState(() => _selectedDateRange = range),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startIndexController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Start'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _endIndexController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'End'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.search),
                label: const Text('Search'),
                onPressed: _isLoading ? null : _submitQuery,
              ),
              const SizedBox(height: 20),
              Expanded(
                child:
                    _articles.isEmpty
                        ? const Center(child: Text('No papers found'))
                        : ListView.builder(
                          itemCount: _articles.length,
                          itemBuilder:
                              (ctx, index) =>
                                  ArticleCard(article: _articles[index]),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
