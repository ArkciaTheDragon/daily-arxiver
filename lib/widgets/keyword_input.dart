import 'package:flutter/material.dart';

class KeywordInput extends StatefulWidget {
  final ValueChanged<List<String>> onChanged;

  const KeywordInput({super.key, required this.onChanged});

  @override
  _KeywordInputState createState() => _KeywordInputState();
}

class _KeywordInputState extends State<KeywordInput> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _keywords = [];

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
            labelText: '输入关键词',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: _addKeyword,
            ),
            border: const OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _addKeyword,
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
