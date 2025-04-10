import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AppConfig extends ChangeNotifier {
  static final AppConfig _instance = AppConfig._internal();

  factory AppConfig() => _instance;

  AppConfig._internal();

  String _baseUrl = 'http://172.29.2.84:5000/'; // Default URL
  int _connectTimeout = 3; // seconds
  int _receiveTimeout = 10; // seconds

  String get baseUrl => _baseUrl;
  int get connectTimeout => _connectTimeout;
  int get receiveTimeout => _receiveTimeout;

  set baseUrl(String url) {
    _baseUrl = url;
    notifyListeners();
  }

  set connectTimeout(int seconds) {
    _connectTimeout = seconds;
    notifyListeners();
  }

  set receiveTimeout(int seconds) {
    _receiveTimeout = seconds;
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

  Future<void> setConnectTimeout(int seconds) async {
    if (seconds <= 0) {
      throw ArgumentError('Timeout must be greater than 0 seconds');
    }
    connectTimeout = seconds; // Reuse the setter
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('connectTimeout', seconds);
    } catch (e) {
      debugPrint('Failed to save connectTimeout: $e');
      rethrow;
    }
  }

  Future<void> setReceiveTimeout(int seconds) async {
    if (seconds <= 0) {
      throw ArgumentError('Timeout must be greater than 0 seconds');
    }
    receiveTimeout = seconds; // Reuse the setter
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('receiveTimeout', seconds);
    } catch (e) {
      debugPrint('Failed to save receiveTimeout: $e');
      rethrow;
    }
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load base URL
      final savedUrl = prefs.getString('baseUrl');
      if (savedUrl != null && savedUrl != _baseUrl) {
        _baseUrl = savedUrl;
      }

      // Load connect timeout
      final savedConnectTimeout = prefs.getInt('connectTimeout');
      if (savedConnectTimeout != null &&
          savedConnectTimeout != _connectTimeout) {
        _connectTimeout = savedConnectTimeout;
      }

      // Load receive timeout
      final savedReceiveTimeout = prefs.getInt('receiveTimeout');
      if (savedReceiveTimeout != null &&
          savedReceiveTimeout != _receiveTimeout) {
        _receiveTimeout = savedReceiveTimeout;
      }

      // Notify once after loading all settings
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load settings: $e');
    }
  }

  Future<void> resetToDefaults() async {
    _baseUrl = 'http://172.29.2.84:5000/';
    _connectTimeout = 3;
    _receiveTimeout = 10;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('baseUrl');
      await prefs.remove('connectTimeout');
      await prefs.remove('receiveTimeout');
    } catch (e) {
      debugPrint('Failed to reset settings: $e');
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
