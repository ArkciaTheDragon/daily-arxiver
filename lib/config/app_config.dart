import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AppConfig extends ChangeNotifier {
  static final AppConfig _instance = AppConfig._internal();

  factory AppConfig() => _instance;

  AppConfig._internal();

  String _baseUrl = 'http://172.29.3.84:5000/'; // Default URL

  String get baseUrl => _baseUrl;

  set baseUrl(String url) {
    _baseUrl = url;
    notifyListeners();
  }

  Future<void> setBaseUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAbsolutePath) {
      throw ArgumentError('Invalid URL: $url');
    }
    baseUrl = url; // Reuse the setter
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('baseUrl', url);
    } catch (e) {
      debugPrint('Failed to save baseUrl: $e');
      rethrow; // Optionally rethrow the error
    }
  }

  Future<void> loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('baseUrl');
    if (savedUrl != null && savedUrl != _baseUrl) {
      _baseUrl = savedUrl;
      notifyListeners(); // Notify listeners when loading a saved URL
    }
  }
}
