import 'package:flutter/material.dart';

class KeywordInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;
  const KeywordInputField({
    super.key,
    required this.controller,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 2,
      shadowColor: Colors.black.withAlpha(25),
      borderRadius: BorderRadius.circular(12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Add new keyword',
          hintText: 'Type and press Enter or tap +',
          floatingLabelBehavior: FloatingLabelBehavior.never,
          prefixIcon: const Icon(Icons.tag_rounded),
          suffixIcon: IconButton(
            icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
            onPressed: onAdd,
            tooltip: 'Add keyword',
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
        ),
        onSubmitted: (_) => onAdd(),
      ),
    );
  }
}

class KeywordsList extends StatelessWidget {
  final List<String> keywords;
  final void Function(int) onRemove;
  final void Function(int, int) onReorder;
  const KeywordsList({
    super.key,
    required this.keywords,
    required this.onRemove,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (keywords.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.label,
              size: 48,
              color: theme.colorScheme.onSurface.withAlpha(100),
            ),
            const SizedBox(height: 8),
            Text(
              'No keywords added yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
            ),
          ],
        ),
      );
    }
    return ReorderableListView.builder(
      itemCount: keywords.length,
      itemBuilder: (ctx, index) => ListTile(
        key: ValueKey(keywords[index]),
        title: Text(keywords[index]),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: theme.colorScheme.error),
          onPressed: () => onRemove(index),
        ),
      ),
      onReorder: onReorder,
    );
  }
}
