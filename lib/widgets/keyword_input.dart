import 'package:flutter/material.dart';

class KeywordInput extends StatefulWidget {
  final ValueChanged<List<String>> onChanged;
  final List<String> initialKeywords;

  const KeywordInput({
    super.key,
    required this.onChanged,
    this.initialKeywords = const [],
  });

  @override
  KeywordInputState createState() => KeywordInputState();
}

class KeywordInputState extends State<KeywordInput> {
  final TextEditingController _controller = TextEditingController();
  late List<String> _keywords;

  @override
  void initState() {
    super.initState();
    _keywords = List.from(widget.initialKeywords);
  }

  void _addKeyword() {
    final keyword = _controller.text.trim();
    if (keyword.isNotEmpty && !_keywords.contains(keyword)) {
      setState(() {
        _keywords.add(keyword);
        _controller.clear();
        widget.onChanged(_keywords);
      });
    }
  }

  void _removeKeyword(String keyword) {
    setState(() {
      _keywords.remove(keyword);
      widget.onChanged(_keywords);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Search Keyword',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: _addKeyword,
            ),
            border: const OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _addKeyword(), // Handle 'Enter' key press
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children:
              _keywords
                  .map(
                    (keyword) => Chip(
                      label: Text(keyword),
                      deleteIcon: const Icon(Icons.cancel, size: 18),
                      onDeleted: () => _removeKeyword(keyword),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}
