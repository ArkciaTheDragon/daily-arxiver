import '../services/api_service.dart';
import '../widgets/keywords_widgets.dart';
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
  List<String> _originalKeywords = []; // To track original state
  late ApiService _apiService;
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<ApiService>(context, listen: false);
    _keywordsFuture = _loadKeywords();
  }

  Future<List<String>> _loadKeywords() async {
    try {
      final keywords = await _apiService.getUserKeywords(widget.username);
      setState(() {
        _currentKeywords = List.from(keywords);
        _originalKeywords = List.from(keywords); // Store original state
        _hasUnsavedChanges = false;
      });
      return keywords;
    } catch (e) {
      _showSnackBar('Failed to load keywords: ${e.toString()}');
      return [];
    }
  }

  Future<void> _saveKeywords() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      await _apiService.updateUserKeywords(widget.username, _currentKeywords);
      _showSnackBar('Keywords saved successfully!');
      setState(() {
        _originalKeywords = List.from(
          _currentKeywords,
        ); // Update original state
        _hasUnsavedChanges = false;
      });
    } catch (e) {
      _showSnackBar('Failed to save keywords: ${e.toString()}');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _addKeyword() {
    if (_keywordController.text.trim().isNotEmpty) {
      setState(() {
        _currentKeywords.add(_keywordController.text.trim());
        _keywordController.clear();
        _checkForChanges();
      });
    }
  }

  void _removeKeyword(int index) {
    setState(() {
      _currentKeywords.removeAt(index);
      _checkForChanges();
    });
  }

  void _checkForChanges() {
    // Check if current keywords differ from original
    if (_originalKeywords.length != _currentKeywords.length) {
      _hasUnsavedChanges = true;
      return;
    }

    for (int i = 0; i < _originalKeywords.length; i++) {
      if (_originalKeywords[i] != _currentKeywords[i]) {
        _hasUnsavedChanges = true;
        return;
      }
    }

    _hasUnsavedChanges = false;
  }

  Future<bool?> _showUnsavedConfirm() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'You have unsaved changes. Do you want to discard them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        bool shouldPop = true;
        if (_hasUnsavedChanges) {
          shouldPop = await _showUnsavedConfirm() ?? false;
        }
        if (context.mounted && shouldPop) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Keywords for ${widget.username}'),
          elevation: 0,
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  KeywordInputField(
                    controller: _keywordController,
                    onAdd: _addKeyword,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(
                        Icons.list_alt_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Keywords',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_currentKeywords.isNotEmpty)
                        Chip(
                          label: Text(
                            '${_currentKeywords.length}',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: theme.colorScheme.primary,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      const Spacer(),
                      Text(
                        'Drag to reorder',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.drag_indicator,
                        size: 16,
                        color: theme.colorScheme.onSurface.withAlpha(150),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: KeywordsList(
                      keywords: _currentKeywords,
                      onRemove: _removeKeyword,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = _currentKeywords.removeAt(oldIndex);
                          _currentKeywords.insert(newIndex, item);
                          _checkForChanges();
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: _hasUnsavedChanges
            ? FloatingActionButton(
                onPressed: _isSaving ? null : _saveKeywords,
                tooltip: 'Save keywords',
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.save),
              )
            : null,
      ),
    );
  }
}
