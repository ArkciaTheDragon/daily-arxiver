// services/api_service.dart
import 'dart:convert';
import 'package:daily_arxiv_flutter/models/article_model.dart';
import 'package:daily_arxiv_flutter/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/query_model.dart';
import '../config/app_config.dart';

class ApiService extends ChangeNotifier {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig().baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  ApiService() {
    AppConfig().addListener(() {
      _dio.options.baseUrl = AppConfig().baseUrl;
    });
  }

  Future<List<Article>> executeQuery(QueryParameters parameters) async {
    try {
      final response = await _dio.post(
        '/query',
        data: parameters.toJson(),
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }

      return _parseArticles(response.data);
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode ?? 0,
        message: e.message ?? 'Network error',
      );
    } catch (e) {
      throw const ApiException(code: 0, message: 'Unknown error');
    }
  }

  Future<List<String>> fetchUsers() async {
    try {
      final response = await _dio.get(
        '/users',
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        return UserResponse.fromJson(response.data).usernames;
      }
      throw _handleError(response);
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode ?? 0,
        message: e.message ?? 'Failed to fetch users',
      );
    } catch (e) {
      throw const ApiException(code: 0, message: 'Unknown error');
    }
  }

  Future<List<String>> getUserKeywords(String username) async {
    try {
      final response = await _dio.get(
        '/keywords',
        queryParameters: {'username': username},
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return List<String>.from(response.data['keywords']);
      }
      throw _handleError(response);
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode ?? 0,
        message: e.message ?? 'Failed to fetch keywords',
      );
    }
  }

  Future<bool> updateUserKeywords(
    String username,
    List<String> keywords,
  ) async {
    try {
      final response = await _dio.post(
        '/keywords',
        data: {'username': username, 'keywords': keywords},
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return response.data['success'] as bool;
      }
      throw _handleError(response);
    } on DioException catch (e) {
      throw ApiException(
        code: e.response?.statusCode ?? 0,
        message: e.message ?? 'Failed to update keywords',
      );
    }
  }

  List<Article> _parseArticles(final List<dynamic> articles) {
    try {
      return articles
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
        code: 500,
        message: 'Failed to parse articles: ${e.toString()}',
      );
    }
  }

  Map<String, dynamic> _convertTimestamps(Map<String, dynamic> json) {
    // 统一转换时间戳字段
    const timestampFields = ['added_date', 'submitted_date'];

    return json.map((key, value) {
      if (timestampFields.contains(key) && value is int) {
        return MapEntry(key, 1000 * value);
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
      default:
        return 'Error ($code)';
    }
  }
}

// 自定义异常类
class ApiException implements Exception {
  final int code;
  final String message;

  const ApiException({required this.code, required this.message});

  @override
  String toString() => '[HTTP $code] $message';
}
