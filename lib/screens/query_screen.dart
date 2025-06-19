import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/query_model.dart';
import '../services/api_service.dart';
import '../widgets/keyword_input.dart';
import '../widgets/time_range_picker.dart';
import 'keywords_screen.dart';
import 'article_list_screen.dart';

class QueryScreen extends StatefulWidget {
  final String username;

  const QueryScreen({super.key, required this.username});

  @override
  QueryScreenState createState() => QueryScreenState();
}

class QueryScreenState extends State<QueryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _startIndexController = TextEditingController(text: "0");
  final _endIndexController = TextEditingController(text: "10");

  List<String> _selectedKeywords = [];
  DateTimeRange? _selectedDateRange;
  bool _isLoading = false;
  bool _isLoadingKeywords = true;

  @override
  void initState() {
    super.initState();
    // Set default date range to 1 month ago until today
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
    _loadDefaultKeywords();
  }

  Future<void> _loadDefaultKeywords() async {
    setState(() {
      _isLoadingKeywords = true;
    });

    try {
      final keywords = await Provider.of<ApiService>(
        context,
        listen: false,
      ).getUserKeywords(widget.username);

      if (mounted) {
        setState(() {
          _selectedKeywords = keywords;
          _isLoadingKeywords = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load default keywords: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoadingKeywords = false;
        });
      }
    }
  }

  Future<void> _submitQuery() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final params = QueryParameters(
        query: _selectedKeywords,
        startTime:
            _selectedDateRange?.start ??
            DateTime.now().subtract(const Duration(days: 30)),
        endTime: _selectedDateRange?.end ?? DateTime.now(),
        startIndex: int.parse(_startIndexController.text),
        endIndex: int.parse(_endIndexController.text),
      );

      final result = await Provider.of<ApiService>(
        context,
        listen: false,
      ).executeQuery(params);

      setState(() => _isLoading = false);

      if (result.isNotEmpty && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleListScreen(
              articles: result,
              searchQuery: _selectedKeywords,
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No articles found for your query'),
            backgroundColor: Colors.amber,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Query failed: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Query from ${widget.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Saved Keywords',
            onPressed: () async {
              final updatedKeywords = await Navigator.push<List<String>>(
                context,
                MaterialPageRoute(
                  builder: (_) => KeywordsScreen(username: widget.username),
                ),
              );

              if (updatedKeywords != null && updatedKeywords.isNotEmpty) {
                setState(() {
                  _selectedKeywords = updatedKeywords;
                });
              }
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Keywords',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _isLoadingKeywords
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : KeywordInput(
                              initialKeywords: _selectedKeywords,
                              onChanged: (keywords) =>
                                  _selectedKeywords = keywords,
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Time Range',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TimeRangePicker(
                        initialRange: _selectedDateRange,
                        onRangeSelected: (range) =>
                            setState(() => _selectedDateRange = range),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Result Range',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _startIndexController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Start Index',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _endIndexController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'End Index',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.search),
                      label: const Text('Search Papers'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _submitQuery,
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
