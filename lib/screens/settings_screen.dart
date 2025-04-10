import 'package:flutter/material.dart';

import '../config/app_config.dart';

class SettingsScreen extends StatelessWidget {
  final TextEditingController _urlController = TextEditingController(
    text: AppConfig().baseUrl,
  );

  final TextEditingController _connectTimeoutController = TextEditingController(
    text: AppConfig().connectTimeout.toString(),
  );

  final TextEditingController _receiveTimeoutController = TextEditingController(
    text: AppConfig().receiveTimeout.toString(),
  );

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Base URL',
                  hintText: 'http://example.com',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _connectTimeoutController,
                decoration: const InputDecoration(
                  labelText: 'Connect Timeout (seconds)',
                  hintText: '3',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _receiveTimeoutController,
                decoration: const InputDecoration(
                  labelText: 'Receive Timeout (seconds)',
                  hintText: '10',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _saveSettings(context),
        tooltip: 'Save Settings',
        child: const Icon(Icons.save),
      ),
    );
  }

  void _saveSettings(BuildContext context) {
    // Save base URL
    AppConfig().baseUrl = _urlController.text;

    // Save connect timeout (with validation)
    try {
      final connectTimeout = int.parse(_connectTimeoutController.text);
      if (connectTimeout > 0) {
        AppConfig().connectTimeout = connectTimeout;
      } else {
        _showError(context, 'Connect timeout must be greater than 0');
        return;
      }
    } catch (e) {
      _showError(context, 'Invalid connect timeout value');
      return;
    }

    // Save receive timeout (with validation)
    try {
      final receiveTimeout = int.parse(_receiveTimeoutController.text);
      if (receiveTimeout > 0) {
        AppConfig().receiveTimeout = receiveTimeout;
      } else {
        _showError(context, 'Receive timeout must be greater than 0');
        return;
      }
    } catch (e) {
      _showError(context, 'Invalid receive timeout value');
      return;
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings updated successfully!')),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
