import 'package:daily_arxiver/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _urlController;
  late final TextEditingController _connectTimeoutController;
  late final TextEditingController _receiveTimeoutController;

  @override
  void initState() {
    super.initState();
    final appConfig = AppConfig();
    _urlController = TextEditingController(text: appConfig.baseUrl);
    _connectTimeoutController = TextEditingController(
      text: appConfig.connectTimeout.toString(),
    );
    _receiveTimeoutController = TextEditingController(
      text: appConfig.receiveTimeout.toString(),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _connectTimeoutController.dispose();
    _receiveTimeoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Theme',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (value) => themeProvider.setThemeMode(value!),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (value) => themeProvider.setThemeMode(value!),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System'),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (value) => themeProvider.setThemeMode(value!),
              ),
              const Divider(),
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
        onPressed: _saveSettings,
        tooltip: 'Save Settings',
        child: const Icon(Icons.save),
      ),
    );
  }

  Future<void> _saveSettings() async {
    final connectTimeout = int.tryParse(_connectTimeoutController.text);
    if (connectTimeout == null) {
      _showError('Invalid connect timeout value.');
      return;
    }

    final receiveTimeout = int.tryParse(_receiveTimeoutController.text);
    if (receiveTimeout == null) {
      _showError('Invalid receive timeout value.');
      return;
    }

    try {
      final appConfig = AppConfig();
      await appConfig.setBaseUrl(_urlController.text);
      await appConfig.setConnectTimeout(connectTimeout);
      await appConfig.setReceiveTimeout(receiveTimeout);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!')),
      );
    } on ArgumentError catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('An unexpected error occurred: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
