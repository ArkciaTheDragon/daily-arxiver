// services/api_service.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/article_model.dart';
import '../models/query_model.dart';
import '../models/user_model.dart';

class ApiService extends ChangeNotifier {
  final Dio _dio;
  final AppConfig _config = AppConfig();

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig().baseUrl,
          connectTimeout: Duration(seconds: AppConfig().connectTimeout),
          receiveTimeout: Duration(seconds: AppConfig().receiveTimeout),
        ),
      ) {
    _config.addListener(_updateDioSettings);
  }

  void _updateDioSettings() {
    _dio.options.baseUrl = _config.baseUrl;
    _dio.options.connectTimeout = Duration(seconds: _config.connectTimeout);
    _dio.options.receiveTimeout = Duration(seconds: _config.receiveTimeout);
  }

  @override
  void dispose() {
    _config.removeListener(_updateDioSettings);
    super.dispose();
  }

  Future<List<Article>> executeQuery(QueryParameters parameters) => _request(
    'POST',
    '/query',
    data: parameters.toJson(),
    parser: (data) => _parseArticles(data),
    errorMessage: 'Network error',
  );

  Future<List<String>> fetchUsers() => _request(
    'GET',
    '/users',
    parser: (data) => UserResponse.fromJson(data).usernames,
    errorMessage: 'Failed to fetch users',
  );

  Future<String> analyzePaperSection(String arxivId, String section) =>
      _request(
        'POST',
        '/analysis',
        data: {'arxiv_id': arxivId, 'section': section},
        parser: _parsePaperAnalysis,
        errorMessage: 'Failed to analyze section',
        receiveTimeout: const Duration(minutes: 1),
      );

  String _parsePaperAnalysis(dynamic data) {
    if (data is Map) {
      if (data.containsKey('anaysis')) {
        return data['anaysis'] as String;
      } else if (data.containsKey('analysis')) {
        return data['analysis'] as String;
      } else if (data.containsKey('error')) {
        return data['error'] as String;
      }
    }
    throw ApiException(
      code: -1,
      message: 'Unexpected server response for analysis.',
    );
  }

  Future<List<String>> getUserKeywords(String username) => _request(
    'GET',
    '/keywords',
    queryParameters: {'username': username},
    parser: (data) => List<String>.from(data['keywords']),
    errorMessage: 'Failed to fetch keywords',
  );

  Future<bool> updateUserKeywords(String username, List<String> keywords) =>
      _request(
        'POST',
        '/keywords',
        data: {'username': username, 'keywords': keywords},
        parser: (data) => data['success'] as bool,
        errorMessage: 'Failed to update keywords',
      );

  Future<List<String>> getUserReadPapers(String username) => _request(
    'GET',
    '/users/read_papers',
    queryParameters: {'username': username},
    parser: (data) => List<String>.from(data['arxiv_ids']),
    errorMessage: 'Failed to fetch read papers',
  );

  Future<bool> setUserReadPapers(String username, List<String> arxivIds) =>
      _request(
        'POST',
        '/users/read_papers',
        data: {'username': username, 'arxiv_ids': arxivIds},
        parser: (data) => data['success'] as bool,
        errorMessage: 'Failed to set read papers',
      );

  Future<List<String>> getUserFavoritePapers(String username) => _request(
    'GET',
    '/users/favorite_papers',
    queryParameters: {'username': username},
    parser: (data) => List<String>.from(data['arxiv_ids']),
    errorMessage: 'Failed to fetch favorite papers',
  );

  Future<bool> setUserFavoritePapers(String username, List<String> arxivIds) =>
      _request(
        'POST',
        '/users/favorite_papers',
        data: {'username': username, 'arxiv_ids': arxivIds},
        parser: (data) => data['success'] as bool,
        errorMessage: 'Failed to set favorite papers',
      );

  Future<T> _request<T>(
    String method,
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) parser,
    required String errorMessage,
    Duration? receiveTimeout,
  }) async {
    try {
      debugPrint(
        'Request: $method $path\nData: $data\nQuery: $queryParameters',
      );
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status! < 500,
          receiveTimeout: receiveTimeout,
        ),
      );

      if (response.statusCode == 200) {
        try {
          return parser(response.data);
        } catch (e) {
          debugPrint(
            'Unexpected response from $path: $e\nData: ${response.data}',
          );
          if (e is ApiException) rethrow;
          throw const ApiException(
            code: -1,
            message: 'Failed to parse data from the server.',
          );
        }
      }
      throw _handleError(response);
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode ?? 0,
        message: e.message ?? errorMessage,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: -1,
        message: 'An unknown error occurred: $errorMessage',
      );
    }
  }

  List<Article> _parseArticles(final Map<String, dynamic> articlesData) {
    try {
      final dynamic articlesList = articlesData['articles'];
      if (articlesList is! List) {
        throw ApiException(
          code: -1,
          message: 'Invalid article format: "articles" field is not a list.',
        );
      }

      return articlesList
          .map((articleJson) {
            try {
              return Article.fromJson(_convertTimestamps(articleJson));
            } catch (e) {
              debugPrint('Failed to parse article: $e');
              return null; // Skip invalid articles
            }
          })
          .whereType<Article>() // Filter out null values
          .toList();
    } catch (e) {
      throw ApiException(
        code: -1,
        message: 'Failed to parse articles: ${e.toString()}',
      );
    }
  }

  Map<String, dynamic> _convertTimestamps(Map<String, dynamic> json) {
    // 统一转换时间戳字段
    const timestampFields = ['added_date', 'submitted_date'];

    return json.map((key, value) {
      if (timestampFields.contains(key) && value is num) {
        return MapEntry(key, (value * 1000).toInt());
      }
      return MapEntry(key, value);
    });
  }

  ApiException _handleError(Response response) {
    final statusCode = response.statusCode ?? 500;
    final errorData =
        response.data is String ? jsonDecode(response.data) : response.data;

    return ApiException(
      code: statusCode,
      message: errorData['message'] ?? _getDefaultErrorMessage(statusCode),
    );
  }

  String _getDefaultErrorMessage(int code) {
    switch (code) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 404:
        return 'Not found';
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      default:
        return 'Error ($code)';
    }
  }
}

class ApiException implements Exception {
  final int code;
  final String message;

  const ApiException({required this.code, required this.message});

  @override
  String toString() {
    if (code > 99) return '[HTTP $code] $message';
    return message;
  }
}
