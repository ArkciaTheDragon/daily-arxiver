import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KeywordsScreen extends StatefulWidget {
  final String username;

  const KeywordsScreen({super.key, required this.username});

  @override
  KeywordsScreenState createState() => KeywordsScreenState();
}

class KeywordsScreenState extends State<KeywordsScreen> {
  final _keywordController = TextEditingController();
  late Future<List<String>> _keywordsFuture;
  List<String> _currentKeywords = [];
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<ApiService>(context, listen: false);
    _keywordsFuture = _loadKeywords();
  }

  Future<List<String>> _loadKeywords() async {
    try {
      final keywords = await _apiService.getUserKeywords(widget.username);
      setState(() => _currentKeywords = keywords);
      return keywords;
    } catch (e) {
      _showSnackBar('Failed to load keywords: ${e.toString()}');
      return [];
    }
  }

  Future<void> _saveKeywords() async {
    try {
      await _apiService.updateUserKeywords(widget.username, _currentKeywords);
      _showSnackBar('Keywords saved successfully!');
    } catch (e) {
      _showSnackBar('Failed to save keywords: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _addKeyword() {
    if (_keywordController.text.trim().isNotEmpty) {
      setState(() {
        _currentKeywords.add(_keywordController.text.trim());
        _keywordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keywords of ${widget.username}'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveKeywords),
        ],
      ),
      body: FutureBuilder<void>(
        future: _keywordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _keywordController,
                  decoration: InputDecoration(
                    labelText: 'Keyword',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addKeyword,
                    ),
                  ),
                  onSubmitted: (_) => _addKeyword(),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child:
                      _currentKeywords.isEmpty
                          ? const Center(child: Text('No keywords added yet.'))
                          : ReorderableListView.builder(
                            itemCount: _currentKeywords.length,
                            itemBuilder:
                                (ctx, index) => ListTile(
                                  key: ValueKey(_currentKeywords[index]),
                                  title: Text(_currentKeywords[index]),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed:
                                        () => setState(
                                          () =>
                                              _currentKeywords.removeAt(index),
                                        ),
                                  ),
                                ),
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) newIndex--;
                                final item = _currentKeywords.removeAt(
                                  oldIndex,
                                );
                                _currentKeywords.insert(newIndex, item);
                              });
                            },
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
