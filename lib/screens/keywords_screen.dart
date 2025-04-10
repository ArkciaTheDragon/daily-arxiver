import 'package:daily_arxiv_flutter/services/api_service.dart';
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

  Future<List<String>> _loadKeywords() async {
    try {
      final keywords = await context.read<ApiService>().getUserKeywords(
        widget.username,
      );
      setState(() => _currentKeywords = keywords);
      return keywords;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载失败: ${e.toString()}')));
      return [];
    }
  }

  Future<void> _saveKeywords() async {
    try {
      await context.read<ApiService>().updateUserKeywords(
        widget.username,
        _currentKeywords,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('保存成功!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存失败: ${e.toString()}')));
    }
  }

  @override
  void initState() {
    super.initState();
    _keywordsFuture = _loadKeywords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.username}的关键词'),
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
                    labelText: '添加新关键词',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (_keywordController.text.trim().isNotEmpty) {
                          setState(() {
                            _currentKeywords.add(
                              _keywordController.text.trim(),
                            );
                            _keywordController.clear();
                          });
                        }
                      },
                    ),
                  ),
                  onSubmitted:
                      (_) =>
                          _keywordController.text.trim().isNotEmpty
                              ? setState(() {
                                _currentKeywords.add(
                                  _keywordController.text.trim(),
                                );
                                _keywordController.clear();
                              })
                              : null,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child:
                      _currentKeywords.isEmpty
                          ? const Center(child: Text('暂无关键词'))
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
