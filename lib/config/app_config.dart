import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Use constants for SharedPreferences keys to prevent typos and ease maintenance.
const String _kBaseUrlKey = 'baseUrl';
const String _kConnectTimeoutKey = 'connectTimeout';
const String _kReceiveTimeoutKey = 'receiveTimeout';

// Define default values in one place to avoid duplication and magic numbers.
const String _kDefaultBaseUrl = 'http://172.29.2.84:5000/';
const int _kDefaultConnectTimeout = 3; // seconds
const int _kDefaultReceiveTimeout = 10; // seconds

class AppConfig extends ChangeNotifier {
  static final AppConfig _instance = AppConfig._internal();

  factory AppConfig() => _instance;

  AppConfig._internal();

  // Initialize private fields with default values.
  String _baseUrl = _kDefaultBaseUrl;
  int _connectTimeout = _kDefaultConnectTimeout;
  int _receiveTimeout = _kDefaultReceiveTimeout;

  // Public getters for read-only access to the configuration.
  String get baseUrl => _baseUrl;
  int get connectTimeout => _connectTimeout;
  int get receiveTimeout => _receiveTimeout;

  /// Updates the base URL and persists it to storage.
  /// Throws [ArgumentError] if the URL is invalid.
  Future<void> setBaseUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isAbsolute) {
      throw ArgumentError('Invalid URL: $url');
    }
    if (_baseUrl == url) return; // No change

    _baseUrl = url;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kBaseUrlKey, url);
    } catch (e) {
      debugPrint('Failed to save baseUrl: $e');
      rethrow;
    }
  }

  /// Updates the connection timeout and persists it to storage.
  /// Throws [ArgumentError] if the timeout is not positive.
  Future<void> setConnectTimeout(int seconds) async {
    if (seconds <= 0) {
      throw ArgumentError('Timeout must be greater than 0 seconds');
    }
    if (_connectTimeout == seconds) return; // No change

    _connectTimeout = seconds;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kConnectTimeoutKey, seconds);
    } catch (e) {
      debugPrint('Failed to save connectTimeout: $e');
      rethrow;
    }
  }

  /// Updates the receive timeout and persists it to storage.
  /// Throws [ArgumentError] if the timeout is not positive.
  Future<void> setReceiveTimeout(int seconds) async {
    if (seconds <= 0) {
      throw ArgumentError('Timeout must be greater than 0 seconds');
    }
    if (_receiveTimeout == seconds) return; // No change

    _receiveTimeout = seconds;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kReceiveTimeoutKey, seconds);
    } catch (e) {
      debugPrint('Failed to save receiveTimeout: $e');
      rethrow;
    }
  }

  /// Loads all settings from persistent storage.
  /// Notifies listeners only if any value has changed.
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool hasChanged = false;

      final savedUrl = prefs.getString(_kBaseUrlKey) ?? _kDefaultBaseUrl;
      if (_baseUrl != savedUrl) {
        _baseUrl = savedUrl;
        hasChanged = true;
      }

      final savedConnectTimeout =
          prefs.getInt(_kConnectTimeoutKey) ?? _kDefaultConnectTimeout;
      if (_connectTimeout != savedConnectTimeout) {
        _connectTimeout = savedConnectTimeout;
        hasChanged = true;
      }

      final savedReceiveTimeout =
          prefs.getInt(_kReceiveTimeoutKey) ?? _kDefaultReceiveTimeout;
      if (_receiveTimeout != savedReceiveTimeout) {
        _receiveTimeout = savedReceiveTimeout;
        hasChanged = true;
      }

      if (hasChanged) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load settings: $e');
    }
  }

  /// Resets all settings to their default values and removes them from storage.
  Future<void> resetToDefaults() async {
    bool hasChanged = false;

    if (_baseUrl != _kDefaultBaseUrl) {
      _baseUrl = _kDefaultBaseUrl;
      hasChanged = true;
    }
    if (_connectTimeout != _kDefaultConnectTimeout) {
      _connectTimeout = _kDefaultConnectTimeout;
      hasChanged = true;
    }
    if (_receiveTimeout != _kDefaultReceiveTimeout) {
      _receiveTimeout = _kDefaultReceiveTimeout;
      hasChanged = true;
    }

    if (hasChanged) {
      notifyListeners();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kBaseUrlKey);
      await prefs.remove(_kConnectTimeoutKey);
      await prefs.remove(_kReceiveTimeoutKey);
    } catch (e) {
      debugPrint('Failed to reset settings: $e');
    }
  }
}
