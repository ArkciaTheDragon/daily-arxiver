import 'package:flutter/material.dart';

Color getUserColor(String username, ThemeData theme) {
  final int hash = username.codeUnits.fold(
    0,
    (prev, element) => prev + element,
  );
  final List<Color> colors = [
    theme.colorScheme.primary,
    theme.colorScheme.secondary,
    theme.colorScheme.tertiary,
    Colors.teal,
    Colors.indigo,
    Colors.purple,
    Colors.deepOrange,
  ];
  return colors[hash % colors.length];
}
