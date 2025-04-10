// models/query_model.dart
import 'package:flutter/foundation.dart';

@immutable
class QueryParameters {
  final List<String> query;
  final DateTime startTime;
  final DateTime endTime;
  final int startIndex;
  final int endIndex;

  QueryParameters({
    required this.query,
    required this.startTime,
    required this.endTime,
    required this.startIndex,
    required this.endIndex,
  }) : assert(startIndex >= 0, '起始索引不能为负数'),
       assert(endIndex >= startIndex, '结束索引不能小于起始索引'),
       assert(endTime.isAfter(startTime), '结束时间必须晚于开始时间');

  factory QueryParameters.defaults() => QueryParameters(
    query: const [],
    startTime: DateTime.now().subtract(const Duration(days: 7)),
    endTime: DateTime.now(),
    startIndex: 0,
    endIndex: 10,
  );

  Map<String, dynamic> toJson() => {
    'query': query,
    'start_time': startTime.millisecondsSinceEpoch ~/ 1000,
    'end_time': endTime.millisecondsSinceEpoch ~/ 1000,
    'start_index': startIndex,
    'end_index': endIndex,
  };

  QueryParameters copyWith({
    List<String>? query,
    DateTime? startTime,
    DateTime? endTime,
    int? startIndex,
    int? endIndex,
  }) => QueryParameters(
    query: query ?? this.query,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    startIndex: startIndex ?? this.startIndex,
    endIndex: endIndex ?? this.endIndex,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueryParameters &&
          listEquals(other.query, query) &&
          other.startTime == startTime &&
          other.endTime == endTime &&
          other.startIndex == startIndex &&
          other.endIndex == endIndex);

  @override
  int get hashCode =>
      Object.hash(query.hashCode, startTime, endTime, startIndex, endIndex);
}
