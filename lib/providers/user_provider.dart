import 'package:flutter/material.dart';
import 'package:daily_arxiver/services/api_service.dart';
import 'package:daily_arxiver/models/article_model.dart';

class UserProvider extends ChangeNotifier {
  String? _currentUser;
  List<String> _readPapers = [];
  List<String> _favoritePapers = [];
  ApiService? _apiService;

  String? get currentUser => _currentUser;
  List<String> get readPapers => _readPapers;
  List<String> get favoritePapers => _favoritePapers;

  void setApiService(ApiService apiService) async {
    _apiService = apiService;
  }

  void setUser(String username) async {
    if (_currentUser != username) {
      _currentUser = username;
      await _fetchUserPapers();
      notifyListeners();
    }
  }

  Future<void> _fetchUserPapers() async {
    if (_currentUser != null && _apiService != null) {
      _readPapers = await _apiService!.getUserReadPapers(_currentUser!);
      _favoritePapers = await _apiService!.getUserFavoritePapers(_currentUser!);
    }
  }

  Future<void> toggleReadStatus(Article article) async {
    if (_currentUser == null || _apiService == null) return;
    if (_readPapers.contains(article.arxivId)) {
      _readPapers.remove(article.arxivId);
    } else {
      _readPapers.add(article.arxivId);
    }
    await _apiService!.setUserReadPapers(_currentUser!, _readPapers);
    notifyListeners();
  }

  bool isArticleRead(String arxivId) {
    return _readPapers.contains(arxivId);
  }

  Future<void> toggleFavoriteStatus(Article article) async {
    if (_currentUser == null || _apiService == null) return;
    if (_favoritePapers.contains(article.arxivId)) {
      _favoritePapers.remove(article.arxivId);
    } else {
      _favoritePapers.add(article.arxivId);
    }
    await _apiService!.setUserFavoritePapers(_currentUser!, _favoritePapers);
    notifyListeners();
  }

  bool isArticleFavorite(String arxivId) {
    return _favoritePapers.contains(arxivId);
  }
}
