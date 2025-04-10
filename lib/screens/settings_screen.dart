import 'package:flutter/material.dart';

import '../config/app_config.dart';

class SettingsScreen extends StatelessWidget {
  final TextEditingController _urlController = TextEditingController(
    text: AppConfig().baseUrl,
  );

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'Base URL'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                AppConfig().baseUrl = _urlController.text;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Base URL updated!')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
